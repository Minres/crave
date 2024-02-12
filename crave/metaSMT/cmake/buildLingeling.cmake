FetchContent_Declare(
    lingeling_repo
    URL https://fmv.jku.at/lingeling/lingeling-ayv-86bf266-140429.zip
)
FetchContent_GetProperties(lingeling_repo)

if(NOT lingeling_repo_POPULATED)
    FetchContent_Populate(lingeling_repo)

    set(install_dir ${CMAKE_INSTALL_PREFIX})
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        # Fallback in case where CMAKE_INSTALL_PREFIX is not explicitly set by the user
        set(install_dir ${CMAKE_BINARY_DIR}/solvers/lingeling)
    endif()

    if(NOT lingeling_EXTERNAL_PROJECT_ADDED)
        execute_process(
            COMMAND mkdir -p ${install_dir}/include
            COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/LingelingCMakeLists.txt CMakeLists.txt
            COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/lglcfg.h.in.cmake .
            COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/lglcflags.h.in.cmake .
            WORKING_DIRECTORY ${lingeling_repo_SOURCE_DIR}
        )

        ExternalProject_Add(
            lingeling
            BUILD_IN_SOURCE TRUE
            SOURCE_DIR ${lingeling_repo_SOURCE_DIR}
            CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${install_dir}
        )

        set(lingeling_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()

    add_library(lingeling_git::lingeling_git INTERFACE IMPORTED)
    target_include_directories(lingeling_git::lingeling_git INTERFACE ${install_dir}/include)
    target_link_libraries(lingeling_git::lingeling_git INTERFACE lingeling)
    target_link_directories(lingeling_git::lingeling_git INTERFACE ${install_dir}/lib)
    message(STATUS "Use lingeling from ${install_dir}")
endif()
