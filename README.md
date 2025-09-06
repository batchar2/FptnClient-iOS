
sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer

conan install . --profile:host=conan-ios-profile --profile:build=default --build=missing --output-folder=build-ios-arm64

cd build-ios-arm64

cmake .. -G Xcode \
    -DCMAKE_TOOLCHAIN_FILE=build/Release/generators/conan_toolchain.cmake \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0
cmake --build . --config Release

cd .. 

xcodebuild -create-xcframework \
    -library build-ios-arm64/Release-iphoneos/libfptn_native_lib.a -headers fptn/src/fptn-protocol-lib \
    -output fptn.xcframework



# IT WORKS

sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer

conan install . --profile:host=conan-ios-profile --profile:build=default --build=missing

cmake .. -G Xcode \
    -DCMAKE_TOOLCHAIN_FILE=Release/generators/conan_toolchain.cmake \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0

xcodebuild -project fptn_native_lib.xcodeproj \
           -scheme fptn_native_lib \
           -configuration Release \
           -sdk iphoneos \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGNING_REQUIRED=NO \
           BUILD_LIBRARY_FOR_DISTRIBUTION=YES

cmake --build . --config Release



















#conan install . --profile:host=conan-ios-profile --profile:build=default \
#    --output-folder=build --build=missing \
#    -s:h compiler.cppstd=17 -s:b compiler.cppstd=gnu17 \
#    -c tools.cmake.cmaketoolchain:generator="Xcode"

conan install . --profile:host=conan-ios-profile --profile:build=default --build=missing

cmake .. -G Xcode \
    -DCMAKE_TOOLCHAIN_FILE=Release/generators/conan_toolchain.cmake \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0




xcodebuild -project fptn_native_lib.xcodeproj \
           -scheme fptn_native_lib \
           -configuration Release \
           -sdk iphoneos \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGNING_REQUIRED=NO \
           BUILD_LIBRARY_FOR_DISTRIBUTION=YES


#conan install . --profile:host=conan-ios-profile --profile:build=default \
#    --output-folder=build --build=missing \
#    -s:h compiler.cppstd=17 -s:b compiler.cppstd=gnu17 \
#    -c tools.cmake.cmaketoolchain:generator="Unix Makefiles"


