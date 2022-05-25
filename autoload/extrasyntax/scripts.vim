"
" functions from the bash scripts
"

let s:pluginpath=fnamemodify(fnamemodify(resolve(expand('<sfile>:h')), ':h'), ':h')
let s:scriptpath=s:pluginpath . "/scripts/extrasyntax.sh"

function! extrasyntax#scripts#find_constants(file)
    return system([s:scriptpath, "find_constants", a:file])
endfunction

function! extrasyntax#scripts#find_enums(file)
    return system([s:scriptpath, "find_enums", a:file])
endfunction

function! extrasyntax#scripts#find_all_files_from_project(dir = s:project_root)
    return system([s:scriptpath, "find_all_files_from_project", a:dir])
endfunction

