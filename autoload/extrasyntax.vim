let s:pluginpath=fnamemodify(resolve(expand('<sfile>:h')), ':h')
let s:scriptpath=s:pluginpath . "/scripts/extrasyntax.sh"
let s:datapath=stdpath('cache') . "/extrasyntax"
" this will be the file that will determine the root of your project
" Set this to a file that will always be in the root of your projects
let s:anchor=get(g:, "extrasyntax_anchor_file", "CMakeLists.txt")
let s:project_root=getcwd()
let s:project_datapath=s:datapath

function! extrasyntax#set_project_root_dir(dir)
    let s:project_root=a:dir

    " let the project name be the full directory path
    " use join() + split() to remove the / at the beggining

    let s:project_datapath=s:datapath . "/" . join(split(a:dir, "/"), ".")
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

        if filereadable(searchdir."/".s:anchor)
            call extrasyntax#set_project_root_dir(searchdir)
            break
        endif
    endfor

endfunction

" Setup the plugin
function! extrasyntax#init()
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

"
" cache manipulation functions
"

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

function! extrasyntax#current_file_syntax_path()
    return s:project_datapath . "/" . join(split(expand("%:p"), "/"), ".") . ".vim"
endfunction

function! extrasyntax#has_constant(constant, file)
    return !empty(system(["grep", a:file, "-e", "'\<".a:constant."'\>"]))
endfunction

function! extrasyntax#load_file_constants(file)
    let outputfile=s:project_datapath . "/" . join(split(a:file, "/"), ".") . ".vim"

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
    endif
endfunction

function! extrasyntax#loadall_from_project()
    if (!isdirectory(s:project_datapath))
        call mkdir(s:project_datapath, "p")
    endif

    let files=split(glob(s:project_datapath . "/*.vim"))

    if (empty(files))
        let sources=split(extrasyntax#find_all_files_from_project())
        for src in sources
            call extrasyntax#load_file_constants(src)
        endfor
    else
        for file in files
            call extrasyntax#loadsyntax(file)
        endfor
    endif
endfunction
