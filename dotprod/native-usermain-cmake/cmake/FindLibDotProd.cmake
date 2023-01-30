find_library (DOTPROD_LIBRARIES
    NAMES dotprod
    HINTS
    "$ENV{DOTPROD_ROOT}"
    "$ENV{DOTPROD_ROOT}/lib"
    "$ENV{DOTPROD_ROOT}/lib64"
)

find_path (DOTPROD_INCLUDE_DIRS
    NAMES dotprod.h
    HINTS
    "$ENV{DOTPROD_ROOT}"
    "$ENV{DOTPROD_ROOT}/include"
)

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args (LibDotProd DEFAULT_MSG DOTPROD_INCLUDE_DIRS DOTPROD_LIBRARIES)

if (LibDotProd_FOUND)
    message (STATUS "Found LibDotProd (include: ${DOTPROD_INCLUDE_DIRS}, library: ${DOTPROD_LIBRARIES})")
    mark_as_advanced (DOTPROD_ROOT_DIR DOTPROD_INCLUDE_DIRS DOTPROD_LIBRARIES)
endif ()