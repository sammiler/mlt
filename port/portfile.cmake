vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# Only support MSVC on Windows  
if(NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "This port only supports Windows")
endif()

# Check for MSVC specifically
if(VCPKG_TARGET_TRIPLET MATCHES "mingw" OR VCPKG_TOOLCHAIN MATCHES "mingw")
    message(FATAL_ERROR "This port only supports MSVC compiler, not MinGW")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sammiler/mlt
    REF msvc-master
    SHA512 f4bb3181ac8aad7b62432a7454d083717cc2f044c1b91b6a9c9819dae574368fa5616e49a5b0a093da5924ba21c055c2b17da7efe6cf8facd36577abf7af14b4
    HEAD_REF msvc-master
)

# Handle submodules manually since vcpkg_from_github doesn't include .git
# Download vid.stab submodule
vcpkg_from_github(
    OUT_SOURCE_PATH VIDSTAB_SOURCE_PATH
    REPO georgmartius/vid.stab
    REF master
    SHA512 a15654b50e1f548929d183b1ee9e2905b8ece8d57ad3ec0a7d179ba56809afccfc23f9e034e7f046c91c95f8cf33ff683e70e2f9af6b41fdd4863107dcc29b53
    HEAD_REF master
)

# Download frei0r submodule  
vcpkg_from_github(
    OUT_SOURCE_PATH FREI0R_SOURCE_PATH
    REPO dyne/frei0r
    REF master
    SHA512 c9c62aecf5235bfd31e3f1375b9d3d62f2b5ce0b34dd6e1811a60bd5e924929629374fbd5b8d3170dbde445cf9db75c0cf1f801e3ab9be164d11ec10d2de1cbe
    HEAD_REF master
)

