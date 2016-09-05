#!/usr/bin/env python3
import configparser
import io
import os
import glob

config = io.StringIO();
config.write("[DEFAULT]\n");
print("[ EP ] Loading .env file")
config.write(open(".env").read())
config.seek(0, os.SEEK_SET)
cp = configparser.ConfigParser();
cp.readfp(config);
print("[ EP ] Loading done")
print("[ EP ] Getting all config files")
configs = glob.glob("config/*.php")
print("[ EP ] Patching config files")
for configFileName in configs:
    print("[ EP ] Patching " + configFileName)
    configFile = open(configFileName, "r+")
    lines = configFile.readlines()
    configFile.seek(0)
    configFile.truncate()
    for line in lines:
        if "env('" in line:
            substring = line[line.find("env('")+5:]
            key = substring[:substring.index('\'')]
            try:
                value = cp.get("DEFAULT", key)
                toReplace = line[line.find("=>")+3:line.find("),")+1]
                if not value.isdigit() and value != "true" and value != "false":
                    value = "\"" + value + "\""
                print("[ EP ] " + configFileName + " - replacing " + toReplace + " with " + value)
                line = line.replace(toReplace, value)
            except Exception:
                key = key

        configFile.write(line)
    print("[ EP ] File " + configFileName + " was patched!")
