#!/bin/sh
set -e

sudo pvcreate /dev/sdb
sudo vgcreate cinder-volumes /dev/sdb