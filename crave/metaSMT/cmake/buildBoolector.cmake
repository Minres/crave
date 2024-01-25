FetchContent_Declare(
    boolector_repo
    GIT_REPOSITORY https://github.com/Boolector/boolector.git
    GIT_TAG 3.2.3
)
FetchContent_GetProperties(boolector_repo)

if(NOT boolector_repo_POPULATED)
    FetchContent_Populate(boolector_repo)

    set(boolector_install_dir ${CMAKE_BINARY_DIR}/_deps/boolector-install)
    if(NOT boolector_EXTERNAL_PROJECT_ADDED)
        execute_process(
            COMMAND ./contrib/setup-lingeling.sh 
            COMMAND ./contrib/setup-btor2tools.sh 
            COMMAND ./contrib/setup-cadical.sh 
            WORKING_DIRECTORY ${boolector_repo_SOURCE_DIR}
        )

        execute_process(
            COMMAND ./configure.sh --prefix ${boolector_install_dir} --shared
            WORKING_DIRECTORY ${boolector_repo_SOURCE_DIR}
            RESULT_VARIABLE CONFIGURE_RESULT
            OUTPUT_VARIABLE CONFIGURE_OUTPUT
        )
        
        if (CONFIGURE_RESULT)
            message(FATAL_ERROR "Boolector configure failed. Output:\n${CONFIGURE_OUTPUT}")
        endif()

        execute_process(
            COMMAND make -C build -j install
            WORKING_DIRECTORY ${boolector_repo_SOURCE_DIR}
        )
        set(boolector_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()

    find_package(Boolector REQUIRED HINTS ${boolector_install_dir}/lib/cmake)
    message(STATUS "Use boolector from ${boolector_install_dir}")
endif()




