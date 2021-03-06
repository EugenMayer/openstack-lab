init:
	./generate_keys.sh

start: init
	VAGRANT_EXPERIMENTAL="disks" vagrant up --no-parallel

controller:
	vagrant ssh controller

creds:
	vagrant ssh deploy -c 'sudo cat /etc/kolla/passwords.yml | grep keystone_admin_password'

clean:
	./generate_keys.sh
	vagrant destroy --force
	rm -fr sshkeys
	rm -fr .vagrant

cleanAll:
	for i in `vagrant global-status | grep virtualbox | awk '{ print $1 }'` ; do vagrant destroy $i ; 
	vagrant global-status --prune