FetchContent_Declare(
  z3_git
  GIT_REPOSITORY https://github.com/Z3Prover/z3.git
  GIT_TAG z3-4.6.0
)
FetchContent_GetProperties(z3_git)
if(NOT riscvfw_POPULATED)
    FetchContent_Populate(z3_git)
endif()
set(install_dir ${CMAKE_INSTALL_PREFIX})
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    # Fallback in case where CMAKE_INSTALL_PREFIX is not explicitly set by the user
    set(install_dir ${CMAKE_BINARY_DIR}/solvers/z3)
endif()

find_package(Threads REQUIRED)
find_package(OpenMP)

if(OPENMP_FOUND)
  message(STATUS "Use Z3 with OpenMP")
else()
  set(Z3_OPENMP --noomp)
  message(STATUS "Use Z3 without OpenMP")
endif()

add_custom_command(
  OUTPUT ${install_dir}/lib/libz3.a
  WORKING_DIRECTORY ${z3_git_SOURCE_DIR}
  COMMAND git reset --hard HEAD
  COMMAND git apply -p0 ${CMAKE_CURRENT_LIST_DIR}/z3-z3-4.6.0__permutation_matrix.patch
  COMMAND ./configure --staticlib ${Z3_OPENMP} --prefix=${install_dir}
  COMMAND make -C build -j
  COMMAND make -C build install
  COMMENT "Building Z3 library"
  USES_TERMINAL
)
add_custom_target(z3_git DEPENDS ${install_dir}/lib/libz3.a)
add_library(z3 INTERFACE)
target_include_directories(z3 INTERFACE ${install_dir}/include)
target_link_libraries(z3 INTERFACE ${install_dir}/lib/libz3.a)
if(OPENMP_FOUND)
  target_link_libraries(z3 INTERFACE OpenMP::OpenMP_CXX)
endif()
target_link_libraries(z3 INTERFACE Threads::Threads)
target_link_directories(z3 INTERFACE ${install_dir}/lib)
add_dependencies(z3 DEPENDS z3_git)
add_library(z3::z3 ALIAS z3)

message(STATUS "Use Z3 from ${install_dir}")

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
set(z3_CMAKE_CONFIG_DIR ${CMAKE_INSTALL_LIBDIR}/cmake/z3)

install(TARGETS z3 EXPORT z3-targets)

install(
  EXPORT z3-targets
  DESTINATION ${z3_CMAKE_CONFIG_DIR}
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/z3-config-version.cmake
    VERSION 4.6.0
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    ${CMAKE_CURRENT_LIST_DIR}/z3-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/z3-config.cmake
    INSTALL_DESTINATION ${z3_CMAKE_CONFIG_DIR}
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/z3-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/z3-config-version.cmake
    DESTINATION ${z3_CMAKE_CONFIG_DIR})
