#!/bin/bash

# Check if URL argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 sshurl"
    exit 1
fi

url=$1

# Parse the URL
proto=$(echo "$url" | cut -d'/' -f1)   # e.g. ssh://
userhostport=$(echo "$url" | cut -d'/' -f2)   # e.g. username@hostname:port
pwd=$(echo "$url" | cut -d'/' -f3-)   # password (after the second '/')

# Split userhostport into user, host, and port
userhost=$(echo "$userhostport" | cut -d':' -f1)   # e.g. username@hostname
port=$(echo "$userhostport" | cut -d':' -f2)       # port (optional)

# If no port is provided, set default SSH port (22)
if [ -z "$port" ]; then
    port=22
fi

# Extract user and host
user=$(echo "$userhost" | cut -d'@' -f1)  # e.g. username
host=$(echo "$userhost" | cut -d'@' -f2)  # e.g. hostname

# If the user is missing (e.g. "hostname" instead of "user@hostname"), assume root
if [ -z "$user" ]; then
    user="root"
fi

# URL decode the password
pwd=$(echo "$pwd" | sed 's/%\([A-Fa-f0-9][A-Fa-f0-9]\)/\x\1/g')

# Run sshpass with ssh to connect to the server
export SSHPASS="$pwd"
sshpass -e ssh -o StrictHostKeyChecking=no -p "$port" "$user@$host"

