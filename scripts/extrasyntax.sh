#!/usr/bin/bash

GREP=$(which grep)
SED=$(which sed)
TR=$(which tr)
PERL=$(which perl)
CPP=$(which cpp)
DIFF=$(which diff)

function find_constants () {
    [[ -z "${1}" || ! -f "${1}" ]] && echo "" && return 1
    [[ ! -f "${2}/predefs.txt" ]] && echo "" && return 1

    FILE=${1}
    CACHE_DIR=${2}
    TMPFILE=$(mktemp)

    ${CPP} -dD -E -x c ${FILE} 2>/dev/null | ${GREP} "#define" | cut -d' ' -f2 | grep -v -E -e "\w+\(.*\)$" > ${TMPFILE}

    grep ${TMPFILE} -v -f "${CACHE_DIR}/predefs.txt" | grep -v -E -e "(^_.*|_H(_INCLUDED)?$)"

    rm ${TMPFILE}

    return 0
}

function find_enums () {
    [[ -z "${1}" || ! -f "${1}" || ! -r "${1}" ]] && echo "" && return 1

    ${SED} 's/\/\/.*$//' ${1} | ${TR} "\n" " " | ${PERL} -pe 's/\/\*.*?\*\///g' |\
        ${GREP} -E -e 'enum\s*\w*\s*{(\s*\w*\s*=?\s*-?\w*\s*,?)+}' --only-matching |\
        ${SED} -E 's/(\s*=\s*-?\w*,?|,|enum\s*\w*\s*\{\s*|\s*\})//g' | ${SED} -z -E 's/\s+/\n/g'

    return 0
}

function find_all_files_from_project () {
    [[ -z "${1}" || ! -d "${1}" ]] && echo "" && return 1

    find ${1} ! -path *CMakeFiles* -name *.c -o -name *.h 2>/dev/null
}

if [[ ! -z "${1}" ]]; then
    "${@}"
fi
