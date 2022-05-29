#!/usr/bin/bash

GCC=$(which gcc)
CLANG=$(which clang)

function regenerate_predefs () {
    FILE=${1}
    COMMAND=${2}
    TARGET=${3}

    if [[ ! -z "${TARGET}" ]]; then
        # clang-only cross-compilation option
        TARGET_ARG="-target ${TARGET} "
    fi

    TMPFILE=$(mktemp)

    ${COMMAND} ${TARGET_ARG} -dM -E -x c /dev/null | grep "#define" | cut -d' ' -f2 > ${TMPFILE}

    if [[ ! -z "$(diff --unidirectional-new-file -q ${FILE} ${TMPFILE})" ]]; then
        echo "Saving ${COMMAND} ${TARGET_ARG}predefined macros"
        cp ${TMPFILE} ${FILE}
    else
        echo "${COMMAND} ${TARGET_ARG}predefined macros did not change"
    fi

    rm ${TMPFILE}
}

usage="usage: ./regenerate_predefs.sh <CACHE_DIR>"

CACHE_DIR=${1}

[ -z "${CACHE_DIR}" ] && echo ${usage} && exit 1

PREDEFS_GNU="${CACHE_DIR}/predefs-gnu.txt"
PREDEFS_CLANG="${CACHE_DIR}/predefs-clang-gnu.txt"
PREDEFS_CLANG_MSVC="${CACHE_DIR}/predefs-clang-msvc.txt"

WINDOWS_TARGET="x86_64-pc-windows-gnu"

regenerate_predefs ${PREDEFS_GNU} ${GCC}
regenerate_predefs ${PREDEFS_CLANG} ${CLANG}
regenerate_predefs ${PREDEFS_CLANG_MSVC} ${CLANG} ${WINDOWS_TARGET}

# merge everything
sort -u ${PREDEFS_GNU} ${PREDEFS_CLANG} ${PREDEFS_CLANG_MSVC} > "${CACHE_DIR}/predefs.txt"
