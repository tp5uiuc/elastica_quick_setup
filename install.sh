#!/usr/bin/env sh

pushd "$(pwd)" || exit

function fail() {
	printf '%s\n' "$1" >&2 ## Send message to stderr.
	exit "${2-1}"          ## Return a code specified by $2, or 1 by default.
}

if ! hash git 2>/dev/null; then
	fail "Please install git"
fi

read -rd '' globalhelp <<-EOF
	usage
	-----
	./install.sh [-d dpath] [-i ipath] [-c compiler]

	options and explanations
	---------------------------
	  help : Print this help message

	  d dpath : Path to download source of libraries (created if it does not exist).
	          Defaults to ${HOME}/Desktop/third_party/

	  i installpath : Path to install libraries (created if it does not exist).
	          Defaults to ${HOME}/Desktop/third_party_installed/

	  c compiler : C++ compiler to build/install libraries.
	          If not provided, the best known option will be chosen.
EOF

if [[ $1 =~ ^([hH][eE][lL][pP]|[hH])$ ]]; then
	echo "${globalhelp}"
	exit 0
fi

while [ $# -gt 0 ]; do
	case "$1" in
	-d | -dpath | --dpath)
		DOWNLOAD_PATH="$2"
		;;
	-i | -ipath | --ipath)
		INSTALL_PATH="$2"
		;;
	-c | -compiler)
		GLOBAL_CXX_COMPILER="$2"
		;;
	-h | -help | --help)
		echo "${globalhelp}"
		exit 0
		;;
	*)
		printf "* install: Invalid option encountered, see usage below*\n"
		echo "${globalhelp}"
		exit 1
		;;
	esac
	shift
	shift
done

function _elastica_detect_compiler() {
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
_elastica_detect_compiler

# Path to download header only libraries
DOWNLOAD_PATH=${DOWNLOAD_PATH:-"${HOME}/Desktop/third_party"}
INSTALL_PATH=${INSTALL_PATH:-"${HOME}/Desktop/third_party_installed"}
GLOBAL_CXX_COMPILER=${GLOBAL_CXX_COMPILER:-"${_CXX_}"}
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

mkdir -p "${DOWNLOAD_PATH}" && cd "${DOWNLOAD_PATH}" || exit

function setup_library() {
	local name=$1
	local repo=$2
	local script_name="${3:-"build_${name}"}.sh"
	local detection_script_name="elastica_detect_compiler.sh"

	echo "Building ${name}"
	local repo_path="${DOWNLOAD_PATH}/${name}/"
	if [ -d "${repo_path}" ]; then
		# Get the latest version
		cd "${repo_path}" && git pull origin
	else
		git clone --depth 1 "${repo}" "${repo_path}" || fail "Could not clone ${name}"
	fi
	cp "${SCRIPT_DIR}/detail/${script_name}" "${repo_path}" && cd "${repo_path}" || exit
	cp "${SCRIPT_DIR}/detail/${detection_script_name}" "${repo_path}" && cd "${repo_path}" || exit
	source "${script_name}" "${INSTALL_PATH}" "${GLOBAL_CXX_COMPILER}" || fail "Could not build ${name}"
}

setup_library "blaze" "https://bitbucket.org/blaze-lib/blaze.git"
setup_library "blaze_tensor" "https://github.com/STEllAR-GROUP/blaze_tensor.git"
setup_library "brigand" "https://github.com/edouarda/brigand.git"
setup_library "cxxopts" "https://github.com/jarro2783/cxxopts.git"
setup_library "yaml-cpp" "https://github.com/jbeder/yaml-cpp.git"
setup_library "HighFive" "https://github.com/BlueBrain/HighFive"
setup_library "tbb" "https://github.com/oneapi-src/oneTBB.git"

touch ~/.localrc
chmod u+rwx ~/.localrc

if [ ! -v BLAZE_ROOT ]; then
	echo "export BLAZE_ROOT='${INSTALL_PATH}'" >>~/.localrc
fi
if [ ! -v BLAZE_TENSOR_ROOT ]; then
	echo "export BLAZE_TENSOR_ROOT='${INSTALL_PATH}'" >>~/.localrc
fi
if [ ! -v BRIGAND_ROOT ]; then
	echo "export BRIGAND_ROOT='${INSTALL_PATH}'" >>~/.localrc
fi
if [ ! -v cxxopts_DIR ]; then
	echo "export cxxopts_DIR='${INSTALL_PATH}'" >>~/.localrc
fi
# This will add to previously installed quicksetup profiles as well
if [ ! -v YamlCpp_ROOT ]; then
	echo "export YamlCpp_ROOT='${INSTALL_PATH}'" >>~/.localrc
fi
# We have a FindHighFive.cmake that is case-insensitive
if [ ! -v HighFive_ROOT ]; then
	echo "export HighFive_ROOT='${INSTALL_PATH}'" >>~/.localrc
fi
if [ ! -v TBB_ROOT ]; then
	echo "export TBB_ROOT='${INSTALL_PATH}'" >>~/.localrc
fi

read -rd '' finalmessage <<-EOF
	    The path to the libraries just installed are appended to the file ~/.localrc. To ensure that the paths are exported, please run the following command:
EOF

echo ""
echo "${finalmessage}"
echo ""

if [ -n "${ZSH_VERSION}" ]; then
	echo "echo \"[ -f ~/.localrc ] && . ~/.localrc\" >> ~/.zshrc"
elif [ -n "${BASH_VERSION}" ]; then
	echo "echo \"[ -f ~/.localrc -a -r ~/.localrc ] && . ~/.localrc\" >> ~/.bashrc"
else
	fail "shell not recognized, please source localrc manually"
fi

unset -f _elastica_detect_compiler
unset -f setup_library
unset SCRIPT_DIR
unset INSTALL_PATH
unset DOWNLOAD_PATH
unset GLOBAL_CXX_COMPILER
unset _CXX_

popd || exit
