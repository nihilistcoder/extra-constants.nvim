#!/usr/bin/bash

NVIM_SYNTAX_FILE="/usr/share/nvim/runtime/syntax/c.vim"

CACHE_DIR=${1}

[[ -z "${CACHE_DIR}" || ! -d "${CACHE_DIR}" ]] && echo "usage: ./regenerate_nvim_syntax.sh <CACHE_DIR>" && exit 1

NVIM_SYNTAX_TXT="${CACHE_DIR}/nvim_syntax.txt"

grep ${NVIM_SYNTAX_FILE} -E -e "syn\s*keyword\s*cConstant" | sed "s/^\s*syn\s*keyword\s*cConstant\s*//" | tr " " "\n" > ${NVIM_SYNTAX_TXT}
grep ${NVIM_SYNTAX_FILE} -E -e "syn\s*keyword\s*cType" | sed "s/^\s*syn\s*keyword\s*cType\s*//" | tr " " "\n" >> ${NVIM_SYNTAX_TXT}
grep ${NVIM_SYNTAX_FILE} -E -e "syn\s*keyword\s*cStorageClass" | sed "s/^\s*syn\s*keyword\s*cStorageClass\s*//" | tr " " "\n" >> ${NVIM_SYNTAX_TXT}
