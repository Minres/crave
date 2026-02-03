include(ExternalProject)
include(FetchContent)

set(HELP2MAN_INSTALL_DIR ${CMAKE_INSTALL_PREFIX})
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(HELP2MAN_INSTALL_DIR ${CMAKE_BINARY_DIR}/solvers/help2man)
endif()

file(MAKE_DIRECTORY "${HELP2MAN_INSTALL_DIR}/bin")

ExternalProject_Add(help2man_ext
    URL http://ftp.gnu.org/gnu/help2man/help2man-1.49.3.tar.xz
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    CONFIGURE_COMMAND ./configure --prefix=${HELP2MAN_INSTALL_DIR}
    BUILD_COMMAND make -j${CRAVE_BUILD_JOBS}
    INSTALL_COMMAND make install
    BUILD_IN_SOURCE 1
    BUILD_BYPRODUCTS ${HELP2MAN_INSTALL_DIR}/bin/help2man
)

FetchContent_Declare(
    stp_repo
    GIT_REPOSITORY https://github.com/stp/stp.git
    GIT_TAG 2.3.4
)
FetchContent_GetProperties(stp_repo)

if(NOT stp_repo_POPULATED)
    FetchContent_Populate(stp_repo)
endif()

set(install_dir ${CMAKE_INSTALL_PREFIX})
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(install_dir ${CMAKE_BINARY_DIR}/solvers/stp)
endif()

include(GNUInstallDirs)
set(STP_LIBDIR "${install_dir}/${CMAKE_INSTALL_LIBDIR}")

file(MAKE_DIRECTORY "${install_dir}/include")
file(MAKE_DIRECTORY "${STP_LIBDIR}")

set(MINISAT_LIB "${MINISAT_INSTALL_DIR}/lib/libminisat.so")

ExternalProject_Add(stp_ext
    SOURCE_DIR ${stp_repo_SOURCE_DIR}
    DOWNLOAD_COMMAND ""
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${install_dir}
        -DCMAKE_INSTALL_LIBDIR=${CMAKE_INSTALL_LIBDIR}
        -DENABLE_PYTHON_INTERFACE=OFF
        -DONLY_SIMPLE=ON
        -DNOCRYPTOMINISAT=ON
        -DMINISAT_INCLUDE_DIR=${MINISAT_INSTALL_DIR}/include
        -DMINISAT_LIBRARY=${MINISAT_LIB}
        -DCMAKE_PROGRAM_PATH=${HELP2MAN_INSTALL_DIR}/bin
    BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --parallel ${CRAVE_BUILD_JOBS}
    INSTALL_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --target install
    BUILD_BYPRODUCTS ${STP_LIBDIR}/libstp.so.2.3
    DEPENDS minisat_ext help2man_ext
)

add_library(stp UNKNOWN IMPORTED)
set_target_properties(stp PROPERTIES
    IMPORTED_LOCATION ${STP_LIBDIR}/libstp.so.2.3
    INTERFACE_INCLUDE_DIRECTORIES ${install_dir}/include
)
add_dependencies(stp stp_ext)

message(STATUS "Use STP 2.3.4 from ${install_dir}")
