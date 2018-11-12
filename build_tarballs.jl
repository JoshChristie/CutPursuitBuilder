# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "CutPursuitBuilder"
version = v"0.0.2"

# Collection of sources required to build CutPursuit
sources = [
    "https://github.com/FugroRoames/cut-pursuit.git" =>
    "f621b1a6850a195e145de2806e2c7fda09815641"
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/cut-pursuit/src
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain -DJlCxx_DIR=../../../destdir/lib/cmake/JlCxx/ ..

# NOTE: This is a hack to remove -std=c++14 which is not supported by gcc-4.8
echo "# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.11

# compile CXX with /opt/x86_64-linux-gnu/bin/x86_64-linux-gnu-g++
CXX_FLAGS =  -Wall -std=c++11 -fopenmp -O3 -fPIC  -std=gnu++1y

CXX_DEFINES = -DJULIA_ENABLE_THREADING -Dcpjl_EXPORTS

CXX_INCLUDES = -I/workspace/srcdir/cut-pursuit/src/../include -isystem /workspace/destdir/include -isystem /workspace/destdir/include/julia" > CMakeFiles/cpjl.dir/flags.make

make -j${nproc}
cp libcpjl.so $prefix/lib
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
# platforms = supported_platforms()
platforms = [
    Linux(:x86_64, libc=:glibc)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libcpjl", :libcpjl)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaInterop/libcxxwrap-julia/releases/download/v0.5.1/build_libcxxwrap-julia-1.0.v0.5.1.jl",
    "https://github.com/JuliaPackaging/JuliaBuilder/releases/download/v1.0.0-2/build_Julia.v1.0.0.jl",
    "https://github.com/twadleigh/BoostBuilder/releases/download/v1.68.0-4/build_Boost.v1.68.0.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
