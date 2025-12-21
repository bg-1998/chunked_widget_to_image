mkdir -p build
cd build
cmake ../../src -DCMAKE_OSX_SYSROOT=macosx -DCMAKE_OSX_ARCHITECTURES=arm64 -DMACOS=ON
make

#mkdir -p build/macos_arm64
#cd build/macos_arm64
#cmake ../../../src -DCMAKE_OSX_SYSROOT=macosx -DCMAKE_OSX_ARCHITECTURES=arm64 -DMACOS=ON
#make

#mkdir -p build/macos_x86_64
#cd build/macos_x86_64
#cmake ../../../src -DCMAKE_OSX_SYSROOT=macosx -DCMAKE_OSX_ARCHITECTURES=x86_64 -DMACOS=ON
#make