" vim:foldmethod=marker:foldlevel=0

let s:pluginpath=fnamemodify(resolve(expand('<sfile>:h')), ':h')
let s:datapath=stdpath('cache') . "/extra-constants"
let s:blacklistdir=s:datapath."/blacklist"
let s:whitelistdir=s:datapath."/whitelist"
" this will be the file that will determine the root of your project
" Set this to a file that will always be in the root of your projects
let s:anchors=get(g:, "extra_constants_anchor_files", ["CMakeLists.txt", "Makefile"])
let s:project=""
let s:project_root=getcwd()
let s:project_datapath=s:datapath
let s:project_internal_name=""
let s:project_compile_commands=""
let s:buffers=[]

" file_output_name {{{

function! extra_constants#file_output_name(file)
    return s:project_datapath . "/" . extra_constants#utils#this_file_internal_name(a:file) . ".vim"
endfunction

" }}}

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

" set_project_root_dir {{{

function! extra_constants#set_project_root_dir(dir)
    let s:project_root=a:dir

    " let the project name be the full directory path
    " use join() + split() to remove the / at the beggining

    let s:project_datapath=s:datapath . "/" . s:project_internal_name
endfunction

" }}}

" init {{{

function! extra_constants#init()
    if (!isdirectory(s:datapath))
        call mkdir(s:datapath, "p")
    endif

    if (!isdirectory(s:blacklistdir))
        call mkdir(s:blacklistdir, "p")
    endif

    if (!isdirectory(s:whitelistdir))
        call mkdir(s:whitelistdir, "p")
    endif

    let root_dir=extra_constants#utils#find_project_root_dir(s:anchors)
    let s:project_internal_name=extra_constants#utils#this_file_internal_name(root_dir[1])

    if (root_dir[0] == 1)
        call extra_constants#set_project_root_dir(root_dir[1])
    endif

    let s:project=fnamemodify(s:project_root, ":t")

    if (filereadable(s:project_root."/compile_commands.json"))
        let s:project_compile_commands=s:project_root."/compile_commands.json"
    endif
endfunction

" }}}

" loadsyntax {{{

function! extra_constants#loadsyntax(path)
    if (!filereadable(a:path))
        return
    endif

    for buf in s:buffers
        let winid=bufwinid(buf)
        call win_execute(winid, "source " . a:path)
    endfor
endfunction

" }}}

" load_file_constants {{{

function! extra_constants#load_file_constants(file)
    if (filereadable(s:blacklistdir."/".s:project_internal_name))
        return
    endif

    let outputfile=extra_constants#file_output_name(a:file)

    let constants=split(extra_constants#scripts#find_constants(a:file, s:project_compile_commands))
    let constants+=split(extra_constants#scripts#find_enums(a:file))
    let constants=systemlist("sort -u -", constants)

    for i in range(len(constants))
        let constants[i] = "syn keyword cConstant " . constants[i]
    endfor

    let tempfile=tempname()
    call writefile(constants, tempfile)

    let differ=system(["diff", "-q", "-N", tempfile, outputfile])

    if (!empty(differ))
        call writefile(constants, outputfile)
        call extra_constants#loadsyntax(outputfile)
    endif
endfunction

" }}}

" loadall_from_project {{{
function! extra_constants#loadall_from_project()
    " search the project in the blacklist directory
    " if we find it, then we don't load anything
    if (filereadable(s:blacklistdir."/".s:project_internal_name))
        return
    endif

    if (!filereadable(s:whitelistdir."/".s:project_internal_name))
        let choices="&Yes\n&No"
        let msg="(Extra-Syntax) Load constants for '".s:project."'?"
        if (confirm(msg, choices, 2, "Question") == 2)
            call system(["touch", s:blacklistdir."/".s:project_internal_name])
            return
        else
            call system(["touch", s:whitelistdir."/".s:project_internal_name])
        endif
    endif

    if (!isdirectory(s:project_datapath))
        call mkdir(s:project_datapath, "p")
    endif

    let files=split(glob(s:project_datapath . "/*.vim"))

    if (!empty(files))
        for file in files
            call extra_constants#loadsyntax(file)
        endfor
    endif

    let sources=split(extra_constants#scripts#find_all_files_from_project())

    " search for any files that we do not have
    for src in sources
        let outputfile=s:project_datapath . "/" . join(split(src, "/"), ".") . ".vim"
        if (count(files, outputfile) == 0)
            call extra_constants#load_file_constants(src)
        endif
    endfor
endfunction

" }}}
