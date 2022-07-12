#!/usr/bin/env sh

# CXXOPTS automatically installs in the CXXOPTS subdirectory
CXXOPTS_BUILD_DIR="build"
CXXOPTS_INSTALL_PREFIX=${1:-"${HOME}/Desktop/third_party_installed"}

mkdir -p "${CXXOPTS_INSTALL_PREFIX}"

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
_CXX_COMPILER=${2:-"${_CXX_}"}

# Requires >3.14
cmake -B "${CXXOPTS_BUILD_DIR}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${_CXX_COMPILER}" \
	-DCXXOPTS_BUILD_EXAMPLES=OFF \
	-DCXXOPTS_BUILD_TESTS=OFF \
	-S .
cmake --build "${CXXOPTS_BUILD_DIR}"
cmake --install "${CXXOPTS_BUILD_DIR}" --prefix "${CXXOPTS_INSTALL_PREFIX}"

unset _CXX_COMPILER
unset _CXX_
unset -f elastica_detect_compiler
unset CXXOPTS_BUILD_DIR
unset CXXOPTS_INSTALL_PREFIX
