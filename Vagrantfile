Vagrant.configure("2") do |config|
    config.vm.box = "precise64"
    config.vm.box_url = "http://files.vagrantup.com/precise64.box"
    config.vm.network "forwarded_port", guest: 3000, host: 3000
    config.vm.network "forwarded_port", guest: 443, host: 443
    config.vm.network "forwarded_port", guest: 443, host: 8443
    config.vm.network "forwarded_port", guest: 5432, host: 5432


    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "chef-recipes"
      chef.roles_path = "chef-recipes/roles"
      chef.data_bags_path = "chef-recipes/data_bags"
      chef.add_recipe "myapp"
      #chef.add_role "web"
  
      # You may also specify custom JSON attributes:
      # chef.json = { :mysql_password => "foo" }
    end

    config.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", "2048", "--cpus", "2"]
    end

    # finally! escape from symlink hell when using npm install in /vagrant on vm
    # http://www.conroyp.com/2013/04/13/symlink-shenanigans-nodejs-npm-express-vagrant/
    # http://blog.liip.ch/archive/2012/07/25/vagrant-and-node-js-quick-tip.html
    #config.vm.customize ["setextradata", :id,
    #                     "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
end
