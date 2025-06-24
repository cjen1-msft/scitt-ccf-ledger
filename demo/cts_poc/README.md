# CTS PoC Demo

This demo provides a generic Proof of Concept for a Code Transparency Service (CTS) using the SCITT CCF ledger. The scripts provided in this folder allow configuring a new SCITT CCF instance, generating and submitting claims in COSE format, getting a SCITT receipt for a submitted claim, and verifying the receipt validity.

## Prerequisites

- The ledger expects payloads to be signed into COSE_Sign1 signature envelopes, also called signed statements. You can set up custom [X509 signing cert](../../docs/configuration.md#x509-roots) locally via the script `0-cacerts-generator.sh`:

    ```bash
    mkdir -p /demo/x509_roots
    CACERT_OUTPUT_DIR="/demo/x509_roots" /demo/0-cacerts-generator.sh
    ```
- `0-cacerts-generator.sh` will also setup the configuration file (see [documentation](../../docs/configuration.md#scitt-configuration)).

- The admin (operator) will need to be recognized by the CTS instance. The member certificate and private key are generated automatically and stored in the `workspace` folder (`member0_cert.pem` and `member0_privk.pem`) **after starting the local instance**.

## Instructions

### CTS Operator

1. Start the instance with a single admin (member):

    ``` 
    UVM_SECURITY_CONTEXT_DIR=$UVM_SECURITY_CONTEXT_DIR cchost --config /host/dev-config.json --enclave-file /usr/src/app/libscitt.snp.so
    ```

    Set the `SCITT_URL` variable if you are targeting a remote instance already deployed and publicly accessible:

    ```
    export SCITT_URL=127.0.0.1:8000
    ```

    If the `SCITT_URL` variable is not set, the scripts will target a local instance by default (`https://localhost:8000`).

2. Run the [`1-operator-demo.sh`](1-operator-demo.sh) to configure the instance.

    ```bash
   MEMBER_CERT_PATH="/host/member0_cert.pem" MEMBER_KEY_PATH="/host/member0_privk.pem" SCITT_CONFIG_PATH="/demo/x509_roots/configuration.json" /demo/1-operator-demo.sh
    ```

### CTS client

#### Prepare payload to be signed

You need to have a file to sign. There is a limit on the size of the payload (1MB) so it needs to be reasonably small.

```bash
echo '{"content":"some demo text"}' > /demo/payload.json
```

#### Sign the payload

If you created your own certificate and key combination as mentioned in the prerequisites then the following command will create a signature.

```bash
ISSUER=$(cat /demo/x509_roots/issuer.txt)
CACERT_PATH="/demo/x509_roots/cacert.pem" PRIVATE_KEY_PATH="/demo/x509_roots/cacert_privk.pem" CLAIM_CONTENT_PATH="/demo/payload.json" COSE_CLAIMS_OUTPUT_PATH="/demo/payload.sig.cose" DID_X509_ISSUER="$ISSUER" /demo/2-claim-generator.sh
```

#### Submit the COSE_Sign1 claim file

Submit the COSE claim to the SCITT ledger and verify a receipt for the committed transaction by running the [`3-client-demo.sh`](3-client-demo.sh) script.

The script will submit the COSE claim to the SCITT ledger and will wait for a receipt to be generated. Once the receipt is generated, the script will print the CBOR receipt in a readable format, and verify the receipt validity.

```bash
COSE_CLAIMS_PATH="/demo/payload.sig.cose" OUTPUT_FOLDER="/demo" /demo/3-client-demo.sh
```

#### Known Issues and Workaround for Local Virtual Build

- Proposal failing with 403
    > enclave:../src/node/rpc/member_frontend.h:103 - POST /gov/proposals returning error 403: Member m[1e6aee66336c09bf4random8b55398nodeb3d2e08478c092491459a6063] is not active.

    This means the scitt instance is not configured properly.
    _Workaround:_ To configure on local, run following command and re-try:
    > ./pyscitt.sh governance local_development --url $SCITT_URL