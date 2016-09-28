#!/bin/bash

###This script is used to mirror the jenkins jobs log on RackHD Jenkins to cloud
set -e
set -x

sync_files(){
    local files_number=0
    rm -rf rsync_log
    rsync "$@" 2>&1|tee rsync_log
    files_number=$(cat rsync_log |awk '/Number of regular files transferred/{print $NF}')
    echo "$files_number"
}

#start to pull jobs in jenkins server to jump server
opt="-ravzh --stats --exclude Maglev-BRI-Test --exclude sandbox"

#current jobs in jenkins server
source1=${JENKINS_JOBS-jenkins@rackhdci.lss.emc.com:/var/lib/jenkins/jobs/}
#old builds of jobs in jenkins server
source2=${JENKINS_JOBS_BUILDS-jenkins@rackhdci.lss.emc.com:/mnt/nfsroot/var/lib/jenkins/jobs/}
#destination directory of jumper server
dest=${JUMPER_DIR-/var/lib/jenkins/jobs}
case $dest in
    */)dest=${dest%/};;
esac


sync_files $opt $source1 $dest
sync_files $opt $source2 $dest

#cloud host username:ip
cloud_host=${CLOUD_HOST-root@147.178.202.18}
#directory of jobs on cloud
cloud_jobs=${CLOUD_JOBS-jenkins@147.178.202.18:/var/lib/jenkins/jobs}
dest="${dest}/"

sync_files $opt $dest $cloud_jobs


#if any file is transfered to cloud, the jenkins service should be force reload
#if [ "$files_transfered" -gt 0 ];
#then
#    ssh $cloud_host "service jenkins force-reload"
#fi
