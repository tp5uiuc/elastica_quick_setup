#!/usr/bin/env sh

# Blaze automatically installs in the blaze subdirectory
BLAZE_BUILD_DIR="build"
BLAZE_INSTALL_PREFIX=${1:-"${HOME}/Desktop/third_party_installed"}
mkdir -p "${BLAZE_INSTALL_PREFIX}"

_CXX_="garbage"
source "detect_compiler.sh" # populates _CXX_
elastica_detect_compiler

# >3.14
# -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
cmake -B "${BLAZE_BUILD_DIR}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${_CXX_}" \
	-DBLAZE_SHARED_MEMORY_PARALLELIZATION=OFF \
	-DUSE_LAPACK=OFF \
	-S .
cmake --build "${BLAZE_BUILD_DIR}"
cmake --install "${BLAZE_BUILD_DIR}" --prefix "${BLAZE_INSTALL_PREFIX}"

unset BLAZE_BUILD_DIR
unset BLAZE_INSTALL_PREFIX
