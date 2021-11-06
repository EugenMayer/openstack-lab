# Setup Openstack

Default configuration for our lab setup is stored under `/mnt/config/bin/setup_defaults.sh` or `config/bin/setup_defaults.sh` in the repo.

See yourself what is done there. This script is not run automatically, so do so optionally

```bash
vagrant ssh deploy
sudo -s

/mnt/config/bin/setup_defaults.sh
```

## OVN Floating ip setup

If you want to finish the setup you need to make the controller the chassis, do so:

```bash
vagrant ssh controller
sudo -s
docker exec -it neutron_server bash -c 'ovs-vsctl set open . external-ids:ovn-cms-options="enable-chassis-as-gw"'
```
