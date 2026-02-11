#!/bin/bash
set -e

# Deployment script for go-weather-api
# This script extracts the deployment package and restarts the service

DEPLOY_DIR="/opt/go-weather-api"
SERVICE_NAME="go-weather-api"
BINARY_NAME="go-weather-api"
TEMP_DIR="/tmp"
EXTRACT_DIR="$TEMP_DIR/go-weather-api-deploy-$$"

# Check if passwordless sudo is available
SUDO_CMD=""
if sudo -n true 2>/dev/null; then
    SUDO_CMD="sudo"
    echo "Passwordless sudo available"
else
    echo "Passwordless sudo not available, will try operations without sudo"
fi

echo "Starting deployment..."

# Create a temporary extraction directory
mkdir -p $EXTRACT_DIR

# Extract the deployment package to the temp directory
echo "Extracting deployment package..."
if ! tar -xzf $TEMP_DIR/go-weather-api.tar.gz -C $EXTRACT_DIR --no-same-owner --no-same-permissions 2>/dev/null; then
    echo "Retrying extraction without permission flags..."
    tar -xzf $TEMP_DIR/go-weather-api.tar.gz -C $EXTRACT_DIR || {
        echo "Error: Failed to extract deployment package!"
        exit 1
    }
fi

# Create deployment directory if it doesn't exist
echo "Creating deployment directory..."
if ! mkdir -p $DEPLOY_DIR 2>/dev/null; then
    if [ -n "$SUDO_CMD" ]; then
        $SUDO_CMD mkdir -p $DEPLOY_DIR
    else
        # Fallback to user's home directory if we can't create /opt directory
        DEPLOY_DIR="$HOME/go-weather-api"
        echo "Cannot create /opt/go-weather-api, using $DEPLOY_DIR instead"
        mkdir -p $DEPLOY_DIR
    fi
fi

# Stop the service if it's running (if using systemd)
# Check if we can use systemctl (may require sudo)
if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet $SERVICE_NAME 2>/dev/null || ([ -n "$SUDO_CMD" ] && $SUDO_CMD systemctl is-active --quiet $SERVICE_NAME 2>/dev/null); then
        echo "Stopping service..."
        systemctl stop $SERVICE_NAME 2>/dev/null || ([ -n "$SUDO_CMD" ] && $SUDO_CMD systemctl stop $SERVICE_NAME 2>/dev/null) || true
    fi
fi

# Copy files to deployment directory
echo "Copying files to $DEPLOY_DIR..."
if [ -f "$EXTRACT_DIR/$BINARY_NAME" ]; then
    if ! cp $EXTRACT_DIR/$BINARY_NAME $DEPLOY_DIR/ 2>/dev/null; then
        if [ -n "$SUDO_CMD" ]; then
            $SUDO_CMD cp $EXTRACT_DIR/$BINARY_NAME $DEPLOY_DIR/
        else
            echo "Error: Cannot copy binary to $DEPLOY_DIR (permission denied)"
            exit 1
        fi
    fi
elif [ -f "$BINARY_NAME" ]; then
    if ! cp $BINARY_NAME $DEPLOY_DIR/ 2>/dev/null; then
        if [ -n "$SUDO_CMD" ]; then
            $SUDO_CMD cp $BINARY_NAME $DEPLOY_DIR/
        else
            echo "Error: Cannot copy binary to $DEPLOY_DIR (permission denied)"
            exit 1
        fi
    fi
else
    echo "Error: Binary $BINARY_NAME not found!"
    exit 1
fi

# Copy optional files
[ -f "$EXTRACT_DIR/go.mod" ] && (cp $EXTRACT_DIR/go.mod $DEPLOY_DIR/ 2>/dev/null || ([ -n "$SUDO_CMD" ] && $SUDO_CMD cp $EXTRACT_DIR/go.mod $DEPLOY_DIR/ 2>/dev/null) || true)
[ -f "$EXTRACT_DIR/go.sum" ] && (cp $EXTRACT_DIR/go.sum $DEPLOY_DIR/ 2>/dev/null || ([ -n "$SUDO_CMD" ] && $SUDO_CMD cp $EXTRACT_DIR/go.sum $DEPLOY_DIR/ 2>/dev/null) || true)

# Make binary executable
if ! chmod +x $DEPLOY_DIR/$BINARY_NAME 2>/dev/null; then
    if [ -n "$SUDO_CMD" ]; then
        $SUDO_CMD chmod +x $DEPLOY_DIR/$BINARY_NAME
    else
        echo "Warning: Cannot make binary executable (permission denied)"
    fi
fi

# Start the service (if using systemd)
if command -v systemctl >/dev/null 2>&1; then
    if systemctl list-unit-files 2>/dev/null | grep -q "^${SERVICE_NAME}.service" || ([ -n "$SUDO_CMD" ] && $SUDO_CMD systemctl list-unit-files 2>/dev/null | grep -q "^${SERVICE_NAME}.service"); then
        echo "Starting service..."
        systemctl start $SERVICE_NAME 2>/dev/null || ([ -n "$SUDO_CMD" ] && $SUDO_CMD systemctl start $SERVICE_NAME 2>/dev/null) || true
        systemctl status $SERVICE_NAME --no-pager 2>/dev/null || ([ -n "$SUDO_CMD" ] && $SUDO_CMD systemctl status $SERVICE_NAME --no-pager 2>/dev/null) || true
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
rm -rf $EXTRACT_DIR
rm -f $TEMP_DIR/go-weather-api.tar.gz

echo "Deployment completed successfully!"
