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

banner "Test for rbenv executable"

PATH_HAS_RBENV="${TMP_DIR}/bin"

mkdir -p "${PATH_HAS_RBENV}"
BINARY="${PATH_HAS_RBENV}/rbenv"

touch "${BINARY}"
chmod +x "${BINARY}"

echo "#!/usr/bin/env bash" > "${BINARY}"
echo "echo \"rbenv FTW!\"" >> "${BINARY}"
echo "exit 0" >> "${BINARY}"

# Need /usr/bin/ruby
PATH="/usr/bin:${PATH_HAS_RBENV}" \
  HOME="${TMP_DIR}" \
  GEM_HOME="" GEM_PATH="" \
  ./install-calabash-local-osx.rb

STATUS=$?

if [ "${STATUS}" = 10 ]; then
  pass "Script exits if rbenv is installed"
else
  fail "Rbenv is installed, but script did not exit"
  exit 1
fi

banner "Test for ~/.rbenv"

mkdir -p "${TMP_DIR}/.rbenv"

# Need /usr/bin/ruby
PATH="/usr/bin" \
  HOME="${TMP_DIR}" \
  GEM_HOME="" GEM_PATH="" \
  ./install-calabash-local-osx.rb

STATUS=$?

if [ "${STATUS}" = 10 ]; then
  pass "Script exits if there is a ~/.rbenv dir or file"
else
  fail "Found a ~/.rbenv dir or file, but script did not exit"
  exit 1
fi

