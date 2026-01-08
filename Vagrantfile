Vagrant.configure("2") do |config|
  nodes = {
    "controller" => { :ip => "192.168.121.10", :mem => 2048, :cpu => 2 },
    "worker-01"  => { :ip => "192.168.121.11", :mem => 1024, :cpu => 1 },
    "worker-02"  => { :ip => "192.168.121.12", :mem => 1024, :cpu => 1 }
  }

  config.vm.box = "generic/rocky9"

  ssh_pub_key = File.read(File.expand_path("~/.ssh/id_ed25519.pub"))

  nodes.each do |name, specs|
    config.vm.define name do |node|
      node.vm.hostname = name

      node.vm.network "private_network", 
        ip: specs[:ip], 
        netmask: "255.255.255.0"

      node.vm.provider :libvirt do |domain|
        domain.memory = specs[:mem]
        domain.cpus   = specs[:cpu]
        domain.driver = "kvm"
      end

      node.vm.provision "shell" do |s|
        s.inline = <<-SHELL
          echo "Configuring SSH access..."
          echo "$1" >> /home/vagrant/.ssh/authorized_keys
          chmod 600 /home/vagrant/.ssh/authorized_keys
        SHELL
        s.args = [ssh_pub_key.strip]
      end

    end
  end
end
