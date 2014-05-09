" Linux Magazine syntax file
" Language:	Linux Magazine Article
" Maintainer:	John Beppu <beppu@cpan.org>
" Last Change:	2002 Jan 3
" Location:	http://www.linux-mag.com/

" for portability
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" define syntax elements
syn case match
syn match   linuxmagHeader /^[A-Z_]\+: /
syn region  linuxmagTextAttr start=/[BCI]</ end=/>/ 
  \ contains=linuxmagTextAttr
syn region  linuxmagCodeBlock start=/^C<$/ end=/^>$/
syn match   linuxmagURL /[a-z]\+:\/\/[A-Za-z0-9\-/~._:%?=&#]\+/
syn match   linuxmagEmail /[A-z0-9-_.]\+@[A-Za-z0-9\-.]\+/
syn region  linuxmagBoxBegin start=/\[ BEGIN/ end=/ ]/
syn region  linuxmagBoxEnd start=/\[ END/ end=/ ]/
syn region  linuxmagComment1 
\ start=/\[ \w\+:/ end=/]/ 
 \ contains=linuxmagEditor,linuxmagNote,
  \ linuxmagComment1,
   \ linuxmagComment2
syn region  linuxmagComment2 
\ start=/\[ Ed/ end=/]/ 
 \ contains=linuxmagEditor,linuxmagNote,
  \ linuxmagComment1,
   \ linuxmagComment2
syn match   linuxmagEditor /[A-Z]\+:/ contained
syn keyword linuxmagNote TODO FIXME XXX contained

" link syntax elements to standard highlighting groups
if version >= 508 || !exists("did_linuxmag_syn_inits")
  if version < 508
    let did_linuxmag_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink linuxmagHeader	    Keyword
  HiLink linuxmagCodeBlock  String
  HiLink linuxmagTextAttr   String
  HiLink linuxmagURL	    Function
  HiLink linuxmagEmail	    Function
  HiLink linuxmagBoxBegin   Include
  HiLink linuxmagBoxEnd	    Include
  HiLink linuxmagNote	    Todo
  HiLink linuxmagComment1   Comment
  HiLink linuxmagComment2   Comment
  HiLink linuxmagEditor     Debug

  delcommand HiLink
endif

" finish
let b:current_syntax = "linuxmag"
