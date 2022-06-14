#!/usr/bin/env sh

# Blaze automatically installs in the blaze subdirectory
BLAZE_TENSOR_BUILD_DIR="build"
BLAZE_TENSOR_INSTALL_PREFIX=${1:-"${HOME}/Desktop/third_party_installed"}

BLAZE_PATH="${1}/share/blaze/cmake/"
mkdir -p "${BLAZE_TENSOR_INSTALL_PREFIX}"

function elastica_detect_compiler() {
	# check gcc version starting from 9 on to 4
	local version_array=($(seq 11 -1 4))
	local CXX_ver_arr=("${version_array[@]/#/g++-}")
	local CC_ver_arr=("${version_array[@]/#/g++-}")
	# Try and detect GNU g++ from the shell, if not use default CC
	for cxx_ver in "${CXX_ver_arr[@]}"; do
		if command -v "${cxx_ver}" >/dev/null 2>&1 && "${cxx_ver}" --version | grep -q '[Gg][Cc][Cc]'; then
			_CXX_="${cxx_ver}"
			break
		fi
	done
	# Check if not set, else set it
	if [ -z "${_CXX_}" ] && g++ --version; then
		_CXX_="g++"
	fi
}
elastica_detect_compiler

# Requires >3.14
cmake -B "${BLAZE_TENSOR_BUILD_DIR}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${_CXX_}" \
	-Dblaze_DIR="${BLAZE_PATH}" \
	-S .
cmake --build "${BLAZE_TENSOR_BUILD_DIR}"
cmake --install "${BLAZE_TENSOR_BUILD_DIR}" --prefix "${BLAZE_TENSOR_INSTALL_PREFIX}"

unset _CXX_
unset -f elastica_detect_compiler
unset BLAZE_PATH
unset BLAZE_TENSOR_BUILD_DIR
unset BLAZE_TENSOR_INSTALL_PREFIX
