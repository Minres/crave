# pull the git repo
FetchContent_Declare(
    cudd_repo
    GIT_REPOSITORY https://github.com/nbruns1/cudd.git
    GIT_TAG cudd-3.0.0
)
FetchContent_GetProperties(cudd_repo)
if(NOT cudd_repo_POPULATED)
    FetchContent_Populate(cudd_repo)
endif()
set(install_dir ${CMAKE_INSTALL_PREFIX})
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    # Fallback in case where CMAKE_INSTALL_PREFIX is not explicitly set by the user
    set(install_dir ${CMAKE_BINARY_DIR}/solvers/cudd)
endif()
# build the cudd library
add_custom_command(
  OUTPUT ${install_dir}/lib/libcudd.a
  WORKING_DIRECTORY ${cudd_repo_SOURCE_DIR}
  COMMAND touch configure.ac aclocal.m4 configure Makefile.am Makefile.in
  COMMAND ./configure --enable-obj --enable-dddmp --prefix=${install_dir}
  COMMAND make -j
  COMMAND make install
  COMMENT "Building CUDD library"
  USES_TERMINAL
)
add_custom_target(cudd_git DEPENDS ${install_dir}/lib/libcudd.a)
# declare the cudd target
add_library(cudd INTERFACE)
target_include_directories(cudd INTERFACE ${install_dir}/include)
target_link_libraries(cudd INTERFACE ${install_dir}/lib/libcudd.a)
target_link_directories(cudd INTERFACE ${install_dir}/lib)
add_dependencies(cudd cudd_git)
add_library(cudd::cudd ALIAS cudd)
# install the target
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
set(cudd_CMAKE_CONFIG_DIR ${CMAKE_INSTALL_LIBDIR}/cmake/cudd)

install(TARGETS cudd EXPORT cudd-targets)

install(
  EXPORT cudd-targets
  DESTINATION ${cudd_CMAKE_CONFIG_DIR}
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/cudd-config-version.cmake
    VERSION 3.0.0
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    ${CMAKE_CURRENT_LIST_DIR}/cudd-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/cudd-config.cmake
    INSTALL_DESTINATION ${cudd_CMAKE_CONFIG_DIR}
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/cudd-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/cudd-config-version.cmake
    DESTINATION ${cudd_CMAKE_CONFIG_DIR})
