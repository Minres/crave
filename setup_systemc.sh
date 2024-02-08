#!/bin/bash

set -e  # Exit immediately if any command returns a non-zero status

NUM_THREADS=4  # Default value
SYSTEMC_VERSION="2.3.4"
DOWNLOAD_URL="https://github.com/accellera-official/systemc/archive/refs/tags/${SYSTEMC_VERSION}.tar.gz"
CMAKE_ARGS=""  # Additional CMake arguments

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -j <num_threads>    Set the number of threads for building (default: 4)"
  echo "  --install <dir>     Set the installation directory (default: current directory)"
  echo "  --cmake-args <args> Additional CMake arguments"
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
    --cmake-args)
      CMAKE_ARGS="$2"
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

echo "Installing SystemC"
wget "$DOWNLOAD_URL"
tar xvzf "${SYSTEMC_VERSION}.tar.gz"
pushd "systemc-${SYSTEMC_VERSION}"
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" -DCMAKE_CXX_STANDARD=17 -DENABLE_PHASE_CALLBACKS_TRACING=OFF -DBUILD_SHARED_LIBS=OFF $CMAKE_ARGS .
make -j "$NUM_THREADS"
make install -j "$NUM_THREADS"

popd  # go back to the original directory
rm -rf "${SYSTEMC_VERSION}.tar.gz"

export SYSTEMC_HOME=${INSTALL_PREFIX}/systemc-${SYSTEMC_VERSION}
echo "SYSTEMC_HOME set to $SYSTEMC_HOME"
echo "Installation complete"

