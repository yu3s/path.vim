vim9script

def Filename_map(prefix: string, files: list<string>): list<dict<any>>
	var matches: list<dict<any>>

	for file in files
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

		matches->add({
					\ 'menu': menu,
					\ 'word': word,
					\ 'abbr': abbr,
					\ 'icase': 1,
					\ 'dup': 0
					\ })
	endfor

	return matches
enddef

def Sort(item1: dict<any>, item2: dict<any>): number
	if item1["menu"] ==# '[dir]' && item2["menu"] !=# '[dir]'
		return -1
	endif
	if item1['menu'] !=# '[dir]' && item2['menu'] ==# '[dir]'
		return 1
	endif
	return 0
enddef

def Completor(ctx: dict<any>): void
	var bufnr = ctx['bufnr']
	var typed = ctx['typed']
	var col   = ctx['col']

	var kw    = matchstr(typed, '<\@<!\(\.\{0,2}/\|\~\).*$')
	var kwlen = len(kw)

	var cwd: string
	var glob: string
	var pre: string

	if kwlen < 1
		return
	endif

	if kw !~ '^\(/\|\~\)'
		cwd = expand('#' .. bufnr .. ':p:h') .. '/' .. kw
	else
		cwd = kw
	endif

	if has('win32')
		glob = fnamemodify(cwd, ':t') .. '*'
	else
		glob = fnamemodify(cwd, ':t') .. '.\=[^.]*'
	endif
	cwd  = fnamemodify(cwd, ':p:h')
	pre  = fnamemodify(kw, ':h')

	if pre !~ '/$'
		pre = pre .. '/'
	endif

	var cwdlen   = strlen(cwd)
	var startcol = col - kwlen
	var files    = split(globpath(cwd, glob), '\n')
	var matches: list<dict<any>> = Filename_map(pre, files)
	matches  = sort(matches, function('Sort'))

	setl completeopt=menuone,noinsert,noselect
	if startcol > 0
		call complete(startcol, matches)
	endif
enddef

export def Complete(): void
	var ret = {'bufnr': bufnr('%'), 'curpos': getcurpos(), 'changedtick': b:changedtick}
	ret['lnum'] = ret['curpos'][1]
	ret['col'] = ret['curpos'][2]
	ret['filetype'] = &filetype
	ret['filepath'] = expand('%:p')
	ret['typed'] = strpart(getline(ret['lnum']), 0, ret['col'] - 1)

	Completor(ret)
enddef
