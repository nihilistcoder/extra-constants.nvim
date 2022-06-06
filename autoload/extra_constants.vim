" vim:foldmethod=marker:foldlevel=0
let s:datapath=stdpath('cache') . "/extra-constants"

" a list of constants that already have syntax highlighting
let s:nvim_syntax_txt=s:datapath."/nvim_syntax.txt"
" a list of predefined macros that will be sorted out
let s:predefs_txt=s:datapath."/predefs.txt"

let s:compile_commands=""
let s:buffers=[]

let s:plugin_initialized=0

let s:constants_list=[]

" add_current_buffer {{{
function! extra_constants#add_current_buffer()
    let buf=bufnr("%")
    if (index(s:buffers, buf) == -1)
        let s:buffers+=[buf]
    endif
endfunction

" }}}

" remove_current_buffer {{{

function! extra_constants#remove_current_buffer()
    let buf=bufnr("%")
    let ndx=index(s:buffers, buf)
    if (ndx == -1)
        call remove(s:buffers, ndx)
    endif
endfunction

"}}}

" init {{{

function! extra_constants#init()
    if (!isdirectory(s:datapath))
        call mkdir(s:datapath, "p")
    endif

    if (!filereadable(s:nvim_syntax_txt))
        call extra_constants#scripts#regenerate_nvim_syntax()
    endif

    if (!filereadable(s:predefs_txt))
        call extra_constants#scripts#regenerate_predefs()
    endif

    let s:compile_commands=extra_constants#utils#find_file_in_root("compile_commands.json")

    let s:plugin_initialized=1
endfunction

" }}}

" loadsyntax {{{

function! extra_constants#loadsyntax()
    call extra_constants#add_current_buffer()

    for buf in s:buffers
        let source_commands=map(copy(s:constants_list), '"syn keyword cConstant ". v:val')
        for cmd in source_commands
            call win_execute(bufwinid(buf), cmd)
        endfor
    endfor
endfunction

" }}}

" load_constants_from_file {{{

function! extra_constants#load_constants_from_file(path)
    let constants=extra_constants#scripts#find_constants(a:path, s:compile_commands)
    let constants+=extra_constants#scripts#find_enums(a:path, s:compile_commands)

    let s:constants_list=uniq(sort(s:constants_list + constants))
    call extra_constants#loadsyntax()
endfunction

" }}}
