########################################################################################
##	MIT License
########################################################################################
##	Copyright (c) 2011-2016 University of Bremen, Germany.
##
##	Permission is hereby granted, free of charge, to any person obtaining a copy
##	of this software and associated documentation files (the "Software"), to deal
##	in the Software without restriction, including without limitation the rights
##	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
##	copies of the Software, and to permit persons to whom the Software is
##	furnished to do so, subject to the following conditions:
##
##	The above copyright notice and this permission notice shall be included in all
##	copies or substantial portions of the Software.
##
##	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
##	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
##	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
##	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
##	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
##	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
##	SOFTWARE.
##########################################################################################

add_library(metaSMT STATIC
  lib/_var_id.cpp
)

target_link_libraries(metaSMT PUBLIC ${metaSMT_LIBS})
target_include_directories(metaSMT PUBLIC 
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:include>
)

if(metaSMT_USE_Z3)
  target_link_libraries(metaSMT PUBLIC z3_git::z3_git)
  target_compile_definitions(metaSMT PRIVATE metaSMT_Z3_ULL_API)
endif()

if(metaSMT_USE_CUDD)
  target_link_libraries(metaSMT PUBLIC cudd_git::cudd_git)
endif()

if (metaSMT_USE_YICES2)
  target_link_libraries(metaSMT PUBLIC yices2_git::yices2_git)
endif()
    
if (metaSMT_USE_CVC4)
  target_link_libraries(metaSMT PUBLIC cvc4_git::cvc4_git)
endif()

if(metaSMT_USE_STP)
  target_link_libraries(metaSMT PUBLIC stp_git::stp_git)
endif()

if(metaSMT_USE_MiniSat)
  target_link_libraries(metaSMT PUBLIC minisat_git::minisat_git)
endif()

if(metaSMT_USE_picosat)
  target_link_libraries(metaSMT PUBLIC picosat_git::picosat_git)
endif()

if(metaSMT_USE_lingeling)
  target_link_libraries(metaSMT PUBLIC lingeling_git::lingeling_git)
endif()

if(metaSMT_USE_Aiger)
  target_link_libraries(metaSMT PUBLIC aiger_git::aiger_git)
endif()

if(metaSMT_USE_Boolector)
  target_link_libraries(metaSMT PUBLIC Boolector::boolector)
  if ((Boolector_VERSION VERSION_GREATER 2) OR (Boolector_VERSION VERSION_EQUAL 2))
    message( STATUS "Use Boolector ${Boolector_VERSION}" )
    if ((Boolector_VERSION VERSION_GREATER 2.2.0))
      message( STATUS "Use Boolector v2 new API" )
      target_compile_definitions(metaSMT PUBLIC metaSMT_BOOLECTOR_2_NEW_API)
    endif()
  else()
    message( STATUS "Use Boolector v1" )
    target_compile_definitions(metaSMT PUBLIC metaSMT_BOOLECTOR_1_API)
  endif()
endif()

### INSTALL
include(GNUInstallDirs)
install(TARGETS metaSMT EXPORT metasmt-targets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/metaSMT
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/metaSMT
    DESTINATION ${CMAKE_INSTALL_PREFIX}/include
    FILES_MATCHING PATTERN "*.hpp"
)

set(metaSMT_CMAKE_CONFIG_DIR ${CMAKE_INSTALL_LIBDIR}/cmake)
include(CMakePackageConfigHelpers)

install(EXPORT metasmt-targets
    DESTINATION ${metaSMT_CMAKE_CONFIG_DIR}
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/metasmt-config-version.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    ${CMAKE_CURRENT_LIST_DIR}/../cmake/metasmt-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/metasmt-config.cmake
    INSTALL_DESTINATION ${metaSMT_CMAKE_CONFIG_DIR}
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/metasmt-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/metasmt-config-version.cmake
    DESTINATION ${metaSMT_CMAKE_CONFIG_DIR})
