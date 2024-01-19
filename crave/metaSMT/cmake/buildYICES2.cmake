FetchContent_Declare(
    yices2_repo
    GIT_REPOSITORY https://github.com/SRI-CSL/yices2.git
    GIT_TAG Yices-2.6.4
)
FetchContent_GetProperties(yices2_repo)

if(NOT yices2_repo_POPULATED)
    FetchContent_Populate(yices2_repo)

    # install dir must be availble to configure time otherwise CMake will complain
    set(yices2_install_dir ${CMAKE_BINARY_DIR}/_deps/yices2_git-install)

    if(NOT yices2_EXTERNAL_PROJECT_ADDED)
        execute_process(
            COMMAND mkdir -p ${yices2_install_dir}/include
            COMMAND mkdir -p ${yices2_install_dir}/lib
            WORKING_DIRECTORY ${yices2_repo_SOURCE_DIR}
        )

        ExternalProject_Add(
            yices2
            BUILD_IN_SOURCE TRUE
            SOURCE_DIR ${yices2_repo_SOURCE_DIR}
            CONFIGURE_COMMAND autoconf
            COMMAND ./configure --prefix=${yices2_install_dir}
            BUILD_COMMAND make -j
            INSTALL_COMMAND make install -j
        )

        set(yices2_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()

    add_library(yices2_git::yices2_git INTERFACE IMPORTED)
    target_include_directories(yices2_git::yices2_git INTERFACE ${yices2_install_dir}/include)
    target_link_libraries(yices2_git::yices2_git INTERFACE yices)
    target_link_directories(yices2_git::yices2_git INTERFACE ${yices2_install_dir}/lib)
    message(STATUS "Use yices2 from ${yices2_install_dir}")
endif()
