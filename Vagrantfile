Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.box_check_update = false

  machines = {
    "web01" => { ip: "192.168.56.11", memory: 768 },
    "app01" => { ip: "192.168.56.12", memory: 768 },
    "ops01" => { ip: "192.168.56.13", memory: 768 }
  }

  machines.each do |name, settings|
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network "private_network", ip: settings[:ip]
      node.vm.synced_folder ".", "/vagrant", disabled: true
      node.vm.provider "virtualbox" do |vb|
        vb.name = "ansible-lab-#{name}"
        vb.memory = settings[:memory]
        vb.cpus = 1
      end
    end
  end
end

