cmake_minimum_required(VERSION 3.15)
project(mlt_test)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find the MLT package
find_package(Mlt7 REQUIRED)

# Create a simple test executable
add_executable(mlt_test main.cpp)

# Link against MLT libraries
target_link_libraries(mlt_test PRIVATE Mlt7::mlt Mlt7::mlt++)

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
