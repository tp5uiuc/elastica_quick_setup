#!/usr/bin/env sh

# CXXOPTS automatically installs in the CXXOPTS subdirectory
CXXOPTS_BUILD_DIR="build"
CXXOPTS_INSTALL_PREFIX=${1:-"${HOME}/Desktop/third_party_installed"}

mkdir -p "${CXXOPTS_INSTALL_PREFIX}"

# check gcc version starting from 9 on to 4
version_array=($(seq 9 -1 4))
CXX_ver_arr=("${version_array[@]/#/g++-}")
CC_ver_arr=("${version_array[@]/#/g++-}")
# Try and detect GNU g++ from the shell, if not use default CC
for cxx_ver in "${CXX_ver_arr[@]}"; do
	if command -v "${cxx_ver}" >/dev/null 2>&1 && "${cxx_ver}" --version | grep -q '[Gg][Cc][Cc]'; then
		CXX="${cxx_ver}"
		break
	fi
done
# Check if not set, else set it
if [ -z "${CXX}" ] && g++ --version; then
	CXX="g++"
fi
if [ -z "${CXX}" ]; then
	# We have no hope, fall back on XZ's g++
	CXX="/usr/local/bin/g++"
	# CXX="/usr/local/Cellar/gcc/8.2.0/bin/g++-8"
fi

# Requires >3.14
cmake -B "${CXXOPTS_BUILD_DIR}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCXXOPTS_BUILD_EXAMPLES=OFF \
	-DCXXOPTS_BUILD_TESTS=OFF \
	-S .
cmake --build "${CXXOPTS_BUILD_DIR}"
cmake --install "${CXXOPTS_BUILD_DIR}" --prefix "${CXXOPTS_INSTALL_PREFIX}"

unset CXXOPTS_BUILD_DIR
unset CXXOPTS_INSTALL_PREFIX
