Vagrant.configure("2") do |config|
  config.vm.box = "precise"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.ssh.forward_agent = true

  config.vm.synced_folder "./", "/vagrant"
  config.vm.provision :shell, :inline => "sudo -u vagrant /vagrant/build.sh"

  config.vm.provider "virtualbox" do |v|
    # Make us faster
    v.customize [ "modifyvm", :id, "--memory", "1536", "--cpus", "2" ]
    v.customize ['storagectl', :id, '--name', 'SATA Controller', '--hostiocache', 'on']
    v.customize ['storagectl', :id, '--name', 'SATA Controller', '--controller', 'IntelAHCI']
    v.customize ['modifyvm', :id, "--chipset", "ich9"]

    v.customize ["createhd", '--filename', 'busybox_os.vdi', '--size', 50]
    v.customize ["storageattach", :id, "--storagectl", "SATA Controller", '--port', 1, '--device', 0, '--type', 'hdd', '--medium', 'busybox_os.vdi' ]
  end
end
