# Installation Notes for the CRAVE2UVM prototype

This projects contains a prototypical integration of CRAVE with UVM-SystemC to provide access to constrained randomization and coverage.
For demonstration, we ported the SystemVerilog example UBUS to UVM-SystemC and included it in this distribution.

## Requirements

Make sure all pre install requirements of CRAVE and UVM-SystemC are met:

* CMake (at least v3.20)
* GNU Make
* Ninja (recommended)
* g++ (at least v4.7.2)
* SystemC:
  the environment variable SYSTEMC_HOME must show to the SystemC installation.
* UVM-SystemC:
  the environment variable UVM_SYSTEMC_HOME must show to the UVM-SystemC installation.
* zlib development libraries (e.g. zlib1g-dev).
* Boost (at least v1.50.0 and the environment variable BOOST_ROOT must be set accordingly)

If Boost installation is already available BOOST_ROOT envrinment should point to its location.
Alternatively, the boost library will be automatically downloaded and built by CMake if needed.

The version of CRAVE included in this distribution by default will build a minimal configuration (Glog and 2 solver backends: CUDD and Z3).
Other configurations with additional backends (e.g. Boolector, SWORD, CVC4, etc.) are also possible.
If download is permitted, CRAVE can automatically download and build these backends.
Otherwise, the user needs to provide appropriate source or binary archive in deps/cache.
For more detailed instructions , please refer to the CRAVE README or contact us.

## Installation

Configure with a preset, then build and install. The build directory is `build/<PRESET>`.

### Usage Examples

* **Minimal setup (CUDD and Z3):**

  ```sh
  cmake --preset CUDD-Z3
  cmake --build --preset CUDD-Z3 --target install
  ```

* **Full setup (all SMTs):**

  ```sh
  cmake --preset ALL
  cmake --build --preset ALL --target install
  ```

### Notes

* If you already have Boost, SystemC, or UVM-SystemC installed, set the corresponding environment variables (`BOOST_ROOT`, `SYSTEMC_HOME`, `UVM_SYSTEMC_HOME`) before running CMake to skip downloading/building them.
* CMake will attempt to download and build missing dependencies automatically.
* CMake dependency resolution order: env var -> system search -> fetch/build. To force downloading/building use `-DFETCH_ALL_DEPS=ON` or per-dependency flags: `-DFETCH_BOOST=ON`, `-DFETCH_SYSTEMC=ON`, `-DFETCH_UVM_SC=ON`.
* For CVC4 support, ensure Python’s `toml` package is installed:

  ```sh
  pip install toml
  ```
* The install prefix defaults to the current working directory unless `-DCMAKE_INSTALL_PREFIX=<DIR>` is provided.

### Running Tests

Tests are registered in subdirectories of the build directory.

```sh
ctest --test-dir build/ALL/crave/tests
ctest --test-dir build/ALL/crave/metaSMT/tests
```

## Tested OS

This distribution has been tested on the following 64-bit Linux (x86_64) systems:

* CentOS7 gcc 7.3.0
* Rocky Linux 9.5 gcc 13.3.1

## Contact

For bugreport and feedback: <https://github.com/accellera-official/crave/issues>
