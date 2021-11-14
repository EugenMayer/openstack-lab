## WAT

Start an self contained OpenStack LAB with 1 controller node and 2 compute nodes - all using vagrant in one command.
OpenStack is deployed vanilla using `Kolla` via the `deploy` box.

Thia `wan` provider network for floating ips, a `management` network for the cluster management and node (OVN) interop.

- We are not using DVR / distributed IPs
- OVN North-Bridge (gateway node) and (database node) are deployed to the controller

Status:

- openstack: Xena
- Debian: 11 (bullseye) (controller and nodes)
- Neutron type: OVN non DVR

## Requirements

- Installed `Virtualbox` and `Vagrant` on your system
- Installed `vagrant plugin install vagrant-hostmanager`
- About 15GB of RAM (10 for the controller and 2 for each node and 1 for the deploy node).
- If you want to start `instances` (nested virtualization), for now this does only work with AMD CPUs (virtualbox 6.1.26 as for now).
  Intel is known to have more issue nested virtualization under VirtualBox, nothing we can do about that right now. Might
  change in the future. With intel you get a GPT starting issue when booting an instance

## Usage

```bash
git clone https://github.com/EugenMayer/openstack-lab
cd openstack-lab

make start
```

You should now have a `openstack` installation with 1 contrroller and 2 compute nodes able to start VMs.

Connect via `http://172.27.240.2`

The credentials are

- User: `admin`
- Password: run `make creds` to see the password

### Connect to boxes via ssh

```bash
vagrant ssh deployer
vagrant ssh controller1
vagrant ssh compute1
vagrant ssh compute2
```

## De-Bootstrap

```
make clean
```

## Advanced / Internals

### Docs

And overview of most kolla-ansible docs can be found [here](https://docs.openstack.org/kolla-ansible/latest/admin/index.html)

### Inventory configuration

You find the inventory configuration in `config/` including the `group_vars`. This folder is mounted via `vagrant` into `/mnt/config/` and then used via `kolla-ansible -i /mnt/config`

`config/mulitnode/` was taken from the original and modified in the top
until the marker `############# NO CHANGES BELOW THIS LINE ###############`
The base `multinode` is in `/multinode_original` which is based on `master` commit `37136478d7530493465d484db06c4b04b3afdd93`

### Network

`eth0` is ignored here since it is a host-only virtualbox network for virtualbox interops. So just ignore that interface.

**The common networks are:**

- internal `mngmnt`: `172.27.240.0/24` for the management of the cluster / internal communication between controller / compute nodes. This network can be access from the host
- provider network `wan`: `203.0.113.0/24` for the provider floating ips (WAN). We picked that ip range since openstack tutorials pick those too

**Deploy has 2 networks:**

1. `eth1` as `mngmnt` (172.27.240.240)

**Controller has 3 networks:**

1. `eth1` as `mngmnt` (172.27.240.2)
2. `eth2` as `wan` (203.0.113.2)

**Compute 1/2 have 3 networks:**

We have no WAN interface here, since we are NOT using [DVR](https://docs.openstack.org/networking-ovn/latest/admin/refarch/refarch.html#distributed-floating-ips-dvr) in this setup

1. `eth1` as `mngmnt` (172.27.240.3/172.27.240.4)

### Troubleshooting

- If the controller has not enough ram, it creates a huge load after the initial deployment. It seems like about 10GB is what it needs

### Using the openstack CLI

You can now run the openstack cli by connecting to deploy and run:

```bash
$ vagrant ssh deployer
$ sudo -s
$ source /opt/kolla/bin/activate
$ . /etc/kolla/admin-openrc.sh
$ openstack {command}
```
