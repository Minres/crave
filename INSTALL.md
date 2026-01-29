# Installation Notes for the CRAVE2UVM prototype

This projects contains a prototypical integration of CRAVE with UVM-SystemC to provide access to constrained randomization and coverage.
For demonstration, we ported the SystemVerilog example UBUS to UVM-SystemC and included it in this distribution.

## Requirements

Make sure all pre install requirements of CRAVE and UVM-SystemC are met:

* CMake (at least v3.20)
* GNU Make
* Ninja (used by the buildscript for the CRAVE build)
* g++ (at least v4.7.2)
* wget (used by the buildscript to download dependencies)
* SystemC:
  the environment variable SYSTEMC_HOME must show to the SystemC installation.
* UVM-SystemC:
  the environment variable UVM_SYSTEMC_HOME must show to the UVM-SystemC installation.
* zlib development libraries (e.g. zlib1g-dev).
* Boost (at least v1.50.0 and the environment variable BOOST_ROOT must be set accordingly)

If Boost installation is already available BOOST_ROOT envrinment should point to its location.
Alternativelly, the boost library will be automatically installed locally by the buildscript.

The version of CRAVE included in this distribution by default will build a minimal configuration (Glog and 2 solver backends: CUDD and Z3).
Other configurations with additional backends (e.g. Boolector, SWORD, CVC4, etc.) are also possible.
If download is permitted, CRAVE can automatically download and build these backends.
Otherwise, the user needs to provide appropriate source or binary archive in deps/cache.
For more detailed instructions , please refer to the CRAVE README or contact us.

## Installation

The [`buildscript`](./buildscript) automates the installation and setup of all dependencies required for CRAVE2UVM, including Boost, SystemC, and UVM-SystemC. It also configures and builds the CRAVE2UVM project itself.

### What the Script Does

1. **Checks Environment Variables:**  
   Ensures required compilers and environment variables are set (`CXX`, `CC`, etc.). Defaults to `gcc/g++` if present.

2. **Parses Command-Line Options:**  
   * `-j <num_threads>`: Number of threads for building (default: 4).
   * `--install <DIR>`: Installation directory (default: current directory).
   * `--preset <PRESET>`: Selects a build preset (e.g., `CUDD-Z3`, `ALL`).

3. **Installs Dependencies (if needed):**  
   * **Boost:** Downloads and builds Boost **1.85.0** locally if `BOOST_ROOT` is not set. Override with `BOOST_VERSION`.
   * **SystemC:** Downloads and builds **SystemC 2.3.4** if `SYSTEMC_HOME` is not set. Override with `SYSTEMC_VERSION`.
   * **UVM-SystemC:** Downloads and builds **uvm-systemc 1.0-beta4** if `UVM_SYSTEMC_HOME` is not set. Override with `UVM_SYSTEMC_VERSION`.

4. **Configures and Builds CRAVE2UVM:**  
   Runs CMake with the selected preset and builds the project. The build directory is `build/<PRESET>`.

5. **Logging:**  
   All output is logged to `crave2uvm_build.log` (in the repo root) for troubleshooting.

### Usage Examples

* **Minimal setup (CUDD and Z3):**

  ```sh
  ./buildscript --install <INSTALL_DIR> --preset CUDD-Z3
  ```

* **Full setup (all SMTs):**

  ```sh
  ./buildscript --install <INSTALL_DIR> --preset ALL
  ```

### Notes

* If you already have Boost, SystemC, or UVM-SystemC installed, set the corresponding environment variables (`BOOST_ROOT`, `SYSTEMC_HOME`, `UVM_SYSTEMC_HOME`) before running the script to skip their installation.
* The script will attempt to download and build missing dependencies automatically.
* For CVC4 support, ensure Python’s `toml` package is installed:

  ```sh
  pip install toml
  ```
* The install prefix defaults to the current working directory unless `--install <DIR>` is provided.

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
