FetchContent_Declare(
    cvc4_repo
    GIT_REPOSITORY https://github.com/CVC4/CVC4-archived.git
    GIT_TAG 1.8
)
FetchContent_GetProperties(cvc4_repo)

if(NOT cvc4_repo_POPULATED)
    FetchContent_Populate(cvc4_repo)
endif()

set(install_dir ${CMAKE_INSTALL_PREFIX})
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    # Fallback in case where CMAKE_INSTALL_PREFIX is not explicitly set by the user
    set(install_dir ${CMAKE_BINARY_DIR}/solvers/cvc4)
endif()

execute_process(
  WORKING_DIRECTORY ${cvc4_repo_SOURCE_DIR}
  COMMAND bash -c "./contrib/get-antlr-3.4 && ./configure.sh --python3 --prefix=${install_dir} && make -C build install -j"
  RESULT_VARIABLE CVC4_RESULT
  ECHO_OUTPUT_VARIABLE
  ECHO_ERROR_VARIABLE
)

# Check the result of the command
if(NOT CVC4_RESULT EQUAL 0)
  message(FATAL_ERROR "Failed to build CVC4: ${CVC4_OUTPUT}")
endif()

find_package(CVC4 CONFIG REQUIRED PATHS ${install_dir}/lib/cmake)

message(STATUS "Use cvc4 from ${install_dir}")
