autocmd extrasyntax VimEnter * ++once call extrasyntax#init()
autocmd extrasyntax UIEnter * ++once call extrasyntax#loadall_from_project()
