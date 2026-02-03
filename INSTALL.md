# Installation Notes for the CRAVE2UVM prototype

This project contains a prototypical integration of CRAVE with UVM-SystemC to provide access to constrained randomization and coverage.
For demonstration, we ported the SystemVerilog example UBUS to UVM-SystemC and included it in this distribution.

## Requirements

Base tools:

* CMake (at least v3.20)
* GNU Make
* Ninja (recommended)
* g++ (at least v4.7.2)
* zlib development libraries (e.g. zlib1g-dev)

Dependencies (SystemC, UVM-SystemC, Boost):

You have two options:

1) **Use system installations** (recommended when downloads are restricted). Set env vars to point to your installs:
   * `BOOST_ROOT`
   * `SYSTEMC_HOME`
   * `UVM_SYSTEMC_HOME`

2) **Let CMake fetch/build them** (recommended for a clean, self-contained build):
   * Use `-DFETCH_ALL_DEPS=ON` or per-dependency flags.

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

* **Complete setup (all SMTs) including fetching Boost, SystemC, and UVM-SystemC:**

  ```sh
  cmake --preset ALL -DFETCH_ALL_DEPS=ON
  cmake --build --preset ALL --target install
  ```

* **Fetch prerequisites selectively:**

  * Fetch only Boost, use system SystemC/UVM-SystemC:

    ```sh
    cmake --preset ALL -DFETCH_BOOST=ON
    cmake --build --preset ALL --target install
    ```

  * Fetch only SystemC and UVM-SystemC, use system Boost:

    ```sh
    cmake --preset ALL -DFETCH_SYSTEMC=ON -DFETCH_UVM_SC=ON
    cmake --build --preset ALL --target install
    ```

  * Fetch only UVM-SystemC (use system Boost and SystemC):

    ```sh
    cmake --preset ALL -DFETCH_UVM_SC=ON
    cmake --build --preset ALL --target install
    ```

### Notes

* Dependency resolution order: env var -> system search -> fetch/build.
* To force downloading/building use `-DFETCH_ALL_DEPS=ON` or per-dependency flags:
  `-DFETCH_BOOST=ON`, `-DFETCH_SYSTEMC=ON`, `-DFETCH_UVM_SC=ON`.
* For CVC4 support, ensure Python’s `toml` package is installed:

  ```sh
  pip install toml
  ```

* The install prefix is set by the presets (currently `/tmp/crave2uvm_install`). Override it with `-DCMAKE_INSTALL_PREFIX=<DIR>` if needed.

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

For bug reports and feedback: <https://github.com/accellera-official/crave/issues>
