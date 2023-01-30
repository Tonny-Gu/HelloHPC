cmake_minimum_required (VERSION 3.10)
project (DotProdExample)

add_executable (dotprod.exe main.c)
target_include_directories (dotprod.exe PUBLIC ${DOTPROD_INCLUDE_DIRS})
target_link_libraries (dotprod.exe LINK_PUBLIC ${DOTPROD_LIBRARIES})

install (TARGETS dotprod.exe
    RUNTIME DESTINATION bin
)