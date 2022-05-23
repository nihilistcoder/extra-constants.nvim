#!/usr/bin/bash

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
    output=${2}/$(${3}/create-output-name.sh ${file})
    for constant in ${constants}; do
        grep ${output} -e ${constant} &>/dev/null
        if [[ $? -ne 0 ]]; then
            echo "syn keyword cConstant ${constant}" >> ${output}
        fi
    done
}

