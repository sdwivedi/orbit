# Copyright (c) 2020 The Orbit Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

if(CMAKE_VS_PLATFORM_NAME STREQUAL "x64")
  set(DIA_PLATFORM_NAME "amd64")
else()
  set(DIA_PLATFORM_NAME "")
endif()

find_library(
  DIASDK_LIB
  NAMES diaguids.lib
  PATH_SUFFIXES "lib/${DIA_PLATFORM_NAME}"
  HINTS "$ENV{VSINSTALLDIR}/DIA SDK" "${CMAKE_GENERATOR_INSTANCE}/DIA SDK")

find_path(
  DIASDK_INC dia2.h
  PATH_SUFFIXES "include/"
  HINTS "$ENV{VSINSTALLDIR}/DIA SDK" "${CMAKE_GENERATOR_INSTANCE}/DIA SDK")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DIASDK DEFAULT_MSG DIASDK_LIB DIASDK_INC)

if(DIASDK_FOUND)
  add_library(DIASDK STATIC IMPORTED GLOBAL)
  set_target_properties(DIASDK PROPERTIES IMPORTED_LOCATION ${DIASDK_LIB})
  target_include_directories(DIASDK SYSTEM INTERFACE ${DIASDK_INC})

  add_library(DIASDK::DIASDK ALIAS DIASDK)
endif()
