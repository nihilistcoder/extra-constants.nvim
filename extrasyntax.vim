function! ESyntaxSetProjectRootDir(dir)
    if (a:dir == "")
        return
    endif

    let s:rootdir=a:dir

    " let the project name be the full directory path
    " use join() + split() to remove the / at the beggining
    let project_name=join(split(s:rootdir, "/"), ".")

    let s:projectdir=data_dir . "/" . project_name
endfunction

" finds the root directory by traversing the path up until we
" find a CMakeLists.txt (or other) file, since we know there will be one there
function! ESyntaxFindProjectRootDir()

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

    call ESyntaxSetProjectRootDir(get(l:, "found", ""))
endfunction

" Setup the plugin
function! SetupInit()
    " get path to this script
    let s:path=fnamemodify(resolve(expand('<sfile>:p')), ':h')

    let s:afterdir=s:path . "after/syntax"
    " this will be the file that will determine the root of your project
    " Set this to a file that will always be in the root of your projects
    let g:extrasyntax_anchor_file="CMakeLists.txt"

    " the directory where the plugin data will be stored
    let data_dir=stdpath('cache') . "/extrasyntax"

    call ESyntaxFindProjectRootDir()
endfunction

" this function will call the script ~/.config/nvim/update-syntax-files.sh
" with the root directory of the current project
"
" WARNING: the script this function executes will recursively search all .c and .h
" files on your project. If your project is very big, it may take some time to
" finish. For now, it updates all files once run, but I may change that in the
" future.
function! ESyntaxUpdateAllSyntaxFiles()
    let root=get(s:, "rootdir", "")

    if (root == "")
        echo "Root directory of project not found. Call ESyntaxSetProjectRootDir(PATH) to set it manually."
    endif
    let scriptpath=s:path . "/update-syntax-files.sh"
    echo "Updating syntax files..."
    system([scriptpath, s:afterdir, s:projectdir, s:rootdir])
endfunction
