# Certificate Authority

This project contains a set of helper scripts for maintaining a Certificate
Authority (CA).


## Prerequisites

* OpenSSL v1.1.1+


## Configuration

Most of the configuration values in `openssl.cnf` are ok as defaults. However,
you may want to change some values, such as the defaults under the
`req_distinguished_name` section.


## Creating a Self-Signed CA

To create a self-signed CA, we need to first create a certificate signing
request (CSR). Here, we will create a CSR and a private ECDSA key with the
`openssl req` command.

```
$ openssl req -config config/openssl.cnf \
> -newkey ec:config/ecparams -nodes -keyout private/cakey.pem \
> -out private/ca.csr
```

You can inspect the contents of the request using the following command,

```
$ openssl req -in private/ca.csr -noout -text
```

Once the CSR is created, we sign it with the `openssl ca` command. We pass in
`-extensions v3_ca` to force it to add the extensions required to generate a CA
certificate.

```
$ openssl ca -config config/openssl.cnf -selfsign -extensions v3_ca \
> -enddate 99991231235959Z -create_serial -in private/ca.csr -out cacert.pem
```

Say `yes` to all prompts that proceed. The `-enddate 99991231235959Z` option is
a value specified in RFC 5280 for generating a certificate that never expires.
It is not advised that you do this, but we'll let it pass for a CA.

You can inspect the details of the certificate with the following command,

```
$ openssl x509 -in cacert.pem -noout -text
```


## Creating a Server Certificate

As with every certificate, you need to create a private key and generate a
certificate signing request for the CA to sign. Servers also require a
`subjectAltName` extension for specifying its fully-qualified domain name
(FQDN). On newer versions of OpenSSL, you can do this with the `-addext`
option when constructing the CSR.

```
$ openssl req -config config/openssl.cnf \
> -newkey ec:config/ecparams -nodes -keyout private/server-example.key \
> -out private/server-example.csr \
> -addext 'subjectAltName=DNS:example.com'

$ openssl ca -config/openssl.cnf -extensions server_cert \
> -in private/server-example.csr -out certs/server-example.pem
```


## Creating a Client Certificate

Client certificates can be created in a similar fashion, except we do not have
to give them a `subjectAltName` and we pass in `client_cert` instead of
`server_cert`. In most case, the common name (CN) attribute will define the
user's username.

```
$ openssl req -config config/openssl.cnf \
> -newkey ec:config/ecparams -nodes -keyout private/client-username.key \
> -out private/client-username.csr

$ openssl ca -config/openssl.cnf -extensions client_cert \
> -in private/client-username.csr -out certs/client-username.pem
```


## Verifying Certificates

The `openssl verify` command allows us to verify if our certificates are valid.

```
$ openssl verify -CAfile ./cacert.pem certs/server-example.pem certs/client-username.pem
certs/server-example.pem: OK
certs/client-username.pem: OK
```

To go one step further, you can verify if a certificate is valid as a client or
as a server.

```
$ openssl verify -CAfile ./cacert.pem -purpose sslserver certs/server-example.pem
certs/server-example.pem: OK
```

```
$ openssl verify -CAfile ./cacert.pem -purpose sslclient certs/client-username.pem
certs/server-example.pem: OK
```

If you wish to go even one step further, you can experiment with the `s_server`
and `s_client` commands in OpenSSL to run an actual server/client with the
certificates.
