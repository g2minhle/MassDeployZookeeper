MassDeployZookeeper
===================

A script to deploy a lager number of Zookeeper instance at one time

deploy_zookeeper.sh : Deploy Zookeeper to all the given machine via ssh and sftp


$1 : The path to the file listing all the host, login id and password.
	Format : <ip> <login id> <password>


Note : In order to make the script works, please have a copy of the zookeeper binary in
	the same folder as the script. ie : ./deploy_zookeeper.sh ; ./zookeeper/bin/


Author : lehoangminh@live.com
