augroup extrasyntax
    au!
augroup END

function! ExtraSyntaxLoadFromHeaders(dir)
    let sources=split(extrasyntax#find_all_files_from_project(a:dir))
    if (!empty(sources))
        for src in sources
            call extrasyntax#load_file_constants(src)
        endfor
    endif
endfunction
