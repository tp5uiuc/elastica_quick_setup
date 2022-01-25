#!/usr/bin/env sh

# CXXOPTS automatically installs in the CXXOPTS subdirectory
CXXOPTS_INSTALL_PATH="${1}"
mkdir -p "${CXXOPTS_INSTALL_PATH}"
mkdir -p build && cd "$_" || exit

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
if [ -z "${CXX}" ] && g++ --version | grep -q '[Gg][Cc][Cc]'; then
	CXX="g++"
fi
if [ -z "${CXX}" ]; then
	# We have no hope, fall back on XZ's g++
	CXX="/usr/local/bin/g++"
	# CXX="/usr/local/Cellar/gcc/8.2.0/bin/g++-8"
fi

cmake .. -DCMAKE_INSTALL_PREFIX="${CXXOPTS_INSTALL_PATH}" -DCMAKE_CXX_COMPILER="${CXX}" -DCXXOPTS_BUILD_EXAMPLES=OFF -DCXXOPTS_BUILD_TESTS=OFF
# make standalone
make install
