FetchContent_Declare(
    picosat_repo
    URL https://fmv.jku.at/picosat/picosat-965.tar.gz
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

add_subdirectory(${picosat_repo_SOURCE_DIR} ${CMAKE_BINARY_DIR}/picosat)

message(STATUS "Use PicoSAT 965 from ${CMAKE_INSTALL_PREFIX}")
