# MetaSMT Source Staging for Export

# Directory for staging sources for export
set(METASMT_EXPORT_STAGING_DIR "${CMAKE_BINARY_DIR}/metasmt-export-staging")
# Final bundle path
set(METASMT_EXPORT_DEPS_BUNDLE "${CMAKE_BINARY_DIR}/metasmt-deps.tar.gz")

# Target to create the staging directory
add_custom_target(metasmt-export-deps
    COMMAND ${CMAKE_COMMAND} -E make_directory "${METASMT_EXPORT_STAGING_DIR}"
    COMMENT "Preparing metaSMT dependency staging area"
)

# Target to create the final bundle from the staging directory
add_custom_target(metasmt-export-deps-bundle
    DEPENDS metasmt-export-deps
    COMMAND ${CMAKE_COMMAND} -E chdir "${METASMT_EXPORT_STAGING_DIR}" ${CMAKE_COMMAND} -E tar czf "${METASMT_EXPORT_DEPS_BUNDLE}" .
    COMMENT "Creating metaSMT dependency bundle: ${METASMT_EXPORT_DEPS_BUNDLE}"
)

# Macro to register an ExternalProject for export
# Usage: metasmt_register_dep_for_export(solver_name target_name)
macro(metasmt_register_dep_for_export name target)
    if(NOT METASMT_DEPS_DIR)
        # Only stage for export if we are NOT already in offline mode
        # (Exporting an offline bundle is redundant)
        
        # Ensure we have the SOURCE_DIR property
        ExternalProject_Get_Property(${target} SOURCE_DIR)
        
        # Make the export target depend on the download step of this solver
        # This ensures sources are available before staging
        if(TARGET ${target}-download)
            add_dependencies(metasmt-export-deps ${target}-download)
        else()
            # Fallback for backends that don't use standard download steps (if any)
            add_dependencies(metasmt-export-deps ${target})
        endif()

        add_custom_command(TARGET metasmt-export-deps POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory "${METASMT_EXPORT_STAGING_DIR}/${name}"
            COMMAND ${CMAKE_COMMAND} -E copy_directory "${SOURCE_DIR}" "${METASMT_EXPORT_STAGING_DIR}/${name}"
            COMMENT "Staging ${name} source for export from ${SOURCE_DIR}"
        )
    endif()
endmacro()
