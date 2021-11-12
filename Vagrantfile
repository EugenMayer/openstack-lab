# -*- mode: ruby -*-
# vi: set ft=ruby :

deploy = { 'hostname' => 'deploy', 'ip_management' => '172.27.240.240' }
controllerNodes = {
  'compute1' => { 'hostname' => 'controller', 'ip_management' => '172.27.240.2', 'ip_wan' => '203.0.113.2' }
}

computeNodes = {
  'compute1' => { 'hostname' => 'compute1', 'ip_management' => '172.27.240.3' },
  'compute2' => { 'hostname' => 'compute2', 'ip_management' => '172.27.240.4' }
}

Vagrant.configure('2') do |config|
  # get our pre-generated ssh keys
  if Dir.exist?('sshkeys')
    public_key = File.read('sshkeys/id_rsa.pub')
    private_key = File.read('sshkeys/id_rsa')
  end

  # config.vm.box = "centos/8"
  # config.vm.box = "ubuntu/hirsute64"
  # config.vm.box = "ubuntu/focal64"
  config.vm.box = 'debian/bullseye64'

  # ensure our hosts can resolve themselfs via hostnames
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = false
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  # setup the compute nodes first
  computeNodes.keys.sort.each do |key|
    hostname = computeNodes[key]['hostname']
    config.vm.define hostname do |box|
      box.vm.host_name = hostname

      # openstack management network - must come first so the hostname is assigned to this network
      box.vm.network 'private_network', ip: computeNodes[key]['ip_management'], hostname: true # , virtualbox__intnet: true
      # Provider network: wan/floating ip
      # box.vm.network "private_network", ip: computeNodes[key]['ip_wan'], virtualbox__intnet: true

      box.vm.provider :virtualbox do |vb|
        vb.memory = 3048
        vb.cpus = 2
        # Enable nested virtualization, since we want to host VMs on compute
        vb.customize ['modifyvm', :id, '--nested-hw-virt', 'on']
      end

      # for vagrant
      box.vm.provision 'shell', inline: <<-SCRIPT
        sudo mkdir -p /root/.ssh
        sudo chmod u=rwx,g=,o= /root/.ssh
        echo '#{public_key}' >> /root/.ssh/authorized_keys
        chmod -R 600  /root/.ssh/authorized_keys
      SCRIPT

      box.vm.provision 'shell', path: 'compute/1_prepare_os.sh'
    end
  end

  # our controller nodes - we actually have only 1
  controllerNodes.keys.sort.each do |key|
    hostname = controllerNodes[key]['hostname']
    ip_management = controllerNodes[key]['ip_management']
    ip_vm = controllerNodes[key]['ip_vm']
    ip_wan = controllerNodes[key]['ip_wan']

    config.vm.define hostname do |box|
      box.vm.provider :virtualbox do |vb|
        vb.memory = 10_048
        vb.cpus = 6
      end
      box.vm.host_name = hostname
      # openstack management network - must come first so the hostname is assigned to this network
      box.vm.network 'private_network', ip: ip_management, hostname: true # , virtualbox__intnet: true
      # Provider network: wan/floatingip
      box.vm.network 'private_network', ip: ip_wan # , virtualbox__intnet: true

      box.vm.provision 'shell', inline: <<-SCRIPT
        sudo mkdir -p /root/.ssh
        sudo chmod u=rwx,g=,o= /root/.ssh
        sudo echo '#{public_key}' >> /root/.ssh/authorized_keys
        sudo chmod -R 600 /root/.ssh/authorized_keys
      SCRIPT
      box.vm.provision 'shell', path: 'controller/1_prepare_os.sh'
    end
  end

  # this is the node we deploy the entire cluster from
  config.vm.define :deploy do |box|
    box.vm.provider :virtualbox do |vb|
      vb.memory = 1000
      vb.cpus = 1
    end
    box.vm.host_name = deploy['hostname']

    # deploy is only in the management network
    box.vm.network 'private_network', ip: deploy['ip_management'], hostname: true # , virtualbox__intnet: true

    config.vm.synced_folder 'config/', '/mnt/config'

    # deploy ssh private/public key before we install
    # This ensure we have root ssh access on all nodes (controller/compute)
    box.vm.provision 'shell', inline: <<-SCRIPT
      sudo mkdir -p /root/.ssh
      sudo chmod u=rwx,g=,o= /root/.ssh#{'    '}
      sudo echo '#{private_key}' > /root/.ssh/id_rsa
      sudo echo '#{public_key}' > /root/.ssh/id_rsa.pub
      sudo chmod -R 600 /root/.ssh/id_rsa
      sudo chmod -R 600 /root/.ssh/id_rsa.pub
    SCRIPT

    box.vm.provision 'shell', path: 'deploy/1_prepare_os.sh'
    box.vm.provision 'shell', path: 'deploy/2_install_kolla.sh'
    box.vm.provision 'shell', path: 'deploy/3_configure_kolla.sh'
    box.vm.provision 'shell', path: 'deploy/4_verify.sh'
    box.vm.provision 'shell', path: 'deploy/5_openstack_install.sh'
  end
end
