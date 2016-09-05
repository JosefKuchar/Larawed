@echo off
setlocal enableDelayedExpansion
ECHO Patching %1
cd %1
REM Goto laravel folder

ECHO [INFO] Installing paragonie/random_compat to solve CSPRNG error
REM Install paragonie/random_compat:"~1.4" to solve CSPRNG error
call composer require paragonie/random_compat:"~1.4"
REM Forward all requests to public directory by .htaccess
ECHO [ OK ] Done
ECHO [INFO] Creating .htaccess in root
ECHO ^<IfModule mod_rewrite.c^>>> .htaccess
ECHO RewriteEngine On>> .htaccess
ECHO RewriteRule ^(.*)$ public/$1 [L]>> .htaccess
ECHO ^</IfModule^>>> .htaccess
ECHO [ OK ] .htaccess in root done
REM Modify existing .htaccess in public/.htaccess
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
python %~dp0/envPatcher.py
ECHO [ OK ] envPatching done
