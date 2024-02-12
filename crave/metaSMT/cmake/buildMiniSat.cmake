if(NOT DEFINED MINISAT_MODULE_INCLUDED)
    set(MINISAT_MODULE_INCLUDED TRUE INTERNAL "Flag indicating whether Minisat module has already been included")

    FetchContent_Declare(
        minisat_repo
        GIT_REPOSITORY https://github.com/stp/minisat.git
        GIT_TAG releases/2.2.1
    )
    FetchContent_GetProperties(minisat_repo)
    FetchContent_Populate(minisat_repo)

    set(install_dir ${CMAKE_INSTALL_PREFIX})
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        # Fallback in case where CMAKE_INSTALL_PREFIX is not explicitly set by the user
        set(install_dir ${CMAKE_BINARY_DIR}/solvers/minisat)
    endif()
    execute_process(
        COMMAND mkdir -p ${install_dir}/include
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )

    if(NOT minisat_EXTERNAL_PROJECT_ADDED)
        ExternalProject_Add(
            minisat
            SOURCE_DIR ${minisat_repo_SOURCE_DIR}
            CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${install_dir} 
        )
        set(minisat_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()

    # Manually set Minisat include and library directories
    set(MINISAT_INCLUDE_DIRS ${install_dir}/include CACHE INTERNAL "Minisat include directories")
    set(MINISAT_LIBRARY_DIRS ${install_dir}/lib CACHE INTERNAL "Minisat library directories")

    add_library(minisat_git::minisat_git INTERFACE IMPORTED)
    target_include_directories(minisat_git::minisat_git INTERFACE ${MINISAT_INCLUDE_DIRS})
    target_link_libraries(minisat_git::minisat_git INTERFACE minisat)
    target_link_directories(minisat_git::minisat_git INTERFACE ${MINISAT_LIBRARY_DIRS})
    target_compile_definitions(minisat_git::minisat_git INTERFACE
        __STDC_LIMIT_MACROS
        __STDC_FORMAT_MACROS
    )
    message(STATUS "Use minisat from ${install_dir}")
endif()