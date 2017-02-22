#!/usr/bin/env bash

set -e

function banner {
  echo ""
  echo "$(tput setaf 5)######## $1 #######$(tput sgr0)"
  echo ""
}

function info {
  echo "$(tput setaf 2)INFO: $1$(tput sgr0)"
}

function version {
  echo "$(tput setaf 3)$1: $2$(tput sgr0)"
}
function error {
  echo "$(tput setaf 1)ERROR: $1$(tput sgr0)"
  exit $2
}

#usage: validate_cmd <exit_code> <action_message> <error_code_if_unsuccessful>
function validate_cmd {
  if [ $1 -ne 0 ]; then
    error "Error $2" $3
  fi
}

banner "Updating Calabash Sandbox Gems"
info "If you're not a maintainer, don't run this script!"

# Create a reference to the ./calabash-sandbox script.
SANDBOX_SCRIPT="${PWD}/calabash-sandbox"

info "Retrieving Gemfile"
SANDBOX="${HOME}/.calabash/sandbox"

if [ ! -d "${SANDBOX}" ]; then
  error "Sandbox does not exist! Make sure you have a sandbox installation first." 11
fi

info "Updating Gemfile and Gemfile.lock"
cp "./Gemfile.OSX" "${SANDBOX}/Gemfile"

validate_cmd $? "copying Gemfile.OSX" 10

cd "${SANDBOX}"
GEMS_DIR=Gems

# We need a clean install
rm -rf "${GEMS_DIR}"

info "Installing the latest version of bundler"
GEM_HOME="${GEMS_DIR}" GEM_PATH="${GEMS_DIR}" gem install bundler
echo

info "Installing Gems"
GEM_HOME="${GEMS_DIR}" GEM_PATH="${GEMS_DIR}" bundle update
echo

info "Done! Now the sandbox contains:"
IOS=`calabash-ios version | tr -d '\n'`
DROID=`calabash-android version | tr -d '\n'`
XTC=`test-cloud version | tr -d '\n'`
version "      calabash-ios" $IOS
version "  calabash-android" $DROID
version "xamarin-test-cloud" $XTC

info "Zipping Gems"
rm -rf CalabashGems.zip
zip -qr CalabashGems.zip $GEMS_DIR
validate_cmd $? "zipping gems" 4

banner "Testing S3 Connection"

info "Verifying Credentials"
aws s3 ls | grep "calabash-files"
validate_cmd $? "verifying credentials. If you are a maintainer and don't have creds, \
you should know who to talk to in order to get them." 6

info "Uploading CalabashGems.zip to S3. This will take a while. Be patient, grasshopper"
aws s3 cp CalabashGems.zip s3://calabash-files/CalabashGems.zip
validate_cmd $? "uploading CalabashGems.zip to S3" 7

info "Cleaning Up"
rm -rf CalabashGems.zip
validate_cmd $? "cleaning up" 9

info "All done. Please commit the latest 'calabash-sandbox' file so that users \
will see the updated version number."

banner "SUCCESS"
