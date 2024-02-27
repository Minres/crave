FetchContent_Declare(
    lingeling_repo
    URL https://fmv.jku.at/lingeling/lingeling-ayv-86bf266-140429.zip
)
FetchContent_GetProperties(lingeling_repo)

if(NOT lingeling_repo_POPULATED)
    FetchContent_Populate(lingeling_repo)
endif()

execute_process(
    COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/LingelingCMakeLists.txt CMakeLists.txt
    COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/lglcfg.h.in.cmake .
    COMMAND cp ${CMAKE_CURRENT_LIST_DIR}/lglcflags.h.in.cmake .
    WORKING_DIRECTORY ${lingeling_repo_SOURCE_DIR}
)

add_subdirectory(${lingeling_repo_SOURCE_DIR} ${CMAKE_BINARY_DIR}/lingeling)