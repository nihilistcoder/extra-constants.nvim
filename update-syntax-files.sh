#!/usr/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )"

. ${SCRIPT_DIR}/extrasyntax-functions.sh

syntax_dir=${1}
data_dir=${2}

if [[ ! -d ${syntax_dir} ]]; then
    mkdir -p ${syntax_dir}
fi

if [[ ! -d ${data_dir} ]]; then
    mkdir -p ${data_dir}
fi

if [[ -d ${3} ]]; then
    # directory given, search for all C files and headers and update the syntax files
    files=$(find ${3} ! -path *CMakeFiles* -name *.c -o -name *.h)

    for file in ${files}; do
        update_syntax_file_if_needed ${file} ${syntax_dir} ${SCRIPT_DIR}
    done
else
    # single file, update the syntax file of this single file
    update_syntax_file_if_needed ${3} ${syntax_dir} ${SCRIPT_DIR}
fi
