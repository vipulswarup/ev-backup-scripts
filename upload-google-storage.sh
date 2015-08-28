#Copy backup to google cloud bucket
gsutil cp /opt/backup/ev_bak_$timestamp.tar.gz gs://ev-live-backup/
