autocmd! extra_constants BufEnter,BufWritePost * call extra_constants#load_constants_from_file(expand("%:p"))
autocmd! extra_constants BufDelete * call extra_constants#remove_current_buffer()
