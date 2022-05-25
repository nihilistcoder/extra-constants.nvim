function! extrasyntax#utils#this_file_internal_name(file="%:p")
    return join(split(expand(a:file), "/"), ".")
endfunction

" finds the root directory by traversing the path up until we find a
" CMakeLists.txt (or other) file, since we know there will be one there
function! extrasyntax#utils#find_project_root_dir(anchors)
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

        for anchor in a:anchors
            if filereadable(searchdir."/".anchor)
                return searchdir
            endif
        endfor
    endfor
    return current_dir
endfunction

function! extrasyntax#utils#has_constant(constant, file)
    return !empty(system(["grep", a:file, "-e", "syn keyword cConstant ".a:constant.""]))
endfunction
