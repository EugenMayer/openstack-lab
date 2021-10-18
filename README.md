## WAT

Start an self contained OpenStack LAB with 2 compute nodes and a controller node - all using vagrant in one command.

Status:

- openstack: Xena
- CentOs 8 (controller and nodes)

## Requirements

Install `Virtualbox` and `Vagrant` on your system

Also install the `hostmanager` vagrant plugin

```bash
vagrant plugin install vagrant-hostmanager
```

## Usage

```bash
git clone https://github.com/EugenMayer/openstack-lab
cd openstack-lab

make start
```

To see your credentials type `make creds`
Now connect via browser on `http://127.0.0.1:8080`

You should now have a `openstack` installation with 2 hosts able to start VMs

### Connect to boxes via ssh

```bash
vagrant ssh controller
vagrant ssh compute1
vagrant ssh compute2
```

## De-Bootstrap

```
make clean

# or
vagrant destroy --force
```
