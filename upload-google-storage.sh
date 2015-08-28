#copy file name from /opt/backup/bakfile.txt
value=$(</opt/backup/bakfile.txt)
echo "Bak file name is $value \n"
echo "Uploading $value"
#Copy backup to google cloud bucket
gsutil cp $value gs://ev-live-backup/
