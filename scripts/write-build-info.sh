#!/bin/sh
#
# Records the revision and applied patches of the given project in build.txt
# in the install prefix, replacing any previous entry for the project.
#

set -eo pipefail

PROJECT=$1

if [ -z "$PROJECT" ]; then
  echo "Usage: $0 <project>"
  exit 1
fi

BUILD_TXT="$UNIX_INSTALL_PREFIX/build.txt"
SRC_DIR="`cygpath -u "$SRCROOT"`/$PROJECT"

write_header() {
  echo "Build type: $BUILD_TYPE"
  echo "Architecture: $ARCH"
  echo "Visual Studio: $VSCMD_VER"
  echo "Clang: `clang --version | head -n 1`"
}

write_entry() {
  echo "* $PROJECT"
  printf '\t- Revision: %s\n' "`git -C "$SRC_DIR" rev-parse HEAD`"

  tag=`git -C "$SRC_DIR" describe --tags --exact-match 2>/dev/null || true`
  if [ -n "$tag" ]; then
    printf '\t- Tag: %s\n' "$tag"
  fi

  has_patches=false
  for patch_dir in "`cygpath -u "$ROOT_DIR"`/patches" ${ADDITIONAL_PATCHES_DIR:+"`cygpath -u "$ADDITIONAL_PATCHES_DIR"`"}; do
    for patch in `find "$patch_dir" -name "$PROJECT-*.patch" | sort`; do
      if [ "$has_patches" != true ]; then
        printf '\t- Patches:\n'
        has_patches=true
      fi
      printf '\t\t%s\n' "`basename "$patch"`"
    done
  done
}

entry=`write_entry`

if [ -f "$BUILD_TXT" ]; then
  # replace previous entry for this project in place, or append it
  awk -v RS= -v header="* $PROJECT" -v entry="$entry" '
    { split($0, lines, "\n"); if (lines[1] == header) { $0 = entry; found = 1 } }
    { print sep $0; sep = "\n" }
    END { if (!found) print sep entry }
  ' "$BUILD_TXT" > "$BUILD_TXT.tmp"
else
  { write_header; echo; echo "$entry"; } > "$BUILD_TXT.tmp"
fi

mv "$BUILD_TXT.tmp" "$BUILD_TXT"
