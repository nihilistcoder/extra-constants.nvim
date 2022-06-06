" finds the root directory by traversing the path up until we find a
" CMakeLists.txt (or other) file, since we know there will be one there
function! extra_constants#utils#find_file_in_root(file)
    " shell current directory
    let current_dir=getcwd()

    let dirs=split(current_dir, "/")

    let searchdir_arr=[""]
    for path in dirs
        let searchdir_arr+=[path]
        let searchdir=join(searchdir_arr, "/")

        if (filereadable(searchdir."/".a:file))
            return searchdir."/".a:file
        endif
    endfor
    return ""
endfunction
