augroup extra_constants
    au!
    au VimEnter *.c,*.h ++once call extra_constants#init()
augroup END
