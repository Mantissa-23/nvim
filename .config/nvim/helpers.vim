"                           Custom Functions
" ----------------------------------------------------------------------------
" COLORSCHEMES

" Functions to toggle colorscheme between dark and light schemes, for quick
" switching between dark and light environments.

function! DarkScheme()
    colorscheme gruvbox
    set background=dark
endfunction

function! LightScheme()
    colorscheme gruvbox
    set background=light
endfunction

function! ToggleScheme()
    if &background ==# 'light'
        call DarkScheme() elseif &background ==# 'dark' call LightScheme()
    endif
endfunction

" JOURNALING

function! JFilename()
    let journaldir = '~/Docs/Org/Journal/'
    let name = strftime('%Y%m%d.md')
    return journaldir . name
endfunction

function! JNewEntry()
    execute "VimwikiMakeDiaryNote"
    
    " If new file unopened in buffer, add date header
    if empty(glob("%"))
        execute "normal! A# " . strftime('%A, %m/%d/%y')
    endif

    execute "normal! Go\<esc>o## " . strftime('%H:%M ')
endfunction

function! JViewEntry()
    let filename = JFilename()
    execute ":vsp" filename
endfunction

" VIMWIKI

function! VimWikiTitle()
  let filename = expand('%')
  let title = expand('%:r')

  if empty(glob(filename))
  execute "normal! I= " . title . " =\n\n%toc\n"
endfunction

"autocmd Filetype vimwiki call VimWikiTitle()

" NEOMAKE

" Function to automatically set makeprg, valuable for C++ and C
function! g:BuildInSubDir(buildsubdir)
    " Sets makeprg base dir
    let toplevelpath = FindTopLevelProjectDir()
    let builddir = toplevelpath . a:buildsubdir
    let makeprgcmd = 'make -C ' . builddir
    if builddir !=? "//build"
        let &makeprg=makeprgcmd
    endif
endfunction

function! FindTopLevelProjectDir()
    " Searches for a .git directory upward till root.
    let isittopdir = finddir('.git')
    if isittopdir ==? ".git"
        return getcwd()
    endif
    let gitdir = finddir('.git', ';')
    let gitdirsplit = split(gitdir, '/')
    let toplevelpath = '/' . join(gitdirsplit[:-2],'/')
    return toplevelpath
endfunction

" ENTER-ENTER
function! EnterEnter()
	if getline(".") =~ '^\s*\(//\|#\|"\)\s*$'
		return "\<C-u>"
	else
		return "\<CR>"
	endif
endfunction

" !function ToggleSpelling()
"     if &spelllang ==# 'en_us'
" endfunction

" Returns project absolute root if the current file is within rootdir and rootglobs can be
" found within that rootdir
function! IsProject(rootdir, rootglobs)
  let abspath = expand('%:p')
  let projroot = []
  call substitute(abspath, '^\/.*\/' . a:rootdir, '\=add(projroot, submatch(0))', '')
  if len(projroot) > 0
    let globhits = 0
    for g in a:rootglobs
      if len(globpath(projroot[0], g)) > 0
        let globhits += 1
      endif
    endfor
    if globhits == len(a:rootglobs)
      return projroot[0]
    endif
    return 0
  endif
  return 0
endfunction

function! GetFiletypes()
    " Get a list of all the runtime directories by taking the value of that
    " option and splitting it using a comma as the separator.
    let rtps = split(&runtimepath, ",")
    " This will be the list of filetypes that the function returns
    let filetypes = []

    " Loop through each individual item in the list of runtime paths
    for rtp in rtps
        let syntax_dir = rtp . "/syntax"
        " Check to see if there is a syntax directory in this runtimepath.
        if (isdirectory(syntax_dir))
            " Loop through each vimscript file in the syntax directory
            for syntax_file in split(glob(syntax_dir . "/*.vim"), "\n")
                " Add this file to the filetypes list with its everything
                " except its name removed.
                call add(filetypes, fnamemodify(syntax_file, ":t:r"))
            endfor
        endif
    endfor

    " This removes any duplicates and returns the resulting list.
    " NOTE: This might not be the best way to do this, suggestions are welcome.
    return uniq(sort(filetypes))
endfunction
