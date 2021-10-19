#!/bin/sh
set -e

sudo pvcreate /dev/sdc
sudo vgcreate cinder-volumes /dev/sdc