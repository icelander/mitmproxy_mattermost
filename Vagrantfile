# -*- mode: ruby -*-
# vi: set ft=ruby :

MATTERMOST_VERSION = "5.18.0"
ROOT_PW = 'mysql_root_password'
MMST_PW = 'really_secure_password'

# my_conf = YAML.load(File.open('conf.yaml').read)

Vagrant.configure("2") do |config|
  config.vm.box = 'bento/ubuntu-18.04'
  config.vm.network "forwarded_port", guest: 8065, host: 8065
  config.vm.network "forwarded_port", guest: 3306, host: 13306
  config.vm.network "forwarded_port", guest: 8081, host: 8081
  config.vm.hostname = 'mattermost'

  config.vm.provision :shell do |s|
    s.path = 'mitmproxy_setup.sh'
  end

  config.vm.provision :shell do |s|
    s.path = 'setup.sh'
    s.args   = [MATTERMOST_VERSION,
                ROOT_PW, 
                MMST_PW]
  end

end