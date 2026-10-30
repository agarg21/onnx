# Copyright (c) ONNX Project Contributors
#
# SPDX-License-Identifier: Apache-2.0

param(
    [Parameter()]
    [String]$cmake_arch = "x64",

    [Parameter()]
    [String]$build_type = "Release"
)

echo "Build ABSL-cpp from source on Windows."
Invoke-WebRequest -Uri https://github.com/abseil/abseil-cpp/releases/download/20250127.0/abseil-cpp-20250127.0.tar.gz -OutFile abseil-cpp.tar.gz -Verbose
tar -xvf abseil-cpp.tar.gz
if ($LASTEXITCODE -ne 0) { throw "tar failed to extract abseil-cpp.tar.gz (exit code $LASTEXITCODE)" }

echo "Build protobuf from source on Windows."
# When bumping the protobuf version, keep the cache path in .github/workflows/main.yml
# ("Cache external protobuf - Windows") in sync, or the cache silently misses.
Invoke-WebRequest -Uri https://github.com/protocolbuffers/protobuf/releases/download/v31.1/protobuf-31.1.tar.gz -OutFile protobuf.tar.gz -Verbose
tar -xvf protobuf.tar.gz
if ($LASTEXITCODE -ne 0) { throw "tar failed to extract protobuf.tar.gz (exit code $LASTEXITCODE)" }
cd protobuf-31.1
mkdir protobuf_install
$protobuf_install_dir = (Resolve-Path protobuf_install).Path
mkdir build
cd build
$protobuf_root_dir = Get-Location

cmake -G "Visual Studio 17 2022" -A $cmake_arch -Dprotobuf_MSVC_STATIC_RUNTIME=OFF -DABSL_MSVC_STATIC_RUNTIME=OFF -DBUILD_SHARED_LIBS=OFF -Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_BUILD_EXAMPLES=OFF -DABSL_ROOT_DIR="$protobuf_root_dir/../../abseil-cpp-20250127.0" -DCMAKE_CXX_STANDARD=17 -DABSL_PROPAGATE_CXX_STD=on -DCMAKE_INSTALL_PREFIX="$protobuf_install_dir" ..
if ($LASTEXITCODE -ne 0) { throw "cmake configure for protobuf failed (exit code $LASTEXITCODE)" }
cmake --build . --config $build_type --target install
if ($LASTEXITCODE -ne 0) { throw "cmake build/install for protobuf failed (exit code $LASTEXITCODE)" }
echo "Protobuf installation complete."
echo "Set paths"
$env:Path = "$protobuf_install_dir/lib;$protobuf_install_dir/include;$protobuf_install_dir/bin;$env:Path"
protoc --version
if ($LASTEXITCODE -ne 0) { throw "installed protoc failed to run (exit code $LASTEXITCODE)" }
cd ../../
