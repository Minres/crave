set(install_dir ${CMAKE_INSTALL_PREFIX})
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(install_dir ${CMAKE_BINARY_DIR}/solvers/boolector)
endif()

file(MAKE_DIRECTORY "${install_dir}/include")
file(MAKE_DIRECTORY "${install_dir}/lib")

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

message(STATUS "Use Boolector ${Boolector_VERSION} from ${install_dir}")
