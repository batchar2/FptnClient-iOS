
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