#!/usr/bin/env bash

# Accept input as argument, or prompt interactively if left empty
PLAYBOOK_USER="${1}"

if [ -z "${PLAYBOOK_USER}" ]; then
  read -rp "Enter username to check/add: " PLAYBOOK_USER
fi

# Exit if still empty
if [ -z "${PLAYBOOK_USER}" ]; then
  echo "Error: No user specified."
  exit 1
fi

# Exit early if the user DOES NOT exist (also checked in playbook)
if ! id "$PLAYBOOK_USER" &>/dev/null; then
  echo "Error: User '$PLAYBOOK_USER' does not exist."
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "${SCRIPT_DIR}" > /dev/null

export ANSIBLE_HOST_KEY_CHECKING=0

ansible-playbook \
    --inventory=./inventory/production.yml \
    ./playbooks/adduser.yml \
    -e "playbook_user=${PLAYBOOK_USER}"

popd > /dev/null