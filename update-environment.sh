#! /bin/sh
#
# SPDX-FileCopyrightText: Copyright (c) 2024-2025 Confluent Inc.
# SPDX-License-Identifier: Apache-2.0
#

# Script safety options
set -o errexit
set -o nounset
# Set pipefail if it works in a subshell, disregard if unsupported
# shellcheck disable=SC3040
(set -o pipefail 2> /dev/null) && set -o pipefail

# Bugfix: "data" directory may be created by `docker compose` but even in that case,
# it is created with insufficient permissions for the Kafka Connect exercise.
sudo install -m 777 -o training -g users -d "$HOME/confluent-admin/data"

# Set up some local variables
VARFILE="$HOME/.cpvars" # Where we're writing CP- & Kafka-related values
# shellcheck disable=SC2088
PRINTVARFILE="~/$(basename "$VARFILE")"
BRC="$HOME/.bashrc"
DOCKERFILE="$HOME/confluent-admin/compose.yaml"

# Function to get a parameter from the environment of the Docker compose file
get_env_param() {
    grep -m1 "$2": "$1" 2>/dev/null | sed 's/^[^:]*: //';
}

# Find CLUSTER_ID or bail on Docker compose file errors
CLUSTERID=$(get_env_param "$DOCKERFILE" 'CLUSTER_ID')
if [ -z "$CLUSTERID" ] ; then
  echo "Error: $DOCKERFILE doesn't exist or it doesn't define CLUSTER_ID. Exiting"
  exit 1
fi

# Find CONTROLLER_QUORUM_VOTERS or bail on Docker compose file errors
CONTROLLERS=$(get_env_param "$DOCKERFILE" 'KAFKA_CONTROLLER_QUORUM_VOTERS')
if [ -z "$CONTROLLERS" ] ; then
  echo "Error: $DOCKERFILE doesn't exist or it doesn't define KAFKA_CONTROLLER_QUORUM_VOTERS. Exiting"
  exit 1
fi

# Create and populate the file with relevant CP variables
if [ ! -f "$VARFILE" ] ; then
cat <<EOF >"$VARFILE"
export CLUSTERID=$CLUSTERID
export CONTROLLERS="$CONTROLLERS"
export BOOTSTRAPS="kafka-1:19092,kafka-2:29092,kafka-3:39092"
EOF
fi

if [ -f "$BRC" ] ; then
    # Make the shell (assumed to be Bash) to source our variables on start-up
    # First, test if it's already been done
    if grep -qxF "source $VARFILE" "$BRC" ; then
        echo "Startup already set-up. To add the variables to this terminal, please run:"
        echo "source $PRINTVARFILE"
        echo ""
        exit 0
    fi
else
   # No Bash, no luck
   echo "No .bashrc found for current user. If login shell has been set up differently, please configure the corresponding login file and/or source this file in all your shells:"
   echo "source $PRINTVARFILE"
   echo ""
   exit 0
fi

# Really do make bash source our variables on start-up
echo "source $PRINTVARFILE" >>"$BRC"
cat <<EOF
To add the variables to a terminal that is already opened (like this one), please run:
source $PRINTVARFILE
For terminals opened from this point onwards, the variables will be automatically added.

EOF
