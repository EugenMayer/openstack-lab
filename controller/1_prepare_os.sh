#!/bin/sh
set -e

apt-get update
apt-get upgrade -y

# we need an ntp serever on all nodes
apt-get install -y chrony 
apt-get install -y curl

# docker helper tools
echo '''#!/bin/bash
set -e
docker exec ovn_controller ovn-trace $@
''' > /usr/local/bin/ovn-trace

echo '''#!/bin/bash
set -e
docker exec ovn_nb_db ovn-nbctl $@
'''> /usr/local/bin/ovn-nbctl

echo '''#!/bin/bash
set -e
docker exec ovn_sb_db ovn-sbctl $@
''' > /usr/local/bin/ovn-sbctl

echo '''#!/bin/bash
set -e
docker exec openvswitch_vswitchd ovs-vsctl $@
''' > /usr/local/bin/ovs-vsctl

chmod +x /usr/local/bin/ovn-sbctl /usr/local/bin/ovn-nbctl /usr/local/bin/ovs-vsctl /usr/local/bin/ovn-trace