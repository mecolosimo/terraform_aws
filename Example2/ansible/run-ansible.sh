#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd ${SCRIPT_DIR} > /dev/null

export ANSIBLE_HOST_KEY_CHECKING=0

ansible-playbook \
        --inventory=./inventory/production.yml \
	./playbooks/site.yml

popd > /dev/null
