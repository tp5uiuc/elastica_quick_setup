#!/usr/bin/env sh

pushd $(pwd)

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
	./install.bash <options>
	
	options and explanations
	---------------------------
	  help : Print this help message
	
	  dpath : Path to download source of libraries (created if it does not exist).
	          Defaults to ${HOME}/Desktop/third_party/
	
	  installpath : Path to install libraries (created if it does not exist).
	          Defaults to ${HOME}/Desktop/third_party_installed/
EOF

if [[ $1 =~ ^([hH][eE][lL][pP]|[hH])$ ]]; then
	echo "${globalhelp}"
	exit 0
fi

# Path to download header only libraries
DOWNLOAD_PATH=${1:-"${HOME}/Desktop/third_party"}
INSTALL_PATH=${2:-"${HOME}/Desktop/third_party_installed"}
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
	source "${script_name}" "${INSTALL_PATH}" || fail "Could not build ${name}"
}

setup_library "blaze" "https://bitbucket.org/blaze-lib/blaze.git"
setup_library "blaze_tensor" "https://github.com/STEllAR-GROUP/blaze_tensor.git"
setup_library "brigand" "https://github.com/edouarda/brigand.git"
setup_library "cxxopts" "https://github.com/jarro2783/cxxopts.git"
setup_library "yaml-cpp" "https://github.com/jbeder/yaml-cpp.git"

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
if [ ! -v YAMLCPP_ROOT ]; then
	echo "export YAMLCPP_ROOT='${INSTALL_PATH}'" >>~/.localrc
fi

read -rd '' finalmessage <<-EOF
	    The path to the libraries just installed are appended to the file ~/.localrc. To ensure that the paths are exported, please run the following command:
EOF

echo ""
echo "${finalmessage}"
echo ""

if [ ! -z "${ZSH_VERSION}" ]; then
	echo "echo \"[ -f ~/.localrc ] && . ~/.localrc\" >> ~/.zshrc"
elif [ ! -z "${BASH_VERSION}" ]; then
	echo "echo \"[ -f ~/.localrc -a -r ~/.localrc ] && . ~/.localrc\" >> ~/.bashrc"
else
	fail "shell not recognized, please source localrc manually"
fi

unset -f setup_library
unset SCRIPT_DIR
unset INSTALL_PATH
unset DOWNLOAD_PATH

popd
