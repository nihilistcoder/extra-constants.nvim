autocmd extrasyntax VimEnter * ++once call extrasyntax#init()
autocmd extrasyntax UIEnter * ++once call extrasyntax#loadall_from_project()
autocmd! extrasyntax BufWritePost * call extrasyntax#load_file_constants(expand("%:p"))
