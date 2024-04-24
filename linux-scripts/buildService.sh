#!/bin/bash

call() {
  echo "VideogameAutomationService initialized"
  sudo chmod 777 -R /home/daniele/myagent
  return 0
}

create_jar_file() {
  path=$1
  cd "${path}" || exit 1
  mvn -v
  mvn clean install
  sudo chmod 777 -R /home/daniele/myagent
}

build_and_push_on_docker() {
  path=$1
  image_name=$2
  image_tag=$3
  password_encrypted=$4
  userdock=$5
  passwdock=$6
  cd "${path}" || exit 1
  docker login -u ${userdock} -p ${passwdock}
  docker buildx build . -t ${image_name} || exit 1
  docker tag "${image_name}" dannybatchrun/${image_name}:${image_tag} || exit 1
  sudo useAnsibleVault "${password_encrypted}" "decrypt"
  docker push dannybatchrun/${image_name}:${image_tag} || exit 1
  sudo useAnsibleVault "${password_encrypted}" "encrypt"
  sudo chmod 777 -R /home/daniele/myagent
}

use_ansible_vault() {
  password_encrypted=$1
  choice=$2
  cd /home/daniele/.docker || exit 1
  set +x; echo "${password_encrypted}" > passwordFile || exit 1
  ansible-vault "${choice}" config.json --vault-password-file passwordFile && rm passwordFile || exit 1
  sudo chmod 777 -R /home/daniele/myagent
}

if [ "$1" == "create_jar_file" ]; then
  shift
  create_jar_file "$@"
elif [ "$1" == "build_and_push_on_docker" ]; then
  shift
  build_and_push_on_docker "$@"
elif [ "$1" == "use_ansible_vault" ]; then
  shift
  use_ansible_vault "$@"
fi
