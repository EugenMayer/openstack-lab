This is our inventory for the deployment. See https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#organizing-host-and-group-variables
for the layout.
It is mounted to `deployer` under `/mnt/config` and used via `kolla-ansible -i /mnt/config`

`multinode` is copied from `/opt/kolla/share/kolla-ansible/ansible/inventory/multinode` and modified.
See marker `############# NO CHANGES BELOW THIS LINE ###############` - nothing below that line was modified, so only the
top part needs to be taken care of on upgrade

The base `multinode` is in `/multinode_original` which is based on `master` commit `37136478d7530493465d484db06c4b04b3afdd93`
