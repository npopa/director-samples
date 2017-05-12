#!/usr/local/bin/bash -x
#

#This script is based on https://github.com/cloudera/director-scripts


# Bash 4+ required
if (( ${BASH_VERSION%%.*} < 4 )); then
  echo "bash 4 or higher is required. The current version is ${BASH_VERSION}."
  exit 1
fi

# Prints out a usage statement
usage()
{
  cat << EOF
This script will create a new AMI and preload it with CDH parcels to speed up
bootstrapping time for Cloudera Director.

You must ensure AWS credentials are available in the environment for this to
work properly. Please refer to Packer documentation here:
https://www.packer.io/docs/builders/amazon-ebs.html.

Extra packer options can be provided in the PACKER_VARS environment variable
prior to executing this script.

Usage: $0 [options] 

OPTIONS:
  -h
    Show this help message
  -a <ami-info>
    Use a specific base AMI
  -d
    Run packer in debug mode

For the -a option, specify for <ami-info> a quoted string with the following
elements, separated by spaces:

  ami-id "pv"|"hvm" ssh-username root-device-name

Example: -a "ami-00000000 hvm centos72 /dev/sda1"

EOF
}

AMI_OPT=
DEBUG=
JAVA_VERSION=1.7
JDK_REPO=Director
PRE_EXTRACT=
PUBLIC_IP=
while getopts "a:dj:J:pPh" opt; do
  case $opt in
    d)
      DEBUG=1
      ;;
    h)
      usage
      exit
      ;;
    ?)
      usage
      exit
      ;;
  esac
done
shift $((OPTIND - 1))

if ! hash packer 2> /dev/null; then
    echo "Packer is not installed or is not on the path. Please correct this before continuing."
else
    echo "Found packer version: $(packer version)"
fi

# Gather arguments into variables
AWS_REGION=${AWS_REGION}
NAME=AUTO
CDH_URL=${CDH_REPO}
CM_REPO_URL=${CM_REPO}

echo "Using AMI ${AMI_INFO[0]} for OS $OS"

AMI=${AWS_AMI_ID}
USERNAME=${SSH_USERNAME}
ROOT_DEVICE_NAME="/dev/sda"


# Set up packer variables
PACKER_VARS_ARRAY=( $PACKER_VARS )
PACKER_VARS_ARRAY+=(-var "region=$AWS_REGION")
PACKER_VARS_ARRAY+=(-var "ami=$AMI")
PACKER_VARS_ARRAY+=(-var "ami_virtualization_type=pv")
PACKER_VARS_ARRAY+=(-var "ssh_username=$USERNAME")
PACKER_VARS_ARRAY+=(-var "root_device_name=$ROOT_DEVICE_NAME")
PACKER_VARS_ARRAY+=(-var "ami_prefix=$NAME")


# Set up other packer options
PACKER_OPTS=()
if [[ -n $DEBUG ]]; then
  PACKER_OPTS+=(-debug)
fi

JSON=packer_rhel.json

packer build "${PACKER_VARS_ARRAY[@]}" "${PACKER_OPTS[@]}" "$JSON"
