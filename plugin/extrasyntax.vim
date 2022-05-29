augroup extrasyntax
    au!
    au VimEnter *.c,*.h ++once call extrasyntax#init()
    au UIEnter *.c,*.h ++once call extrasyntax#loadall_from_project()
    au VimEnter *.c,*.h ++once call extrasyntax#scripts#regenerate_predefs()
augroup END

function! ExtraSyntaxLoadFromHeaders(dir)
    let sources=split(extrasyntax#find_all_files_from_project(a:dir))
    if (!empty(sources))
        for src in sources
            call extrasyntax#load_file_constants(src)
        endfor
    endif
endfunction
