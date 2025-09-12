cmake_minimum_required(VERSION 3.16)
project(fptn_native_lib VERSION 1.0.0 LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# iOS specific settings
set(CMAKE_OSX_DEPLOYMENT_TARGET 17.0)
set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE NO)


option(COPY_SOURCE_FILES "Copy source files to output directory" ON)
set(SOURCE_COPY_DIR "${CMAKE_CURRENT_BINARY_DIR}/exported_sources" CACHE PATH "Directory to copy source files to")


# Dependencies and compile options
add_definitions(
    -DNDEBUG
    -DO3
    -DWSP_GGML_USE_CPU
    -DWSP_GGML_USE_ACCELERATE
    -DWSP_GGML_USE_METAL
    -DWSP_GGML_METAL_USE_BF16
)


if (CMAKE_OSX_ARCHITECTURES STREQUAL "arm64")
    add_definitions(-DWSP_GGML_CPU_GENERIC)
endif ()

# Find packages
find_package(fptn REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(nlohmann_json REQUIRED)

include_directories(src/)
include_directories(fptn/src/)
include_directories(fptn/src/fptn-protocol-lib)

# Create library target
add_library(fptn_native_lib SHARED
    src/WrapperHttpsClientBridge.cpp 
    src/WrapperHttpsClientBridge.h
)

# Link required frameworks
target_link_libraries(fptn_native_lib PRIVATE
    "-framework Accelerate"
    "-framework Foundation"
    "-framework Metal"
    "-framework MetalKit"
    fptn::fptn
    OpenSSL::SSL
    OpenSSL::Crypto
    "-lssl"
    "-lcrypto"
)

file(GLOB_RECURSE ALL_HEADERS 
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.hxx"
    "${CMAKE_CURRENT_SOURCE_DIR}/fptn/src/*.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/fptn/src/*.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/fptn/src/*.hxx"
)

set_target_properties(fptn_native_lib PROPERTIES
    MACOSX_FRAMEWORK_IDENTIFIER "com.fptn.native"
    MACOSX_FRAMEWORK_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${PROJECT_VERSION}
    FRAMEWORK TRUE
    FRAMEWORK_VERSION ${PROJECT_VERSION}
    VERSION ${PROJECT_VERSION}
    PUBLIC_HEADER "${ALL_HEADERS}"
    XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC NO
    # ЗАМЕНИ ЭТО:
    # CXX_VISIBILITY_PRESET hidden
    # VISIBILITY_INLINES_HIDDEN ON
    # НА ЭТО:
    CXX_VISIBILITY_PRESET default
    VISIBILITY_INLINES_HIDDEN OFF
)

# set_target_properties(fptn_native_lib PROPERTIES
#     MACOSX_FRAMEWORK_IDENTIFIER "com.fptn.native"
#     MACOSX_FRAMEWORK_BUNDLE_VERSION ${PROJECT_VERSION}
#     MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${PROJECT_VERSION}
#     FRAMEWORK TRUE
#     FRAMEWORK_VERSION ${PROJECT_VERSION}
#     VERSION ${PROJECT_VERSION}
#     PUBLIC_HEADER "${ALL_HEADERS}"
#     XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC NO
#     # Enable visibility for framework exports
#     CXX_VISIBILITY_PRESET hidden
#     VISIBILITY_INLINES_HIDDEN ON
# )
# copy all files
foreach(header_file ${ALL_HEADERS})
    file(RELATIVE_PATH relative_path "${CMAKE_CURRENT_SOURCE_DIR}" "${header_file}")
    set(target_file "${CMAKE_CURRENT_BINARY_DIR}/fptn_native_lib.framework/Headers/${relative_path}")
    add_custom_command(TARGET fptn_native_lib POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/fptn_native_lib.framework/Headers/${relative_path}"
        COMMAND ${CMAKE_COMMAND} -E copy "${header_file}" "${target_file}"
        COMMENT "Copying ${relative_path}"
    )
endforeach()

