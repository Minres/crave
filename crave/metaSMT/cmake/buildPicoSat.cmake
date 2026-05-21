set(PICOSAT_SOURCE_ARGS
    URL https://fmv.jku.at/picosat/picosat-965.tar.gz
)

# Resolve local source if in offline mode
metasmt_resolve_local_source(picosat PICOSAT_SOURCE_ARGS)

FetchContent_Declare(
    picosat_repo
    ${PICOSAT_SOURCE_ARGS}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
FetchContent_GetProperties(picosat_repo)

if(NOT picosat_repo_POPULATED)
    FetchContent_Populate(picosat_repo)
endif()

execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/PicosatCMakeLists.txt CMakeLists.txt
    WORKING_DIRECTORY ${picosat_repo_SOURCE_DIR}
)

if(NOT METASMT_DEPS_DIR)
    # Stage the populated PicoSAT source tree directly because it does not use ExternalProject.
    add_custom_command(TARGET metasmt-export-deps-stage POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${METASMT_EXPORT_STAGING_DIR}/picosat"
        COMMAND ${CMAKE_COMMAND} -E copy_directory "${picosat_repo_SOURCE_DIR}" "${METASMT_EXPORT_STAGING_DIR}/picosat"
        COMMAND ${CMAKE_COMMAND} -E remove_directory "${METASMT_EXPORT_STAGING_DIR}/picosat/.git"
        COMMENT "Staging picosat source for export from ${picosat_repo_SOURCE_DIR}"
    )
endif()

add_subdirectory(${picosat_repo_SOURCE_DIR} ${CMAKE_BINARY_DIR}/picosat)

message(STATUS "Use PicoSAT 965 from ${CMAKE_INSTALL_PREFIX}")
