#!/bin/bash
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# builds the config for the scitt container to then run
# run from the root of the repository

set -e -x

PLATFORM=${PLATFORM:-snp}
CCF_HOST=${CCF_HOST:-"localhost"}
CCF_PORT=${CCF_PORT:-8000}
CCF_URL="https://${CCF_HOST}:${CCF_PORT}"

DOCKER_TAG=${DOCKER_TAG:-"scitt-$PLATFORM"}
CONTAINER_NAME=${CONTAINER_NAME:-"scitt-dev-$(date +%s)"}

WORKSPACE=${WORKSPACE:-"workspace/"}

VOLUME_NAME="${CONTAINER_NAME}-vol"

# SNP attestation config
SNP_ATTESTATION_CONFIG=${SNP_ATTESTATION_CONFIG:-}

rm -rf "$WORKSPACE"
mkdir -p "$WORKSPACE"

cp ./pf-demo/dev-config.tmpl.json "$WORKSPACE"/dev-config.json
if [ "$PLATFORM" = "virtual" ]; then
    enclave_platform="Virtual"
    enclave_type="Virtual"
    enclave_file="libscitt.virtual.so"
    DOCKER_FLAGS=()
elif [ "$PLATFORM" = "snp" ]; then
    enclave_platform="SNP"
    enclave_type="Release"
    enclave_file="libscitt.snp.so"
    DOCKER_FLAGS=()
else 
    echo "Unknown platform: $PLATFORM, must be 'virtual', or 'snp'"
    exit 1
fi
sed -i "s/%ENCLAVE_PLATFORM%/$enclave_platform/g" "$WORKSPACE"/dev-config.json
sed -i "s/%ENCLAVE_TYPE%/$enclave_type/g" "$WORKSPACE"/dev-config.json
sed -i "s/%ENCLAVE_FILE%/$enclave_file/g" "$WORKSPACE"/dev-config.json
sed -i "s/%CCF_PORT%/$CCF_PORT/g" "$WORKSPACE"/dev-config.json

if [ "$PLATFORM" = "snp" ]; then
    if [ -f "$SNP_ATTESTATION_CONFIG" ]; then
        SNP_ATTESTATION_CONTENT=$(jq '.' "$SNP_ATTESTATION_CONFIG")
        jq --argjson content "$SNP_ATTESTATION_CONTENT" '.attestation = $content' "$WORKSPACE"/dev-config.json > tmp.json && mv tmp.json "$WORKSPACE"/dev-config.json
    else
        echo "SNP attestation config file not found or not set: $SNP_ATTESTATION_CONFIG"
        exit 1
    fi
fi

cp -r ./app/constitution "$WORKSPACE"

echo "Generate keys"
KEYGEN=$(pwd)/pf-demo/keygenerator.sh
pushd "$WORKSPACE"
$KEYGEN --name member0 --gen-enc-key
popd