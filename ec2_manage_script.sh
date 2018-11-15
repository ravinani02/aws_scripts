#!/usr/bin/env bash

set -eu pipefail


function create() {
  image_id=$1
  instance_type=$2
  key_pair_name=$3
  elastic_ip_associate_id=$4

  instance_id=$(aws ec2 run-instances \
                  --count 1 \
                  --image-id $image_id \
                  --instance-type $instance_type \
                  --key-name $key_pair_name) \
                  --user-data metadata_dump.sh

  if [[ $? -eq 0 ]]; then
    aws ec2 associate-address --instance-id $instance_id --allocation-id $elastic_ip_associate_id
  fi



}

function start() {
  if [[ $(aws ec2 start-instances --instance-id $1) ]];
  then
    echo "Instance with id $1 Started successfully"
  else
    echo "Instance id $1 doesn't exist"
  fi
}


function stop() {
  if [[ $(aws ec2 stop-instances --instance-id $1) ]];
  then
    echo "Instance with id $1 Stopped successfully"
  else
    echo "Instance id $1 doesn't exist"
  fi
}

function restart() {
  if [[ $(aws ec2 restart-instances --instance-id $1) ]];
  then
    echo "Instance with id $1 Restarted successfully"
  else
    echo "Instance id $1 doesn't exist"
  fi
}



start 'i-0cafedd9546b15d7b'
