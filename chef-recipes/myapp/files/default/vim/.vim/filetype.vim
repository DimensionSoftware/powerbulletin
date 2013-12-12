augroup filetypedetect
au BufNewFile,BufRead *.txt       setf linuxmag
au BufNewFile,BufRead *.hx        setf haxe
au BufNewFile,BufRead nginx.conf* setf nginx
au BufNewFile,BufRead *.ooc       set filetype=ooc
augroup END

" Scheme
au BufNewFile,BufRead *.scm     call SetFileTypeScheme(getline(1))

" Template Toolkit
" au BufNewFile,BufRead *.tt2 
"   if ( getline(1) . getline(2) . getline(3) =~ '<\chtml' 
"             && getline(1) . getline(2) . getline(3) !~ '<[%?]' ) 
"     || getline(1) =~ '<!DOCTYPE HTML' | 
"     setf tt2html | 
"   else | 
"     setf tt2 | 
"   endif 

fun! SetFileTypeScheme(name)
  if a:name =~ 'gimp-request'
    setf scmpl
  else
    setf scheme
  endif
endfun
