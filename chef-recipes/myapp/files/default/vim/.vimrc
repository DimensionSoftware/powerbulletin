" editor options
set ve=all
set ai
set expandtab
set hidden
set laststatus=2
set exrc
set nowrap lazyredraw
set ruler
set shiftwidth=2
set softtabstop=2
set noautowrite
set showmatch
set listchars=eol:$,tab:]-,trail:#,extends:+
set cursorline
set cursorcolumn
set grepprg="ack -a"
set title
set modeline
set modelines=5
set fcs+=vert:\ 
set fcs+=fold:\-
set encoding=utf-8

" nerdtree
let g:NERDTreeWinSize = 42

" ftplugins?
filetype plugin indent on

" taglist
let Tlist_Ctags_Cmd="/opt/local/bin/ctags"
let Tlist_Inc_Winwidth=0

" zencoding
let g:user_zen_settings = { 'indentation': '  ' }

" pathogen
"let g:Powerline_symbols = 'fancy'
call pathogen#infect()

" file-explorer
let g:explHideFiles='^\.'

" colo[u]rful
syntax on
if has("gui_running")
  "set guifont=Liberation\ Mono\ 9
  set guifont=monofur:h12.0
  colorscheme ice
else
  set t_Co=256
  colorscheme ice
endif

" perl
au BufRead *.t set ft=perl

" antiword
au BufRead *.doc call s:read("antiword")

" remember last line number
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

" Usage:  :let ma = Mark() ... execute ma
" has the same effect as  :normal ma ... :normal 'a
" without affecting global marks.
" You can also use Mark(17) to refer to the start of line 17 and Mark(17,34)
" to refer to the 34'th (screen) column of the line 17.  The functions
" Line() and Virtcol() extract the line or (screen) column from a "mark"
" constructed from Mark() and default to line() and virtcol() if they do not
" recognize the pattern.
" Update:  :execute Mark() now restores screen position as well as the cursor.
fun! Mark(...)
  if a:0 == 0
    let mark = line(".") . "G" . virtcol(".") . "|"
    normal! H
    let mark = "normal!" . line(".") . "Gzt" . mark
    execute mark
    return mark
  elseif a:0 == 1
    return "normal!" . a:1 . "G1|"
  else
    return "normal!" . a:1 . "G" . a:2 . "|"
  endif
endfun

function! StripTrailingSpaces()
  if ( GetVar( "noStripSpaces" ) != 1 )
    let currPos=Mark()
    exec 'v:^--\s*$:s:\s\+$::e'
    exe currPos
  endif
endfunction

" Remove trailing blanks upon saving except from lines containing sigdashes
au BufWritePre * silent! call StripTrailingSpaces()

" funky keymappings
map <M-x> :wqa!
map <F2> :!perldoc %<CR>
map <F3> :qa!
map <F9> :!perl -Ilib -c %<CR>
map <M-d> dd
map <M-n> :bn<CR>
map <M-p> :bp<CR>
map \nt :NERDTreeToggle<CR>
map _ :!perl %<CR>
imap jj <ESC>
map <C-n> :tabnext<CR>
map <C-p> :tabprev<CR>
imap <C-n> <ESC>:tabnext<CR>
imap <C-p> <ESC>:tabprev<CR>
