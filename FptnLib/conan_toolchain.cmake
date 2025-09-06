 set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build." FORCE)

 # set cmake vars
 set(CMAKE_SYSTEM_NAME iOS)
 set(CMAKE_SYSTEM_VERSION 12.0)
 set(DEPLOYMENT_TARGET ${CONAN_SETTINGS_HOST_MIN_OS_VERSION})
 # Set the architectures for which to build.
 set(CMAKE_OSX_ARCHITECTURES arm64)
 # Setting CMAKE_OSX_SYSROOT SDK, when using Xcode generator the name is enough
 # but full path is necessary for others
 set(CMAKE_OSX_SYSROOT iphoneos)
