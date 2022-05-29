#!/bin/bash

FIND=$(which find)
MKDIR=$(which mkdir)
GREP=$(which grep)

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )"
CACHE_DIR="${HOME}/.cache/nvim/extra-constants"
SYNTAX_DIR="${SCRIPT_DIR}/../after/syntax/c"

if [[ ! -d ${SYNTAX_DIR} ]]; then
    ${MKDIR} -p ${SYNTAX_DIR}
fi

OUTPUT="${SYNTAX_DIR}/libgcc.vim"
echo -n "" > ${OUTPUT} # truncate the file

GCC_INCLUDE_DIR="$(gcc -print-search-dirs | grep -e "install:" | cut -d' ' -f2)include"

HEADERS=$(${FIND} ${GCC_INCLUDE_DIR} -name *.h)

CONSTANTS_ALL_FILE=$(mktemp)

for file in ${HEADERS}; do
    ${SCRIPT_DIR}/functions.sh find_constants ${file} ${CACHE_DIR} >> ${CONSTANTS_ALL_FILE}
    ${SCRIPT_DIR}/functions.sh find_enums ${file} ${HOME} >> ${CONSTANTS_ALL_FILE}
done

CONSTANTS=$(sort ${CONSTANTS_ALL_FILE} | uniq)

for c in ${CONSTANTS}; do
    echo "syn keyword cConstant ${c}"  >> ${OUTPUT}
done

rm ${CONSTANTS_ALL_FILE}
