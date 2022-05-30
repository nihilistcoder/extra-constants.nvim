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
    return system([s:scriptpath, "find_constants", a:file, s:cachedir, a:compile_commands])
endfunction

" }}}

" find_enums {{{

function! extra_constants#scripts#find_enums(file)
    return system([s:scriptpath, "find_enums", a:file])
endfunction

" }}}

" find_all_files_from_project {{{

function! extra_constants#scripts#find_all_files_from_project(dir = s:project_root)
    return system([s:scriptpath, "find_all_files_from_project", a:dir])
endfunction

" }}}

" regenerate_predefs {{{

function! extra_constants#scripts#regenerate_predefs()
    let cmd=[s:scriptdir."/regenerate_predefs.sh", s:cachedir]
    let opts={"detach":1}
    call chanclose(jobstart(cmd, opts))
endfunction

"}}}