# Download glaxnimate submodule from GitLab
vcpkg_download_distfile(
    GLAXNIMATE_ARCHIVE
    URLS "https://gitlab.com/mattbas/glaxnimate/-/archive/master/glaxnimate-master.tar.gz"
    FILENAME "glaxnimate-master.tar.gz"
    SHA512 2424b0cced3c4edb98e1fc6a7b4b90b7bdf64d10e8e21e29adf4c1f89d2edb61904a9af6041342b5a75346b7bdd617b04e4304b90f97faf5a00df46dfdb0e2c4
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH GLAXNIMATE_SOURCE_PATH
    ARCHIVE "${GLAXNIMATE_ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

# Copy submodules to their expected locations
file(COPY "${VIDSTAB_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/external/vid.stab")
file(COPY "${FREI0R_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/external/frei0r")
file(COPY "${GLAXNIMATE_SOURCE_PATH}/glaxnimate-master/" DESTINATION "${SOURCE_PATH}/src/modules/glaxnimate/glaxnimate")

# Patch external/frei0r to use ${CMAKE_SOURCE_DIR}/external/frei0r paths
set(FREI0R_CMAKE "${SOURCE_PATH}/external/frei0r/CMakeLists.txt")
if(EXISTS "${FREI0R_CMAKE}")
    file(READ "${FREI0R_CMAKE}" FREI0R_CMAKE_CONTENT)
    # install include dir
    string(REPLACE "\${CMAKE_SOURCE_DIR}/" "\${CMAKE_SOURCE_DIR}/external/frei0r/" FREI0R_CMAKE_CONTENT "${FREI0R_CMAKE_CONTENT}")
    file(WRITE "${FREI0R_CMAKE}" "${FREI0R_CMAKE_CONTENT}")
endif()

# Apply a small compatibility patch to glaxnimate riff.hpp for MSVC C++17
# MSVC reports C3615 when a constexpr ctor uses std::vector iterators (non-constexpr in C++17).
# We replace `constexpr RangeIterator(` with `RangeIterator(` to compile under vcpkg's toolchain.
set(RIFF_HEADER "${SOURCE_PATH}/src/modules/glaxnimate/glaxnimate/src/core/io/aep/riff.hpp")
if(EXISTS "${RIFF_HEADER}")
    file(READ "${RIFF_HEADER}" RiffContent)
    string(REPLACE "constexpr RangeIterator(" "RangeIterator(" RiffContent "${RiffContent}")
    file(WRITE "${RIFF_HEADER}" "${RiffContent}")
endif()

# Configure features
set(FEATURE_OPTIONS "")

# Override specific modules based on features
if("qt6" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_QT6=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_QT6=OFF")
endif()

if("qt5" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_QT=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_QT=OFF")
endif()

if("avformat" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_AVFORMAT=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_AVFORMAT=OFF")
endif()

if("sdl2" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_SDL2=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_SDL2=OFF")
endif()

if("sdl1" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_SDL1=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_SDL1=OFF")
endif()

if("frei0r" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_FREI0R=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_FREI0R=OFF")
endif()

if("sox" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_SOX=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_SOX=OFF")
endif()

if("movit" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_MOVIT=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_MOVIT=OFF")
endif()

if("decklink" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_DECKLINK=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_DECKLINK=OFF")
endif()

if("gdk" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_GDK=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_GDK=OFF")
endif()

if("glaxnimate" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_GLAXNIMATE=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_GLAXNIMATE=OFF")
endif()

if("glaxnimate-qt6" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_GLAXNIMATE_QT6=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_GLAXNIMATE_QT6=OFF")
endif()

if("jackrack" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_JACKRACK=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_JACKRACK=OFF")
endif()

if("kdenlive" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_KDENLIVE=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_KDENLIVE=OFF")
endif()

if("ndi" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_NDI=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_NDI=OFF")
endif()

if("normalize" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_NORMALIZE=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_NORMALIZE=OFF")
endif()

if("oldfilm" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_OLDFILM=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_OLDFILM=OFF")
endif()

if("opencv" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_OPENCV=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_OPENCV=OFF")
endif()

if("plus" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_PLUS=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_PLUS=OFF")
endif()

if("plusgpl" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_PLUSGPL=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_PLUSGPL=OFF")
endif()

if("resample" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_RESAMPLE=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_RESAMPLE=OFF")
endif()

if("rtaudio" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_RTAUDIO=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_RTAUDIO=OFF")
endif()

if("rubberband" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_RUBBERBAND=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_RUBBERBAND=OFF")
endif()

if("spatialaudio" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_SPATIALAUDIO=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_SPATIALAUDIO=OFF")
endif()

if("vidstab" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_VIDSTAB=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_VIDSTAB=OFF")
endif()

if("vorbis" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_VORBIS=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_VORBIS=OFF")
endif()

if("xine" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_XINE=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_XINE=OFF")
endif()

if("xml" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DMOD_XML=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DMOD_XML=OFF")
endif()

# Set vcpkg specific compiler flags for MSVC
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_TRIPLET MATCHES "mingw")
    set(VCPKG_CXX_FLAGS "/permissive /std:c++20")
    set(VCPKG_C_FLAGS "")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DCMAKE_CXX_STANDARD=20
        # Core build options
        -DGPL=ON
        -DGPL3=ON
        -DBUILD_TESTING=OFF
        -DBUILD_DOCS=OFF
        -DCLANG_FORMAT=ON
        -DBUILD_TESTS_WITH_QT6=OFF
        -DMELT_NOINSTALL=OFF
        -DBUILD_SHARED_LIBS=ON
        -DWINDOWS_DEPLOY=ON
        
        # Module options (using exact CMake default values from sammiler/mlt project)
        # These match the options from your CMakeLists.txt
        -DMOD_AVFORMAT=ON
        -DMOD_DECKLINK=ON
        -DMOD_FREI0R=ON
        -DMOD_GDK=ON
        -DMOD_GLAXNIMATE=OFF
        -DMOD_GLAXNIMATE_QT6=OFF
        -DMOD_JACKRACK=ON
        -DUSE_LV2=ON
        -DUSE_VST2=ON
        -DMOD_KDENLIVE=ON
        -DMOD_NDI=OFF
        -DMOD_NORMALIZE=ON
        -DMOD_OLDFILM=ON
        -DMOD_OPENCV=OFF
        -DMOD_MOVIT=OFF  # Explicitly OFF as requested
        -DMOD_PLUS=ON
        -DMOD_PLUSGPL=ON
        -DMOD_QT=OFF
        -DMOD_QT6=ON
        -DMOD_RESAMPLE=ON
        -DMOD_RTAUDIO=ON
        -DMOD_RUBBERBAND=ON
        -DMOD_SDL1=OFF
        -DMOD_SDL2=ON
        -DMOD_SOX=OFF  # Explicitly OFF as requested
        -DMOD_SPATIALAUDIO=OFF
        -DMOD_VIDSTAB=ON
        -DMOD_VORBIS=ON
        -DMOD_XINE=ON
        -DMOD_XML=ON
        
        # SWIG bindings (all disabled for vcpkg)
        -DSWIG_CSHARP=OFF
        -DSWIG_JAVA=OFF
        -DSWIG_LUA=OFF
        -DSWIG_NODEJS=OFF
        -DSWIG_PERL=OFF
        -DSWIG_PHP=OFF
        -DSWIG_PYTHON=OFF
        -DSWIG_RUBY=OFF
        -DSWIG_TCL=OFF
        
        # Feature overrides (applied last to override defaults)
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_build()

vcpkg_cmake_install()

# Create proper directory structure for MLT-7
# Note: On Windows, MLT installs headers to mlt-7/framework and mlt-7/mlt++
# The CMAKE_INSTALL_INCLUDEDIR already includes the mlt-7 subdirectory

# Handle tools - copy melt to tools directory
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/melt.exe")
    vcpkg_copy_tools(TOOL_NAMES melt AUTO_CLEAN)
endif()

# Handle MLT modules 
# On Windows with WINDOWS_DEPLOY=ON, modules should be in lib/mlt
# We need to ensure they're properly placed for vcpkg

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

# Handle CMake config
vcpkg_cmake_config_fixup(
    PACKAGE_NAME Mlt7
    CONFIG_PATH lib/cmake/Mlt7
)

# Remove debug includes and tools
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")

# Remove debug executables
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(GLOB DEBUG_EXES "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
    foreach(DEBUG_EXE ${DEBUG_EXES})
        file(REMOVE "${DEBUG_EXE}")
    endforeach()
endif()

# Handle pkg-config files if they exist
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
    vcpkg_fixup_pkgconfig()
endif()

# Clean up debug symbols and intermediate files (but keep them in debug builds)
file(GLOB_RECURSE PDB_FILES "${CURRENT_PACKAGES_DIR}/*.pdb")
file(GLOB_RECURSE ILK_FILES "${CURRENT_PACKAGES_DIR}/*.ilk")
file(GLOB_RECURSE EXP_FILES "${CURRENT_PACKAGES_DIR}/*.exp")

# Remove PDB files from release builds, keep in debug
foreach(FILE ${PDB_FILES})
    if(NOT "${FILE}" MATCHES "/debug/")
        file(REMOVE "${FILE}")
    endif()
endforeach()

# Remove all ILK files (intermediate linker files)
foreach(FILE ${ILK_FILES})
    file(REMOVE "${FILE}")
endforeach()

# Remove EXP files from release, but keep .lib files
foreach(FILE ${EXP_FILES})
    if(NOT "${FILE}" MATCHES "/debug/")
        file(REMOVE "${FILE}")
    endif()
endforeach()

# Verify the installation structure
message(STATUS "MLT installation completed")
if(EXISTS "${CURRENT_PACKAGES_DIR}/include/mlt-7")
    message(STATUS "Headers installed to include/mlt-7/")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/mlt")
    message(STATUS "Modules installed to lib/mlt/")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/share/mlt")
    message(STATUS "Data files installed to share/mlt/")
endif()
