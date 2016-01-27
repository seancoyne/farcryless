# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"
  
  config.vm.hostname = "local.farcrylesstest.com"
  
  config.hostsupdater.remove_on_suspend = true

  config.vm.network "private_network", ip: "10.10.10.166"

  config.vm.synced_folder "./", "/var/www/farcry/plugins/farcryless"

  config.vm.provider "virtualbox" do |vb|
  	vb.name = "FarCry Less Dev"
		vb.memory = "2048"
  end
  
  config.vm.provision :chef_solo do |chef|
		chef.log_level = "info"
		chef.cookbooks_path = "./chef/cookbooks"
		chef.roles_path = "./chef/roles"
		chef.add_role "farcryless"
		chef.install = true
		chef.file_cache_path = "/vagrant/chef/cache"
	end

end