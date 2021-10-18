#!/bin/sh
set -e

## install packstack
dnf config-manager --enable powertools
# xena not working yet
# dnf install -y centos-release-openstack-xenu
dnf install -y centos-release-openstack-wallaby
dnf update -y
dnf install -y openstack-packstack 