# Predefine the probe results that the project uses.
# If these variables are already defined in the cache, 
# check_* macros will not invoke try_compile again.
set(COMPILER_HAS_DEPRECATED_ATTR OFF CACHE BOOL "force skip broken deprecated check")
set(HAVE___deprecated__ OFF CACHE BOOL "")
set(HAVE_ATTRIBUTE_DEPRECATED OFF CACHE BOOL "")
set(HAVE_C___ATTRIBUTE___DEPRECATED OFF CACHE BOOL "")

# Optional: clear CMAKE_REQUIRED_DEFINITIONS in case the project
# mistakenly pushes -DCOMPILER_HAS_DEPRECATED_ATTR into try_compile.
set(CMAKE_REQUIRED_DEFINITIONS "" CACHE STRING "")
