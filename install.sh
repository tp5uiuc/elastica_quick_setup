#!/usr/bin/env sh

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
DOWNLOAD_PATH=${1:-"${HOME}/Desktop/third_party/"}
INSTALL_PATH=${2:-"${HOME}/Desktop/third_party_installed/"}
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

mkdir -p "${DOWNLOAD_PATH}" && cd "${DOWNLOAD_PATH}" || exit

# Install blaze, blaze_tensor and brigand
echo "Building Blaze"
BLAZE_REPO="https://bitbucket.org/blaze-lib/blaze.git"
BLAZE_PATH="${DOWNLOAD_PATH}/blaze/"
if [ -d "${BLAZE_PATH}" ]; then
	# Get the latest version
	cd "${BLAZE_PATH}" && git pull origin
else
	git clone --depth 1 "${BLAZE_REPO}" "${BLAZE_PATH}" || fail "Could not clone blaze"
fi
cp "${SCRIPT_DIR}/detail/build_blaze.sh" "${BLAZE_PATH}" && cd "${BLAZE_PATH}" || exit
source build_blaze.sh "${INSTALL_PATH}" || fail "Could not build blaze"

echo "Building BlazeTensor"
BLAZE_TENSOR_REPO="https://github.com/STEllAR-GROUP/blaze_tensor.git"
BLAZE_TENSOR_PATH="${DOWNLOAD_PATH}/blaze_tensor/"
if [ -d "${BLAZE_TENSOR_PATH}" ]; then
	# Get the latest version
	cd "${BLAZE_TENSOR_PATH}" && git pull origin
else
	git clone --depth 1 "${BLAZE_TENSOR_REPO}" "${BLAZE_TENSOR_PATH}" || fail "Could not clone blaze_tensor"
fi
cp "${SCRIPT_DIR}/detail/build_blaze_tensor.sh" "${BLAZE_TENSOR_PATH}" && cd "${BLAZE_TENSOR_PATH}" || exit
source build_blaze_tensor.sh "${INSTALL_PATH}" || fail "Could not build blaze_tensor"

echo "Building Brigand"
BRIGAND_REPO="https://github.com/edouarda/brigand.git"
BRIGAND_PATH="${DOWNLOAD_PATH}/brigand/"
if [ -d "${BRIGAND_PATH}" ]; then
	# Get the latest version
	cd "${BRIGAND_PATH}" && git pull origin
else
	git clone --depth 1 "${BRIGAND_REPO}" "${BRIGAND_PATH}" || fail "Could not clone brigand"
fi
cp "${SCRIPT_DIR}/detail/build_brigand.sh" "${BRIGAND_PATH}" && cd "${BRIGAND_PATH}" || exit
source build_brigand.sh "${INSTALL_PATH}" || fail "Could not build brigand"

# git clone --depth 1 "${BRIGAND_REPO}"

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
