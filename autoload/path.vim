vim9script

def Filename_map(prefix: string, file: string): dict<any>
	var abbr = fnamemodify(file, ':t')
	var word = prefix .. abbr
	var menu: string

	if isdirectory(file)
		menu = '[dir]'
		abbr = '/' .. abbr
	else
		menu = '[file]'
		abbr = abbr
	endif

	return {
				\ 'menu': menu,
				\ 'word': word,
				\ 'abbr': abbr,
				\ 'icase': 1,
				\ 'dup': 0
				\ }
enddef

#def Sort(item1: dict<any>, item2: dict<any>): dict<any>
#	if item1.menu ==# '[dir]' && item2.menu !=# '[dir]'
#		return -1
#	endif
#	if item1.menu !=# '[dir]' && item2.menu ==# '[dir]'
#		return 1
#	endif
#	return 0
#enddef

def Completor(ctx: dict<any>)
	echomsg ctx
	var bufnr = ctx['bufnr']
	var typed = ctx['typed']
	var col   = ctx['col']

	var kw    = matchstr(typed, '<\@<!\(\.\{0,2}/\|\~\).*$')
	var kwlen = len(kw)

	var cwd: string

	if kwlen < 1
		return
	endif

	if kw !~ '^\(/\|\~\)'
		cwd = expand('#' .. bufnr .. ':p:h') .. '/' .. kw
	else
		cwd = kw
	endif

	var glob = fnamemodify(cwd, ':t') .. '.\=[^.]*'

	cwd  = fnamemodify(cwd, ':p:h')
	var pre  = fnamemodify(kw, ':h')

	if pre !~ '/$'
		pre = pre .. '/'
	endif

	var cwdlen   = strlen(cwd)
	var startcol = col - kwlen
	var files    = split(globpath(cwd, glob), '\n')

	echomsg "files:"
	echomsg files
	#var matches  = map(files, (key, val) => Filename_map(pre, v:val))
	#matches  = sort(matches, function('Sort'))

	#echomsg matches

	#call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches)
enddef

export def g:Popup(): string
#function! asyncomplete#context() abort
#    let l:ret = {'bufnr':bufnr('%'), 'curpos':getcurpos(), 'changedtick':b:changedtick}
#    let l:ret['lnum'] = l:ret['curpos'][1]
#    let l:ret['col'] = l:ret['curpos'][2]
#    let l:ret['filetype'] = &filetype
#    let l:ret['filepath'] = expand('%:p')
#    let l:ret['typed'] = strpart(getline(l:ret['lnum']),0,l:ret['col']-1)
#    return l:ret
#endfunction
	var ctx = {'bufnr': bufnr('%'), 'curpos': getcurpos()}
    ctx['lnum'] = ctx['curpos'][1]
    ctx['col'] = ctx['curpos'][2]
    ctx['filepath'] = expand('%:p')
    ctx['typed'] = strpart(getline(ctx['lnum']), 0, ctx['col'] - 1)
	Completor(ctx)
	return ''
enddef
