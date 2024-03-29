#!/bin/bash

call() {
  echo "VideogameAutomationService initialized"
  return 0
}

create_jar_file() {
  path=$1
  cd "${path}" || exit 1
  mvn -v
  mvn clean install
}

build_and_push_on_docker() {
  path=$1
  image_name=$2
  image_tag=$3
  password_encrypted=$4
  username_dockerhub="dannybatchrun"
  cd "${path}" || exit 1
  docker buildx build . -t ${image_name} || exit 1
  docker tag ${image_name} ${username_dockerhub}:${image_name}:${image_tag} || exit 1
  useAnsibleVault "${password_encrypted}" "decrypt"
  docker push ${username_dockerhub}/${image_name}:${image_tag} || exit 1
  useAnsibleVault "${password_encrypted}" "encrypt"
}

use_ansible_vault() {
  password_encrypted=$1
  choice=$2
  cd /home/daniele/.docker || exit 1
  set +x; echo "${password_encrypted}" > passwordFile || exit 1
  ansible-vault "${choice}" config.json --vault-password-file passwordFile && rm passwordFile || exit 1
}
