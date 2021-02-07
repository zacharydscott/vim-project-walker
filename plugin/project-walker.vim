" Vim Terminal Tab
" Author: Zachary Scott
" Version: 0.1

if exists("g:vim_project_walker_loaded")
  finish
endif

let g:vim_project_walker_loaded = 1

" Trying out some things here. This is more of a functional programming
" approach. I'm not sure if I broke it into too many functions. Still
" a bit new to vimscript.

let s:link_creation_text = "Add new project locations by adding text in the form of:
      \ \[project name\]: \[project path\]. Save any changes like a normal file before navigating. Comments are also supported with a
      \ leading (\")."

command! ProjectMenu call <SID>ProjectMenu()

function! s:ProjectMenu()
  let path = s:GetCurentPath()
  bot new
  execute "e " . path
  set syntax=project_walker
  if exists('g:project_walker_jump_nmap')
    let nmap = g:project_walker_jump_nmap
  else 
    let nmap = '<CR>'
  endif
    execute 'nnoremap <buffer> ' . nmap . " :call <SID>LineNavigate()<CR>"
endfunction

command! -complete=custom,<SID>AvailableProjects -nargs=1 ProjectNavigate call <SID>ProjectNavigate(<q-args>)

function! s:AvailableProjects(A,L,P)
  let path = s:GetCurentPath()
  let config = readfile(path)
  let proj_list = []
  for line in config
    let p_line = s:ProcessLine(line)
    if len(p_line) > 1
      call add(proj_list, p_line[0])
    endif
  endfor
  return join(proj_list,"\n")
endfunction

function! s:ProjectNavigate(name)
  let path = s:GetCurentPath()
  let config = readfile(path)
  for line in config
    let line = s:ProcessLine(line)
    let length = len(line)
    if length && line[0] ==? a:name
      if length == 1
        echom "There is no path provided."
      else
        let success = s:NavigateToProject(line[1])
        if success
          echom "The working directory is now: " . a:name . " - " . line[1]
        endif
        return
      endif
    endif
  endfor
endfunction


" This could be done statically, but then the reloading would be required for
" changes
function! s:GetCurentPath()
  let default = $HOME . '/.config/.vim_project_walker'
  if exists('g:project_walker_path')
    let path = g:project_walker_path
  elseif exists('$PROJECTPATH')
    let path = $PROJECTPATH
  else
    let path = default
  endif
  if !filereadable(path)
    echom path . " doesn't exist. Creating it now. Add new jump points with" . s:link_creation_text
    if path == default
      echom "The default path is " . default . ". You can use a custom path by setting the
            \ g:project_walker_path variable."
    endif
    call writefile(["\" " . s:link_creation_text], path)
  endif
  return path
endfunction

function! s:LineNavigate()
  let p_line = s:ProcessLine(getline('.'))
  let length = len(p_line)
  if length == 0
    echom "There is no project on this line, or it is a comment."
  elseif length == 1
    echom "There is no path provided."
  else
    let success = s:NavigateToProject(p_line[1])
    if success
      q!
      echom "The working directory is now: " . p_line[0] . " - " . p_line[1]
    endif
  endif
endfunction

function! s:ProcessLine(line)
  let cut_line = matchstr(a:line, "^[^\"]*")
  return split(cut_line,':')
endfunction

function! s:NavigateToProject(project)
  let dir = substitute(a:project,'^\s*\(.*\)\s$','\1','')
  let dir = finddir(dir)
  if dir ==# ''
    echom a:project . " does not exist or is inaccessible. Please check the path."
    return 0
  else
    execute 'cd ' . dir
    return 1
  endif
endfunction

