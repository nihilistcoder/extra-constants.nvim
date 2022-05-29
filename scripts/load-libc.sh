#!/bin/bash

FIND=$(which find)
MKDIR=$(which mkdir)
DIRNAME=$(which dirname)
GREP=$(which grep)

SCRIPT_DIR="$( cd -- "$(${DIRNAME} -- "${BASH_SOURCE[0]:-$0}";)" &> /dev/null && pwd 2> /dev/null; )"
CACHE_DIR="${HOME}/.cache/nvim/extra-constants"
SYNTAX_DIR="${SCRIPT_DIR}/../after/syntax/c"

if [[ ! -d ${SYNTAX_DIR} ]]; then
    ${MKDIR} -p ${SYNTAX_DIR}
fi

OUTPUT="${SYNTAX_DIR}/libc.vim"
echo -n "" > ${OUTPUT} # truncate the file

HEADERS=$(${FIND} /usr/include \( -path *usr/include/asm-generic/* -o \
                          -path *usr/include/asm/* -o \
                          -path *usr/include/bits/* -o \
                          -path *usr/include/sys/* \
                          -name *.h \)  -o \
                          ! -path *usr/include/*/* -a\
                          \( -name assert.h -o -name complex.h -o -name ctype.h -o \
                          -name errno.h -o -name fenv.h -o -name float.h -o \
                          -name inttypes.h -o -name limits.h -o -name locale.h -o \
                          -name math.h -o -name setjmp.h -o -name signal.h -o \
                          -name stdalign.h -o -name stdarg.h -o -name stdatomic.h -o \
                          -name stdbool.h -o -name stddef.h -o -name stdint.h -o \
                          -name stdio.h -o -name stdlib.h -o -name stdnoreturn.h -o \
                          -name string.h -o -name tgmath.h -o -name threads.h -o \
                          -name time.h -o -name uchar.h -o -name wchar.h -o -name wctype.h \))

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
