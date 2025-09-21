#!/bin/bash

echo ".scripts/ps_plus.sh"

echo "systemctl list-units --state=running"
systemctl list-units --state=running

echo "pstree -ap"
pstree -ap