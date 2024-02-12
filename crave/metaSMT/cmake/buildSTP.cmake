include(cmake/buildMiniSat.cmake)

FetchContent_Declare(
    stp_repo
    GIT_REPOSITORY https://github.com/stp/stp.git
    GIT_TAG 2.3.3
)
FetchContent_GetProperties(stp_repo)

if(NOT stp_repo_POPULATED)
    FetchContent_Populate(stp_repo)

    set(install_dir ${CMAKE_INSTALL_PREFIX})
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        # Fallback in case where CMAKE_INSTALL_PREFIX is not explicitly set by the user
        set(install_dir ${CMAKE_BINARY_DIR}/solvers/stp)
    endif()

    if(NOT stp_EXTERNAL_PROJECT_ADDED)
        execute_process(
            COMMAND mkdir -p ${install_dir}/include
            WORKING_DIRECTORY ${stp_repo_SOURCE_DIR}
        )

        ExternalProject_Add(
            stp
            BUILD_IN_SOURCE TRUE
            SOURCE_DIR ${stp_repo_SOURCE_DIR}
            CMAKE_ARGS -DENABLE_PYTHON_INTERFACE=off -DONLY_SIMPLE=on -DNOCRYPTOMINISAT=on -DCMAKE_INSTALL_PREFIX=${install_dir} -DMINISAT_INCLUDE_DIR=${MINISAT_INCLUDE_DIRS} -DMINISAT_LIBRARY=${MINISAT_LIBRARY_DIRS}/libminisat.so 
            DEPENDS minisat_git::minisat_git
        )

        set(stp_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()

    add_library(stp_git::stp_git INTERFACE IMPORTED)
    target_include_directories(stp_git::stp_git INTERFACE ${install_dir}/include)
    target_link_libraries(stp_git::stp_git INTERFACE stp)
    target_link_directories(stp_git::stp_git INTERFACE ${install_dir}/lib64)
    message(STATUS "Use STP from ${install_dir}")
endif()
