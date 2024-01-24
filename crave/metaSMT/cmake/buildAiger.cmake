FetchContent_Declare(
    aiger_repo
    URL https://fmv.jku.at/aiger/aiger-20071012.zip
)
FetchContent_GetProperties(aiger_repo)

if(NOT aiger_repo_POPULATED)
    FetchContent_Populate(aiger_repo)

    # install dir must be availble to configure time otherwise CMake will complain
    set(aiger_install_dir ${CMAKE_BINARY_DIR}/_deps/aiger-install)
    if(NOT aiger_EXTERNAL_PROJECT_ADDED)
        execute_process(
            COMMAND mkdir -p ${aiger_install_dir}/include
            COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/AigerCMakeLists.txt CMakeLists.txt
            WORKING_DIRECTORY ${aiger_repo_SOURCE_DIR}
        )

        ExternalProject_Add(
            aiger
            BUILD_IN_SOURCE TRUE
            SOURCE_DIR ${aiger_repo_SOURCE_DIR}
            CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${aiger_install_dir}
        )

        set(aiger_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()

    add_library(aiger_git::aiger_git INTERFACE IMPORTED)
    target_include_directories(aiger_git::aiger_git INTERFACE ${aiger_install_dir}/include)
    target_link_libraries(aiger_git::aiger_git INTERFACE Aiger)
    target_link_directories(aiger_git::aiger_git INTERFACE ${aiger_install_dir}/lib)
    message(STATUS "Use aiger from ${aiger_install_dir}")
endif()
