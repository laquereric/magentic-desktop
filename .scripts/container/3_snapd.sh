#!/bin/bash

echo ".scripts/3_snapd.sh"

systemctl unmask snapd.service
systemctl enable snapd.service
systemctl start snapd.service