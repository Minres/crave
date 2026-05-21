set(LINGELING_SOURCE_ARGS
    URL https://fmv.jku.at/lingeling/lingeling-ayv-86bf266-140429.zip
)

# Resolve local source if in offline mode
metasmt_resolve_local_source(lingeling LINGELING_SOURCE_ARGS)

FetchContent_Declare(
    lingeling_repo
    ${LINGELING_SOURCE_ARGS}
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
FetchContent_GetProperties(lingeling_repo)

if(NOT lingeling_repo_POPULATED)
    FetchContent_Populate(lingeling_repo)
endif()

execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/LingelingCMakeLists.txt CMakeLists.txt
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/lglcfg.h.in.cmake .
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_DIR}/lglcflags.h.in.cmake .
    WORKING_DIRECTORY ${lingeling_repo_SOURCE_DIR}
)

if(NOT METASMT_DEPS_DIR)
    # Stage the populated Lingeling source tree directly because it does not use ExternalProject.
    add_custom_command(TARGET metasmt-export-deps-stage POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${METASMT_EXPORT_STAGING_DIR}/lingeling"
        COMMAND ${CMAKE_COMMAND} -E copy_directory "${lingeling_repo_SOURCE_DIR}" "${METASMT_EXPORT_STAGING_DIR}/lingeling"
        COMMAND ${CMAKE_COMMAND} -E remove_directory "${METASMT_EXPORT_STAGING_DIR}/lingeling/.git"
        COMMENT "Staging lingeling source for export from ${lingeling_repo_SOURCE_DIR}"
    )
endif()

add_subdirectory(${lingeling_repo_SOURCE_DIR} ${CMAKE_BINARY_DIR}/lingeling)

message(STATUS "Use Lingeling ayv-86bf266-140429 from ${CMAKE_INSTALL_PREFIX}")
