# Installation Notes for the CRAVE2UVM prototype

This projects contains a prototypical integration of CRAVE with UVM-SystemC to provide access to constrained randomization and coverage.
For demonstration, we ported the SystemVerilog example UBUS to UVM-SystemC and included it in this distribution.

## Requirements

Make sure all pre install requirements of CRAVE and UVM-SystemC are met:

* CMake (at least v3.20)
* GNU Make
* g++ (at least v4.7.2)
* SystemC: 
  the environment variable SYSTEMC_HOME must show to the SystemC installation. 
* UVM-SystemC:
  the environment variable UVM_SYSTEMC_HOME must show to the UVM-SystemC installation. 
* zlib development libraries (e.g. zlib1g-dev).
* Boost (at least v1.50.0 and the environment variable BOOST_ROOT must be set accordingly)

If Boost installation is already available BOOST_ROOT envrinment should point to its location.
Alternativelly boost library cna be installed by conan.

Install conan:
# create a virtual environment
python -m venv .venv
# activate virtual environment
source .venv/bin/activate
# install conan 2
pip install --upgrade pip
pip install conan
# install Boost
conan install . --output-folder=build/ALL --build=missing



The version of CRAVE included in this distribution by default will build a minimal configuration (Glog and 2 solver backends: CUDD and Z3). 
Other configurations with additional backends (e.g. Boolector, SWORD, CVC4, etc.) are also possible. 
If download is permitted, CRAVE can automatically download and build these backends.
Otherwise, the user needs to provide appropriate source or binary archive in deps/cache.
For more detailed instructions , please refer to the CRAVE README or contact us.

## Installation

To install and run the example, use the buildscript on the toplevel of this repository. 
The installation of crave2uvm requires the libraries systemc and uvm-systemc, they are automatically installed by this script if the environment variables SYSTEMC_HOME and UVM_SYSTEMC_HOME are not set.

`./buildscript --install <INSTALL_DIR>`

Or set SYSTEMC_HOME and UVM_SYSTEMC_HOME and run cmake:

1. Minimal CRAVE setup with CUDD and Z3: `cmake --preset CUDD-Z3 .`

2. CRAVE setup with all SMTs (YICES2, CVC4, MiniSat, STP, Aiger, picosat): `cmake --preset ALL .`

## Tested OS

This distribution has been tested on the following 64-bit Linux (x86_64) systems:

* CentOS7 gcc 7.3.0

## Contact

For bugreport and feedback: <https://github.com/accellera-official/crave/issues>

