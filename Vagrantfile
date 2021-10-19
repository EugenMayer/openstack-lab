# -*- mode: ruby -*-
# vi: set ft=ruby :

deploy =  {'hostname' => 'deploy',  "ip_management" => "10.0.0.240"}
controllerNodes = {
  'compute1' => {'hostname' => 'controller', "ip_vm" => "172.30.0.2", "ip_management" => "10.0.0.2"},
}

computeNodes = {
  'compute1' => {'hostname' => 'compute1', "ip_vm" => "172.30.0.3", "ip_management" => "10.0.0.3"},
  'compute2' => {'hostname' => 'compute2', "ip_vm" => "172.30.0.4", "ip_management" => "10.0.0.4"}
}

Vagrant.configure("2") do |config|
  # get our pre-generated ssh keys
  if Dir.exist?('sshkeys') 
    public_key = File.read("sshkeys/id_rsa.pub")
    private_key = File.read("sshkeys/id_rsa")
  end
 

  #config.vm.box = "centos/8"
  #config.vm.box = "ubuntu/hirsute64"
  config.vm.box = "ubuntu/focal64"

  #ensure our hosts can resolve themselfs via hostnames 
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
      box.vm.network "private_network", ip: computeNodes[key]['ip_management'], hostname: true, virtualbox__intnet: true

      # VM network
      box.vm.network "private_network", ip: computeNodes[key]['ip_vm'], virtualbox__intnet: true


      # we need some space for our VG/PV
      box.vm.disk :disk, size: "20GB", name: "lvm-disk"

      box.vm.provider :virtualbox do |vb|
        vb.memory = 2048
        vb.cpus = 2
        vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
      end
      
      # for vagrant
      box.vm.provision "shell", inline: <<-SCRIPT
        echo '#{public_key}' >> /root/.ssh/authorized_keys
        chmod -R 600  /root/.ssh/authorized_keys
        SCRIPT

      box.vm.provision "shell", path: "compute/1_prepare_os.sh"
      box.vm.provision "shell", path: "compute/2_setup_lvm.sh"
    end
  end

  # our controller nodes
  controllerNodes.keys.sort.each do |key|
    hostname = controllerNodes[key]['hostname']
    ip_vm = controllerNodes[key]['ip_vm']
    ip_management = controllerNodes[key]['ip_management']

    config.vm.define hostname do |box|
      box.vm.provider :virtualbox do |vb|
        vb.memory = 3048
        vb.cpus = 3
      end
      box.vm.host_name = hostname

      #box.vm.network "forwarded_port", guest: 80, host: 8080
      #box.vm.network "forwarded_port", guest: 2616, host: 2616
    
      # openstack management network - must come first so the hostname is assigned to this network
      box.vm.network "private_network", ip: ip_management, hostname: true, virtualbox__intnet: true
      # VM network
      box.vm.network "private_network", ip: ip_vm, virtualbox__intnet: true
     
      box.vm.provision "shell", inline: <<-SCRIPT
        sudo echo '#{public_key}' >> /root/.ssh/authorized_keys
        sudo chmod -R 600 /root/.ssh/authorized_keys
        SCRIPT
      box.vm.provision "shell", path: "controller/1_prepare_os.sh"
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
    box.vm.network "private_network", ip: deploy['ip_management'], hostname: true, virtualbox__intnet: true

    config.vm.synced_folder "config/", "/mnt/config"
    #deploy ssh private/public key before we install
    box.vm.provision "shell", inline: <<-SCRIPT
      sudo echo '#{private_key}' > /root/.ssh/id_rsa_cluster
      sudo echo '#{public_key}' > /root/.ssh/id_rsa_cluster.pub
      sudo chmod -R 600 /root/.ssh/id_rsa_cluster
      sudo chmod -R 600 /root/.ssh/id_rsa_cluster.pub
      SCRIPT

    box.vm.provision "shell", path: "deploy/1_prepare_os.sh"
    box.vm.provision "shell", path: "deploy/2_install_kolla.sh"
    box.vm.provision "shell", path: "deploy/3_configure_kolla.sh"
    box.vm.provision "shell", path: "deploy/4_verify.sh"
    box.vm.provision "shell", path: "deploy/5_openstack_install.sh"
  end
end
