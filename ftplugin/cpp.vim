
let s:extrasyntax_vim=fnamemodify(resolve(expand('<sfile>:p')), ':h') . "/extrasyntax.vim"
source s:extrasyntax_vim

autocmd extrasyntax_autocmd Syntax * ++once call extrasyntax#SetupInit()
