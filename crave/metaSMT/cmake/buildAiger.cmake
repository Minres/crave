FetchContent_Declare(
    aiger_repo
    URL https://fmv.jku.at/aiger/aiger-20071012.zip
)
FetchContent_GetProperties(aiger_repo)

if(NOT aiger_repo_POPULATED)
    FetchContent_Populate(aiger_repo)

    set(install_dir ${CMAKE_INSTALL_PREFIX})
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        # Fallback in case where CMAKE_INSTALL_PREFIX is not explicitly set by the user
        set(install_dir ${CMAKE_BINARY_DIR}/solvers/aiger)
    endif()

    if(NOT aiger_EXTERNAL_PROJECT_ADDED)
        execute_process(
            COMMAND mkdir -p ${install_dir}/include
            COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/AigerCMakeLists.txt CMakeLists.txt
            WORKING_DIRECTORY ${aiger_repo_SOURCE_DIR}
        )

        ExternalProject_Add(
            aiger
            BUILD_IN_SOURCE TRUE
            SOURCE_DIR ${aiger_repo_SOURCE_DIR}
            CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${install_dir}
        )

        set(aiger_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()

    add_library(aiger_git::aiger_git INTERFACE IMPORTED)
    target_include_directories(aiger_git::aiger_git INTERFACE ${install_dir}/include)
    target_link_libraries(aiger_git::aiger_git INTERFACE Aiger)
    target_link_directories(aiger_git::aiger_git INTERFACE ${install_dir}/lib)
    message(STATUS "Use aiger from ${install_dir}")
endif()
