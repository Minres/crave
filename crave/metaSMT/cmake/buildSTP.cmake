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
