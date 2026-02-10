set(install_dir ${CMAKE_INSTALL_PREFIX})
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(install_dir ${CMAKE_BINARY_DIR}/solvers/boolector)
endif()

file(MAKE_DIRECTORY "${install_dir}/include")
file(MAKE_DIRECTORY "${install_dir}/lib")
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

ExternalProject_Add(boolector_ext
  GIT_REPOSITORY https://github.com/Boolector/boolector.git
  GIT_TAG 3.2.3
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
  CONFIGURE_COMMAND bash -c "./contrib/setup-lingeling.sh && ./contrib/setup-btor2tools.sh && ./contrib/setup-cadical.sh && ./configure.sh --prefix ${install_dir} --shared"
  BUILD_COMMAND bash -c "make -C build -j${CRAVE_BUILD_JOBS}"
  INSTALL_COMMAND bash -c "make -C build install"
  BUILD_IN_SOURCE 1
  BUILD_BYPRODUCTS ${install_dir}/lib/libboolector.so
)

set(Boolector_VERSION 3.2.3 CACHE STRING "" FORCE)
set(Boolector_FOUND TRUE CACHE BOOL "" FORCE)
set(Boolector_INCLUDE_DIRS "${install_dir}/include" CACHE PATH "" FORCE)

add_library(Boolector::boolector UNKNOWN IMPORTED)
set_target_properties(Boolector::boolector PROPERTIES
  IMPORTED_LOCATION ${install_dir}/lib/libboolector.so
  INTERFACE_INCLUDE_DIRECTORIES ${install_dir}/include
)
add_dependencies(Boolector::boolector boolector_ext)

set(boolector_CMAKE_CONFIG_DIR ${CMAKE_INSTALL_LIBDIR}/cmake/boolector)
set(SOLVER_TARGET "Boolector::boolector")
set(SOLVER_VARNAME "Boolector")
set(SOLVER_LIBNAME "libboolector.so")
set(SOLVER_LIBDIR "lib")
set(SOLVER_INCLUDEDIR "include")
set(SOLVER_FIND_DEPS "")
set(SOLVER_SET_LINK_LIBS "")

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/boolector-config-version.cmake
    VERSION 3.2.3
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    ${CMAKE_CURRENT_LIST_DIR}/solver-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/boolector-config.cmake
    INSTALL_DESTINATION ${boolector_CMAKE_CONFIG_DIR}
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/boolector-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/boolector-config-version.cmake
    DESTINATION ${boolector_CMAKE_CONFIG_DIR}
)

message(STATUS "Use Boolector ${Boolector_VERSION} from ${install_dir}")
