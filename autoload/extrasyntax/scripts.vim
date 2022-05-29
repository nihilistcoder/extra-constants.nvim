" vim:foldmethod=marker:foldlevel=0

"
" functions from the bash scripts in the scripts/ folder
"

let s:pluginpath=fnamemodify(fnamemodify(resolve(expand('<sfile>:h')), ':h'), ':h')
let s:scriptdir=s:pluginpath."/scripts"
let s:scriptpath=s:pluginpath . "/scripts/extrasyntax.sh"

" find_constants {{{

function! extrasyntax#scripts#find_constants(file)
    return system([s:scriptpath, "find_constants", a:file])
endfunction

" }}}

" find_enums {{{

function! extrasyntax#scripts#find_enums(file)
    return system([s:scriptpath, "find_enums", a:file])
endfunction

" }}}

" find_all_files_from_project {{{

function! extrasyntax#scripts#find_all_files_from_project(dir = s:project_root)
    return system([s:scriptpath, "find_all_files_from_project", a:dir])
endfunction

" }}}

function! extrasyntax#scripts#regenerate_predefs()
    let cmd=[s:scriptdir."/regenerate_predefs.sh", stdpath("cache")."/extrasyntax"]
    let opts={"detach":1}
    call chanclose(jobstart(cmd, opts))
endfunction
