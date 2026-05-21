# MetaSMT Source Staging for Export

# Directory for staging sources for export
set(METASMT_EXPORT_STAGING_DIR "${CMAKE_BINARY_DIR}/metasmt-export-staging")
# Final bundle path
set(METASMT_EXPORT_DEPS_BUNDLE "${CMAKE_BINARY_DIR}/metasmt-deps.tar.gz")

if(NOT METASMT_DEPS_DIR)
    # Internal target that prepares the staging area and collects dependency sources.
    add_custom_target(metasmt-export-deps-stage
        COMMAND ${CMAKE_COMMAND} -E remove_directory "${METASMT_EXPORT_STAGING_DIR}"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${METASMT_EXPORT_STAGING_DIR}"
        COMMENT "Preparing metaSMT dependency staging area"
    )

    # Public target to create the final bundle from the staging directory.
    add_custom_target(metasmt-export-deps
        DEPENDS metasmt-export-deps-stage
        COMMAND ${CMAKE_COMMAND} -E chdir "${METASMT_EXPORT_STAGING_DIR}" ${CMAKE_COMMAND} -E tar czf "${METASMT_EXPORT_DEPS_BUNDLE}" .
        COMMENT "Creating metaSMT dependency bundle: ${METASMT_EXPORT_DEPS_BUNDLE}"
    )
endif()

# Macro to register an ExternalProject for export
# Usage: metasmt_register_dep_for_export(solver_name target_name)
macro(metasmt_register_dep_for_export name target)
    if(NOT METASMT_DEPS_DIR)
        # Ensure we have the SOURCE_DIR property
        ExternalProject_Get_Property(${target} SOURCE_DIR)

        # Make the staging target depend on the download step of this solver.
        # This ensures sources are available before staging.
        if(TARGET ${target}-download)
            add_dependencies(metasmt-export-deps-stage ${target}-download)
        else()
            # Fallback for backends that don't use standard download steps (if any)
            add_dependencies(metasmt-export-deps-stage ${target})
        endif()

        add_custom_command(TARGET metasmt-export-deps-stage POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory "${METASMT_EXPORT_STAGING_DIR}/${name}"
            COMMAND ${CMAKE_COMMAND} -E copy_directory "${SOURCE_DIR}" "${METASMT_EXPORT_STAGING_DIR}/${name}"
            # Drop top-level Git metadata to keep the export bundle small and source-only.
            COMMAND ${CMAKE_COMMAND} -E remove_directory "${METASMT_EXPORT_STAGING_DIR}/${name}/.git"
            COMMENT "Staging ${name} source for export from ${SOURCE_DIR}"
        )
    endif()
endmacro()
