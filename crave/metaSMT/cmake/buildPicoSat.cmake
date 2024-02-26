FetchContent_Declare(
    picosat_repo
    URL https://fmv.jku.at/picosat/picosat-936.tar.gz
)
FetchContent_GetProperties(picosat_repo)

if(NOT picosat_repo_POPULATED)
    FetchContent_Populate(picosat_repo)
endif()

execute_process(
    COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/PicosatCMakeLists.txt CMakeLists.txt
    COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/picosat-config.cmake.in .
    WORKING_DIRECTORY ${picosat_repo_SOURCE_DIR}
)

add_subdirectory(${picosat_repo_SOURCE_DIR} ${CMAKE_BINARY_DIR}/picosat)