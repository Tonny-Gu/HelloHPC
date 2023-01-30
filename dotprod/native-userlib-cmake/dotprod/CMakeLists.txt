cmake_minimum_required (VERSION 3.10)
project (DotProdLib)

add_library (dotprod SHARED src/dotprod.c)
target_include_directories (dotprod PUBLIC include)

set_target_properties(dotprod PROPERTIES PUBLIC_HEADER include/dotprod.h)
install (TARGETS dotprod
    LIBRARY DESTINATION lib
    PUBLIC_HEADER DESTINATION include
)