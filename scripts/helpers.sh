config="$root/config/openssl.cnf"
randfile="$root/private/.rand"
ecparams="$root/config/ecparams"
default_opts=(-config "$config")

# The following value is indicates that a certificate will never expire,
# documented in RFC 5280.
never_expire="99991231235959Z"

ca_key="$root/private/cakey.pem"
ca_cert="$root/cacert.pem"


ask_yes() {
  local msg="$1"
  read -p "$msg [y/N] " resp
  [[ "${resp:0:1}" == "y" || "${resp:0:1}" == "Y" ]] && return 0
  return 1
}
