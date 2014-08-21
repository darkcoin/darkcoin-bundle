REQS = git apache2 python-vm-builder ruby debootstrap lxc apt-cacher-ng \
	virt-what lxctl fakeroot faketime zip unzip subversion bridge-utils

.PHONY: all hostvm drkb

all: hostvm drkb

hostvm:
	vagrant destroy --force
	vagrant up
	vagrant ssh --command "sudo apt-get update"
	
	# https://github.com/mitchellh/vagrant/issues/289
	vagrant ssh --command "sudo DEBIAN_FRONTEND=noninteractive \
		apt-get upgrade -y"
	
	vagrant reload
	vagrant ssh --command "sudo apt-get install -y $(REQS)"
	vagrant halt

drkb:
	vagrant up
	vagrant ssh --command "\
		if [ -d ~/gitian-builder ]; then \
			rm -rf ~/gitian-builder; \
		fi"
	
	vagrant ssh --command "git clone -b master \
		'https://github.com/darkcoin/gitian-builder.git' ~/gitian-builder"
	
	vagrant ssh --command "\
		if [ -d ~/darkcoin-bundle ]; then \
			rm -rf ~/darkcoin-bundle; \
		fi"
	
	vagrant ssh --command "\
		rsync -r --exclude=.vagrant \
		/darkcoin-bundle/ ~/darkcoin-bundle"
	
	vagrant ssh --command "cd ~/darkcoin-bundle/gitian && USE_LXC=1 make"
	
	vagrant ssh --command "cd ~/darkcoin-bundle/gitian && \
		cp -R 3.* /vagrant/"
	
	vagrant halt
