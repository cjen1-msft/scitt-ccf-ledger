#!/usr/bin/env bash
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

source venv/bin/activate

timeout=15
while ! curl -s -f -k "$CCF_URL"/node/network > /dev/null; do
    echo "Waiting for CCF to start..."
    sleep 1
    timeout=$((timeout - 1))
    if [ $timeout -eq 0 ]; then
        echo "CCF failed to start, exiting"
        echo "Docker logs:"
        docker logs "$CONTAINER_NAME"
        exit 1
    fi
done

scitt governance local_development \
    --url "$CCF_URL" \
    --member-key "$WORKSPACE"/member0_privk.pem \
    --member-cert "$WORKSPACE"/member0_cert.pem

echo "SCITT is running: ${CCF_URL}"
docker logs -f "$CONTAINER_NAME"