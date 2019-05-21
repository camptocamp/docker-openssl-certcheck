#!/bin/sh -e

export LANG=C

test -d "$1" || (echo "usage: $0 <dir>" && exit 1)

cat << EOF
HTTP/1.0 200
Content-Type: text/plain
Connection: close

EOF

for cert in "$1"/*.pem; do
  IFS='
'
  TAGS=''
  NOTBEFORE=0
  NOTAFTER=0

  for line in $(openssl x509 -noout -issuer -subject -dates < "$cert"); do
    key=$(echo "$line" | cut -f1 -d=)
    val=$(echo "$line" | cut -f2- -d=)

    if [ "$key" = "issuer" ] || [ "$key" = "subject" ]; then
      TAGS="$TAGS$(echo "$line" | sed -r -e 's/=/="/' -e 's/$/"/'),"
    fi
    if [ "$key" = "notBefore" ]; then
      NOTBEFORE=$(date -d "$val" +%s)
    fi
    if [ "$key" = "notAfter" ]; then
      NOTAFTER=$(date -d "$val" +%s)
    fi
  done

  TAGS="${TAGS}certfile=\"${cert}\""

  echo "openssl_x509_notbefore{$TAGS} $NOTBEFORE"
  echo "openssl_x509_notafter{$TAGS} $NOTAFTER"

done
