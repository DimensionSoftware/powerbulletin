" QuickASCII - Vim global plugin for easy adding of ASCII chars
" File: qascii.vim
" Last change: 2002 Jul 06
" Maintainer: Peter Valach <pvalach@gmx.net>
" Version: 1.0
"
" Description:
"   Yet another ASCII table plugin :). I often need to insert some high-ASCII
"   character that my keymap doesn't allow to write and none of the *ASCII
"   plugins I saw was so easy and quick to use, so I wrote my own. It's my
"   first plugin for VIM and I welcome any bug reports, ideas and suggestions.
"
"   I tested it only on Linux version of VIM 6.1, but it should work in all
"   VIM 6.x versions.
"
" Usage:
"   Plugin creates only one function: QuickAscii. It takes four parameters
"   (all of them are required):
"       columns -- number of columns to show characters in
"       split   -- 0 for horizontal, 1 for vertical split (see below)
"       first   -- number of first character to display
"       last    -- number of last character to display
"
"   For practical use it's recommended to create a mapping with your favourite
"   parameters. For example (64 columns, horizontal, all high-ASCII chars):
"   :nmap <f2> :call QuickAscii(64,0,128,255)<cr>
"   :imap <f2> <Esc>:call QuickAscii(64,0,128,255)<cr>
"
"   Plugin works by splitting of active window (horizontal or vertical). There
"   it displays given range of ASCII chars. You may use all movement commands
"   as usual, only these are redefined:
"       <i> will put char under cursor on cursor-position of previous window
"       <a> will put char under cursor after cursor-position of previous window
"       <Enter> will put character under cursor after cursor-position, close
"           plugin window and start insert mode
"       <Shift>-<Enter> will do the same as <Enter>, without starting insert
"       <q> and <Esc> will close plugin window
"
" Install:
"   Just put this file (qascii.vim) into your plugin directory or put it
"   anywhere and source it (replace {YOUR-PATH} with real path, of course :)
"   :source {YOUR-PATH}/qascii.vim
"
"   It's highly recommended to create a mapping afterwards (see Usage).
"
" Bugs:
"   After going back to vertical split window using <CTRL-W><p> in VIM 6.1 it
"   sometimes resizes automatically. I don't if it's a bug or feature :) and
"   I'll appreciate any suggestions about this issue.
"
" History:
"   1.0 (2002/07/06)
"   - lots of code cleanups
"   - made all commands silent
"   - added <Esc> and <Shitf>-<Enter> mappings
"   - added split type (horizontal/vertical) option
"   - added 'first' and 'last' parameters
"   - 'first line empty' workaround
"   - updated <Enter> mapping to close window and start insert mode
"   - added all header texts
"   0.1 (2002/07/05)
"   - first working version (not released :)


" load this function only once
if exists("loaded_quickascii")
  finish
endif
let loaded_quickascii = 1

" just to be sure :)
let s:cpo_save = &cpo
set cpo&vim

function! QuickAscii(columns,split,first,last)
    " Desc:
    " columns -- number of columns to show characters in
    " split   -- 0 for horizontal, 1 for vertical split
    " first   -- number of first character to display
    " last    -- number of last character to display

    " * set variables {{{

    "ch1 -- char number to start with
    let ch1 = a:first
    "ch2 -- char number to end with
    let ch2 = a:last
    "cols -- columns (number of chars on one line)
    let cols = a:columns

    " if first is before last, exchange them
    if (ch1 > ch2)
        let i = ch1
        let ch1 = ch2
        let ch2 = i
    endif
    "chnum -- number of chars
    let chnum = ch2 - ch1 + 1
    "rows -- rows
    let rows = chnum / cols
    " if not exact, add one row
    if (chnum % cols != 0)
        let rows = rows + 1
    endif

    " * set variables }}}

    " * create new window {{{

    " if split variable is 1, split vertical, otherwise "normal" :)
    if (a:split == 1)
        silent execute cols.'vsplit __QuickASCII'
    else
        silent execute rows.'split __QuickASCII'
    endif
    setlocal noswapfile
    setlocal buftype=nowrite
    setlocal bufhidden=delete
    setlocal nonumber
    setlocal nowrap
    setlocal norightleft
    setlocal foldcolumn=0
    " it must be modifiable until content is written :)
    setlocal modifiable

    " * create new window }}}

    " * print chars {{{

    let i = 0
    " ascii table is printed in rows
    while(i < rows)

        let j = 0

        "out -- string of one line
        let out = ""  

        " print 64 chars on line
        while((j < cols) && ((ch1 + j + i * cols) <= ch2))
            let out = out.nr2char(ch1 + j + i * cols)
            " next char
            let j = j + 1
        endwhile

        " print line (first line with !, so there's no first empty line :)
        if (i == 0)
            silent put! =out
        else
            silent put =out
        endif

        " next line
        let i = i + 1
    endwhile
    " * print chars }}}

    " * post-display buffer settings {{{

    " don't allow to modify contents
    setlocal nomodifiable
    " <i> will put character under cursor into text of previous window
    noremap <silent> <buffer> i "myl<c-w>pP<c-w>p
    " <a> will put character under cursor after text of previous window
    noremap <silent> <buffer> a "myl<c-w>pp<c-w>p
    " <Enter> will put character under cursor after text, close and insertmode
    noremap <silent> <buffer> <cr> "myl<c-w>pp<c-w>p<c-w>ca
    " <S-Enter> will put character under cursor after text and close
    noremap <silent> <buffer> <s-cr> "myl<c-w>pp<c-w>p<c-w>c
    " <q> and <Esc> will close window
    noremap <silent> <buffer> q <c-w>c
    noremap <silent> <buffer> <Esc> <c-w>c

    " * post-display buffer settings }}}

endfunction

" restore 'cpo'
let &cpo = s:cpo_save
