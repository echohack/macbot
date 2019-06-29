# These functions are the public API used by install.sh

# Script's color palette
reset="\033[0m"
highlight="\033[42m\033[97m"
dot="\033[33m▸ $reset"
dim="\033[2m"
bold="\033[1m"

headline() {
    printf "${highlight} %s ${reset}\n" "$@"
}

chapter() {
    echo "${highlight} $((count++)).) $@ ${reset}\n"
}

# Prints out a step, if last parameter is true then without an ending newline
step() {
    if [ $# -eq 1 ]
    then echo "${dot}$@"
    else echo "${dot}$@"
    fi
}

run() {
    echo "${dim}▹ $@ $reset"
    eval $@
}

# Downloads a file from a source URL to a local file.
# uses an optional shasum to determine if an existing file can be used.
#
# If an existing file is present and the third argument is set with a shasum
# digest, the file will be checked to see if it's valid. If so, the function
# ends early and returns 0. Otherwise, the shasums do not match so the
# file-on-disk is removed and a normal download proceeds as though no previous
# file existed. This is designed to restart an interrupted download.
#
# Any valid `curl` URL will work.
#
# ```sh
# download_file http://example.com/file.tar.gz file.tar.gz
# # Downloads every time, even if the file exists locally
# download_file http://example.com/file.tar.gz file.tar.gz abc123...
# # Downloads if no local file is found
# download_file http://example.com/file.tar.gz file.tar.gz abc123...
# # File matches checksum: download is skipped, local file is used
# download_file http://example.com/file.tar.gz file.tar.gz oh noes...
# # File doesn't match checksum: local file removed, download attempted
# ```
#
# Will return 0 if a file was downloaded or if a valid cached file was found.
download_file() {
  local url="$1"
  local dst="$HOME/Downloads/$2"
  local sha="$3"
  _curl_cmd=$(command -v curl)
  pushd "$HOME/Downloads" > /dev/null
  if [[ -f $dst && -n "$sha" ]]; then
    echo "Found previous file '$dst', attempting to re-use"
    if verify_file "$dst" "$sha"; then
      echo "Using cached and verified '$dst'"
      return 0
    else
      echo "Clearing previous '$dst' file and re-attempting download"
      rm -fv "$dst"
    fi
  fi

  echo "Downloading '$url' to '$dst'"
  # shellcheck disable=2154
  $_curl_cmd -L "$url" -o "$dst"
  echo "Downloaded '$dst'";
  popd > /dev/null
}

# Verifies that a file on disk matches the given shasum. If the given shasum
# doesn't match the file's shasum then a warning is printed with the expected
# and computed shasum values.
#
# ```sh
# verify_file file.tar.gz abc123...
# ```
#
# Will return 0 if the shasums match, and 1 if they do not match. A message
# will be printed to stderr with the expected and computed shasum values.
verify_file() {
  echo "Verifying $1"
  local checksum
  _openssl_cmd=$(command -v openssl)
  # shellcheck disable=2154
  read -r checksum _ < <($_openssl_cmd dgst -sha256 "$1" | cut -d'=' -f2)
  if [[ $2 = "$checksum" ]]; then
    echo "Checksum verified for $1"
  else
    echo "Checksum invalid for $1:"
    echo "  Expected: $2"
    echo "  Computed: ${checksum}"
    return 1
  fi
  return 0
}