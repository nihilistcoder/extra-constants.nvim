" call script update-syntax-files.sh
function! extrasyntax#update(rootdir_or_file)
    if (get(g:, "extrasyntax_init_called", 0) == 0)
        return
    endif

    let script_path=g:extrasyntax_path . "/../update-syntax-files.sh"
    let after_syntax_c=g:extrasyntax_path . "/../after/syntax/c"
    call system([script_path, after_syntax_c, g:extrasyntax_data_dir, a:rootdir_or_file])
endfunction

" call script create-syntax-output-name.sh
function! extrasyntax#output_name(file)
    if (get(g:, "extrasyntax_init_called", 0) == 0)
        return
    endif

    let script_path=g:extrasyntax_path . "/../create-output-name.sh"
    let after_syntax_c=g:extrasyntax_path . "/../after/syntax/c/"
    return after_syntax_c . system([script_path, a:file])
endfunction

function! extrasyntax#set_project_root_dir(dir)
    if (get(g:, "extrasyntax_init_called", 0) == 0)
        return
    endif

    if (a:dir == "")
        return
    endif

    let g:extrasyntax_found_project_root=1

    let g:extrasyntax_project_rootdir=a:dir

    " let the project name be the full directory path
    " use join() + split() to remove the / at the beggining
    let project_name=join(split(a:dir, "/"), ".")

    let g:extrasyntax_current_project_dir=g:extrasyntax_data_dir . "/" . project_name
endfunction

" finds the root directory by traversing the path up until we
" find a CMakeLists.txt (or other) file, since we know there will be one there
function! extrasyntax#find_project_root_dir()
    if (get(g:, "extrasyntax_init_called", 0) == 0)
        return
    endif

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

        if filereadable(searchdir."/".g:extrasyntax_anchor_file)
            let found=searchdir
            break
        endif
    endfor

    call extrasyntax#set_project_root_dir(get(l:, "found", ""))
endfunction

" reload the specified syntax file
function! extrasyntax#reload(path)
    if (get(g:, "extrasyntax_init_called", 0) == 0)
        return
    endif

    let output_name=extrasyntax#output_name(a:path)
    if filereadable(output_name)
        call execute("source " . output_name)
    endif
endfunction

" Reload ALL syntax files
function! extrasyntax#reload_all()
    if (get(g:, "extrasyntax_init_called", 0) == 0)
        return
    endif

    let files=split(expand(g:extrasyntax_path . "/../after/syntax/c/*.vim"))

    for file in files
        call execute("source " . file)
    endfor
endfunction

function! extrasyntax#reload_current_file()
    if (get(g:, "extrasyntax_init_called", 0) == 0)
        return
    endif

    let current_file=expand("%:p")
    call extrasyntax#update(current_file)
    call extrasyntax#reload(current_file)
endfunction

function! extrasyntax#load_project_if_new()
    let project_name=join(split(g:extrasyntax_project_rootdir, "/")[2:-1], ".")

    let glob_pattern=g:extrasyntax_path . "/../after/syntax/c/" . project_name . ".*.vim"
    if glob(glob_pattern) == ""
        call extrasyntax#update(g:extrasyntax_project_rootdir)
        call extrasyntax#reload_all()
    endif

endfunction

" Setup the plugin
function! extrasyntax#init()
    let g:extrasyntax_init_called=1
    " this will be the file that will determine the root of your project
    " Set this to a file that will always be in the root of your projects
    if get(g:, "extrasyntax_anchor_file", "") == 0
        let g:extrasyntax_anchor_file="CMakeLists.txt"
    endif

    " TODO the directory where the plugin data will be stored
    let g:extrasyntax_data_dir=stdpath('cache') . "/extrasyntax"

    call extrasyntax#find_project_root_dir()
endfunction

