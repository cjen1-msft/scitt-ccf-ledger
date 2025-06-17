# Build docker images for pilotfish

## Build workspace

`pre-bake-workspace.sh` builds the workspace for the container such that it can be started without external dependencies.
From the root of this repository:

For SNP run:
```
WORKSPACE=workspace PLATFORM=snp SNP_ATTESTATION_CONFIG=pf-demo/c-aci-attestation-config.json bash pf-demo/pre-bake-workspace.sh 
```

For virtual run:
```
WORKSPACE=workspace PLATFORM=virtual bash pf-demo/pre-bake-workspace.sh 
```

## Build docker image

Then you can build the docker image with: 
```
PLATFORM=snp WORKSPACE=workspace bash pf-demo/build.sh
```

## Run the image

```
docker run --name "$NAME" --entrypoint "cchost" "$DOCKER_IMAGE_NAME" --config /host/dev-config.json --enclave-file "/usr/src/app/libscitt.snp.so"
```