#!/bin/bash
#
# fetch-inputs.sh - Fetch our inputs from the source mirror
#

MIRROR_URL=https://people.torproject.org/~mikeperry/mirrors/sources/
MIRROR_URL_DCF=https://people.torproject.org/~dcf/mirrors/sources/
MIRROR_URL_ASN=https://people.torproject.org/~asn/mirrors/sources/
set -e
set -u
umask 0022

if ! [ -e ./versions ]; then
  echo >&2 "Error: ./versions file does not exist"
  exit 1
fi

WRAPPER_DIR=$(dirname "$0")
WRAPPER_DIR=$(readlink -f "$WRAPPER_DIR")

if [ "$#" = 1 ]; then
  INPUTS_DIR="$1"
  VERSIONS_FILE=./versions
elif [ "$#" = 2 ]; then
  INPUTS_DIR="$1"
  VERSIONS_FILE=$2
else
  echo >&2 "Usage: $0 [<inputsdir> <versions>]"
  exit 1
fi

if ! [ -e $VERSIONS_FILE ]; then
  echo >&2 "Error: $VERSIONS_FILE file does not exist"
  exit 1
fi

. $VERSIONS_FILE

mkdir -p "$INPUTS_DIR"
cd "$INPUTS_DIR"


##############################################################################
CLEANUP=$(tempfile)
trap "bash '$CLEANUP'; rm -f '$CLEANUP'" EXIT

# FIXME: This code is copied to verify-tags.sh.. Should we make a bash
# function library?
verify() {
  local file="$1"; shift
  local keyring="$1"; shift
  local suffix="$1"; shift

  local f
  for f in "$file" "$file.$suffix" "$keyring"; do
    if ! [ -e "$f" ]; then
      echo >&2 "Error: Required file $f does not exist."; exit 1
    fi
  done

  local tmpfile=$(tempfile)
  echo "rm -f '$tmpfile'" >> "$CLEANUP"
  local gpghome=$(mktemp -d)
  echo "rm -rf '$gpghome'" >> "$CLEANUP"
  exec 3> "$tmpfile"

  GNUPGHOME="$gpghome" gpg --no-options --no-default-keyring --trust-model=always --keyring="$keyring" --status-fd=3 --verify "$file.$suffix" "$file" >/dev/null 2>&1
  if grep -q '^\[GNUPG:\] GOODSIG ' "$tmpfile"; then
    return 0
  else
    return 1
  fi
}

get() {
  local file="$1"; shift
  local url="$1"; shift

  if ! wget -U "" -N "$url"; then
    echo >&2 "Error: Cannot download $url"
    mv "${file}" "${file}.DLFAILED"
    exit 1
  fi
}

update_git() {
  local dir="$1"; shift
  local url="$1"; shift
  local tag="${1:-}"

  if [ -d "$dir/.git" ];
  then
    (cd "$dir" && git remote set-url origin $url && git fetch --prune origin && git fetch --prune --tags origin)
  else
    if ! git clone "$url" "$dir"; then
      echo >&2 "Error: Cloning $url failed"
      exit 1
    fi
  fi

  if [ -n "$tag" ]; then
    (cd "$dir" && git checkout "$tag")
  fi

  # If we're not verifying tags, then some of the tags
  # may actually be branch names that require an update
  if [ $VERIFY_TAGS -eq 0 -a -n "$tag" ];
  then
    (cd "$dir" && git pull || true )
  fi
}

##############################################################################
# Get package files from mirror

# Get+verify sigs that exist
for i in OPENSSL # OBFSPROXY
do
  PACKAGE="${i}_PACKAGE"
  URL="${MIRROR_URL}${!PACKAGE}"
  SUFFIX="asc"
  get "${!PACKAGE}" "$URL"
  get "${!PACKAGE}.$SUFFIX" "$URL.$SUFFIX"

  if ! verify "${!PACKAGE}" "$WRAPPER_DIR/gpg/$i.gpg" $SUFFIX; then
    echo "$i: GPG signature is broken for ${URL}"
    mv "${!PACKAGE}" "${!PACKAGE}.badgpg"
    exit 1
  fi
done


exit 0

