" vim:foldmethod=marker:foldlevel=0

"
" functions from the bash scripts in the scripts/ folder
"

let s:pluginpath=fnamemodify(fnamemodify(resolve(expand('<sfile>:h')), ':h'), ':h')
let s:scriptdir=s:pluginpath."/scripts"
let s:scriptpath=s:pluginpath . "/scripts/functions.sh"
let s:cachedir=stdpath("cache")."/extra-constants"

" find_constants {{{

function! extra_constants#scripts#find_constants(file, compile_commands)
    return systemlist([s:scriptpath, "find_constants", a:file, s:cachedir, a:compile_commands])
endfunction

" }}}

" find_enums {{{

function! extra_constants#scripts#find_enums(file, compile_commands)
    return systemlist([s:scriptpath, "find_enums", a:file, a:compile_commands])
endfunction

" }}}

" regenerate_predefs {{{

function! extra_constants#scripts#regenerate_predefs()
    call system([s:scriptdir."/regenerate_predefs.sh", s:cachedir])
endfunction

"}}}

" regenerate_nvim_syntax {{{

function! extra_constants#scripts#regenerate_nvim_syntax()
    call system([s:scriptdir."/regenerate_nvim_syntax.sh", s:cachedir])
endfunction

"}}}
