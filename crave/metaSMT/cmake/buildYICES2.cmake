FetchContent_Declare(
    yices2_repo
    GIT_REPOSITORY https://github.com/SRI-CSL/yices2.git
    GIT_TAG Yices-2.6.4
)
FetchContent_GetProperties(yices2_repo)

if(NOT yices2_repo_POPULATED)
    FetchContent_Populate(yices2_repo)

    set(install_dir ${CMAKE_INSTALL_PREFIX}/solvers/yices2)
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        # Fallback in case where CMAKE_INSTALL_PREFIX is not explicitly set by the user
        set(install_dir ${CMAKE_BINARY_DIR}/solvers/yices2)
    endif()

    if(NOT yices2_EXTERNAL_PROJECT_ADDED)
        execute_process(
            COMMAND mkdir -p ${install_dir}/include
            COMMAND mkdir -p ${install_dir}/lib
            WORKING_DIRECTORY ${yices2_repo_SOURCE_DIR}
        )

        ExternalProject_Add(
            yices2
            BUILD_IN_SOURCE TRUE
            SOURCE_DIR ${yices2_repo_SOURCE_DIR}
            CONFIGURE_COMMAND autoconf
            COMMAND ./configure --prefix=${install_dir}
            BUILD_COMMAND make -j
            INSTALL_COMMAND make install -j
        )

        set(yices2_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()

    add_library(yices2_git::yices2_git INTERFACE IMPORTED)
    target_include_directories(yices2_git::yices2_git INTERFACE ${install_dir}/include)
    target_link_libraries(yices2_git::yices2_git INTERFACE yices)
    target_link_directories(yices2_git::yices2_git INTERFACE ${install_dir}/lib)
    message(STATUS "Use yices2 from ${install_dir}")
endif()
