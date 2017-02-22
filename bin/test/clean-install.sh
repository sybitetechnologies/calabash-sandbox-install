#!/usr/bin/env bash

function pass {
  echo "$(tput setaf 2)PASS: $1$(tput sgr0)"
}

function fail {
  echo "$(tput setaf 1)FAIL: $1$(tput sgr0)"
}

function banner {
  echo ""
  echo "$(tput setaf 5)######## $1 #######$(tput sgr0)"
  echo ""
}


TMP_DIR="${PWD}/tmp/test/$0"
rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"

DOT_DIR="${TMP_DIR}/.calabash"

mkdir -p "${DOT_DIR}"

banner "Clean install"

HOME="${TMP_DIR}" \
  GEM_HOME="" GEM_PATH="" \
  ./install-calabash-local-osx.rb skip-managed-ruby-check

STATUS=$?

if [ "${STATUS}" = "0" ]; then
  pass "Script made a clean install"
else
  fail "Script did not install"
  exit 1
fi

