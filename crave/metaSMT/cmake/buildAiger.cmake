set(AIGER_SOURCE_ARGS
    URL https://fmv.jku.at/aiger/aiger-20071012.zip
)

# Resolve local source if in offline mode
metasmt_resolve_local_source(aiger AIGER_SOURCE_ARGS)

FetchContent_Declare(
    aiger_repo
    ${AIGER_SOURCE_ARGS}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
FetchContent_GetProperties(aiger_repo)

if(NOT aiger_repo_POPULATED)
    FetchContent_Populate(aiger_repo)
endif()

execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/AigerCMakeLists.txt CMakeLists.txt
    WORKING_DIRECTORY ${aiger_repo_SOURCE_DIR}
)

if(NOT METASMT_DEPS_DIR)
    # Stage the populated Aiger source tree directly because it does not use ExternalProject.
    add_custom_command(TARGET metasmt-export-deps-stage POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${METASMT_EXPORT_STAGING_DIR}/aiger"
        COMMAND ${CMAKE_COMMAND} -E copy_directory "${aiger_repo_SOURCE_DIR}" "${METASMT_EXPORT_STAGING_DIR}/aiger"
        COMMAND ${CMAKE_COMMAND} -E remove_directory "${METASMT_EXPORT_STAGING_DIR}/aiger/.git"
        COMMENT "Staging aiger source for export from ${aiger_repo_SOURCE_DIR}"
    )
endif()

add_subdirectory(${aiger_repo_SOURCE_DIR} ${CMAKE_BINARY_DIR}/aiger)

message(STATUS "Use Aiger 20071012 from ${CMAKE_INSTALL_PREFIX}")
