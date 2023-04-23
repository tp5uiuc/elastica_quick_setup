#!/usr/bin/env sh

# Blaze automatically installs in the blaze subdirectory
BLAZE_BUILD_DIR="build"
BLAZE_INSTALL_PREFIX=${1:-"${HOME}/Desktop/third_party_installed"}
mkdir -p "${BLAZE_INSTALL_PREFIX}"

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

# The last commit of blaze seems faulty and leads to segfault
# within elastica++. We revert that here just to be sure.
git fetch --unshallow # undo depth 1
git checkout cb472ee  # Declare the 'rows()', 'columns()', 'spacing()', and 'capacity()' functions of all adapters as 'constexpr'

# >3.14
# -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
cmake -B "${BLAZE_BUILD_DIR}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${_CXX_COMPILER}" \
	-DBLAZE_SHARED_MEMORY_PARALLELIZATION=OFF \
	-DUSE_LAPACK=OFF \
	-S .
cmake --build "${BLAZE_BUILD_DIR}" --parallel "${_PARALLEL_ARG}"
cmake --install "${BLAZE_BUILD_DIR}" --prefix "${BLAZE_INSTALL_PREFIX}"

unset _PARALLEL_ARG
unset _CXX_COMPILER
unset _CXX_
unset -f elastica_detect_compiler
unset BLAZE_BUILD_DIR
unset BLAZE_INSTALL_PREFIX
