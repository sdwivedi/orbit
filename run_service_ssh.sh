#!/bin/bash

# This script first runs the ggp ssh init command to get the needed
# credentials to connect via ssh. Then it connects to the instance
# with portforwarding and starts OrbitService. To also deploy OrbitService,
# invoke with a the argument --deploy and a path to the OrbitService executable
# e.g. run_service_ssh.sh --deploy build/bin/OrbitService
# All other arguments will be passed to OrbitService.


if [ -z "$GGP_SDK_PATH" ]; then
  echo "Ggp sdk not found"
  exit 1
fi

GGP_EXEC="$GGP_SDK_PATH/dev/bin/ggp"

OTHER_ARGS="$@"
if [ ! -z "$1" ] && [ "$1" == "--deploy" ]; then
  $GGP_EXEC ssh put "$2"
  $GGP_EXEC ssh shell -- chmod u+x /mnt/developer/OrbitService
  OTHER_ARGS="${@:3}"
fi

OUTPUT=$(eval $GGP_EXEC ssh init | tee /dev/tty)

while IFS= read -r line; do
  if [[ $line == *"User:"* ]]; then
    GGP_USER=$(echo ${line/User:/} | sed -e 's/^[[:space:]]*//')
  fi
  if [[ $line == *"Host:"* ]]; then
    GGP_HOST=$(echo ${line/Host:/} | sed -e 's/^[[:space:]]*//')
  fi
  if [[ $line == *"Port:"* ]]; then
    GGP_PORT=$(echo ${line/Port:/} | sed -e 's/^[[:space:]]*//')
  fi
  if [[ $line == *"Key Path:"* ]]; then
    GGP_KEY_PATH=$(echo ${line/Key Path:/} | sed -e 's/^[[:space:]]*//')
  fi
  if [[ $line == *"Known Hosts Path:"* ]]; then
    GGP_KNOWN_HOSTS_PATH=$(echo ${line/Known Hosts Path:/} | sed -e 's/^[[:space:]]*//')
  fi
done <<< "$OUTPUT"

if [ -z "$GGP_USER" ] || [ -z "$GGP_HOST" ] || [ -z "$GGP_PORT" ] || [ -z "$GGP_KEY_PATH" ] || [ -z "$GGP_KNOWN_HOSTS_PATH" ]; then
  echo "Unable to get all necessary information from ggp ssh init"
  exit 1
fi

ssh -t -p"$GGP_PORT" -F/dev/null -i"$GGP_KEY_PATH" -oStrictHostKeyChecking=yes -oUserKnownHostsFile="$GGP_KNOWN_HOSTS_PATH" \
-L44766:localhost:44766 -L44765:localhost:44765 "$GGP_USER"@"$GGP_HOST" -- sudo /mnt/developer/OrbitService "$OTHER_ARGS"
