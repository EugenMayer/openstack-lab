## WAT

Start an self contained OpenStack LAB with 1 controller node and 2 compute nodes - all using vagrant in one command.
OpenStack is deployed vanilla using `Kolla` via the `deploy` box.

Status:

- openstack: Xena
- Debian: 11 (bullseye) (controller and nodes)

## Requirements

- Installed `Virtualbox` and `Vagrant` on your system
- Installed `vagrant plugin install vagrant-hostmanager`
- About 15GB of RAM (10 for the controller and 2 for each node and 1 for the deploy node).

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
vagrant ssh deploy
vagrant ssh controller
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

### Network

We have 2 networks attached to the vm:

- `mngmnt`: `172.27.240.0/24` for the management of the cluster / internal communication between controller / compute nodes. This network can be access from the host
- `vmlan`: `10.0.0.0/24` for the vm-lan and neutron network. This is a internal network only

- Deploy has 2 networks:
  1. `eth1` as `mngmnt` (172.27.240.240)
  2. (the host-only network we do not care about)
- Controller has 3 networks:
  1. `eth1` as `mngmnt` (172.27.240.2)
  1. `eth2` as `vmlan` (10.0.0.2)
  1. and (the host-only network we do not care about)
- Compute 1/2 have 3 networks:
  1. `eth1` as `mngmnt` (172.27.240.3/172.27.240.4)
  2. `eth2` as `vmlan` (10.0.0.3/10.0.0.4)
  3. and (the host-only network we do not care about)

### Troubleshooting

- If the controller has not enough ram, it creates a huge load after the initial deployment. It seems like about 10GB is what it needs

### Using the openstack CLI

You can now run the openstack cli by connecting to deploy and run:

```bash
$ vagrant ssh deploy
$ sudo -s
$ source /opt/kolla/bin/activate
$ . /etc/kolla/admin-openrc.sh
$ openstack {command}
```
