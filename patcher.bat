@echo off
setlocal enableDelayedExpansion
ECHO [INFO] Patching %1

::cd into project folder
cd %1
ECHO [INFO] Installing paragonie/random_compat to solve CSPRNG error
call composer require paragonie/random_compat:"~1.4"

::Create .htaccess file in root of the project
ECHO [ OK ] Done
ECHO [INFO] Creating .htaccess in root
ECHO ^<IfModule mod_rewrite.c^>>> .htaccess
ECHO RewriteEngine On>> .htaccess
ECHO RewriteRule ^(.*)$ public/$1 [L]>> .htaccess
ECHO ^</IfModule^>>> .htaccess
ECHO [ OK ] .htaccess in root done

::Modify .htaccess file in public/
ECHO [INFO] Patching existing .htaccess in public/
ECHO RewriteEngine On >> public/.htaccess
ECHO RewriteCond %{REQUEST_FILENAME} !-f> public/.htaccess
ECHO RewriteRule ^^(.*[^^/])$ /$1/ [L,R=301]>> public/.htaccess
ECHO RewriteCond %{REQUEST_URI} !^^domains/>> public/.htaccess
ECHO RewriteCond %{REQUEST_URI} !^^/domains/>> public/.htaccess
ECHO RewriteCond %{HTTP_HOST} ^^(www\.)?(.*)$>> public/.htaccess
ECHO RewriteCond %{DOCUMENT_ROOT}/domains/%2 -d>> public/.htaccess
ECHO RewriteRule (.*) domains/%2/$1 [DPI]>> public/.htaccess
ECHO RewriteCond %{REQUEST_URI} !^^subdom/>> public/.htaccess
ECHO RewriteCond %{REQUEST_URI} !^^/subdom/>> public/.htaccess
ECHO RewriteCond %{HTTP_HOST} ^^(www\.)?(.*)\.([^^\.]*)\.([^^\.]*)$>> public/.htaccess
ECHO RewriteRule (.*) subdom/%2/public/$1 [DPI]>> public/.htaccess
ECHO RewriteCond %{REQUEST_FILENAME} !-d>> public/.htaccess
ECHO RewriteCond %{REQUEST_FILENAME} !-f>> public/.htaccess
ECHO RewriteCond %{HTTP_HOST} ^^(www\.)?(.*)\.([^^\.]*)\.([^^\.]*)$>> public/.htaccess
ECHO RewriteRule ^^ index.php [L]>> public/.htaccess
ECHO RewriteCond %{REQUEST_FILENAME} -d>> public/.htaccess
ECHO RewriteRule ^^domains/[^^/]+/(.+[^^/])$ /$1/ [R]>> public/.htaccess
ECHO RewriteCond %{REQUEST_FILENAME} -d>> public/.htaccess
ECHO RewriteRule ^^subdom/[^^/]+/public/(.+[^^/])$ /$1/ [R]>> public/.htaccess
ECHO [ OK ] Patching done
ECHO [INFO] Patching config php files to remove putenv() function by python envPatcher

::Run env patcher
python %~dp0/envPatcher.py
ECHO [ OK ] envPatching done
