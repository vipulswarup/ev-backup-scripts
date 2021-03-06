#!/usr/bin/perl
use strict;
use warnings;
use File::stat;
use Time::localtime;
use Time::Local;
use File::Copy;

#Get today's midnight
my $year=localtime->year() + 1900;
my $month=localtime->mon();
my $day=localtime->mday();

my $midnight=timelocal(0,0,0,$day,$month,$year);
my $midnight_friendly=ctime($midnight);

print "Today's midnight was $midnight_friendly\n";
print "Going to clean up Alfresco Log files \n";

my $num_args = $#ARGV + 1;
if ($num_args != 1) {
    print "\nUsage: cleanup-log-files.pl path_to_alfresco \n";
    exit;
}

my $alf_dir=$ARGV[0];
print "Cleaning logs under: ".$alf_dir."\n";
my $tc_logs=$alf_dir."/tomcat/logs";
my $log_bak_dir="/opt/backup/logs".$alf_dir;

print "Alfresco Directory being used: ".$alf_dir."\n";
print "Tomcat Log Directory being used: ".$tc_logs."\n";

#If /opt/backup/logs doesn't exist, then create it
if (not -d $log_bak_dir){
	print "Creating directory: ".$log_bak_dir."\n";
	mkdir $log_bak_dir;
}

#Delete any old log files from target directory
system("rm $log_bak_dir/*");

#Move all log files less than 1 month old (except for current files) to backup
#Current files are those that have been modified today


# first process every log file under $alf_dir
opendir(DIR, $alf_dir) or die $!;

while (my $file = readdir(DIR)) {
        # Use a regular expression to ignore files beginning with a period
        next if ($file =~ m/^\./);
	# Similarly ignore files that don't have the word ".log" inside their file names	
	next unless ($file =~ m/\.log.*$/);
	my $full_file_name=$alf_dir."/".$file;
	checkAndArchive($full_file_name,$file);

    }

closedir(DIR);



#Now process files under $tc_logs
opendir(DIR, $tc_logs) or die $!;

while (my $file = readdir(DIR)) {
        # Use a regular expression to ignore files beginning with a period
        next if ($file =~ m/^\./);

	my $full_file_name=$tc_logs."/".$file;
	checkAndArchive($full_file_name,$file);

    }

closedir(DIR);

exit 0;

#Function for checking and archiving a file
sub checkAndArchive {

	
	my ($file_to_archive)=(@_)[0];
	my ($file_name)=(@_)[1];

	#Get file modified time
	my $modtime=stat($file_to_archive)->mtime;
	
	#Get user friendly representation of modified time
	my $modtime_friendly=ctime($modtime);
	
	# If file was modified before the last midnight
	if ($modtime<$midnight){

		print "Will archive file: $file_to_archive"."-- Last modified at:".$modtime_friendly."\n";
		print "Moving it to $log_bak_dir/$file_name \n";		
		move ($file_to_archive,"$log_bak_dir/$file_name");
	}

}


