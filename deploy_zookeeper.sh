#!/bin/sh

# get the list of all host
count=0
hostFile=$1
finalCfgFile="./zoo.cfg"
templateCfgFile="./zoo_template.cfg"
pathToZookeekerRoot="./zookeeper"
zipFile=${pathToZookeekerRoot}.zip
preSftpCommand="pre_sftp_command"
sftpCommand="sftp_command"
sshCommand="ssh_command"
sshCommandId="ssh_commandId"
zookeeperDataDir="./data"

cat $templateCfgFile > $finalCfgFile
echo "dataDir=$zookeeperDataDir" >> $finalCfgFile

# edit the config file of zookeeper
while read line 
do
	set $line
	ip=$1
	echo "server.$count=$ip:2888:3888" >> $finalCfgFile
	count=`expr $count + 1`
done < $hostFile

count=0
cp $finalCfgFile $pathToZookeekerRoot/conf/$finalCfgFile
zip -r $zipFile $pathToZookeekerRoot > /dev/null

# Create pre sftp command
echo "./zkServer.sh stop" >> $preSftpCommand
echo "rm -rf $pathToZookeekerRoot"  > $preSftpCommand

# Create sftp command
echo "put $zipFile"  > $sftpCommand

# Create ssh command
echo "unzip $zipFile"  > $sshCommand
echo "rm $zipFile"  >> $sshCommand

while read line 
do
	set $line
	ip=$1
	loginId=$2
	password=$3
	sshpass -p "$password" ssh ${loginId}@${ip} < $preSftpCommand > /dev/null
	sshpass -p "$password" sftp ${loginId}@${ip} < $sftpCommand > /dev/null
	sshpass -p "$password" ssh ${loginId}@${ip} < $sshCommand > /dev/null
	echo "mkdir ./zookeeper/bin/data/" > $sshCommandId
	echo "echo $count > ./zookeeper/bin/data/myid" >> $sshCommandId
	echo "cd ./zookeeper/bin/" >> $sshCommandId
	echo "chmod 700 *" >> $sshCommandId
	echo "./zkServer.sh start" >> $sshCommandId
	sshpass -p "$password" ssh ${loginId}@${ip} < $sshCommandId > /dev/null
	count=`expr $count + 1`
done < $hostFile

rm $zipFile
rm $sshCommand
rm $sftpCommand
rm $finalCfgFile
rm $sshCommandId
