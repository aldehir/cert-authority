# Certificate Authority

This project contains a set of helper scripts for maintaining a Certificate
Authority (CA).


## Prerequisites

* OpenSSL v1.1.1+


## Configuration

Most of the configuration values in `openssl.cnf` are ok as defaults. However,
you may want to change some values, such as the defaults under the
`req_distinguished_name` section.


## Generating a Self-Signed CA

The `scripts/new-ca` script will create a new self-signed CA, `cacert.pem`, in
the project directory.
