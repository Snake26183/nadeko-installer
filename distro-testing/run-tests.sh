#!/usr/bin/env bash

# Wannabe hashtable for commands, ncurses and bash are added for minimal images which don't contain bash or clear commands
# Comment or uncomment as needed for testing, you can add other distros/version here, just be sure the docker image name is correct
declare -A DISTROS
DISTROS["debian:11"]="apt update -y;apt install -y curl bash ncurses-bin"
DISTROS["debian:12"]="apt update -y;apt install -y curl bash ncurses-bin"
DISTROS["ubuntu:20.04"]="apt update -y;apt install -y curl bash ncurses-bin"
DISTROS["ubuntu:22.04"]="apt update -y;apt install -y curl bash ncurses-bin"
DISTROS["ubuntu:24.04"]="apt update -y;apt install -y curl bash ncurses-bin"
DISTROS["linuxmintd/mint20-amd64"]="apt update -y;apt install -y curl bash ncurses-bin"
DISTROS["linuxmintd/mint21-amd64"]="apt update -y;apt install -y curl bash ncurses-bin"
DISTROS["linuxmintd/mint22-amd64"]="apt update -y;apt install -y curl bash ncurses-bin"
DISTROS["fedora:38"]="dnf update -y;dnf install -y curl bash ncurses"
DISTROS["fedora:39"]="dnf update -y;dnf install -y curl bash ncurses"
DISTROS["fedora:40"]="dnf update -y;dnf install -y curl bash ncurses"
DISTROS["fedora:41"]="dnf update -y;dnf install -y curl bash ncurses"
DISTROS["opensuse/leap"]="zypper refresh;zypper install -y curl bash ncurses tar gzip gawk"
DISTROS["opensuse/tumbleweed"]="zypper refresh;zypper install -y curl bash ncurses tar gzip gawk"
DISTROS["archlinux"]="pacman -Sy --noconfirm;pacman -S curl bash ncurses --noconfirm"
DISTROS["artixlinux/artixlinux"]="pacman -Sy --noconfirm;pacman -S curl bash ncurses --noconfirm"

token=$1

test_distros() {
  local distro=$1
  local upd_cmd=$2
  local inst_cmd=$3

  echo "Building Docker image for $distro..."
  
  docker build --no-cache --build-arg DISTRO=$distro --build-arg UPD_CMD="$upd_cmd" --build-arg INST_CMD="$inst_cmd" --build-arg TOKEN="$token" -t nadeko-$distro . || {
    echo "Failed to build image for $distro"
    return 1
  }
  
  echo "Running Docker container for $distro..."
  container_id=$(docker run -d nadeko-$distro) || {
    echo "Failed to run container for $distro"
    return 1
  }

  echo "Waiting for the container to stop..."
  
  # Wait for the container to stop and capture the exit code
  exit_code=$(docker wait $container_id)

  # Set file name based on the exit code from container
  if [ "$exit_code" -eq 0 ]; then
    log_file="success_${distro//[\/:]/_}.txt"
  else
    log_file="error_${distro//[\/:]/_}.txt"
  fi

  # Output logs to file and terminal
  docker logs $container_id | tee "$log_file"
  echo "Logs for $distro saved to $log_file"

  docker rm $container_id
}

# Calls the above function for each supported distro, splitting the array items by ';' and passing them to the function
for distro in "${!DISTROS[@]}"; do
  IFS=';' read -r upd_cmd inst_cmd <<< "${DISTROS[$distro]}"
  echo "$distro" "$upd_cmd" "$inst_cmd"
  test_distros "$distro" "$upd_cmd" "$inst_cmd"
done