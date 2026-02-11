#!/bin/bash
set -e

# Deployment script for go-weather-api
# This script extracts the deployment package and restarts the service

DEPLOY_DIR="/opt/go-weather-api"
SERVICE_NAME="go-weather-api"
BINARY_NAME="go-weather-api"
TEMP_DIR="/tmp"

echo "Starting deployment..."

# Extract the deployment package
echo "Extracting deployment package..."
cd $TEMP_DIR
tar -xzf go-weather-api.tar.gz

# Create deployment directory if it doesn't exist
mkdir -p $DEPLOY_DIR

# Stop the service if it's running (if using systemd)
# Check if we can use systemctl (may require sudo)
if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet $SERVICE_NAME 2>/dev/null || sudo systemctl is-active --quiet $SERVICE_NAME 2>/dev/null; then
        echo "Stopping service..."
        systemctl stop $SERVICE_NAME 2>/dev/null || sudo systemctl stop $SERVICE_NAME 2>/dev/null || true
    fi
fi

# Copy files to deployment directory
echo "Copying files to $DEPLOY_DIR..."
cp $BINARY_NAME $DEPLOY_DIR/
cp go.mod $DEPLOY_DIR/ 2>/dev/null || true
cp go.sum $DEPLOY_DIR/ 2>/dev/null || true

# Make binary executable
chmod +x $DEPLOY_DIR/$BINARY_NAME

# Start the service (if using systemd)
if command -v systemctl >/dev/null 2>&1; then
    if systemctl list-unit-files 2>/dev/null | grep -q "^${SERVICE_NAME}.service" || sudo systemctl list-unit-files 2>/dev/null | grep -q "^${SERVICE_NAME}.service"; then
        echo "Starting service..."
        systemctl start $SERVICE_NAME 2>/dev/null || sudo systemctl start $SERVICE_NAME 2>/dev/null || true
        systemctl status $SERVICE_NAME --no-pager 2>/dev/null || sudo systemctl status $SERVICE_NAME --no-pager 2>/dev/null || true
    else
        echo "Service not found in systemd. Binary deployed to $DEPLOY_DIR/$BINARY_NAME"
        echo "You may need to manually start the service or configure a process manager"
    fi
else
    echo "systemctl not available. Binary deployed to $DEPLOY_DIR/$BINARY_NAME"
    echo "You may need to manually start the service or configure a process manager"
fi

# Cleanup
echo "Cleaning up temporary files..."
rm -f $TEMP_DIR/go-weather-api.tar.gz
rm -f $TEMP_DIR/$BINARY_NAME
rm -f $TEMP_DIR/go.mod
rm -f $TEMP_DIR/go.sum

echo "Deployment completed successfully!"
