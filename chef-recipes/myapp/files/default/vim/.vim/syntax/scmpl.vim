" Scheme w/ Perl as a preprocessor
" Language:	Scheme+Perl
" Maintainer:	John Beppu <beppu@cpan.org>
" Last Change:	2001 Dec 17
" Location:	http://www.linux-mag.com/

" for portability
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" load all of the scheme info
source $VIMRUNTIME/syntax/scheme.vim
unlet b:current_syntax

" load all of the perl info into @Perl
syntax include @Perl $VIMRUNTIME/syntax/perl.vim
syntax region scmplPerl 
    \ start=/{/ 
    \ end=/}/ 
    \ contains=@Perl, scmplPerl

" the script header
syntax match scmplSharpBang
    \ "^#!/usr/bin/env.*gimp-request.*$"

" link syntax elements to standard highlighting groups
if version >= 508 || !exists("did_scmpl_syn_inits")
  if version < 508
    let did_scmpl_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif
  HiLink scmplSharpBang PreProc
endif

" finish
let b:current_syntax = "scmpl"
