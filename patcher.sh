#!/bin/bash
echo "[INFO] Patching %1"

#copy temporary env patcher into project folder
cp envPatcher.py $1

#cd into project folder
cd $1

echo "[INFO] Installing paragonie/random_compat to solve CSPRNG error"
composer require paragonie/random_compat:"~1.4"
echo "[ OK ] Done"
echo "[INFO] Creating .htaccess in root"
echo "[INFO] Patching existing .htaccess in public/"
#Create .htaccess file in root of the project
cat <<EOT > .htaccess
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteRule (.*)$ public/$1 [L]
</IfModule>
EOT
#Modify .htaccess file in public/
echo "[ OK ] .htaccess in root done"
cat <<EOT > public/.htaccess
RewriteCond {REQUEST_FILENAME} -f
RewriteRule ^(.*[^/])$ /$1/ [L,R=301]
RewriteCond {REQUEST_URI} domains/
RewriteCond {REQUEST_URI} /domains/
RewriteCond {HTTP_HOST} ^(www\.)?(.*)$
RewriteCond 2 -d
RewriteRule (.*) domains//$1 [DPI]
RewriteCond {REQUEST_URI} subdom/
RewriteCond {REQUEST_URI} /subdom/
RewriteCond {HTTP_HOST} ^(www\.)?(.*)\.([^\.]*)\.([^\.]*)$
RewriteRule (.*) subdom//public/$1 [DPI]
RewriteCond {REQUEST_FILENAME} -d
RewriteCond {REQUEST_FILENAME} -f
RewriteCond {HTTP_HOST} ^(www\.)?(.*)\.([^\.]*)\.([^\.]*)$
RewriteRule ^ index.php [L]
RewriteCond {REQUEST_FILENAME} -d
RewriteRule ^domains/[^/]+/(.+[^/])$ /$1/ [R]
RewriteCond {REQUEST_FILENAME} -d
RewriteRule ^subdom/[^/]+/public/(.+[^/])$ /$1/ [R]
EOT
echo "[ OK ] Patching done"
echo "[INFO] Patching config php files to remove putenv() function by python envPatcher"
#Run env patcher
./envPatcher.py

#Remove env patcher from procject directory
rm envPatcher.py
echo "[ OK ] envPatching done"
