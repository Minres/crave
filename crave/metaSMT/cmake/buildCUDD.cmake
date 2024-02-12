FetchContent_Declare(
    cudd_repo
    GIT_REPOSITORY https://github.com/nbruns1/cudd.git
    GIT_TAG cudd-3.0.0
)
FetchContent_GetProperties(cudd_repo)

if(NOT cudd_repo_POPULATED)
    FetchContent_Populate(cudd_repo)

    set(install_dir ${CMAKE_INSTALL_PREFIX})
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        # Fallback in case where CMAKE_INSTALL_PREFIX is not explicitly set by the user
        set(install_dir ${CMAKE_BINARY_DIR}/solvers/cudd)
    endif()

    if(NOT CUDD_EXTERNAL_PROJECT_ADDED)
        execute_process(
            COMMAND mkdir -p ${install_dir}/include
            COMMAND mkdir -p ${install_dir}/lib
            WORKING_DIRECTORY ${cudd_repo_SOURCE_DIR}
        )

        ExternalProject_Add(
            cudd
            BUILD_IN_SOURCE TRUE
            SOURCE_DIR ${cudd_repo_SOURCE_DIR}
            CONFIGURE_COMMAND touch configure.ac aclocal.m4 configure Makefile.am Makefile.in
            COMMAND ./configure --enable-obj --enable-dddmp --prefix=${install_dir}
            BUILD_COMMAND make -j
            INSTALL_COMMAND make install -j
        )

        set(CUDD_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()

    add_library(cudd_git::cudd_git INTERFACE IMPORTED)
    target_include_directories(cudd_git::cudd_git INTERFACE ${install_dir}/include)
    target_link_libraries(cudd_git::cudd_git INTERFACE cudd)
    target_link_directories(cudd_git::cudd_git INTERFACE ${install_dir}/lib)
    message(STATUS "Use CUDD from ${install_dir}")
endif()
