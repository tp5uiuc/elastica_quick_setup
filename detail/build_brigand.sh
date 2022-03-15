#!/usr/bin/env sh

# BRIGAND automatically installs in the brigand subdirectory
BRIGAND_BUILD_DIR="build"
BRIGAND_INSTALL_PREFIX=${1:-"${HOME}/Desktop/third_party_installed"}

mkdir -p "${BRIGAND_INSTALL_PREFIX}"

# mkdir -p build && cd "$_" || exit

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

# cmake .. -DCMAKE_INSTALL_PREFIX="${BRIGAND_INSTALL_PATH}" -DCMAKE_CXX_COMPILER="${CXX}"
# # make standalone
# make install

cmake -B "${BRIGAND_BUILD_DIR}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-S .
cmake --build "${BRIGAND_BUILD_DIR}"
cmake --install "${BRIGAND_BUILD_DIR}" --prefix "${BRIGAND_INSTALL_PREFIX}"

unset BRIGAND_BUILD_DIR
unset BRIGAND_INSTALL_PREFIX
