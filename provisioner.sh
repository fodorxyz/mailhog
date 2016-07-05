# Create mailhog user so we don't run this as root
useradd -m -s /bin/bash mailhog

# Download executable from GitHub
curl -sS -L -o /usr/local/bin/mailhog https://github.com/mailhog/MailHog/releases/download/v0.2.0/MailHog_linux_amd64

# Make it executable
chmod +x /usr/local/bin/mailhog

# MAILHOG_PASSWORD is a custom input on Fodor
BCRYPT_PASSWORD=`/usr/local/bin/mailhog bcrypt ${MAILHOG_PASSWORD}`

echo "${MAILHOG_USERNAME}:${BCRYPT_PASSWORD}" > /home/mailhog/auth

# Allow mailhog to listen on privileged ports
setcap 'cap_net_bind_service=+ep' /usr/local/bin/mailhog

# Make it start on reboot
tee /etc/init/mailhog.conf <<EOL
description "Mailhog"
start on runlevel [2345]
stop on runlevel [!2345]
respawn
pre-start script
    exec su - mailhog -c "/usr/bin/env /usr/local/bin/mailhog -auth-file=/home/mailhog/auth -api-bind-addr='0.0.0.0:80' -ui-bind-addr='0.0.0.0:80' -smtp-bind-addr='0.0.0.0:25' > /dev/null 2>&1 &"
end script
EOL

# Start it now in the background
service mailhog restart
