# Setup Openstack

Default configuration for our lab setup

```
vagrant ssh controller
sudo -s
docker exec -it neutron_server bash -c 'ovs-vsctl set open . external-ids:ovn-cms-options="enable-chassis-as-gw"'
```

```
vagrant ssh deploy
sudo -s

source /opt/kolla/bin/activate
source /etc/kolla/admin-openrc.sh
```

```
openstack network create --external --share --provider-physical-network physnet1 --provider-network-type flat provider-wan
openstack subnet create --network provider-wan --subnet-range 203.0.113.0/24 --allocation-pool start=203.0.113.2,end=203.0.113.100 --dns-nameserver 1.1.1.1 --gateway 203.0.113.1 provider-wan-v4

openstack network create kwlan --internal --share
openstack subnet create --network kwlan --subnet-range 10.10.0.0/24 --gateway 'auto' --dns-nameserver 1.1.1.1 kwlan-v4

openstack router create lan2wan
openstack router add subnet lan2wan kwlan-v4

openstack router set --external-gateway provider-wan lan2wan

openstack flavor create --disk 5 --vcpus 1 --ram 500 tiny
```

```
wget http://download.cirros-cloud.net/0.5.2/cirros-0.5.2-x86_64-disk.img

openstack image create \
--container-format bare \
--disk-format qcow2 \
--property hw\_disk\_bus=scsi \
--property hw\_scsi\_model=virtio-scsi \
--property os_type=linux \
--property os_distro=cirros \
--property os\_admin\_user=root \
--property os_version='11.1.0' \
--public \
--file cirros-0.5.2-x86_64-disk.img \
cirros-0.5.2
```

```
openstack server create --image cirros-0.5.2 --flavor tiny test --network kwlan
```
