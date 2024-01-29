FetchContent_Declare(
    lingeling_repo
    URL https://fmv.jku.at/lingeling/lingeling-ayv-86bf266-140429.zip
)
FetchContent_GetProperties(lingeling_repo)

if(NOT lingeling_repo_POPULATED)
    FetchContent_Populate(lingeling_repo)

    # install dir must be availble to configure time otherwise CMake will complain
    set(lingeling_install_dir ${CMAKE_BINARY_DIR}/_deps/lingeling-install)
    if(NOT lingeling_EXTERNAL_PROJECT_ADDED)
        execute_process(
            COMMAND mkdir -p ${lingeling_install_dir}/include
            COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/LingelingCMakeLists.txt CMakeLists.txt
            COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/lglcfg.h.in.cmake .
            COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/lglcflags.h.in.cmake .
            WORKING_DIRECTORY ${lingeling_repo_SOURCE_DIR}
        )

        ExternalProject_Add(
            lingeling
            BUILD_IN_SOURCE TRUE
            SOURCE_DIR ${lingeling_repo_SOURCE_DIR}
            CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${lingeling_install_dir}
        )

        set(lingeling_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()

    add_library(lingeling_git::lingeling_git INTERFACE IMPORTED)
    target_include_directories(lingeling_git::lingeling_git INTERFACE ${lingeling_install_dir}/include)
    target_link_libraries(lingeling_git::lingeling_git INTERFACE lingeling)
    target_link_directories(lingeling_git::lingeling_git INTERFACE ${lingeling_install_dir}/lib)
    message(STATUS "Use lingeling from ${lingeling_install_dir}")
endif()
