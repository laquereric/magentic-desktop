#!/bin/bash

echo "scripts/dbus.sh"

# Configure dbus for systemctl replacement
echo "Configuring dbus..."
mkdir -p /var/run/dbus
mkdir -p /run/dbus
dbus-uuidgen > /etc/machine-id
ln -sf /etc/machine-id /var/lib/dbus/machine-id

# Clean up any existing dbus pid file
echo "Cleaning up existing dbus files..."
rm -f /run/dbus/pid
rm -f /var/run/dbus/pid

# Start dbus daemon in background
echo "Starting dbus daemon..."
dbus-daemon --system --fork