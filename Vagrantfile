# -*- mode: ruby -*-
# vi: set ft=ruby :

computeNodes = {
  'compute1' => {'hostname' => 'compute1'},
  'compute2' => {'hostname' => 'compute2'}
}

Vagrant.configure("2") do |config|
  # get our pre-generated ssh keys
  if Dir.exist?('sshkeys') 
    public_key = File.read("sshkeys/id_rsa.pub")
    private_key = File.read("sshkeys/id_rsa")
  end
 

  #config.vm.box = "centos/8"
  config.vm.box = "centos/stream8"
  # ensure our hosts can resolve themselfs via hostnames 
  config.vm.network "private_network", type: "dhcp"
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = false
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
    if vm.id
      read_ip_address(vm)
    end
  end

  # setup the compute nodes first
  computeNodes.keys.sort.each do |key|
    hostname = computeNodes[key]['hostname']
    config.vm.define hostname do |box|
      box.vm.provider :virtualbox do |vb|
        vb.memory = 2048
        vb.cpus = 2
        vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
      end
      box.vm.host_name = hostname
      
      # deploy the ssh key of controller
      box.vm.provision "shell", inline: <<-SCRIPT
        sudo mkdir -p /root/.ssh
        sudo chmod u=rwx,g=,o= /root/.ssh
        sudo echo '#{public_key}' >> /root/.ssh/authorized_keys
        sudo chmod -R 600 /root/.ssh/authorized_keys
        SCRIPT

      box.vm.provision "shell", path: "compute/1_centos_prepare.sh"
      #box.vm.provision "shell", path: "sudo hostnamectl set-hostname #{hostname}"
    end
  end
  
  config.vm.define :controller do |box|
    box.vm.provider :virtualbox do |vb|
      vb.memory = 3048
      vb.cpus = 3
    end
    box.vm.host_name = "controller"
    #box.vm.network "forwarded_port", guest: 80, host: 8080
    #box.vm.network "forwarded_port", guest: 2616, host: 2616
  
    hostname = "controller"

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

    # install opennebula via minione
    box.vm.provision "shell", path: "controller/1_centos_prepare.sh"
    #box.vm.provision "shell", path: "sudo hostnamectl set-hostname #{hostname}"
    box.vm.provision "shell", path: "controller/2_prepare_packstack.sh"
    box.vm.provision "shell", path: "controller/3_openstack_install.sh"


    # ensure our ssh keys are properly picked up
    #box.vm.provision "shell", inline: "sudo systemctl restart opennebula-ssh-agent.service"
  end
end

$logger = Log4r::Logger.new('vagrantfile')
def read_ip_address(machine)
  command =  "ip a | grep 'inet' | grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $2 }' | cut -f1 -d\"/\""
  result  = ""

  $logger.info "Processing #{ machine.name } ... "

  begin
    # sudo is needed for ifconfig
    machine.communicate.sudo(command) do |type, data|
      result << data if type == :stdout
    end
    $logger.info "Processing #{ machine.name } ... success"
  rescue
    result = "# NOT-UP"
    $logger.info "Processing #{ machine.name } ... not running"
  end

  # the second inet is more accurate
  result.chomp.split("\n").select { |hash| hash != "" }[1]
end