FetchContent_Declare(
    boolector_git
    GIT_REPOSITORY https://github.com/Boolector/boolector.git
    GIT_TAG 3.2.3
)
FetchContent_GetProperties(boolector_git)

if(NOT boolector_git_POPULATED)
    FetchContent_Populate(boolector_git)
endif()
set(install_dir ${CMAKE_INSTALL_PREFIX})
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    # Fallback in case where CMAKE_INSTALL_PREFIX is not explicitly set by the user
    set(install_dir ${CMAKE_BINARY_DIR}/solvers/boolector)
endif()

execute_process(
    COMMAND ./contrib/setup-lingeling.sh 
    COMMAND ./contrib/setup-btor2tools.sh 
    COMMAND ./contrib/setup-cadical.sh 
    WORKING_DIRECTORY ${boolector_git_SOURCE_DIR}
)

execute_process(
  WORKING_DIRECTORY ${boolector_git_SOURCE_DIR}
  COMMAND bash -c "./configure.sh --prefix ${install_dir} --shared && make -C build -j install"
  RESULT_VARIABLE BOOLECTOR_RESULT
  ECHO_OUTPUT_VARIABLE
  ECHO_ERROR_VARIABLE
)

if(NOT BOOLECTOR_RESULT EQUAL 0)
  message(FATAL_ERROR "Failed to build Boolector: ${BOOLECTOR_OUTPUT}")
endif()

find_package(Boolector REQUIRED HINTS ${install_dir}/lib/cmake)
message(STATUS "Use boolector from ${install_dir}")




