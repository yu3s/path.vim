vim9script

if exists('g:pathvim') || &cp
	finish
endif
g:pathvim = 1

import autoload 'path.vim'

inoremap <buffer> <silent> / /<Cmd>call <SID>path.Complete()<CR>
