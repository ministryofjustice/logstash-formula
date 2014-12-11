# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "logstash", primary: true do |node|

    # mount salt required folders
    node.vm.synced_folder "../utils-formula/utils", "/srv/salt-formula/utils"
    node.vm.synced_folder "../redis-formula/redis", "/srv/salt-formula/redis"
    node.vm.synced_folder "../java-formula/java", "/srv/salt-formula/java"
    node.vm.synced_folder "../firewall-formula/firewall", "/srv/salt-formula/firewall"
    node.vm.synced_folder "../bootstrap-formula/bootstrap", "/srv/salt-formula/bootstrap"
    node.vm.synced_folder "../apparmor-formula/apparmor", "/srv/salt-formula/apparmor"
    node.vm.synced_folder "../python-formula/python", "/srv/salt-formula/python"
    node.vm.synced_folder "../elasticsearch-formula/elasticsearch", "/srv/salt-formula/elasticsearch"
    node.vm.synced_folder "../nginx-formula/nginx", "/srv/salt-formula/nginx"

    node.vm.synced_folder "logstash", "/srv/salt-formula/logstash"
    node.vm.synced_folder "vagrant/salt/pillar", "/srv/pillar"
    node.vm.synced_folder "vagrant/salt/root", "/srv/salt"

    node.vm.box = "mikepea/precise64_bigpkg_salt"
    node.vm.hostname = "logstash"

    node.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--memory", "1024"]
      v.name = "logstash"
    end

    node.vm.provision :salt do |salt|

      salt.verbose = true
      salt.minion_config = "vagrant/salt/minion"
      salt.run_highstate = true

    end

  end

end
