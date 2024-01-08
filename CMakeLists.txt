###############################################################################
#
# Licensed to Accellera Systems Initiative Inc. (Accellera) under one or
# more contributor license agreements.  See the NOTICE file distributed
# with this work for additional information regarding copyright ownership.
# Accellera licenses this file to you under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#
###############################################################################

cmake_minimum_required(VERSION 3.17)
project(crave2uvm VERSION 1.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set (CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

find_package(SystemC REQUIRED)
if(NOT SystemC_FOUND)
    message(FATAL_ERROR "SystemC not found. Please provide the path to SystemC.")
endif()

find_package(CRAVE REQUIRED)
if(NOT CRAVE_FOUND)
    message(FATAL_ERROR "CRAVE not found. Please provide the path to CRAVE.")
endif()

find_package(UVM-SystemC REQUIRED)
if(NOT UVM-SystemC_FOUND)
    message(FATAL_ERROR "UVM-SystemC not found. Please provide the path to UVM-SystemC.")
endif()

# CRAVE2UVM
add_library(crave2uvm INTERFACE)
target_include_directories(crave2uvm INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/include>
    $<INSTALL_INTERFACE:include>
)

# Set the default installation directory to the build directory
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Default installation directory" FORCE)
endif()

install(TARGETS crave2uvm 
    RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
    ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_PREFIX}/include/crave2uvm
    COMPONENT lib
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src/include/
    DESTINATION ${CMAKE_INSTALL_PREFIX}/include/crave2uvm
    FILES_MATCHING PATTERN "*.h"
)

export(TARGETS crave2uvm
  NAMESPACE crave2uvm::
  FILE ${CMAKE_INSTALL_PREFIX}/Findcrave2uvm.cmake
)

# Add examples directory
add_subdirectory(examples)
