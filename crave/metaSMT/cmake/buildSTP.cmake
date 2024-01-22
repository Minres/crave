FetchContent_Declare(
    stp_repo
    GIT_REPOSITORY https://github.com/stp/stp.git
    GIT_TAG 2.3.3
)
FetchContent_GetProperties(stp_repo)

if(NOT stp_repo_POPULATED)
    FetchContent_Populate(stp_repo)

    # install dir must be availble to configure time otherwise CMake will complain
    set(stp_install_dir ${CMAKE_BINARY_DIR}/_deps/stp-install)

    if(NOT stp_EXTERNAL_PROJECT_ADDED)
        execute_process(
            COMMAND mkdir -p ${stp_install_dir}/include
            WORKING_DIRECTORY ${stp_repo_SOURCE_DIR}
        )

        set(minisat_install_dir ${CMAKE_BINARY_DIR}/_deps/minisat_ep-install)
        ExternalProject_Add(
            minisat
            GIT_REPOSITORY https://github.com/stp/minisat.git
            GIT_TAG releases/2.2.1
            CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${minisat_install_dir} 
            )

        ExternalProject_Add(
            stp
            BUILD_IN_SOURCE TRUE
            SOURCE_DIR ${stp_repo_SOURCE_DIR}
            CMAKE_ARGS -DENABLE_PYTHON_INTERFACE=off -DONLY_SIMPLE=on -DNOCRYPTOMINISAT=on -DCMAKE_INSTALL_PREFIX=${stp_install_dir} -DMINISAT_INCLUDE_DIR=${minisat_install_dir}/include -DMINISAT_LIBRARY=${minisat_install_dir}/lib/libminisat.so 
            DEPENDS minisat
        )

        set(stp_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()

    add_library(stp_git::stp_git INTERFACE IMPORTED)
    target_include_directories(stp_git::stp_git INTERFACE ${stp_install_dir}/include)
    target_link_libraries(stp_git::stp_git INTERFACE stp)
    target_link_directories(stp_git::stp_git INTERFACE ${stp_install_dir}/lib64)
    message(STATUS "Use STP from ${stp_install_dir}")
endif()
