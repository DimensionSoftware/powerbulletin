" Vim color file
" Maintainer: John Beppu <john.beppu@gmail.com>
" Last Change: 2009-12-04
" Version: 1.1
" URI: http://towr.of.bavl.org/


""" Init
set background=dark
highlight clear
if exists("syntax_on")
  syntax reset
endif

let colors_name = "ice"


highlight Normal                                                                  guifg=#c0c0c0 guibg=#061b1f
highlight NonText                             ctermfg=DarkCyan                    guifg=#ffffff guibg=#061b1f
highlight LineNr                              ctermfg=LightCyan                   guifg=#90c0f0 guibg=#061b1f
highlight Comment                             ctermfg=31                          guifg=#5f5f5f guibg=#061b1f
highlight Todo                                ctermfg=White      ctermbg=DarkCyan guifg=#f0fcff guibg=#208090
highlight Statement       cterm=bold          ctermfg=White                       guifg=#208a80 guibg=#061b1f
highlight PreProc                             ctermfg=DarkCyan                    guifg=#40d0c0 guibg=#061b1f
highlight Constant                            ctermfg=123                         guifg=#d0d8ec guibg=#061b1f
highlight Special                             ctermfg=158                         guifg=#307488 guibg=#061b1f
highlight Type                                ctermfg=LightCyan                   guifg=#2cceef guibg=#061b1f
highlight Identifier      cterm=bold          ctermfg=45                          guifg=#70e0f0 guibg=#061b1f
highlight Function        cterm=bold          ctermfg=123                         guifg=#70e0f0 guibg=#061b1f
highlight Title                                                                   guifg=#90d0c0 guibg=#061b1f

highlight StatusLine                          ctermfg=238        ctermbg=White    guifg=#3090f0 guibg=#ffffff
highlight StatusLineNC                        ctermfg=238        ctermbg=White    guifg=#2080d0 guibg=#d0f0c0
highlight VertSplit                           ctermfg=238        ctermbg=White    guifg=#2080d0 guibg=#ffffff
highlight CursorLine      cterm=none                             ctermbg=23                     guibg=#001218
highlight CursorColumn                                           ctermbg=23
highlight Visual          cterm=bold                             ctermbg=23       guifg=#ffffff guibg=#208090
highlight Pmenu                                                                   guifg=#90c0f0 guibg=#107080
highlight Folded          cterm=bold          ctermbg=0          ctermfg=6        guifg=#d0d0d0 guibg=#204080
highlight FoldColumn      cterm=bold          ctermbg=0          ctermfg=6        guifg=#ffffff guibg=#204080
