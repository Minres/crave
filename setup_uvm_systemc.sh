#!/bin/bash

set -e  # Exit immediately if any command returns a non-zero status

NUM_THREADS=16  # Set the default value or let the user pass it as an argument

if [ -n "$1" ]; then
  NUM_THREADS=$1
fi

echo "Installing UVM-SystemC"
wget https://www.accellera.org/images/downloads/standards/systemc/uvm-systemc-1.0-beta4.tar.gz
tar xvzf uvm-systemc-1.0-beta4.tar.gz
pushd uvm-systemc-1.0-beta4

export CXXFLAGS=-std=c++11
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SYSTEMC_HOME/lib-linux64:$SYSTEMC_HOME/lib-linux:$SYSTEMC_HOME/lib64

# Configure and build
config/bootstrap
mkdir -p objdir
pushd objdir
../configure --enable-debug --with-layout=unix --with-arch-suffix=64

echo "Build UVM-SystemC using $NUM_THREADS thread(s)"
make -j "$NUM_THREADS"
make install -j "$NUM_THREADS"

popd  # go back to uvm-systemc-1.0-beta4 directory

# Cleanup
rm -rf objdir uvm-systemc-1.0-beta4.tar.gz

# Set UVM_SYSTEMC_HOME
export UVM_SYSTEMC_HOME=$(pwd)
echo "UVM_SYSTEMC_HOME set to $UVM_SYSTEMC_HOME"

popd  # go back to the original directory
echo "Installation complete"