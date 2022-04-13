#!/bin/bash

INSTALL_DIR="."
VERSION="latest" # latest for most recent or a specific version e.g. 1.16.4

while getopts "hd:v:" OPTION; do
  case "$OPTION" in
    d)
      INSTALL_DIR="$OPTARG";;
    h)
      echo -e "Usage: ./install_tools.sh [-d path] [-v version]"
      echo -e "Example: ./install_tools.sh -d /opt/minecraft/BuildTools -v 1.16.5 \n"
      echo -e "Installs the latest server version in current directory by default.\n"
      echo "  -d path         Specify a path where to install server files"
      echo "  -v version      Install a specific server version"
      exit 0;;

    v)
      VERSION="$OPTARG";;
    ?)
      echo "Use -h for help"
      exit 1;;
  esac
done


mkdir -p "$INSTALL_DIR" || { echo "Failed to create $INSTALL_DIR"; exit 1; }
cd $INSTALL_DIR

echo "--- Downloading BuildTools in `pwd` ---"

wget -O BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar

echo "--- Installing server version $VERSION ---"

git config --global --unset core.autocrlf
java -jar BuildTools.jar --rev $VERSION --output-dir "build"

echo "--- Tools successfully installed for $VERSION server ---"
