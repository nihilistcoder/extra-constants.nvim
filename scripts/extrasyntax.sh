#!/usr/bin/bash

GREP=$(which grep)
SED=$(which sed)
TR=$(which tr)
PERL=$(which perl)

function find_constants () {
    [[ -z "${1}" || ! -f "${1}" || ! -r "${1}" ]] && echo "" && return 1

    ${GREP} ${1} -E -e '#\s*define\s+\w*($|\s)' --only-matching |\
        ${SED} 's/#\s*define\s\+//' | ${GREP} -E '\w*' --only-matching
    return 0
}

function find_enums () {
    [[ -z "${1}" || ! -f "${1}" || ! -r "${1}" ]] && echo "" && return 1

    ${SED} 's/\/\/.*$//' ${1} | ${TR} "\n" " " | ${PERL} -pe 's/\/\*.*?\*\///g' |\
        ${GREP} -E -e 'enum\s*{(\s*\w*\s*=?\s*\w*\s*,?)+}' --only-matching |\
        ${SED} -E 's/(\s*=\s*\w*,?|,|enum\s*\{\s*|\s*\})//g' | ${SED} -z -E 's/\s+/\n/g'

    return 0
}

function find_all_files_from_project () {
    [[ -z "${1}" || ! -d "${1}" ]] && echo "" && return 1

    find ${1} ! -path *CMakeFiles* -name *.c -o -name *.h 2>/dev/null
}

if [[ ! -z "${1}" ]]; then
    "${@}"
fi
