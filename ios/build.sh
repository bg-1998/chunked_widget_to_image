mkdir -p build
cd build
cmake ../../src -DCMAKE_OSX_SYSROOT=iphoneos -DCMAKE_OSX_ARCHITECTURES=arm64 -DIOS=ON
make