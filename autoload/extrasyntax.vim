let s:pluginpath=fnamemodify(resolve(expand('<sfile>:h')), ':h')
let s:scriptpath=s:pluginpath . "/scripts/extrasyntax.sh"
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

function! extrasyntax#this_file_internal_name(file="%:p")
    return join(split(expand(a:file), "/"), ".")
endfunction

function! extrasyntax#current_file_syntax_path()
    return s:project_datapath . "/" . extrasyntax#this_file_internal_name() . ".vim"
endfunction

function! extrasyntax#has_constant(constant, file)
    return !empty(system(["grep", a:file, "-e", "syn keyword cConstant ".a:constant.""]))
endfunction

function! extrasyntax#set_project_root_dir(dir)
    let s:project_root=a:dir

    " let the project name be the full directory path
    " use join() + split() to remove the / at the beggining

    let s:project_internal_name=join(split(a:dir, "/"), ".")
    let s:project_datapath=s:datapath . "/" . s:project_internal_name
    let s:project=fnamemodify(s:project_root, ":t")
endfunction

" finds the root directory by traversing the path up until we find a
" CMakeLists.txt (or other) file, since we know there will be one there
function! extrasyntax#find_project_root_dir()
    " shell current directory
    let current_dir=getcwd()

    " we know our path will have at least /home/USER and never be at the
    " home directory itself (unless you are really crazy), so we skip anything
    " before that and we start at the next directory
    let dirs=split(current_dir, "/")[2:-1]
    let searchdir_arr=[getenv("HOME")]

    for path in dirs
        let searchdir_arr+=[path]
        let searchdir=join(searchdir_arr, "/")

        for anchor in s:anchors
            if filereadable(searchdir."/".anchor)
                call extrasyntax#set_project_root_dir(searchdir)
                break
            endif
        endfor
    endfor

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

    call extrasyntax#find_project_root_dir()
endfunction

"
" functions from the bash script
"
function! extrasyntax#find_constants(file)
    return system([s:scriptpath, "find_constants", a:file])
endfunction

function! extrasyntax#find_enums(file)
    return system([s:scriptpath, "find_enums", a:file])
endfunction

function! extrasyntax#find_all_files_from_project(dir = s:project_root)
    return system([s:scriptpath, "find_all_files_from_project", a:dir])
endfunction

" source the given syntax file
function! extrasyntax#loadsyntax(path)
    if filereadable(a:path)
        call execute("source " . a:path)
    endif
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
    let outputfile=s:project_datapath . "/" . extrasyntax#this_file_internal_name(a:file) . ".vim"

    if (!filereadable(outputfile))
        call system(["touch", outputfile])
    endif

    let constants=split(extrasyntax#find_constants(a:file))+split(extrasyntax#find_enums(a:file))
    let new_constants=[]
    for constant in constants
        if (!extrasyntax#has_constant(constant, outputfile))
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

    let sources=split(extrasyntax#find_all_files_from_project())

    " search for any files that we do not have
    for src in sources
        let outputfile=s:project_datapath . "/" . join(split(src, "/"), ".") . ".vim"
        if (count(files, outputfile) == 0)
            call extrasyntax#load_file_constants(src)
        endif
    endfor
endfunction
