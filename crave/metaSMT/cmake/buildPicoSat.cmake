FetchContent_Declare(
    picosat_repo
    URL https://fmv.jku.at/picosat/picosat-936.tar.gz
)
FetchContent_GetProperties(picosat_repo)

if(NOT picosat_repo_POPULATED)
    FetchContent_Populate(picosat_repo)

    # install dir must be availble to configure time otherwise CMake will complain
    set(picosat_install_dir ${CMAKE_BINARY_DIR}/_deps/picosat-install)
    if(NOT picosat_EXTERNAL_PROJECT_ADDED)
        execute_process(
            COMMAND mkdir -p ${picosat_install_dir}/include
            COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/PicosatCMakeLists.txt CMakeLists.txt
            WORKING_DIRECTORY ${picosat_repo_SOURCE_DIR}
        )

        ExternalProject_Add(
            picosat
            BUILD_IN_SOURCE TRUE
            SOURCE_DIR ${picosat_repo_SOURCE_DIR}
            CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${picosat_install_dir}
        )

        set(picosat_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()

    add_library(picosat_git::picosat_git INTERFACE IMPORTED)
    target_include_directories(picosat_git::picosat_git INTERFACE ${picosat_install_dir}/include)
    target_link_libraries(picosat_git::picosat_git INTERFACE picosat)
    target_link_directories(picosat_git::picosat_git INTERFACE ${picosat_install_dir}/lib)
    message(STATUS "Use picosat from ${picosat_install_dir}")
endif()
