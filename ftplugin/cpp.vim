autocmd extrasyntax VimEnter * ++once call extrasyntax#init()
autocmd extrasyntax UIEnter * ++once call extrasyntax#load_project_if_new()
autocmd! extrasyntax BufWritePost * call extrasyntax#reload_current_file()
