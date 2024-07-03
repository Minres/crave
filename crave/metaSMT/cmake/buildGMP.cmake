if(NOT TARGET gmp)
    FetchContent_Declare(
        gmp_repo
        URL https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz
    )
    FetchContent_GetProperties(gmp_repo)

    if(NOT gmp_repo_POPULATED)
        FetchContent_Populate(gmp_repo)
    endif()

    set(GMP_INSTALL_DIR ${CMAKE_INSTALL_PREFIX})
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        # Fallback in case where CMAKE_INSTALL_PREFIX is not explicitly set by the user
        set(GMP_INSTALL_DIR ${CMAKE_BINARY_DIR}/solvers/gmp)
    endif()

    execute_process(
        WORKING_DIRECTORY ${gmp_repo_SOURCE_DIR}
        COMMAND bash -c "./configure --prefix=${GMP_INSTALL_DIR} --enable-cxx && make -j && make install"
        RESULT_VARIABLE GMP_RESULT
        OUTPUT_VARIABLE GMP_OUTPUT
        ERROR_VARIABLE GMP_ERROR
    )

    # Check the result of the command
    if(NOT GMP_RESULT EQUAL 0)
        message(FATAL_ERROR "Failed to build GMP: ${GMP_OUTPUT} ${GMP_ERROR}")
    endif()

    add_custom_target(gmp_repo DEPENDS ${GMP_INSTALL_DIR}/lib/libgmpxx.a)
    add_library(gmp INTERFACE)
    target_include_directories(gmp INTERFACE ${GMP_INSTALL_DIR}/include)
    target_link_libraries(gmp INTERFACE ${GMP_INSTALL_DIR}/lib/libgmpxx.a)
    target_link_directories(gmp INTERFACE ${GMP_INSTALL_DIR}/lib)
    add_dependencies(gmp DEPENDS gmp_repo)
    add_library(gmp::gmp ALIAS gmp)    
    # install the target
    include(GNUInstallDirs)
    include(CMakePackageConfigHelpers)
    set(gmp_CMAKE_CONFIG_DIR ${CMAKE_INSTALL_LIBDIR}/cmake/gmp)

    install(TARGETS gmp EXPORT gmp-targets)

    install(
        EXPORT gmp-targets
        DESTINATION ${gmp_CMAKE_CONFIG_DIR}
    )

    configure_package_config_file(
        ${CMAKE_CURRENT_LIST_DIR}/gmp-config.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/gmp-config.cmake
        INSTALL_DESTINATION ${gmp_CMAKE_CONFIG_DIR}
    )
    
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/gmp-config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/gmp-config-version.cmake
        DESTINATION ${gmp_CMAKE_CONFIG_DIR})

endif()
