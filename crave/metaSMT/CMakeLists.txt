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


PROJECT(metaSMT VERSION 4.0 LANGUAGES CXX)
cmake_minimum_required(VERSION 3.20)

option(metaSMT_REQUIRE_CXX11 "make C++11 a requirement" on)

if ( NOT metaSMT_REQUIRE_CXX11 AND WIN32 )
  message(FATAL_ERROR "Windows build requires CXX11")
endif()

include(CheckCXXCompilerFlag)

if (metaSMT_REQUIRE_CXX11)
  if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 6.1)
      if(COMPILER_SUPPORTS_CXX11)
        add_definitions(-std=c++11)
      else()
        message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} does not support -std=c++11. Please use a different C++ compiler.")
      endif()
    endif()
  else()
    if(COMPILER_SUPPORTS_CXX11)
      add_definitions(-std=c++11)
    else()
      message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} does not support -std=c++11. Please use a different C++ compiler.")
    endif()
  endif()
endif()

include(CheckIncludeFileCXX)
include(FeatureSummary)

include(CTest)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/Modules )

set(Boost_NO_BOOST_CMAKE true)
set(Boost_NO_SYSTEM_PATHS true)
find_package(Boost REQUIRED)

# From v1.57.0 Boost.Any does not require RTTI
if (${Boost_VERSION} VERSION_LESS 105700)
  message( STATUS "metaSMT requires RTTI" )
  set(metaSMT_REQUIRE_RTTI true)
else()
  message( STATUS "metaSMT does not require RTTI" )
  set(metaSMT_REQUIRE_RTTI false)
endif()

SET_PACKAGE_PROPERTIES(BOOST PROPERTIES DESCRIPTION "Portable C++ libraries" URL "http://www.boost.org/" TYPE REQUIRED PURPOSE "Boost provides free peer-reviewed portable C++ source libraries.")

include_directories(${Boost_INCLUDE_DIRS})

list(INSERT CMAKE_PREFIX_PATH 0 "${CMAKE_SOURCE_DIR}/cmake")

# Set the default version number, but try to calculate
# a proper version from git.
include(cmake/get_git_version.cmake)

include(cmake/build_type.cmake)
include(cmake/default_compliler_flags.cmake)
include(cmake/config_file.cmake)

###  
# Options to force disable certain solvers. 
# set all solvers to "on" with good support and experimental or
# work in progress to "off"
###
option(metaSMT_USE_Boolector  "try to use Boolector solver" on)
option(metaSMT_USE_Z3         "try to use Z3 solver" on)
option(metaSMT_USE_STP        "try to use STP solver" on)
option(metaSMT_USE_CVC4        "try to use CVC4 solver" on)
option(metaSMT_USE_YICES2     "try to use Yices2 solver" on)
option(metaSMT_USE_CUDD       "try to use CUDD BDD package" on )
option(metaSMT_USE_MiniSat    "try to use minisat SAT solver" on)
option(metaSMT_USE_picosat    "try to use picosat SAT solver" on)
option(metaSMT_USE_lingeling  "try to use lingeling SAT solver" on)
option(metaSMT_USE_Aiger      "try to use aiger" on)
option(metaSMT_USE_CW         "try to use clause writers" on)

option(metaSMT_DOC_Doxygen    "try to build doxygen documentation" off)
option(metaSMT_ENABLE_TESTS   "build tests (recommended)" on)

set(metaSMT_CONFIG_DIR "share/metaSMT" CACHE PATH 
  "where to install CMake and Make Config files")

if ( NOT TIMEOUT )
  set(TIMEOUT 5 CACHE STRING "The timeout for tests")
endif()

if ( WIN32 )
  message(STATUS "Windows build: disable all solvers except z3 or CUDD!" )
  set(metaSMT_USE_Boolector  off)
  set(metaSMT_USE_STP off)
  set(metaSMT_USE_CVC4 off)
  set(metaSMT_USE_YICES2 off)
  set(metaSMT_USE_MiniSat off)
  set(metaSMT_USE_picosat off)
  set(metaSMT_USE_lingeling off)
  set(metaSMT_USE_Aiger off)
  set(metaSMT_USE_CW off)
endif()

