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
GEM_DIR="${DOT_DIR}/calabash-gems"

mkdir -p "${GEM_DIR}"

banner "Previous install detected; user says: 'n'"

HOME="${TMP_DIR}" \
  GEM_HOME="" GEM_PATH="" \
  ./install-calabash-local-osx.rb skip-managed-ruby-check <<< "n\n"

STATUS=$?

if [ "${STATUS}" = "30" ]; then
  pass "Script exited before deleting previous install"
else
  fail "Script did not exit before deleting previous install"
  exit 1
fi

banner "Previous install detected; user says: 'N'"

HOME="${TMP_DIR}" \
  GEM_HOME="" GEM_PATH="" \
  ./install-calabash-local-osx.rb skip-managed-ruby-check <<< "N\n"

STATUS=$?

if [ "${STATUS}" = "30" ]; then
  pass "Script exited before deleting previous install"
else
  fail "Script did not exit before deleting previous install"
  exit 1
fi

banner "Previous install detected; user accepts default (N)"

HOME="${TMP_DIR}" \
  GEM_HOME="" GEM_PATH="" \
  ./install-calabash-local-osx.rb skip-managed-ruby-check \
  <<EOF

EOF

STATUS=$?

if [ "${STATUS}" = "30" ]; then
  pass "Script exited before deleting previous install"
else
  fail "Script did not exit before deleting previous install"
  exit 1
fi

banner "Previous install detected; enters invalid input"

HOME="${TMP_DIR}" \
  GEM_HOME="" GEM_PATH="" \
  ./install-calabash-local-osx.rb skip-managed-ruby-check <<< "a"

STATUS=$?

if [ "${STATUS}" = "40" ]; then
  pass "Script exited because of invalid input"
else
  fail "Script did not exit because of invalid input"
  exit 1
fi

banner "Previous install detected; user answers 'y'"

HOME="${TMP_DIR}" \
  GEM_HOME="" GEM_PATH="" \
  ./install-calabash-local-osx.rb skip-managed-ruby-check <<< "y"

STATUS=$?

if [ "${STATUS}" = "0" ]; then
  pass "Script deleted previous install and proceeded with clean install"
else
  fail "Script did not proceed with clean install"
  exit 1
fi

