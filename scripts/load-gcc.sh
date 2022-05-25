#!/bin/bash

FIND=$(which find)
MKDIR=$(which mkdir)
GREP=$(which grep)

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )"

SYNTAX_DIR="${SCRIPT_DIR}/../after/syntax/c"

if [[ ! -d ${SYNTAX_DIR} ]]; then
    ${MKDIR} -p ${SYNTAX_DIR}
fi

GCC_INCLUDE_DIR="$(gcc -print-search-dirs | grep -e "install:" | cut -d' ' -f2)include"

headers=$(${FIND} ${GCC_INCLUDE_DIR} -name *.h)

for file in ${headers}; do
    constants=$(${SCRIPT_DIR}/extrasyntax.sh find_constants ${file})
    enums=$(${SCRIPT_DIR}/extrasyntax.sh find_enums ${file})

    outpufile=${SYNTAX_DIR}/$(echo -n "${file}" | tr "/" "." | sed 's/^\.//').vim
    for constant in ${constants}; do
        already_in_c_vim=$(${GREP} /usr/share/nvim/runtime/syntax/c.vim -e ${constant})
        if [[ ${already_in_c_vim} == "" ]]; then
            echo "syn keyword cConstant ${constant}" >> ${outpufile}
        fi
    done
    for enum in ${enums}; do
        already_in_c_vim=$(${GREP} /usr/share/nvim/runtime/syntax/c.vim -e ${enum})
        if [[ ${already_in_c_vim} == "" ]]; then
            echo "syn keyword cConstant ${enum}" >> ${outpufile}
        fi
    done
done
