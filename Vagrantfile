# -*- mode: ruby -*-
# vi: set ft=ruby :

computeNodes = {
  'compute1' => {'hostname' => 'compute1', "ip" => "172.30.0.3"},
  'compute2' => {'hostname' => 'compute2', "ip" => "172.30.0.4"}
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
    ip = computeNodes[key]['ip']

    config.vm.define hostname do |box|
      box.vm.network "private_network", ip: ip, hostname: true

      box.vm.provider :virtualbox do |vb|
        vb.memory = 2048
        vb.cpus = 2
        vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
      end
      box.vm.host_name = hostname
      
      # deploy the ssh key of controller
      # for root
      box.vm.provision "shell", inline: <<-SCRIPT
        sudo mkdir -p /root/.ssh
        sudo chmod u=rwx,g=,o= /root/.ssh
        sudo echo '#{public_key}' >> /root/.ssh/authorized_keys
        sudo chmod -R 600 /root/.ssh/authorized_keys
        SCRIPT

      # for vagrant
      box.vm.provision "shell", inline: <<-SCRIPT
        mkdir -p /home/vagrant/.ssh
        chmod u=rwx,g=,o= /home/vagrant/.ssh
        echo '#{public_key}' >> /home/vagrant/.ssh/authorized_keys
        chmod -R 600  /home/vagrant/.ssh/authorized_keys
        SCRIPT

      box.vm.provision "shell", path: "compute/1_prepare_os.sh"
    end
  end

  config.vm.define :controller do |box|
    box.vm.provider :virtualbox do |vb|
      vb.memory = 3048
      vb.cpus = 3
    end
    hostname = "controller"
    box.vm.host_name = hostname

    #box.vm.network "forwarded_port", guest: 80, host: 8080
    #box.vm.network "forwarded_port", guest: 2616, host: 2616
  
    box.vm.network "private_network", ip: "172.30.0.2", hostname: true
    #box.vm.network "public_network", ip: "192.168.0.2", bridge: 'enp5s0'

    config.vm.synced_folder "config/", "/mnt/config"
    #deploy ssh private/public key before we install
    box.vm.provision "shell", inline: <<-SCRIPT
      sudo mkdir -p /root/.ssh
      sudo chmod u=rwx,g=,o= /root/.ssh
      sudo echo '#{private_key}' > /root/.ssh/id_rsa
      sudo echo '#{public_key}' > /root/.ssh/id_rsa.pub
      sudo echo '#{public_key}' >> /root/.ssh/authorized_keys
      sudo chmod -R 600 /root/.ssh/id_rsa
      sudo chmod -R 600 /root/.ssh/id_rsa.pub
      sudo chmod -R 600 /root/.ssh/authorized_keys
      SCRIPT


    box.vm.provision "shell", inline: <<-SCRIPT
      sudo echo '#{private_key}' > /home/vagrant/.ssh/id_rsa_cluster
      sudo echo '#{public_key}' > /home/vagrant/.ssh/id_rsa_cluster.pub
      sudo echo '#{public_key}' >> /home/vagrant/.ssh/authorized_keys
      sudo chmod -R 600 /home/vagrant/.ssh/id_rsa_cluster
      sudo chmod -R 600 /home/vagrant/.ssh/id_rsa_cluster.pub
      sudo chmod -R 600 /home/vagrant/.ssh/authorized_keys
      SCRIPT

    box.vm.provision "shell", inline: <<-SCRIPT
      echo '''Host *
        user vagrant
        IdentityFile /home/vagrant/.ssh/id_rsa_cluster
      ''' > /home/vagrant/.ssh/config
      sudo chown vagrant:vagrant /home/vagrant/.ssh/ -R
      SCRIPT

    box.vm.provision "shell", path: "controller/1_prepare_os.sh"
    box.vm.provision "shell", path: "controller/2_install_kolla.sh"
    box.vm.provision "shell", path: "controller/3_openstack_install.sh"
  end
end
