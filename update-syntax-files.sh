#!/usr/bin/bash

syntax_dir=${1}
data_dir=${2}

if [[ ! -d ${syntax_dir} ]]; then
    mkdir -p ${syntax_dir}
fi

if [[ ! -d ${data_dir} ]]; then
    mkdir -p ${data_dir}
fi

# this function will process the given file and output a list
# of all constants defined with #define or enums.
function find_constants () {
    file=${1}

    tempfile=$(mktemp)
    cat ${file} | tr "\n" " " >> ${tempfile}

    grep ${file} -E -e "#\s*define\s*[A-Za-z_][A-Za-z_0-9]*($|\s)" --only-matching | sed 's/# *define *//' | tr "\n" " "

    # difficult to believe, but this will get all enum definitions
    grep ${tempfile} -E -e "enum\s*\{(\s*[A-Za-z_][A-Za-z_0-9]*\s*=?\s*[A-Z[a-z_0-9]+\s*,?)+\s*\}" --only-matching |\
        tr "," "\n" |\
        sed "s/\(\s*=\s*.*$\|enum\s*{\s*\)//" |\
        grep -E -e "[A-Za-z_][A-Za-z_0-9]*" --only-matching |\
        tr "\n" " "
    rm ${tempfile} &>/dev/null
}

function update_syntax_file_if_needed () {
    file=${1}

    constants=$(find_constants ${file})
    output=${syntax_dir}/$(echo "${file}" | sed "s/\/home\/${USER}\///" | tr "/" "." | sed "s/^\.//").vim
    for constant in ${constants}; do
        grep ${output} -e ${constant} &>/dev/null
        if [[ $? -ne 0 ]]; then
            echo "syn keyword cConstant ${constant}" >> ${output}
        fi
    done
}

if [[ -d ${3} ]]; then
    # directory given, search for all C files and headers and update the syntax files
    files=$(find ${3} -not -path *CMakeFiles* -name *.c -o -name *.h)

    for file in ${files}; do
        update_syntax_file_if_needed ${file}
    done
else
    # single file, update the syntax file of this single file
    update_syntax_file_if_needed ${3}
fi
