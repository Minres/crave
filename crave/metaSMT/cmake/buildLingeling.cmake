FetchContent_Declare(
    lingeling_repo
    URL https://fmv.jku.at/lingeling/lingeling-ayv-86bf266-140429.zip
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

add_subdirectory(${lingeling_repo_SOURCE_DIR} ${CMAKE_BINARY_DIR}/lingeling)

message(STATUS "Use Lingeling ayv-86bf266-140429 from ${CMAKE_INSTALL_PREFIX}")
