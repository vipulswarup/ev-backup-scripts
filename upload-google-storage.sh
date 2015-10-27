#copy file name from /opt/backup/bakfile.txt
value=$(</opt/backup/bakfile.txt)
echo "Bak file name is $value \n"
echo "Uploading $value"
#Copy backup to google cloud bucket
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp $value gs://ev-live-backup/

#Also zip up logs backup folder and upload to google cloud
timestamp="$(date +"%Y-%m-%d_%H-%M-%S")"
tar -cvf /opt/backup/logs_$timestamp.tar /opt/backup/logs
pigz --best /opt/backup/logs_$timestamp.tar
#delete previous backup
#copy file name from /opt/backup/log_bakfile.txt
old_bak_file_name=$(</opt/backup/log_bakfile.txt)
#echo "Deleting old log backup file: $old_bak_file_name"
#rm "$old_bak_file_name"

#write name of created file in a txt file for uploader script to pick up
echo "/opt/backup/logs_$timestamp.tar.gz" > /opt/backup/log_bakfile.txt

#Copy logs backup to google cloud bucket
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp "/opt/backup/logs_$timestamp.tar.gz" gs://ev-live-backup/

#Empty logs backup folder
rm /opt/backup/logs/*

