include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/buildGMP.cmake)

# Fetch and build gperf
FetchContent_Declare(
    gperf_repo
    URL https://ftp.gnu.org/pub/gnu/gperf/gperf-3.1.tar.gz
)
FetchContent_GetProperties(gperf_repo)

if(NOT gperf_repo_POPULATED)
    FetchContent_Populate(gperf_repo)
endif()

set(GPERF_INSTALL_DIR ${CMAKE_INSTALL_PREFIX})

execute_process(
  WORKING_DIRECTORY ${gperf_repo_SOURCE_DIR}
  COMMAND bash -c "./configure --prefix=${GPERF_INSTALL_DIR} && make -j && make install"
  RESULT_VARIABLE GPERF_RESULT
  OUTPUT_VARIABLE GPERF_OUTPUT
  ERROR_VARIABLE GPERF_ERROR
)

# Check the result of the command
if(NOT GPERF_RESULT EQUAL 0)
  message(FATAL_ERROR "Failed to build gperf: ${GPERF_OUTPUT} ${GPERF_ERROR}")
endif()

# Find the gperf executable
find_program(GPERF_EXECUTABLE gperf HINTS ${GPERF_INSTALL_DIR}/bin)
if(NOT GPERF_EXECUTABLE)
  message(FATAL_ERROR "gperf executable not found")
endif()

FetchContent_Declare(
    yices2_repo
    GIT_REPOSITORY https://github.com/SRI-CSL/yices2.git
    GIT_TAG Yices-2.6.4
)
FetchContent_GetProperties(yices2_repo)

if(NOT yices2_repo_POPULATED)
    FetchContent_Populate(yices2_repo)
endif()

set(install_dir ${CMAKE_INSTALL_PREFIX})
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    # Fallback in case where CMAKE_INSTALL_PREFIX is not explicitly set by the user
    set(install_dir ${CMAKE_BINARY_DIR}/solvers/yices2)
endif()

add_custom_command(
    OUTPUT ${install_dir}/lib/libyices.a
    WORKING_DIRECTORY ${yices2_repo_SOURCE_DIR}
    COMMAND autoconf
    COMMAND ./configure --prefix=${install_dir}  GPERF=${GPERF_EXECUTABLE} CPPFLAGS=-I${GMP_INSTALL_DIR}/include LDFLAGS=-L${GMP_INSTALL_DIR}/lib
    COMMAND make -j
    COMMAND make install -j
    COMMENT "Building Yicies library"
    USES_TERMINAL
)

add_custom_target(yices2_repo DEPENDS ${install_dir}/lib/libyices.a)
add_library(yices2 INTERFACE)
target_include_directories(yices2 INTERFACE ${install_dir}/include)
target_link_libraries(yices2 INTERFACE ${install_dir}/lib/libyices.a gmp)
target_link_directories(yices2 INTERFACE ${install_dir}/lib)
add_dependencies(yices2 DEPENDS yices2_repo)
add_library(yices2::yices2 ALIAS yices2)
# install the target
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
set(yices2_CMAKE_CONFIG_DIR ${CMAKE_INSTALL_LIBDIR}/cmake/yices2)

install(TARGETS yices2 EXPORT yices2-targets)

install(
  EXPORT yices2-targets
  DESTINATION ${yices2_CMAKE_CONFIG_DIR}
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/yices2-config-version.cmake
    VERSION 2.6.4
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    ${CMAKE_CURRENT_LIST_DIR}/yices2-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/yices2-config.cmake
    INSTALL_DESTINATION ${yices2_CMAKE_CONFIG_DIR}
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/yices2-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/yices2-config-version.cmake
    DESTINATION ${yices2_CMAKE_CONFIG_DIR})
message(STATUS "Use yices2 from ${install_dir}")
