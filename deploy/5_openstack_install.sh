#!/bin/bash
set -e

VENV_PATH=/opt/kolla
cd $VENV_PATH
source $VENV_PATH/bin/activate

# init the server (base only)
kolla-ansible -i ./multinode bootstrap-servers
# ensure all the required bits and configuration are in place
kolla-ansible -i ./multinode prechecks
# deploy controller and compute
kolla-ansible -i ./multinode deploy