if(NOT MINISAT_MODULE_INCLUDED)
    set(MINISAT_MODULE_INCLUDED TRUE CACHE INTERNAL "Flag indicating whether Minisat module has already been included")
    set(minisat_install_dir ${CMAKE_BINARY_DIR}/_deps/minisat-install)
    execute_process(
        COMMAND mkdir -p ${minisat_install_dir}/include
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )

    if(NOT minisat_EXTERNAL_PROJECT_ADDED)
        ExternalProject_Add(
            minisat
            GIT_REPOSITORY https://github.com/stp/minisat.git
            GIT_TAG releases/2.2.1
            CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${minisat_install_dir} 
            )

        set(minisat_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()

    # Manually set Minisat include and library directories
    set(MINISAT_INCLUDE_DIRS ${minisat_install_dir}/include CACHE INTERNAL "Minisat include directories")
    set(MINISAT_LIBRARY_DIRS ${minisat_install_dir}/lib CACHE INTERNAL "Minisat library directories")

    add_library(minisat_git::minisat_git INTERFACE IMPORTED)
    target_include_directories(minisat_git::minisat_git INTERFACE ${MINISAT_INCLUDE_DIRS})
    target_link_libraries(minisat_git::minisat_git INTERFACE minisat)
    target_link_directories(minisat_git::minisat_git INTERFACE ${MINISAT_LIBRARY_DIRS})
    target_compile_definitions(minisat_git::minisat_git INTERFACE
        __STDC_LIMIT_MACROS
        __STDC_FORMAT_MACROS
    )
    message(STATUS "Use minisat from ${minisat_install_dir}")
endif()