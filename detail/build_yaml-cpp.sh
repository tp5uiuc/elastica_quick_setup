#!/usr/bin/env sh

# YAML_CPP automatically installs in the YAML_CPP subdirectory
YAML_CPP_BUILD_DIR="build"
YAML_CPP_INSTALL_PREFIX=${1:-"${HOME}/Desktop/third_party_installed"}
mkdir -p "${YAML_CPP_INSTALL_PREFIX}"

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
_PARALLEL_ARG=${3:-"1"}

# >3.14
# -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
cmake -B "${YAML_CPP_BUILD_DIR}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${_CXX_COMPILER}" \
	-DYAML_BUILD_SHARED_LIBS=on \
	-S .
cmake --build "${YAML_CPP_BUILD_DIR}" --parallel "${_PARALLEL_ARG}"
cmake --install "${YAML_CPP_BUILD_DIR}" --prefix "${YAML_CPP_INSTALL_PREFIX}"

unset _PARALLEL_ARG
unset _CXX_COMPILER
unset _CXX_
unset -f elastica_detect_compiler
unset YAML_CPP_BUILD_DIR
unset YAML_CPP_INSTALL_PREFIX
