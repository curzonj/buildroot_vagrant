Vagrant.configure("2") do |config|
  config.vm.box = "precise"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.synced_folder "./", "/vagrant"
  config.vm.provision :shell, :path => "build.sh"

  config.vm.provider "virtualbox" do |v|
    # Make us faster
    v.customize [ "modifyvm", :id, "--memory", "512", "--cpus", "1" ]
    v.customize ['storagectl', :id, '--name', 'SATA Controller', '--hostiocache', 'on']
    v.customize ['storagectl', :id, '--name', 'SATA Controller', '--controller', 'IntelAHCI']
    v.customize ['modifyvm', :id, "--chipset", "ich9"]

    v.customize ["createhd", '--filename', 'ubuntu_core.vdi', '--size', 40960] # 40GB sparse root
    v.customize ["storageattach", :id, "--storagectl", "SATA Controller", '--port', 1, '--device', 0, '--type', 'hdd', '--medium', 'ubuntu_core.vdi' ]
  end
end
