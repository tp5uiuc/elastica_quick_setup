#!/usr/bin/env sh

# HIGHFIVE automatically installs in the HIGHFIVE subdirectory
HIGHFIVE_BUILD_DIR="build"
HIGHFIVE_INSTALL_PREFIX=${1:-"${HOME}/Desktop/third_party_installed"}

mkdir -p "${HIGHFIVE_INSTALL_PREFIX}"

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

# We need high-five to be found, else this steps error out. Rather than searching for the libraries which is harder,
# we search for the compiler-wrapper here.
if command -v h5cc >/dev/null 2>&1; then # h5cc exists, so good chance that Cmake wont bug out
	cmake -B "${HIGHFIVE_BUILD_DIR}" \
		-D CMAKE_BUILD_TYPE=Release \
		-D CMAKE_CXX_COMPILER="${_CXX_COMPILER}" \
		-D HIGHFIVE_USE_BOOST=OFF \
		-D HIGHFIVE_USE_HALF_FLOAT=OFF \
		-D HIGHFIVE_USE_EIGEN=OFF \
		-D HIGHFIVE_USE_OPENCV=OFF \
		-D HIGHFIVE_USE_XTENSOR=OFF \
		-D HIGHFIVE_EXAMPLES=OFF \
		-D HIGHFIVE_UNIT_TESTS=OFF \
		-D HIGHFIVE_PARALLEL_HDF5=OFF \
		-D HIGHFIVE_BUILD_DOCS=OFF \
		-S .
	# doesn't need to be strictly parallel as its header only
	cmake --build "${HIGHFIVE_BUILD_DIR}" --parallel "${_PARALLEL_ARG}"
	cmake --install "${HIGHFIVE_BUILD_DIR}" --prefix "${HIGHFIVE_INSTALL_PREFIX}"
else
	echo "h5cc was not found. Chances are that HDF5 is not installed on your system, so the HighFive dependency will not be installed."
fi

unset _PARALLEL_ARG
unset _CXX_COMPILER
unset _CXX_
unset -f elastica_detect_compiler
unset HIGHFIVE_BUILD_DIR
unset HIGHFIVE_INSTALL_PREFIX
