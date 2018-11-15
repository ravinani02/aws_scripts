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
                  --key-name $key_pair_name \
                  | grep InstanceId | cut -d":" -f2 | cut -d'"' -f2)

                #  --user-data ./metadata_dump.sh
  while [[ 1 ]]; do
    status=$(aws ec2 describe-instances --instance-ids $instance_id | jq -r '.Reservations[0].Instances[0].State.Name')
    if [[ "$status" = 'running' ]]; then
        break
    fi
    sleep 1
  done

  if [[ $? -eq 0 ]];
  then
    aws ec2 associate-address --instance-id $instance_id --allocation-id $elastic_ip_associate_id
  else
    echo "Can't associate $elastic_ip_associate_id to instance $instance_id"
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


create 'ami-0ac019f4fcb7cb7e6' 't2.micro' 'kovikey' 'eipalloc-0ca1bc05'
#stop 'i-0cafedd9546b15d7b'
