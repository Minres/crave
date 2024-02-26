FetchContent_Declare(
    stp_repo
    GIT_REPOSITORY https://github.com/stp/stp.git
    GIT_TAG 2.3.3
)
FetchContent_GetProperties(stp_repo)

if(NOT stp_repo_POPULATED)
    FetchContent_Populate(stp_repo)
endif()

option(ENABLE_PYTHON_INTERFACE OFF)
option(ONLY_SIMPLE ON)
option(NOCRYPTOMINISAT ON)
add_subdirectory(${stp_repo_SOURCE_DIR} ${CMAKE_BINARY_DIR}/stp)
target_include_directories(stp PUBLIC 
  $<BUILD_INTERFACE:${stp_repo_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>
)
