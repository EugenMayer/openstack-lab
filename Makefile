init:
	./generate_keys.sh

start: init
	vagrant up --no-parallel
	# update all the /etc/hosts files of the nodes
	vagrant hostmanager
	# prepopulate the controller known_hosts file
	#vagrant ssh controller -c 'sudo -- sh -c "ssh-keyscan controller compute1 compute2 >> /var/lib/one/.ssh/known_hosts"'
	#vagrant ssh controller -c 'sudo -- sh -c "chown oneadmin:oneadmin /var/lib/one/.ssh/known_hosts"'
	# add both hosts to our controller
	#vagrant ssh controller -c 'sudo -- sh -c "onehost create compute1 --im qemu --vm qemu"'
	#vagrant ssh controller -c 'sudo -- sh -c "onehost create compute2 --im qemu --vm qemu"'

creds:
	#vagrant ssh controller -c 'sudo cat /var/lib/one/.one/one_auth'

controller:
	vagrant ssh controller

clean:
	./generate_keys.sh
	vagrant destroy --force
	rm -fr sshkeys
	rm -fr .vagrant

cleanAll:
	for i in `vagrant global-status | grep virtualbox | awk '{ print $1 }'` ; do vagrant destroy $i ; 
	vagrant global-status --prune