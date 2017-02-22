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

banner "Test upgrade from version 1.0 installation"

TMP_DIR="${PWD}/tmp/test/$0"
rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"

DOT_DIR="${TMP_DIR}/.calabash"

mkdir -p "${DOT_DIR}"

mkdir -p "${DOT_DIR}/bin"
mkdir -p "${DOT_DIR}/build_info"
mkdir -p "${DOT_DIR}/cache"
mkdir -p "${DOT_DIR}/doc"
mkdir -p "${DOT_DIR}/gems"
mkdir -p "${DOT_DIR}/specifications"

HOME="${TMP_DIR}" \
  GEM_HOME="" GEM_PATH="" \
  ./install-calabash-local-osx.rb skip-install skip-managed-ruby-check

STATUS=$?

if [ "${STATUS}" = "20" ]; then
  pass "Script finished preparing without an error"
else
  fail "Script failed to prepare."
  exit 1
fi

BACKUP_DIR="${DOT_DIR}/version-1.0-install.bak"

if [ -d "${BACKUP_DIR}" ]; then
  pass "Script detected version 1.0 and backed up existing files"
else
  fail "Script did not back up version 1.0 files"
  exit 1
fi

