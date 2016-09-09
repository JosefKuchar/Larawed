# Larawed
Copyright (C) 2016 Josef Kuchař

Larawed is tool that modify existing/new laravel project to run on shared hostings
## U need this in your path:
1. composer
2. python 3 as python3

## How to use
### On MS Windows:
In cmd go to this repository by `cd` and run `python3 larawed.py [--hosting] PATH`
e.g. `python3 larawed.py --hosting wedos C:/Users/Example/Documents/LaravelProject`

### On Linux:
In terminal go to this repository by `cd` and run `./larawed.py [--hosting] PATH`
e.g. `./larawed.py --hosting wedos ~/LaravelProject`

### On macOS:
In terminal go to this repository by `cd` and run `python3 laraved.py [--hosting] PATH`
e.g. `python3 laraved.py --hosting wedos ../LaravelProject`

## Post install/patch
Copy all files to www or root of your subdomain by ftp and set access rights 0777 to storage and bootstrap/cache recursively
