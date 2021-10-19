## WAT

Start an self contained OpenStack LAB with 1 controller node and 2 compute nodes - all using vagrant in one command.
OpenStack is deployed vanilla using `Kolla` via the `deploy` box.

Status:

- openstack: Xena
- Ubuntu 20.04 (controller and nodes)

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

### Network

We have 2 internal networks attached to the vm:

- `mngmnt`: `10.0.0.0/24` for the management of the cluster / internal communication between controller / compute nodes
- `vmlan`: `172.30.0.0/24` for the vm-lan and neutron network

- Deploy has 2 networks:
  1. `enp0s8` as `mngmnt` (10.0.0.240)
  2. (the host-only network we do not care about)
- Controller has 3 networks:
  1. `enp0s8` as `mngmnt` (10.0.0.2)
  1. `enp0s9` as `vmlan` (172.30.0.2)
  1. and (the host-only network we do not care about)
- Compute 1/2 have 3 networks:
  1. `enp0s8` as `mngmnt` (10.0.0.3/10.0.0.4)
  2. `enp0s9` as `vmlan` (172.30.0.3/172.30.0.4)
  3. and (the host-only network we do not care about)

### Troubleshooting

- If the controller has not enough ram, it creates a huge load after the initial deployment. It seems like about 10GB is what it needs
