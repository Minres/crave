FetchContent_Declare(
    cvc4_repo
    GIT_REPOSITORY https://github.com/CVC4/CVC4-archived.git
    GIT_TAG 1.8
)
FetchContent_GetProperties(cvc4_repo)

if(NOT cvc4_repo_POPULATED)
    FetchContent_Populate(cvc4_repo)

    # install dir must be availble to configure time otherwise CMake will complain
    set(cvc4_install_dir ${CMAKE_BINARY_DIR}/_deps/cvc4_git-install)

    if(NOT cvc4_EXTERNAL_PROJECT_ADDED)
        execute_process(
            COMMAND mkdir -p ${cvc4_install_dir}/include
            COMMAND mkdir -p ${cvc4_install_dir}/lib
            WORKING_DIRECTORY ${cvc4_repo_SOURCE_DIR}
        )

        ExternalProject_Add(
            cvc4
            BUILD_IN_SOURCE TRUE
            SOURCE_DIR ${cvc4_repo_SOURCE_DIR}
            CONFIGURE_COMMAND contrib/get-antlr-3.4
            COMMAND ./configure.sh --prefix=${cvc4_install_dir}
            BUILD_COMMAND make -C build -j
            INSTALL_COMMAND make -C build install -j
        )

        set(cvc4_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()

    add_library(cvc4_git::cvc4_git INTERFACE IMPORTED)
    target_include_directories(cvc4_git::cvc4_git INTERFACE ${cvc4_install_dir}/include)
    target_link_libraries(cvc4_git::cvc4_git INTERFACE cvc4)
    target_link_directories(cvc4_git::cvc4_git INTERFACE ${cvc4_install_dir}/lib)
    message(STATUS "CVC4 version without boolean operator IFF")
    target_compile_definitions(cvc4_git::cvc4_git INTERFACE CVC4_WITHOUT_KIND_IFF)

    find_package(GMP QUIET)
    if(NOT GMP_FOUND)
        find_library(GMP_LIBRARIES gmp PATHS ${GMP_DIR})
        find_library(GMPXX_LIBRARIES gmpxx PATHS ${GMP_DIR})
        target_link_libraries(cvc4_git::cvc4_git INTERFACE ${GMP_LIBRARIES} ${GMPXX_LIBRARIES})
    endif()
    message(STATUS "Use cvc4 from ${cvc4_install_dir}")
endif()
