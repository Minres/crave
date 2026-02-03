set(install_dir ${CMAKE_INSTALL_PREFIX})
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(install_dir ${CMAKE_BINARY_DIR}/solvers/minisat)
endif()
set(MINISAT_INSTALL_DIR ${install_dir} CACHE PATH "minisat install prefix" FORCE)

file(MAKE_DIRECTORY "${install_dir}/include")
file(MAKE_DIRECTORY "${install_dir}/lib")

ExternalProject_Add(minisat_ext
  GIT_REPOSITORY https://github.com/stp/minisat.git
  GIT_TAG 14c78206cd12d1d36b7e042fa758747c135670a4
  DOWNLOAD_EXTRACT_TIMESTAMP TRUE
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${install_dir}
  BUILD_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --parallel ${CRAVE_BUILD_JOBS}
  INSTALL_COMMAND ${CMAKE_COMMAND} --build <BINARY_DIR> --target install
  BUILD_BYPRODUCTS ${install_dir}/lib/libminisat.so
)

add_library(minisat UNKNOWN IMPORTED)
set_target_properties(minisat PROPERTIES
  IMPORTED_LOCATION ${install_dir}/lib/libminisat.so
  INTERFACE_INCLUDE_DIRECTORIES ${install_dir}/include
)
add_dependencies(minisat minisat_ext)

message(STATUS "Use MiniSat from ${install_dir}")
