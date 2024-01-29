#!/bin/bash

set -e  # Exit immediately if any command returns a non-zero status

NUM_THREADS=4  # Default value
SYSTEMC_VERSION="2.3.4"
DOWNLOAD_URL="https://github.com/accellera-official/systemc/archive/refs/tags/${SYSTEMC_VERSION}.tar.gz"

if [ -n "$1" ]; then
  NUM_THREADS=$1
fi

echo "Installing SystemC"

# Download and extract
wget "$DOWNLOAD_URL"
tar xvzf "${SYSTEMC_VERSION}.tar.gz"
pushd "systemc-${SYSTEMC_VERSION}"

# Configure and build using CMake
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$(pwd)" -DCMAKE_CXX_STANDARD=11 -DENABLE_PHASE_CALLBACKS_TRACING=OFF -DBUILD_SHARED_LIBS=OFF .
make -j "$NUM_THREADS"
make install -j "$NUM_THREADS"

popd  # go back to the original directory
rm -rf "${SYSTEMC_VERSION}.tar.gz"

# Set SYSTEMC_HOME
export SYSTEMC_HOME=$(pwd)/systemc-${SYSTEMC_VERSION}
echo "SYSTEMC_HOME set to $SYSTEMC_HOME"

echo "Installation complete"
