# MetaSMT Offline Resolution Helpers

# Macro to resolve local source directory if METASMT_DEPS_DIR is set
# Usage: metasmt_resolve_local_source(solver_name out_var)
macro(metasmt_resolve_local_source name out_var)
    if(METASMT_DEPS_DIR)
        set(_local_source "${METASMT_DEPS_DIR}/${name}")
        if(NOT IS_DIRECTORY "${_local_source}")
            message(FATAL_ERROR "Offline mode: ${name} source directory not found at ${_local_source}")
        endif()
        set(${out_var} SOURCE_DIR "${_local_source}")
        message(STATUS "Offline mode: Using local source for ${name} from ${_local_source}")
    endif()
endmacro()
