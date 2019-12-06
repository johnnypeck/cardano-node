#!/usr/bin/env bash

if [ -e configuration/GenesisFiles/ ]
then
    :
else
    echo "configuration/GenesisFiles/GENHASH does not exist"
	./scripts/genesis.sh
fi



RUNNER=${RUNNER:-cabal run -v0 --}


genesis_hash="$(echo $(<configuration/GenesisFiles/GENHASH))"
genesis_root="../cardano-node/configuration/GenesisFiles"
genesis_file="${genesis_root}/genesis.json"

from_addr="2cWKMJemoBain3UWCzSY5wZvcf8uQ2MAaSy8hedrwpqsbYCm4QnBgPn3cEH7KF3X7DKoZ"
from_key="${genesis_root}/delegate-keys.000.key"
default_to_key="${genesis_root}/delegate-keys.001.key"

## ADA to be spent
default_lovelace="863000000000000"

case $# in
        1 ) tx="$1"
            proto_magic="$(jq '.protocolConsts | .protocolMagic' "${genesis_file}")"
            addr="$(scripts/get-default-key-address.sh ${default_to_key})"
            lovelace=${default_lovelace};;
        3 ) tx="$1";
            addr="$2";
            lovelace="$3";;
        * ) cat >&2 <<EOF
Usage:  $(basename $0) TX-FILE TO-ADDR LOVELACE
EOF
            exit 1;; esac

args=" --real-pbft
       --genesis-file        ${genesis_file}
       --genesis-hash        ${genesis_hash}
       issue-genesis-utxo-expenditure
       --tx                  ${tx}
       --wallet-key          ${from_key}
       --rich-addr-from    \"${from_addr}\"
       --txout            (\"${addr}\",${lovelace})
     "
set -x
${RUNNER} cardano-cli ${args}
