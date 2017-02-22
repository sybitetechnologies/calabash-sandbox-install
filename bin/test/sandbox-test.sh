#!/usr/bin/env bash

function error {
  echo "$(tput setaf 1)ERROR: $1$(tput sgr0)"
  exit $2
}

# In the absence of a --no-input option, we need to clear an existing sandbox
# before we test on Jenkins, otherwise the test will block waiting for input.
#
# On Travis the directory will always be empty.
if [ ! -z "${JENKINS_HOME}" ]; then
  rm -rf "${HOME}/.calabash/sandbox"
fi

# Executing this test from ./ causes ./calabash-sandbox to be deleted (mv'ed)
# to /usr/local/bin - assuming it is writable.  Execute the script in tmp
# directory.
TMP_DIR=tmp/sandbox
rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"
cp ./install-osx.sh "${TMP_DIR}"

cp -r bin/test/cucumber "${TMP_DIR}"

GEMFILE="${PWD}/Gemfile.OSX"

cd "${TMP_DIR}"

set -e

./install-osx.sh

# $1 variable to store the version in
# $2 the gem version to extract
function extract_version {
  VERSION=`grep "${2}" "${GEMFILE}" | \
    egrep -o "([0-9]+([.][0-9]+)+)" | \
    head -1 | tr -d '\n'`
  eval "$1=\"${VERSION}\""
}

IOS_EXPECTED_VERSION=""
extract_version IOS_EXPECTED_VERSION "calabash-cucumber"
DROID_EXPECTED_VERSION=""
extract_version DROID_EXPECTED_VERSION "calabash-android"
XTC_EXPECTED_VERSION=""
extract_version XTC_EXPECTED_VERSION "xamarin-test-cloud"

DROID=$( { echo "calabash-android version >&2" |  calabash-sandbox 1>/dev/null; } 2>&1)
IOS=$( { echo "calabash-ios version >&2" | calabash-sandbox 1>/dev/null; } 2>&1)
XTC=$( { echo "test-cloud version >&2" | calabash-sandbox 1>/dev/null; } 2>&1)
gem_home=$( { echo "echo \$GEM_HOME >&2" | calabash-sandbox 1>/dev/null; } 2>&1)

echo "Testing calabash-android version"
if [ "${DROID}" != "${DROID_EXPECTED_VERSION}" ]; then
  error "calabash-android version ($DROID) should be $DROID_EXPECTED_VERSION" 1
fi

echo "Testing calabash-ios version"
if [ "${IOS}" != "${IOS_EXPECTED_VERSION}" ]; then
  error "calabash-ios version ($IOS) should be $IOS_EXPECTED_VERSION" 2
fi

echo "Testing test-cloud version"
if [ "${XTC}" != "${XTC_EXPECTED_VERSION}" ]; then
  error "test-cloud version ($XTC) should be $XTC_EXPECTED_VERSION" 3
fi

echo "Ensuring sandbox GEM_HOME properly set"
if [ "${gem_home}" != "${HOME}/.calabash/sandbox/Gems" ]; then
  echo "Gem Home should be ${HOME}/.calabash/sandbox/Gems; Got $gem_home"
  exit 4
fi

