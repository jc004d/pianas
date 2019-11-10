#!/usr/bin/env bash
#
# Enable port forwarding when using Private Internet Access
#
# Usage:
#  ./port_forwarding.sh

error( )
{
  echo "$@" 1>&2
  exit 1
}

error_and_usage( )
{
  echo "$@" 1>&2
  usage_and_exit 1
}

usage( )
{
  echo "Usage: `dirname $0`/$PROGRAM"
}

usage_and_exit( )
{
  usage
  exit $1
}

version( )
{
  echo "$PROGRAM version $VERSION"
}

write_output_to_file( )
{ echo "writing output to $2"
  output=$1
  file=$2
  echo `jq "$output"` > $file 1>&2
}

port_forward_assignment( )
{
  echo 'Loading port forward assignment information...'
  if [ "$(uname)" == "Linux" ]; then
    client_id=`head -n 100 /dev/urandom | sha256sum | tr -d " -"`
  fi
  if [ "$(uname)" == "Darwin" ]; then
    client_id=`head -n 100 /dev/urandom | shasum -a 256 | tr -d " -"`
  fi
  if [ "$(uname)" == "FreeBSD" ]; then
    client_id=`head -n 100 /dev/urandom | sha | tr -d " -"`
  fi

  json=`curl "http://209.222.18.222:2000/?client_id=$client_id" 2>/dev/null`
  if [ "$json" == "" ]; then
    echo "Port forwarding is already activated on this connection, has expired, or you are not connected to a PIA region that supports port forwarding"
  elif [ "$#" -eq 0 ]; then
    echo "$json"
  else
    write_output_to_file "$json" $1
  fi
}

EXITCODE=0
PROGRAM=`basename $0`
VERSION=2.1

while test $# -gt 0
do
  case $1 in
  --usage | --help | -h )
    usage_and_exit 0
    ;;
  --version | -v )
    version
    exit 0
    ;;
  -o) 
    port_forward_assignment $2
    exit 0;; 
  --output*) 
    o=`echo "$1" | cut -d'=' -f2 | xargs`
    port_forward_assignment $o
    exit 0;;
  *)
    error_and_usage "Unrecognized option: $1"
    ;;
  esac
  shift
done

port_forward_assignment

exit 0