if(metaSMT_USE_Boolector)
  find_package(Boolector QUIET)
  list(APPEND Boolector_INCLUDE_DIR ${boolector_INCLUDE_DIRS})
  list(APPEND Boolector_LIBRARIES ${boolector_LIBRARIES})
else()
  set(Boolector_FOUND 0)
endif()
SET_PACKAGE_PROPERTIES(Boolector PROPERTIES DESCRIPTION "solver for SMT QF_BV and Arrays")

include(ExternalProject)
include(FetchContent)
if (metaSMT_USE_Z3)
  FetchContent_Declare(
    z3_git
    GIT_REPOSITORY https://github.com/Z3Prover/z3.git
    GIT_TAG        z3-4.6.0
  )
  FetchContent_GetProperties(z3_git)
  if(NOT z3_git_POPULATED)
    FetchContent_Populate(z3_git)

    #install dir must be availble to configure time otherwise CMake will complain
    set(z3_install_dir ${CMAKE_BINARY_DIR}/_deps/z3_git-install)
    if(NOT Z3_EXTERNAL_PROJECT_ADDED)
      # Define the patch content as a string
      set(Z3_PATCH_CONTENT
        "--- src/util/lp/permutation_matrix.h	2017-12-18 15:18:30.000000000 +0100\n"
        "+++ src/util/lp/permutation_matrix.h	2020-09-08 09:58:33.638123478 +0200\n"
        "@@ -132,7 +132,7 @@\n"
        "\n"
        "         unsigned size() const { return static_cast<unsigned>(m_rev.size()); }\n"
        "\n"
        "-        unsigned * values() const { return m_permutation; }\n"
        "+        unsigned * values() const { return m_permutation.c_ptr(); }\n"
        "\n"
        "         void resize(unsigned size) {\n"
        "             unsigned old_size = m_permutation.size();\n"
      )

      execute_process(
        COMMAND ${CMAKE_COMMAND} -E make_directory ${z3_install_dir}/include
        COMMAND ${CMAKE_COMMAND} -E make_directory ${z3_install_dir}/lib
        COMMAND patch -p0 < ${CMAKE_COMMAND} -E string(WRAP ${Z3_PATCH_CONTENT})
        WORKING_DIRECTORY ${z3_git_SOURCE_DIR}
      )

      ExternalProject_Add(
        z3
        BUILD_IN_SOURCE = TRUE
        SOURCE_DIR ${z3_git_SOURCE_DIR}
        CONFIGURE_COMMAND ./configure --staticlib --prefix=${z3_install_dir}
        BUILD_COMMAND make -C build -j
        INSTALL_COMMAND make -C build install -j
      )
      set(Z3_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()
    add_library(z3_git::z3_git INTERFACE IMPORTED)
    target_include_directories(z3_git::z3_git INTERFACE ${z3_install_dir}/include)
    target_link_libraries(z3_git::z3_git INTERFACE z3)
    target_link_directories(z3_git::z3_git INTERFACE ${z3_install_dir}/lib)

    find_package(OpenMP)
    if (OPENMP_FOUND)
      message(STATUS "Use Z3 with OpenMP")
    else()
      message(STATUS "Use Z3 without OpenMP")
    endif()
  endif()
endif()

if (metaSMT_USE_YICES2)
  find_package(YICES2 QUIET)
else()
  set(YICES2_FOUND 0)
endif()
SET_PACKAGE_PROPERTIES(YICES2 PROPERTIES DESCRIPTION "solver for various SMT theories")

if(metaSMT_USE_STP)
  find_package(STP QUIET)
else()
  set(STP_FOUND 0)
endif()
SET_PACKAGE_PROPERTIES(STP PROPERTIES DESCRIPTION "solver for various SMT theories")

if(metaSMT_USE_CVC4)
  find_package(CVC4 QUIET)
else()
  set(CVC4_FOUND 0)
endif()
set_package_info(CVC4 "solver for various SMT theories")

if (metaSMT_USE_CUDD)
  FetchContent_Declare(
    cudd_repo
    GIT_REPOSITORY https://github.com/nbruns1/cudd.git
    GIT_TAG cudd-3.0.0
  )
  FetchContent_GetProperties(cudd_repo)
  if(NOT cudd_repo_POPULATED)
    FetchContent_Populate(cudd_repo)

    #install dir must be availble to configure time otherwise CMake will complain
    set(cudd_install_dir ${CMAKE_BINARY_DIR}/_deps/cudd_git-install)
    if(NOT CUDD_EXTERNAL_PROJECT_ADDED)
      execute_process(
        COMMAND mkdir -p ${cudd_install_dir}/include
        COMMAND mkdir -p ${cudd_install_dir}/lib
        WORKING_DIRECTORY ${cudd_repo_SOURCE_DIR}
      )

      ExternalProject_Add(
        cudd
        BUILD_IN_SOURCE TRUE
        SOURCE_DIR ${cudd_repo_SOURCE_DIR}
        CONFIGURE_COMMAND touch configure.ac aclocal.m4 configure Makefile.am Makefile.in
        COMMAND ./configure --enable-obj --enable-dddmp --prefix=${cudd_install_dir}
        BUILD_COMMAND make -j
        INSTALL_COMMAND make install -j
      )

      set(CUDD_EXTERNAL_PROJECT_ADDED TRUE CACHE INTERNAL "Flag indicating whether the external project has been added")
    endif()
    add_library(cudd_git::cudd_git INTERFACE IMPORTED)
    target_include_directories(cudd_git::cudd_git INTERFACE ${cudd_install_dir}/include)
    target_link_libraries(cudd_git::cudd_git INTERFACE cudd)
    target_link_directories(cudd_git::cudd_git INTERFACE ${cudd_install_dir}/lib)
endif()

endif ()

if (metaSMT_USE_Aiger)
  find_package(Aiger QUIET) 
  list(APPEND Aiger_LIBRARIES Aiger)
else ()
  set(Aiger_FOUND 0)
endif()

if (metaSMT_USE_MiniSat)
  find_package(MiniSat QUIET)
else ()
  set(MiniSat_FOUND 0)
endif ()

if (metaSMT_USE_picosat )
  find_package (PicoSAT QUIET)
endif()

if( metaSMT_USE_lingeling )
  find_package( Lingeling QUIET)
endif()

find_package(GMP QUIET)
if(NOT GMP_FOUND)
  find_library(GMP_LIBRARIES gmp PATHS ${GMP_DIR})
  find_library(GMPXX_LIBRARIES gmpxx PATHS ${GMP_DIR})
else()
  set(GMP_LIBRARIES "")
  set(GMPXX_LIBRARIES "")
endif()

if(Boolector_FOUND AND (Boolector_VERSION VERSION_GREATER 2))
  find_package(Threads)
  set(Boolector_LIBRARIES ${Boolector_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT})
endif()

if(CVC4_FOUND)
  if( GMPXX_LIBRARIES )
    set(CVC4_LIBRARIES ${CVC4_LIBRARIES} ${GMPXX_LIBRARIES})
  endif()

  if( GMP_LIBRARIES )
    set(CVC4_LIBRARIES ${CVC4_LIBRARIES} ${GMP_LIBRARIES})
  endif()

  if(EXISTS "${CVC4_INCLUDE_DIR}/cvc4/expr/kind.h")
    file(STRINGS ${CVC4_INCLUDE_DIR}/cvc4/expr/kind.h CVC4_KIND_IFF REGEX "IFF")
    if (NOT CVC4_KIND_IFF)
      message(STATUS "CVC4 version without boolean operator IFF")
      set(CVC4_CXXFLAGS "-DCVC4_WITHOUT_KIND_IFF")
    endif()
  endif()
endif()

if (metaSMT_DOC_Doxygen)
  find_package(Doxygen)
else ()
  set(Doxygen_FOUND 0)
endif ()

#############################################################
## Set LIBS, INCLUDES and metaSMT_AVAILABLE_QF_ABV_SOLVERS  #
#############################################################

set(metaSMT_AVAILABLE_QF_ABV_SOLVERS "")
set(metaSMT_INCLUDES ${Boost_INCLUDE_DIRS})

if(Boolector_FOUND)
  config_find(Boolector ${Boolector_DIR})
  list(APPEND metaSMT_LIBS ${Boolector_LIBRARIES})
  list(APPEND metaSMT_INCLUDES ${Boolector_INCLUDE_DIR})
  if ((Boolector_VERSION VERSION_GREATER 2) OR (Boolector_VERSION VERSION_EQUAL 2))
    message( STATUS "Use Boolector ${Boolector_VERSION}" )
    if ((Boolector_VERSION VERSION_GREATER 2.2.0))
      message( STATUS "Use Boolector v2 new API" )
      set(Boolector_CXXFLAGS "${Boolector_CXXFLAGS} -DmetaSMT_BOOLECTOR_2_NEW_API")
    endif()
  else()
    message( STATUS "Use Boolector v1" )
    set(Boolector_CXXFLAGS "${Boolector_CXXFLAGS} -DmetaSMT_BOOLECTOR_1_API")
  endif()
  set(metaSMT_CXXFLAGS "${metaSMT_CXXFLAGS} ${Boolector_CXXFLAGS}")
  list(APPEND metaSMT_AVAILABLE_QF_ABV_SOLVERS "BTOR")
endif()

if(STP_FOUND)
  config_find(STP ${STP_DIR})
  message( STATUS "STP_LIBRARIES: ${STP_SHARED_LIBRARY}" )
  list(APPEND metaSMT_LIBS ${STP_SHARED_LIBRARY})
  message( STATUS "STP_INCLUDE_DIR: ${STP_INCLUDE_DIRS}" )
  list(APPEND metaSMT_INCLUDES ${STP_INCLUDE_DIRS})
  list(APPEND metaSMT_AVAILABLE_QF_ABV_SOLVERS "STP")
else()
  set( STP_FOUND 0 )
endif()

if(CVC4_FOUND)
  config_find(CVC4 ${CVC4_DIR})
  list(APPEND metaSMT_LIBS ${CVC4_LIBRARIES})
  list(APPEND metaSMT_INCLUDES ${CVC4_INCLUDE_DIR})
  set(metaSMT_CXXFLAGS "${metaSMT_CXXFLAGS} ${CVC4_CXXFLAGS}")
  list(APPEND metaSMT_AVAILABLE_QF_ABV_SOLVERS "CVC4")
endif()

if (YICES2_FOUND)
  config_find(YICES2 ${YICES2_DIR})
  list(APPEND metaSMT_LIBS ${YICES2_LIBRARIES})
  list(APPEND metaSMT_INCLUDES ${YICES2_INCLUDE_DIR})
  list(APPEND metaSMT_AVAILABLE_QF_ABV_SOLVERS "YICES2")
endif()

if(Aiger_FOUND)
  config_find(Aiger ${Aiger_DIR})
  list(APPEND metaSMT_LIBS ${Aiger_LIBRARIES})
  list(APPEND metaSMT_INCLUDES ${Aiger_INCLUDE_DIR})
endif()

if(metaSMT_USE_CUDD)
  list(APPEND metaSMT_LIBS cudd_git::cudd_git)
endif()

if(MiniSat_FOUND)
  config_find(MiniSat ${MiniSat_DIR})
  list(APPEND metaSMT_LIBS ${MiniSat_LIBRARIES})
  list(APPEND metaSMT_INCLUDES ${MiniSat_INCLUDE_DIR})
  set(metaSMT_CXXFLAGS "${metaSMT_CXXFLAGS} ${MiniSat_CXXFLAGS}")
endif()

if (PicoSAT_FOUND)
  config_find(PicoSAT ${PicoSAT_DIR})
  list(APPEND metaSMT_LIBS ${PicoSAT_LIBRARIES})
  list(APPEND metaSMT_INCLUDES ${PicoSAT_INCLUDE_DIR})
endif ()

if (Lingeling_FOUND)
  config_find(Lingeling ${Lingeling_DIR})
  list(APPEND metaSMT_LIBS ${Lingeling_LIBRARIES})
  list(APPEND metaSMT_INCLUDES ${Lingeling_INCLUDE_DIR})
endif ()

############################################################
############# RPATH ########################################
############################################################

include(cmake/library_rpath.cmake)
add_dependent_libraries(${metaSMT_LIBS})


############################################################
############# subdirectories ###############################
############################################################

add_subdirectory(src)
add_subdirectory(doc)

if(metaSMT_ENABLE_TESTS)
  enable_testing()
  add_subdirectory(tests)
endif()

############################################################
########## generate cmake config files #####################
############################################################

#generate_config_files()

Feature_Summary(WHAT ALL)


############################################################
############################################################

# vim: ft=cmake:ts=2:sw=2:expandtab
