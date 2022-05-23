source fnamemodify(resolve(expand('<sfile>:p')), ':h') ."/extrasyntax.vim"

autocmd extrasyntax_autocmd Syntax * ++once call extrasyntax#SetupInit()
