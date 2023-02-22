#!/bin/bash

KEYVAULT_NAME=kv-saas-westeurope-dev
NATS_SERVER=20.101.205.253:4222
OPERATOR=external

## set the path to your pem files according your configuration
export NATS_CERT=./client.pem
export NATS_KEY=./client-key.pem
export NATS_CA=./ca.pem

if [ $# -eq 0 ]
  then
    echo "[Error] please, supply an account name. Usage ./add_nats_account_and_user.sh account"
    exit
fi
if [[ $1 == *['!'_+]* ]]
then
  echo "[ERROR] invalid character in the account name. Must conform to the following pattern: '^[0-9a-zA-Z-]+$'."
  exit
fi

echo Account to proccess: "$1"

#generating user
SECRET_MAME=$1-nats-account
ACCOUNT=$1
USER=$1-user
SECRET_VALUE=account:"$ACCOUNT",user:"$USER"
echo creating secret: "$SECRET_MAME"
echo with account mame: "$ACCOUNT"
echo and user: "$USER"
# echo secret value="$SECRET_VALUE"

echo
echo creating secret in keyvault with account and user
echo adding_keyVault_secret="$SECRET_MAME"
echo adding_keyvault_value="$SECRET_VALUE"
# echo az keyvault secret set --vault-name "${KEYVAULT_NAME}" --name "${SECRET_MAME}" --value "${SECRET_VALUE}"

az keyvault secret set --vault-name "${KEYVAULT_NAME}" --name "${SECRET_MAME}" --value "${SECRET_VALUE}"

## if it's necessary to create an operator uncomment these lines and set OPERATOR var
## with the desired name for the operator

# nsc add operator --generate-signing-key --sys --name ${OPERATOR}
# nsc edit operator --require-signing-keys --account-jwt-server-url "nats://${NATS_SERVER}"

# creating NATS account
echo
echo creating NATS account
nsc add account "${ACCOUNT}"
nsc edit account "${ACCOUNT}" --sk generate

# creating NATS user
echo
echo creating NATS user
nsc add user --account "${ACCOUNT}" "${USER}"
nsc generate creds -n "${USER}" > "${USER}".creds

# saving context
echo
echo saving context
nats context save externalServer --server "nats://${NATS_SERVER}" --nsc nsc://${OPERATOR}/${ACCOUNT}/${USER}

nsc edit account --name "${ACCOUNT}" --js-mem-storage -1 --js-disk-storage -1 --js-streams -1 --js-consumer -1

# pushing account to the server
echo
echo pushing account to the server via TLS using certificate configuration set in NATS_CERT, NATS_KEY and NATS_CA
echo NATS_CERT=${NATS_CERT}
echo NATS_KEY=${NATS_KEY}
echo NATS_CA=${NATS_CA}

nsc push -A

