include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/buildGMP.cmake)

set(install_dir ${CMAKE_INSTALL_PREFIX})
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(install_dir ${CMAKE_BINARY_DIR}/solvers/cvc4)
endif()

file(MAKE_DIRECTORY "${install_dir}/include")
file(MAKE_DIRECTORY "${install_dir}/lib")
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

ExternalProject_Add(cvc4_ext
  GIT_REPOSITORY https://github.com/CVC4/CVC4-archived.git
  GIT_TAG 1.8
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
  CONFIGURE_COMMAND bash -c "./contrib/get-antlr-3.4 && ./configure.sh --python3 --prefix=${install_dir} --gmp-dir=${GMP_INSTALL_DIR}"
  BUILD_COMMAND bash -c "make -C build -j${CRAVE_BUILD_JOBS}"
  INSTALL_COMMAND bash -c "make -C build install"
  BUILD_IN_SOURCE 1
  BUILD_BYPRODUCTS ${install_dir}/lib/libcvc4.so.7
  DEPENDS gmp_ext
)

set(CVC4_FOUND TRUE CACHE BOOL "" FORCE)
set(CVC4_INCLUDE_DIRS "${install_dir}/include" CACHE PATH "" FORCE)

add_library(CVC4::cvc4 UNKNOWN IMPORTED)
set_target_properties(CVC4::cvc4 PROPERTIES
  IMPORTED_LOCATION ${install_dir}/lib/libcvc4.so.7
  INTERFACE_INCLUDE_DIRECTORIES ${install_dir}/include
  INTERFACE_LINK_LIBRARIES gmp::gmp
)
add_dependencies(CVC4::cvc4 cvc4_ext)

set(cvc4_CMAKE_CONFIG_DIR ${CMAKE_INSTALL_LIBDIR}/cmake/cvc4)
set(SOLVER_TARGET "CVC4::cvc4")
set(SOLVER_VARNAME "CVC4")
set(SOLVER_LIBNAME "libcvc4.so.7")
set(SOLVER_LIBDIR "lib")
set(SOLVER_INCLUDEDIR "include")
set(SOLVER_FIND_DEPS "find_dependency(gmp)")
set(SOLVER_SET_LINK_LIBS "set_property(TARGET CVC4::cvc4 APPEND PROPERTY INTERFACE_LINK_LIBRARIES gmp::gmp)")

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/cvc4-config-version.cmake
    VERSION 1.8
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    ${CMAKE_CURRENT_LIST_DIR}/solver-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/cvc4-config.cmake
    INSTALL_DESTINATION ${cvc4_CMAKE_CONFIG_DIR}
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/cvc4-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/cvc4-config-version.cmake
    DESTINATION ${cvc4_CMAKE_CONFIG_DIR}
)

message(STATUS "Use CVC4 1.8 from ${install_dir}")
