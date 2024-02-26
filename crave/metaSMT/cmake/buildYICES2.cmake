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
    COMMAND ./configure --prefix=${install_dir}
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
