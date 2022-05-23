augroup extrasyntax
    au!
    au VimEnter * let g:extrasyntax_path=fnamemodify(resolve(expand('<sfile>:p')), ':h')
augroup END

function! ESyntaxSetProjectRootDir(dir)
    call extrasyntax#set_project_root_dir(a:dir)
endfunction

" this function will call the script ~/.config/nvim/update-syntax-files.sh
" with the root directory of the current project
"
" WARNING: the script this function executes will recursively search all .c and .h
" files on your project. If your project is very big, it may take some time to
" finish. For now, it updates all files once run, but I may change that in the
" future.
function! ESyntaxUpdateAllSyntaxFiles()
    if (get(g:, "extrasyntax_found_project_root", 0) == 0)
        echo "Root directory of project not found. Call ESyntaxSetProjectRootDir(PATH) to set it manually."
    endif

    echo "Updating syntax files..."
    call extrasyntax#update(g:extrasyntax_project_rootdir)
    call extrasyntax#reload_all()
endfunction

function! ESyntaxLoadLibC()
    let script_path=g:extrasyntax_path . "/../load-libc.sh"
    let after_syntax_c=g:extrasyntax_path . "/../after/syntax/c"
    call system([script_path, after_syntax_c])
endfunction
