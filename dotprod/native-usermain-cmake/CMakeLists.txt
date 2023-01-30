# Reference:
# https://cmake.org/examples/
# https://gitlab.com/CLIUtils/modern-cmake/-/blob/master/examples/simple-project/CMakeLists.txt

cmake_minimum_required (VERSION 3.10)
project (DotProdProject)

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake;${CMAKE_MODULE_PATH}")
find_package(LibDotProd REQUIRED)

add_subdirectory (example)