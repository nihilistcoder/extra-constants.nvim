#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )"

syntax_dir="${SCRIPT_DIR}/../after/syntax/c"

if [[ ! -d ${syntax_dir} ]]; then
    mkdir -p ${syntax_dir}
fi

files=$(find /usr/include \( -path *usr/include/asm-generic/* -o \
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

for file in ${files}; do
    constants=$(${SCRIPT_DIR}/extrasyntax.sh find_constants ${file})
    enums=$(${SCRIPT_DIR}/extrasyntax.sh find_enums ${file})

    outpufile=${syntax_dir}/$(echo -n "${file}" | tr "/" "." | sed 's/^\.//').vim
    for constant in ${constants}; do
        echo "syn keyword cConstant ${constant}" >> ${outpufile}
    done
done
