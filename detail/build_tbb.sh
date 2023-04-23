#!/usr/bin/env sh

# TBB automatically installs in the TBB subdirectory
TBB_BUILD_DIR="build"
TBB_INSTALL_PREFIX=${1:-"${HOME}/Desktop/third_party_installed"}
mkdir -p "${TBB_INSTALL_PREFIX}"

function elastica_detect_compiler() {
	# check gcc version starting from 9 on to 4
	local version_array=("$(seq 11 -1 4)")
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
# TBB static build is discouraged for some reason
cmake -B "${TBB_BUILD_DIR}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${_CXX_COMPILER}" \
	-DTBB_TEST=OFF \
	-DTBB4PY_BUILD=OFF \
	-DBUILD_SHARED_LIBS=ON \
	-S .
cmake --build "${TBB_BUILD_DIR}" --parallel "${_PARALLEL_ARG}"
cmake --install "${TBB_BUILD_DIR}" --prefix "${TBB_INSTALL_PREFIX}"

unset _PARALLEL_ARG
unset _CXX_COMPILER
unset _CXX_
unset -f elastica_detect_compiler
unset TBB_BUILD_DIR
unset TBB_INSTALL_PREFIX
