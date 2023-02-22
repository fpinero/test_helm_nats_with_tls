#!/bin/bash

NATS_SERVER=20.101.205.253:4222
OPERATOR=external

if [ $# -lt 2 ]
  then
    printf "[Error] please, supply a json file to use for creating Stream and its subjects and also supply the json files for the consumers.
Take a look at the provided examples files example-StreamConf.json and example-consumer-post.json"
    exit
fi

## set the path to your pem files according your configuration
echo
echo setting TLS environment
export NATS_CERT=./client.pem
export NATS_KEY=./client-key.pem
export NATS_CA=./ca.pem

echo NATS_CERT=${NATS_CERT}
echo NATS_KEY=${NATS_KEY}
echo NATS_CA=${NATS_CA}

# parsing json file
echo
echo parsing stream file
echo Consumer to add:
CONSUMER=$(jq .name "$1" | tr -d '"')
echo "$CONSUMER"
echo subjects to add:
jq .subjects "$1"

# showing current context
echo
echo current context is:
nats context info
echo ---------------------------
echo if you want to use other context press ctrl+C, if you are agree with this context wait for 10 secs, please
echo ---------------------------
sleep 10
echo context is valid

# adding stream
echo
echo adding stream
nats stream add --config "$1"

# adding consumers
echo
echo adding consumers
streamprocessed=$1
for con in "$@"
do
    if [ "$streamprocessed" != "$con" ]
     then
       echo --------------------------------
       echo processing consumer file="$con"
       echo --------------------------------
       nats consumer add "$CONSUMER" --config "$con"
    fi
done




