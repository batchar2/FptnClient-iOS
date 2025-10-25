
# BUILD 


```bash

sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer

cd FptnLib/

git submodule update --init --recursive


# emulator
conan install . --profile:host=conan-simulator-profile --profile:build=default --build=missing --output-folder=build-simulator

cd build-simulator
cmake .. -DCMAKE_TOOLCHAIN_FILE=./build/Debug/generators/conan_toolchain.cmake  -DCMAKE_BUILD_TYPE=Debug

cmake --build . --config Debug

```





```bash
conan install . --profile:host=conan-device-profile --profile:build=default --build=missing --output-folder=build-ios 
cd build-ios
cmake .. -DCMAKE_TOOLCHAIN_FILE=./build/Debug/generators/conan_toolchain.cmake  -DCMAKE_BUILD_TYPE=Debug
cmake --build . --config Debug
copy to fptn-cpp


codesign --force --sign - --timestamp=none FptnVPN/Cpp/fptn_native_lib.framework/fptn_native_lib
codesign --force --sign - --preserve-metadata=identifier,entitlements,flags --timestamp=none FptnVPN/Cpp/fptn_native_lib.framework
codesign -dv FptnVPN/Cpp/fptn_native_lib.framework/fptn_native_lib 
```
