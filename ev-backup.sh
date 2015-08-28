#alfresco dir passed as an argument
#if no dir passed, use /opt/alfresco
alfresco_dir=$1
if [ x$alfresco_dir = x"" ]; then 
	alfresco_dir="/opt/alfresco"
fi
echo "Using alfresco directory: $alfresco_dir"

#check for pigz - multi threaded zip utility
apt-get install pigz

#stop Alfresco
#$alfresco_dir/alfresco.sh stop

#start postgre sql
#/opt/alfresco/postgresql/scripts/ctl.sh start

#make backup directory with today's timestamp
timestamp="$(date +"%Y-%m-%d_%H-%M-%S")"
bak_folder=/opt/backup/ev_backup
mkdir /opt/backup
mkdir $bak_folder

#Dump Alfresco DB to SQL File:
$alfresco_dir/postgresql/bin/pg_dump alfresco > $bak_folder/alfresco-backup.sql

#Stop PostgreSQL:
#$alfresco_dir/postgresql/scripts/ctl.sh stop

#Copy Alfresco Install Folder to Backup Location:
#cp -R $alfresco_dir/alf_data/ $bak_folder
rsync -a -v $alfresco_dir/alf_data/contentstore $bak_folder/ #-- this copies everything except files with no changes
rsync -a -v $alfresco_dir/alf_data/contentstore.deleted $bak_folder/ #-- this copies everything except files with no changes
rsync -a -v $alfresco_dir/alf_data/keystore $bak_folder/ #-- this copies everything except files with no changes
rsync -a -v $alfresco_dir/alf_data/postgresql $bak_folder/ #-- this copies everything except files with no changes
rsync -a -v $alfresco_dir/alf_data/solr4Backup $bak_folder/ #-- this copies everything except files with no changes

#Start Alfresco
#$alfresco_dir/alfresco.sh start &

#zip the backup
tar -cvf /opt/backup/ev_bak_$timestamp.tar $bak_folder
pigz --best /opt/backup/ev_bak_$timestamp.tar
