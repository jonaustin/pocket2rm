#!/bin/bash

# Note about ssh:
# RSA is deprecated as of SSH 8.8 (Potentially-incompatible changes section): 
#    https://lists.mindrot.org/pipermail/openssh-unix-announce/2021-September/000146.html
#
# RM2 openssh only appears to support rsa; to get around it, add something like this to your ssh config
# ~/.ssh/config:
# Host rm2
#   user root
#   hostname 10.11.99.1
#   HostkeyAlgorithms +ssh-rsa
#   PubkeyAcceptedAlgorithms +ssh-rsa


set -eu

check_go() {
  if ! command -v go &> /dev/null; then
    printf "\nGo could not be found, please install it first\n\n"
    return 1
  fi

  export GOPATH=$HOME
  export GOBIN=$GOPATH/bin
  mkdir -p "$GOBIN"
}

compile_bin_files() {

  printf "\ncompiling pocket2rm...\n"

  cd "$INSTALL_SCRIPT_DIR/cmd/pocket2rm-setup"
  go get
  go build main.go

  cd "$INSTALL_SCRIPT_DIR/cmd/pocket2rm"
  go get
  GOOS=linux GOARCH=arm GOARM=7 go build -o pocket2rm.arm

  cd "$INSTALL_SCRIPT_DIR/cmd/pocket2rm-reload"
  go get
  GOOS=linux GOARCH=arm GOARM=7 go build -o pocket2rm-reload.arm

  printf "pocket2rm successfully compiled"
}

copy_bin_files_to_remarkable() {
  cd "$INSTALL_SCRIPT_DIR"
  scp "$HOME/.pocket2rm" root@"$REMARKABLE_IP":/home/root/.
  ssh root@"$REMARKABLE_IP" systemctl stop pocket2rm 2> /dev/null;
  ssh root@"$REMARKABLE_IP" systemctl stop pocket2rm-reload 2> /dev/null;
  scp cmd/pocket2rm/pocket2rm.arm root@"$REMARKABLE_IP":/home/root/.
  scp cmd/pocket2rm-reload/pocket2rm-reload.arm root@"$REMARKABLE_IP":/home/root/.
}

copy_service_files_to_remarkable() {
  cd "$INSTALL_SCRIPT_DIR"
  echo "Copying service files"
  scp cmd/pocket2rm/pocket2rm.service root@"$REMARKABLE_IP":/etc/systemd/system/.
  scp cmd/pocket2rm-reload/pocket2rm-reload.service root@"$REMARKABLE_IP":/etc/systemd/system/.
}

register_and_run_service_on_remarkable() {
  ssh root@"$REMARKABLE_IP" systemctl enable pocket2rm-reload
  ssh root@"$REMARKABLE_IP" systemctl start pocket2rm-reload
}

INSTALL_SCRIPT_DIR=""
REMARKABLE_IP=""

main() {
  INSTALL_SCRIPT_DIR=$(pwd)
  SSH_OPTIONS="-o 'HostKeyAlgorithms=+ssh-rsa'"

  printf "\n"
  read  -r -p "Enter your Remarkable IP address [10.11.99.1]: " REMARKABLE_IP
  read  -r -p "Number of articles to fetch: " NUM_FETCH_ARTICLES
  REMARKABLE_IP=${REMARKABLE_IP:-10.11.99.1}
  export NUM_FETCH_ARTICLES=${NUM_FETCH_ARTICLES:-10}
  
  if [ ! -f "$HOME/.pocket2rm" ]; then
    check_go
    compile_bin_files
    copy_bin_files_to_remarkable
  fi

  copy_service_files_to_remarkable
  register_and_run_service_on_remarkable

  printf "\npocket2rm successfully installed on your Remarkable\n"
}

main
