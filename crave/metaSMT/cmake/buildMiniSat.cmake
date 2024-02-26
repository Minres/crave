FetchContent_Declare(
    minisat_repo
    GIT_REPOSITORY https://github.com/stp/minisat.git
    GIT_TAG 14c78206cd12d1d36b7e042fa758747c135670a4
)
FetchContent_GetProperties(minisat_repo)
if(NOT minisat_repo_POPULATED)
    FetchContent_Populate(minisat_repo)
endif()

set(install_dir ${CMAKE_INSTALL_PREFIX})
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    # Fallback in case where CMAKE_INSTALL_PREFIX is not explicitly set by the user
    set(install_dir ${CMAKE_BINARY_DIR}/solvers/minisat)
endif()

# minisat installation is required by STP in configure phase
execute_process(
  WORKING_DIRECTORY ${minisat_repo_SOURCE_DIR}
  COMMAND bash -c "cmake -B build -DCMAKE_INSTALL_PREFIX=${install_dir} . && make -C build install -j"
  RESULT_VARIABLE minisat_RESULT
  ECHO_OUTPUT_VARIABLE
  ECHO_ERROR_VARIABLE
)

if(NOT minisat_RESULT EQUAL 0)
  message(FATAL_ERROR "Failed to build minisat: ${minisat_OUTPUT}")
endif()

find_package(minisat CONFIG REQUIRED PATHS ${install_dir}/lib/cmake)

message(STATUS "Use minisat from ${install_dir}")