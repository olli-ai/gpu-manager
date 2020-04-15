#! /bin/bash

echo mounting bucket "$1" to "$2"
mkdir -p "$2" || exit $?
gcsfuse -o nonempty "$1" "$2" || exit $?
echo bucket "$1" mounted to "$2"

echo running "$3" "${@:4}"
$3 "${@:4}"
exit $?
