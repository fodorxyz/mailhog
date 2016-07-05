# Create mailhog user so we don't run this as root
useradd -m -s /bin/bash mailhog

# MAILHOG_PASSWORD is a custom input on Fodor
BCRYPT_PASSWORD=`MailHog bcrypt ${MAILHOG_PASSWORD}`

echo "admin:{$BCRYPT_PASSWORD}" > /home/mailhog/auth

# Download executable from GitHub
curl -o /usr/local/bin/mailhog https://github.com/mailhog/MailHog/releases/download/v0.2.0/MailHog_linux_amd64

# Make it executable
chmod +x /usr/local/bin/mailhog

# Make it start on reboot
tee /etc/init/mailhog.conf <<EOL
description "Mailhog"
start on runlevel [2345]
stop on runlevel [!2345]
respawn
pre-start script
    exec su - mailhog -c "/usr/bin/env /usr/local/bin/mailhog -auth-file=/home/mailhog/auth -ui-bind-addr="0.0.0.0:80" -smtp-bind-addr="0.0.0.0:25" > /dev/null 2>&1 &"
end script
EOL

# Start it now in the background
service mailhog restart
