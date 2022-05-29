augroup extra_constants
    au!
    au VimEnter *.c,*.h ++once call extra_constants#init()
    au UIEnter *.c,*.h ++once call extra_constants#loadall_from_project()
    au VimEnter *.c,*.h ++once call extra_constants#scripts#regenerate_predefs()
augroup END

function! ExtraConstantsLoadFromHeaders(dir)
    let sources=split(extra_constants#find_all_files_from_project(a:dir))
    if (!empty(sources))
        for src in sources
            call extra_constants#load_file_constants(src)
        endfor
    endif
endfunction
