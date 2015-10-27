#alfresco dir passed as an argument
#if no dir passed, use /opt/alfresco
alfresco_dir=$1
if [ x$alfresco_dir = x"" ]; then 
	alfresco_dir="/opt/alfresco"
fi
echo "Using alfresco directory: $alfresco_dir"

#Turn on versioning for the bucket
gsutil versioning set on gs://ev-hot-backup-rsync
 
#rsync the current directory to our new bucket
#Adding -m to run multiple parallel processes (speed boost)
gsutil -m rsync -r -d /opt/alfresco gs://ev-hot-backup-rsync/opt_alfresco
gsutil -m rsync -r -d /opt/tenant_data gs://ev-hot-backup-rsync/tenant_data
