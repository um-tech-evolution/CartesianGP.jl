# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/trusty64"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # This creates two machines, one called "releases" and one called
  # "nightlies". They run, unsurprisingly, the release and nightly
  # versions of Julia, respectively.
  ["releases", "nightlies"].each do |version|
    config.vm.define version do |node|
      config.vm.provision "shell", inline: <<-SHELL
        sudo add-apt-repository ppa:staticfloat/julia-deps -y
        sudo add-apt-repository ppa:staticfloat/julia#{version} -y
        sudo apt-get update -qq -y
        sudo apt-get install julia -y
        julia -e 'Pkg.init(); Pkg.clone("/vagrant", "CartesianGP")'
      SHELL

    end
  end
end
