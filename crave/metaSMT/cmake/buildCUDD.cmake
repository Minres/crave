FetchContent_Declare(
    cudd_repo
    GIT_REPOSITORY https://github.com/nbruns1/cudd.git
    GIT_TAG cudd-3.0.0
)
FetchContent_GetProperties(cudd_repo)

if(NOT cudd_repo_POPULATED)
    FetchContent_Populate(cudd_repo)

    # install dir must be availble to configure time otherwise CMake will complain
    set(cudd_install_dir ${CMAKE_BINARY_DIR}/_deps/cudd_git-install)

    if(NOT CUDD_EXTERNAL_PROJECT_ADDED)
        execute_process(
            COMMAND mkdir -p ${cudd_install_dir}/include
            COMMAND mkdir -p ${cudd_install_dir}/lib
            WORKING_DIRECTORY ${cudd_repo_SOURCE_DIR}
        )

        ExternalProject_Add(
            cudd
            BUILD_IN_SOURCE TRUE
            SOURCE_DIR ${cudd_repo_SOURCE_DIR}
            CONFIGURE_COMMAND touch configure.ac aclocal.m4 configure Makefile.am Makefile.in
            COMMAND ./configure --enable-obj --enable-dddmp --prefix=${cudd_install_dir}
            BUILD_COMMAND make -j
            INSTALL_COMMAND make install -j
        )

        set(CUDD_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()

    add_library(cudd_git::cudd_git INTERFACE IMPORTED)
    target_include_directories(cudd_git::cudd_git INTERFACE ${cudd_install_dir}/include)
    target_link_libraries(cudd_git::cudd_git INTERFACE cudd)
    target_link_directories(cudd_git::cudd_git INTERFACE ${cudd_install_dir}/lib)
    message(STATUS "Use CUDD from ${cudd_install_dir}")
endif()
