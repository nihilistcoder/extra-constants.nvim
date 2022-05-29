autocmd! extra_constants BufWritePost * call extra_constants#load_file_constants(expand("%:p"))
autocmd! extra_constants BufEnter * call extra_constants#add_current_buffer()
autocmd! extra_constants BufDelete * call extra_constants#remove_current_buffer()
