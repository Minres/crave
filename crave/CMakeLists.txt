########################################################################################
##	MIT License
########################################################################################
##	Copyright (c) 2012-2020 University of Bremen, Germany. 
##  	Copyright (c) 2015-2020 DFKI GmbH Bremen, Germany.
##  	Copyright (c) 2020 Johannes Kepler University Linz, Austria.
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
cmake_minimum_required(VERSION 3.20)
project(crave VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(${PROJECT_NAME}_CONFIG_DIR "share/${PROJECT_NAME}" CACHE PATH "where to install CMake and Make Config files")

set(CMAKE_BUILD_TYPE Release)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_VERBOSE_MAKEFILE ON) # Force make to print compile commands
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

option(CRAVE_ENABLE_EXPERIMENTAL "enable experimental extensions of CRAVE" ON)
option(CRAVE_ENABLE_TESTS "build tests" ON)
option(CRAVE_BUILD_EXAMPLES "build and test examples" ON)

option(metaSMT_USE_CUDD ON)
option(metaSMT_USE_Z3 ON)
option(metaSMT_USE_SWORD OFF)
option(metaSMT_USE_Boolector OFF)
option(metaSMT_USE_STP OFF)
option(metaSMT_USE_CVC4 OFF)
option(metaSMT_USE_YICES2 OFF)
option(metaSMT_USE_MiniSat OFF)
option(metaSMT_USE_picosat OFF)
option(metaSMT_USE_lingeling OFF)
option(metaSMT_USE_Aiger OFF)
option(metaSMT_USE_CW OFF)

set(Boost_NO_BOOST_CMAKE TRUE)
set(Boost_NO_SYSTEM_PATHS TRUE)

if(WIN32 AND NOT MINGW)
    if(MSVC AND NOT MSVC_VERSION LESS 1900)
        find_package(Boost REQUIRED)
    else()
        message(FATAL_ERROR "CRAVE Windows build only supports Visual Studio C++ 2015 or newer version")
    endif()
else()
    find_package(Boost REQUIRED COMPONENTS system filesystem)
endif()

if(WITH_SYSTEMC)
    find_package(SystemCLanguage REQUIRED)
    find_package(Threads REQUIRED)
endif()

add_subdirectory(metaSMT)

add_subdirectory(src)

if(CRAVE_ENABLE_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

if(CRAVE_BUILD_EXAMPLES)
    enable_testing()
    add_subdirectory(examples)
endif()

set(${PROJECT_NAME}_LIBS ${CMAKE_INSTALL_PREFIX}/lib/lib${PROJECT_NAME}.a ${metaSMT_LIBRARIES})

get_directory_property(ALL_INCLUDES INCLUDE_DIRECTORIES)
set(${PROJECT_NAME}_INCLUDE ${CMAKE_INSTALL_PREFIX}/include ${ALL_INCLUDES})

get_directory_property(${PROJECT_NAME}_DEFS COMPILE_DEFINITIONS)


set(CMAKE_CXX_FLAGS_PROFILING "-O0 -g -Wall -Wextra -pedantic --coverage" CACHE STRING "Flags used by the C++ compiler during maintainer builds." FORCE)
set(CMAKE_C_FLAGS_PROFILING "${CMAKE_CXX_FLAGS_PROFILING}" CACHE STRING "Flags used by the C compiler during maintainer builds." FORCE)
set(CMAKE_EXE_LINKER_FLAGS_PROFILING "--coverage" CACHE STRING "Flags used for linking binaries during maintainer builds." FORCE)
set(CMAKE_SHARED_LINKER_FLAGS_PROFILING " --coverage" CACHE STRING "Flags used by the shared libraries linker during maintainer builds." FORCE)

mark_as_advanced(CMAKE_CXX_FLAGS_PROFILING CMAKE_C_FLAGS_PROFILING CMAKE_EXE_LINKER_FLAGS_PROFILING CMAKE_SHARED_LINKER_FLAGS_PROFILING)

set(CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel Profiling." FORCE)
