let s:pluginpath=fnamemodify(resolve(expand('<sfile>:h')), ':h')
let s:datapath=stdpath('cache') . "/extrasyntax"
let s:blacklistdir=s:datapath."/blacklist"
let s:whitelistdir=s:datapath."/whitelist"
" this will be the file that will determine the root of your project
" Set this to a file that will always be in the root of your projects
let s:anchors=get(g:, "extrasyntax_anchor_files", ["CMakeLists.txt", "Makefile"])
let s:project=""
let s:project_root=getcwd()
let s:project_datapath=s:datapath
let s:project_internal_name=""
let s:buffers=[]

function! extrasyntax#add_current_buffer()
    let buf=bufnr("%")
    if (index(s:buffers, buf) == -1)
        let s:buffers+=[buf]
    endif
endfunction

function! extrasyntax#remove_current_buffer()
    echo "here"
    let buf=bufnr("%")
    let ndx=index(s:buffers, buf)
    if (ndx == -1)
        call remove(s:buffers, ndx)
    endif
endfunction

function! extrasyntax#set_project_root_dir(dir)
    let s:project_root=a:dir

    " let the project name be the full directory path
    " use join() + split() to remove the / at the beggining

    let s:project_internal_name=join(split(a:dir, "/"), ".")
    let s:project_datapath=s:datapath . "/" . s:project_internal_name
    let s:project=fnamemodify(s:project_root, ":t")
endfunction

" Setup the plugin
function! extrasyntax#init()
    if (!isdirectory(s:datapath))
        call mkdir(s:datapath, "p")
    endif

    if (!isdirectory(s:blacklistdir))
        call mkdir(s:blacklistdir, "p")
    endif

    if (!isdirectory(s:whitelistdir))
        call mkdir(s:whitelistdir, "p")
    endif

    call extrasyntax#set_project_root_dir(extrasyntax#utils#find_project_root_dir(s:anchors))
endfunction

" source the given syntax file
function! extrasyntax#loadsyntax(path)
    if (!filereadable(a:path))
        return
    endif

    for buf in s:buffers
        let winid=bufwinid(buf)
        call win_execute(winid, "source " . a:path)
    endfor
endfunction

function! extrasyntax#add_new_constants(constants, outputfile)
    let lines=[]
    for constant in a:constants
        let lines+=["syn keyword cConstant ". constant]
    endfor

    call writefile(lines, a:outputfile, "a")
    call extrasyntax#loadsyntax(a:outputfile)
endfunction

function! extrasyntax#load_file_constants(file)
    let outputfile=s:project_datapath . "/" . extrasyntax#utils#this_file_internal_name(a:file) . ".vim"

    if (!filereadable(outputfile))
        call system(["touch", outputfile])
    endif

    let constants=split(extrasyntax#scripts#find_constants(a:file))
    let constants+=split(extrasyntax#scripts#find_enums(a:file))
    let new_constants=[]
    for constant in constants
        if (!extrasyntax#utils#has_constant(constant, outputfile))
            let new_constants+=[constant]
        endif
    endfor

    if (!empty(new_constants))
        call extrasyntax#add_new_constants(new_constants, outputfile)
    else
        call extrasyntax#loadsyntax(outputfile)
    endif
endfunction

function! extrasyntax#loadall_from_project()
    " search the project in the blacklist directory
    " if we find it, then we don't load anything
    if (filereadable(s:blacklistdir."/".s:project_internal_name))
        return
    endif

    if (!filereadable(s:whitelistdir."/".s:project_internal_name))
        if (tolower(input("(Extra-Syntax) Load extra syntax for '".s:project."'? (Y/N) ")) == "n")
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
            call extrasyntax#loadsyntax(file)
        endfor
    endif

    let sources=split(extrasyntax#scripts#find_all_files_from_project())

    " search for any files that we do not have
    for src in sources
        let outputfile=s:project_datapath . "/" . join(split(src, "/"), ".") . ".vim"
        if (count(files, outputfile) == 0)
            call extrasyntax#load_file_constants(src)
        endif
    endfor
endfunction
