#!/usr/bin/env python3
# By Josef Kuchař
# Import libs
import configparser
import io
import os
import glob

#Create fake heading
config = io.StringIO();
config.write("[DEFAULT]\n");
print("[ EP ] Loading .env file")

#Load .env file in our config with fake heading
config.write(open(".env").read())
config.seek(0, os.SEEK_SET)

#Parse config with ConfigParser
cp = configparser.ConfigParser();
cp.readfp(config);

print("[ EP ] Loading done")
print("[ EP ] Getting all config files")

#Get all .php files in config folder
configs = glob.glob("config/*.php")
print("[ EP ] Patching config files")

#Loop through all config files
for configFileName in configs:
    print("[ EP ] Patching " + configFileName)

    #Open .php config with read and write permissions
    configFile = open(configFileName, "r+")

    #Load content of the file into the variable
    lines = configFile.readlines()

    #Remove content of the file
    configFile.seek(0)
    configFile.truncate()

    #Loop through all lines in file
    for line in lines:
        #Check if there is env() fucntion
        if "env('" in line:
            #Get key by finding substrings "env(" and "'"
            substring = line[line.find("env('")+5:]
            key = substring[:substring.index('\'')]

            try:
                #Get value by key
                value = cp.get("DEFAULT", key)

                #Get string to replace by substrings "env(" and "),"
                toReplace = line[line.find("=>")+3:line.find("),")+1]

                #If value is string, add quatation marks
                if not value.isdigit() and value != "true" and value != "false":
                    value = "\"" + value + "\""

                print("[ EP ] " + configFileName + " - replacing " + toReplace + " with " + value)
                #Replace env(...) by value
                line = line.replace(toReplace, value)
            except Exception:
                #Only for fun
                key = key

        #Write changes into .php config file
        configFile.write(line)
    print("[ EP ] File " + configFileName + " was patched!")
