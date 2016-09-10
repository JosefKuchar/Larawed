#!/usr/bin/env python3
# By Josef Kuchař
# Import libs
import configparser
import io
import os
import glob
import argparse
import subprocess
import sys

# Define constants
PATH = ""
HOSTING = ""

# Define functions
def patchFiles(filename):
    patch = open("patchs/" + filename + ".patch").readlines()
    currentFile = None
    for line in patch:
        # If line is a comment, skip this line
        if "#" in line[:1]:
            continue

        #If line is empty, skip this line
        if line == "\n":
            continue

        #If line is file specs, open the file
        if "!" in line[:1]:
            currentFile = open(PATH + "/" + line[1:].rstrip(), "w")
            continue

        #If line is escaped
        if "\\!" in line[:2]:
            if currentFile is None:
                print("Patch parse error, no file specified first")
            else:
                currentFile.write(line[1:])
                continue

        #If it is a part of file
        if currentFile is None:
            print("Patch parse error, no file specified first")
        else:
            currentFile.write(line)

#Print logo
print(" __                            _ ")
print("|  |   ___ ___ ___ _ _ _ ___ _| |")
print("|  |__| .'|  _| .'| | | | -_| . |")
print("|_____|__,|_| |__,|_____|___|___|")
print("")

# Load patchs
patchs = []
for patch in glob.glob("patchs/*.patch"):
    patchs.append(os.path.basename(patch)[:-6])

# Setup argument parser
argparser = argparse.ArgumentParser(description="- Laravel patching tool for shared hostings", epilog="available hostings: " + ", ".join(patchs))

# Add arguments
argparser.add_argument("path", type=str, nargs=1, help="Path to laravel project")
argparser.add_argument("--hosting", action="store", default="general", help="Select patch for the hosting")
argparser.add_argument("--no-info", dest="info", action="store_const", const=False, default=True, help="Turn off info")
args = argparser.parse_args()

# Check if path exists
if os.path.exists(os.path.abspath(args.path[0])):
    PATH = os.path.abspath(args.path[0])
else:
    argparser.error("This path does not exists");

# Check if path exists
hostingExists = False
for patch in patchs:
    if args.hosting == patch:
        hostingExists = True
if hostingExists:
    HOSTING = args.hosting
else:
    argparser.error("This hosting does not exists")

if args.info:
    print("[ 0% ] Installing random_compat")

# Install random_compat
subprocess.call(["composer", "--no-ansi", "require", "paragonie/random_compat:~1.4"], shell=True, cwd=PATH)

if args.info:
    print("[20% ] Patching with general patch")

# NORMAL FILES PATCHING
patchFiles("general")

if args.info:
    print("[40% ] Patching with " + HOSTING + " patch")

patchFiles(HOSTING)

if args.info:
    print("[60% ] Patching env file")

# CONFIG FILES PATCHING
# Create fake head
config = io.StringIO();
config.write("[DEFAULT]\n");

# Load config file
config.write(open(PATH + "/.env").read())
config.seek(0, os.SEEK_SET)

# Parse config
confparser = configparser.ConfigParser()
confparser.readfp(config)

if args.info:
    print("[80% ] Patching configs")

# Get all config files
configs = glob.glob(PATH + "/config/*.php")

# Patch config files
for configName in configs:
    # Open config file with rw permissions
    configFile = open(configName, "r+")

    # Read content of file
    lines = configFile.readlines()

    # Remove content of the config
    configFile.seek(0)
    configFile.truncate()

    # Loop through lines
    for line in lines:
        # Check if there is env() fucntion
        if "env('" in line:

            # Get key by finding substrings "env(" and "'"
            substring = line[line.find("env('")+5:]
            key = substring[:substring.index('\'')]

            try:
                # Get value by key
                value = confparser.get("DEFAULT", key)

                # Get string to replace by substrings "env(" and "),"
                toReplace = line[line.find("=>")+3:line.find("),")+1]

                # If value is string, add quatation marks
                if not value.isdigit() and value != "true" and value != "false":
                    value = "\"" + value + "\""

                # Replace env(...) by value
                line = line.replace(toReplace, value)
            except Exception:
                # Because python
                key = key

        #W rite changes into .php config file
        configFile.write(line)
if args.info:
    print("[100%] Patching done")
