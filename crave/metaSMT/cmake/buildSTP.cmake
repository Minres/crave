cmake_minimum_required(VERSION 3.14)
project(STP_with_Help2Man)

include(FetchContent)

# Fetch help2man
FetchContent_Declare(
    help2man
    URL http://ftp.gnu.org/gnu/help2man/help2man-1.49.3.tar.xz
)
FetchContent_GetProperties(help2man)

if(NOT help2man_POPULATED)
    FetchContent_Populate(help2man)

    # Build and install help2man
    set(HELP2MAN_BUILD_DIR ${help2man_BINARY_DIR}/help2man-build)
    file(MAKE_DIRECTORY ${HELP2MAN_BUILD_DIR})
    # Configure, build, and install help2man
    execute_process(
        COMMAND sh -c "./configure --prefix=${help2man_BINARY_DIR}/install && make && make install"
        WORKING_DIRECTORY ${help2man_SOURCE_DIR}
    )
endif()

# Update PATH to include help2man
set(ENV{PATH} "${help2man_BINARY_DIR}/install/bin:$ENV{PATH}")

FetchContent_Declare(
    stp_repo
    GIT_REPOSITORY https://github.com/stp/stp.git
    GIT_TAG 2.3.3
)
FetchContent_GetProperties(stp_repo)

if(NOT stp_repo_POPULATED)
    FetchContent_Populate(stp_repo)
endif()

set(ENABLE_PYTHON_INTERFACE OFF CACHE BOOL "Disable python IF" FORCE)
set(ONLY_SIMPLE ON CACHE BOOL "No Boost needed" FORCE)
set(NOCRYPTOMINISAT ON CACHE BOOL "No cryptominisat" FORCE)
add_subdirectory(${stp_repo_SOURCE_DIR} ${CMAKE_BINARY_DIR}/stp)
target_include_directories(stp PUBLIC 
  $<BUILD_INTERFACE:${stp_repo_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>
)
