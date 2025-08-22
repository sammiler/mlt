cmake_minimum_required(VERSION 3.15)
project(mlt_test)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 添加vcpkg包含目录的辅助函数
function(mlt_add_vcpkg_include_dirs target_name)
  if(MSVC AND DEFINED VCPKG_TARGET_TRIPLET)
    if(NOT DEFINED _VCPKG_INSTALLED_DIR AND DEFINED VCPKG_INSTALLED_DIR)
      set(_VCPKG_INSTALLED_DIR "${VCPKG_INSTALLED_DIR}")
    endif()
    if(DEFINED _VCPKG_INSTALLED_DIR)
      target_include_directories(${target_name} PRIVATE "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include")
    endif()
  endif()
endfunction()

# Find the MLT package (using vcpkg)
find_package(Mlt7 REQUIRED)

# Find pthreads (required by MLT on Windows)
if(MSVC)
  find_package(PThreads4W REQUIRED)
endif()

# Create a simple test executable
add_executable(mlt_test main.cpp)

# Apply vcpkg include directories
mlt_add_vcpkg_include_dirs(mlt_test)

# Link against MLT libraries and pthread
if(MSVC)
  target_link_libraries(mlt_test PRIVATE Mlt7::mlt Mlt7::mlt++ PThreads4W::PThreads4W)
else()
  target_link_libraries(mlt_test PRIVATE Mlt7::mlt Mlt7::mlt++)
endif()

# Print some information
message(STATUS "MLT found successfully!")
message(STATUS "MLT include dirs: ${Mlt7_INCLUDE_DIRS}")
message(STATUS "MLT libraries: ${Mlt7_LIBRARIES}")

# Copy MLT data files to output directory for runtime
if(EXISTS "${MLT_DATA_DIR}")
    add_custom_command(TARGET mlt_test POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${MLT_DATA_DIR}" "$<TARGET_FILE_DIR:mlt_test>/mlt_data")
endif()
