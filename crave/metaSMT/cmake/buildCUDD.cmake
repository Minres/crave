include(ExternalProject)

set(install_dir ${CMAKE_INSTALL_PREFIX})
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(install_dir ${CMAKE_BINARY_DIR}/solvers/cudd)
endif()

include(GNUInstallDirs)
set(CUDD_LIBDIR "${install_dir}/${CMAKE_INSTALL_LIBDIR}")

file(MAKE_DIRECTORY "${install_dir}/include")
file(MAKE_DIRECTORY "${CUDD_LIBDIR}")

ExternalProject_Add(cudd_ext
    GIT_REPOSITORY https://github.com/nbruns1/cudd.git
    GIT_TAG cudd-3.0.0
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND bash -c "touch configure.ac aclocal.m4 configure Makefile.am Makefile.in && ./configure --enable-obj --enable-dddmp --prefix=${install_dir} --libdir=${CUDD_LIBDIR}"
    BUILD_COMMAND make -j${CRAVE_BUILD_JOBS}
    INSTALL_COMMAND make install
    BUILD_IN_SOURCE 1
    BUILD_BYPRODUCTS ${CUDD_LIBDIR}/libcudd.a
)

add_library(cudd UNKNOWN IMPORTED)
set_target_properties(cudd PROPERTIES
    IMPORTED_LOCATION ${CUDD_LIBDIR}/libcudd.a
    INTERFACE_INCLUDE_DIRECTORIES ${install_dir}/include
)
add_dependencies(cudd cudd_ext)
add_library(cudd::cudd ALIAS cudd)

message(STATUS "Use CUDD 3.0.0 from ${install_dir}")
