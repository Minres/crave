#!/bin/bash

set -e  # Exit immediately if any command returns a non-zero status

NUM_THREADS=16  # Set the default value or let the user pass it as an argument

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -j <num_threads>    Set the number of threads for building (default: 4)"
  echo "  --install <dir>      Set the installation directory (default: current directory)"
  exit 1
fi

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -j)
      NUM_THREADS="$2"
      shift 2
      ;;
    --install)
      INSTALL_PREFIX="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $key"
      exit 1
      ;;
  esac
done

if [ -z "$INSTALL_PREFIX" ]; then
  INSTALL_PREFIX=$(pwd)  # Default installation directory
fi

echo "Installing UVM-SystemC"
wget https://www.accellera.org/images/downloads/standards/systemc/uvm-systemc-1.0-beta4.tar.gz
tar xvzf uvm-systemc-1.0-beta4.tar.gz
pushd uvm-systemc-1.0-beta4

export CXXFLAGS=-std=c++17
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SYSTEMC_HOME/lib-linux64:$SYSTEMC_HOME/lib-linux:$SYSTEMC_HOME/lib64

# Configure and build
config/bootstrap
mkdir -p objdir
pushd objdir
../configure --enable-debug --enable-shared=no --with-layout=unix --with-arch-suffix=64 --with-systemc=${SYSTEMC_HOME} --prefix=${INSTALL_PREFIX}

echo "Build UVM-SystemC using $NUM_THREADS thread(s)"
make -j "$NUM_THREADS"
make install -j "$NUM_THREADS"

# cleanup
popd  # go back to uvm-systemc-1.0-beta4 directory
popd  # go back to the original directory
rm -rf uvm-systemc-1.0-beta4/objdir uvm-systemc-1.0-beta4.tar.gz

export UVM_SYSTEMC_HOME=${INSTALL_PREFIX}
echo "Installation complete. UVM_SYSTEMC_HOME is $UVM_SYSTEMC_HOME"
