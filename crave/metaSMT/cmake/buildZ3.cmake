FetchContent_Declare(
  z3_git
  GIT_REPOSITORY https://github.com/Z3Prover/z3.git
  GIT_TAG z3-4.6.0
)
FetchContent_GetProperties(z3_git)

if(NOT z3_git_POPULATED)
  FetchContent_Populate(z3_git)

  set(install_dir ${CMAKE_INSTALL_PREFIX})
  if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
      # Fallback in case where CMAKE_INSTALL_PREFIX is not explicitly set by the user
      set(install_dir ${CMAKE_BINARY_DIR}/solvers/z3)
  endif()

  if(NOT Z3_EXTERNAL_PROJECT_ADDED)
    execute_process(
      COMMAND mkdir -p ${install_dir}/include
      COMMAND ${CMAKE_COMMAND} -E make_directory ${install_dir}/lib
      COMMAND git apply -p0 ${CMAKE_CURRENT_LIST_DIR}/z3-z3-4.6.0__permutation_matrix.patch
      WORKING_DIRECTORY ${z3_git_SOURCE_DIR}
    )

    ExternalProject_Add(
      z3
      BUILD_IN_SOURCE = TRUE
      SOURCE_DIR ${z3_git_SOURCE_DIR}
      CONFIGURE_COMMAND ./configure --staticlib --prefix=${install_dir}
      BUILD_COMMAND make -C build -j
      INSTALL_COMMAND make -C build install -j
    )
    set(Z3_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
  endif()

  set(Z3_CMAKE_CONFIG_DIR ${CMAKE_INSTALL_LIBDIR}/cmake/z3)

  add_library(z3_git INTERFACE)
  target_include_directories(z3_git INTERFACE ${install_dir}/include)
  target_link_libraries(z3_git INTERFACE z3)
  target_link_directories(z3_git INTERFACE ${install_dir}/lib)
  message(STATUS "Use Z3 from ${install_dir}")

  include(GNUInstallDirs)
  install(TARGETS z3_git EXPORT z3_git-targets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )
  add_library(z3_git::z3_git ALIAS z3_git)
  include(CMakePackageConfigHelpers)

  install(EXPORT z3_git-targets
    DESTINATION ${Z3_CMAKE_CONFIG_DIR})

  find_package(OpenMP)

  if(OPENMP_FOUND)
    message(STATUS "Use Z3 with OpenMP")
  else()
    message(STATUS "Use Z3 without OpenMP")
  endif()
endif()
