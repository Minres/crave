FetchContent_Declare(
    aiger_repo
    URL https://fmv.jku.at/aiger/aiger-20071012.zip
)
FetchContent_GetProperties(aiger_repo)

if(NOT aiger_repo_POPULATED)
    FetchContent_Populate(aiger_repo)
endif()

execute_process(
    COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/AigerCMakeLists.txt CMakeLists.txt
    WORKING_DIRECTORY ${aiger_repo_SOURCE_DIR}
)

add_subdirectory(${aiger_repo_SOURCE_DIR} ${CMAKE_BINARY_DIR}/aiger)
