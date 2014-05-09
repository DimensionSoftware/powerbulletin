let perl_include_pod = 1
let perl_fold = 1
let perl_fold_block = 1
let perl_nofold_packages = 0

set equalprg=perltidy

"autocmd FileType perl set makeprg="perl $VIMRUNTIME/tools/efm_perl.pl -c % $"
"autocmd FileType perl 
