#!/bin/bash

echo "Starting Docker service..."

# Fix ulimit issues by setting proper limits
ulimit -n 65536
ulimit -u 32768

# Start Docker service with proper error handling
if service docker start 2>/dev/null; then
    echo "Docker service started successfully"
else
    echo "Docker service already running or failed to start"
fi
