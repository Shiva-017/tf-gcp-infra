#!/bin/bash
# Navigate to the root directory
cd ..
cd ..
cd ..

touch /opt/db-startup.sh

# Set environment variables file path
ENV_FILE="/home/packer/webapp/.env"

# Create or overwrite the .env file with database credentials
tee "$ENV_FILE" > /dev/null <<EOF
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD="${db_password}"
DB_HOST="${db_host}"
DB_PORT=${db_port}
NODE_ENV=prod
EOF

# Change ownership of the .env file
chown csye6225:csye6225 "$ENV_FILE"
