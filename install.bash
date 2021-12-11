#!/usr/bin/env bash

function fail() {
	printf '%s\n' "$1" >&2 ## Send message to stderr.
	exit "${2-1}"          ## Return a code specified by $2, or 1 by default.
}

if ! hash git 2>/dev/null; then
	echo "Please install git"
	exit
fi

# Path to download header only libraries
DOWNLOAD_PATH="${HOME}/Desktop/third_party/"
INSTALL_PATH="${HOME}/Desktop/third_party_installed/"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

mkdir -p "${DOWNLOAD_PATH}" && cd "${DOWNLOAD_PATH}" || exit

# Install blaze, blaze_tensor and brigand
echo "Building Blaze"
BLAZE_REPO="https://bitbucket.org/blaze-lib/blaze.git"
BLAZE_PATH="${DOWNLOAD_PATH}/blaze/"
if [ -d "${BLAZE_PATH}"]; then
	# Get the latest version
	cd "${BLAZE_PATH}" && git pull origin
else
	git clone --depth 1 "${BLAZE_REPO}" "${BLAZE_PATH}" || fail "Could not clone blaze"
fi
cp "${SCRIPT_DIR}/build_blaze.sh" "${BLAZE_PATH}" && cd "${BLAZE_PATH}" || exit
source build_blaze.sh "${INSTALL_PATH}" || fail "Could not build blaze"

# BLAZE_TENSOR_REPO="https://github.com/STEllAR-GROUP/blaze_tensor.git"
# git clone --depth 1 "${BLAZE_TENSOR_REPO}"

# BRIGAND_REPO="https://github.com/edouarda/brigand.git"
# git clone --depth 1 "${BRIGAND_REPO}"
