" Align: tool to align multiple fields based on one or more separators
"   Author:		Charles E. Campbell, Jr.
"   Date:		Aug 19, 2002
"   Version:	13
"
"   Functions:
"   AlignCtrl(style,..list..)
"
"        "default" : Sets AlignCtrl to its default values and clears stack
"                    AlignCtrl "Ilp1P1=" '='
"
"         Separators
"              "=" : all alignment demarcation patterns are equivalent
"                    and simultaneously active.  The list is of such
"                    patterns (regular expressions, actually).
"              "C" : cycle through alignment demarcation patterns
"
"         Alignment/Justification
"              "l" : left justify  (no list needed)
"              "r" : right justify (no list needed)
"              "c" : center        (no list needed)
"                    Justification styles are cylic: ie. "lcr" would
"                    mean first field is left-justifed,
"                        second field is centered,
"                        third  field is right-justified,
"                        fourth field is left-justified, etc.
"              "-" : skip this separator+ws+field
"              "+" : repeat last alignment/justification indefinitely
"              ":" : no more alignment/justifcation
"
"         Map Support
"              "m" : next call to Align will AlignPop at end.
"                    AlignCtrl will AlignPush first.
"
"         Padding
"              "p" : current argument supplies pre-field-padding parameter;
"                    ie. that many blanks will be applied before
"                    the field separator. ex. call AlignCtrl("p2").
"                    Can have 0-9 spaces.  Will be cycled through.
"              "P" : current argument supplies post-field-padding parameter;
"                    ie. that many blanks will be applied after
"                    the field separator. ex. call AlignCtrl("P3")
"                    Can have 0-9 spaces.  Will be cycled through.
"
"         Initial White Space
"              "I" : preserve first line's leading whitespace and re-use
"                    subsequently
"              "W" : preserve leading whitespace on every line
"              "w" : don't preserve leading whitespace
"
"         Selection Patterns
"              "g" : restrict alignment to pattern
"              "v" : restrict alignment to not-pattern
"
"              If no arguments are supplied, AlignCtrl() will list
"              current settings.
"
"   [range]Align(..list..)
"              Takes a range and performs the specified alignment on the
"              text.  The range may be :line1,line2 etc, or visually selected.
"              The list is a list of patterns; the current s:AlignCtrl
"              will be used ('=' or 'C').
"
"   Commands:
"   AlignCtrl                : lists current alignment settings
"   AlignCtrl style ..list.. : set alignment separators
"   AlignCtrl {gv} pattern   : apply alignment only to lines which match (g)
"                              or don't match (v) the given pattern
"   [range]Align ..list..    : applies Align() over the specified range
"                              The range may be specified via
"                              visual-selection as well as the usual
"                              [range] specification.  The ..list..
"                              is a list of alignment separators.
"
"   History:
"     13 : Aug 19, 2002 : bug fix: zero-length g/v patterns are ok
"                         bug fix: always skip blank lines
"                         bug fix: AlignCtrl default now also clears g and v
"                                  patterns
"     12 : Aug 16, 2002 : moved keep_ic above zero-length pattern checks
"                         added "AlignCtrl default"
"                         fixed bug with last field getting separator spaces
"                         at end line
"     11 : Jul 08, 2002 : prevent separator patterns which match zero length
"                         -+: included as additional alignment/justification
"                         styles
"     10 : Jun 26, 2002 : =~# (for match case) used instead of =~
"                         ignorecase option handled
"      9 : Jun 25, 2002 : implemented cyclic padding
" ---------------------------------------------------------------------

" Prevent duplicate loading
if exists("g:loaded_align") || &cp
 finish
endif
let g:loaded_align= 1

" Public Interface:
com! -range -nargs=* Align <line1>,<line2>call Align(<f-args>)
com!        -nargs=* AlignCtrl call AlignCtrl(<f-args>)
com!        -nargs=0 AlignPush call AlignPush()
com!        -nargs=0 AlignPop  call AlignPop()

" ---------------------------------------------------------------------

" AlignCtrl: enter alignment patterns here
"
"   Styles   =  all alignment-break patterns are equivalent
"            C  cycle through alignment-break pattern(s)
"            l  left-justified alignment
"            r  right-justified alignment
"            c  center alignment
"
"   Builds   =  s:AlignPat  s:AlignCtrl  s:AlignPatQty
"            C  s:AlignPat  s:AlignCtrl  s:AlignPatQty
"            p  s:AlignPrePad
"            P  s:AlignPostPad
"            w  s:AlignLeadKeep
"            W  s:AlignLeadKeep
"            I  s:AlignLeadKeep
"            l  s:AlignStyle
"            r  s:AlignStyle
"            -  s:AlignStyle
"            +  s:AlignStyle
"            :  s:AlignStyle
"            c  s:AlignStyle
"            g  s:AlignGPat
"            v  s:AlignVPat
fu! AlignCtrl(...)

"  call Decho("AlignCtrl() {")

  " save options that will be changed
  let keep_search = @/
  let keep_ic     = &ic

  if a:0 > 0
   let style      = a:1

   " Check for bad separator patterns (zero-length matches)
   " (but zero-length patterns for g/v is ok)
   if style !~# '[gv]'
    let ipat= 2
    while ipat <= a:0
     if "" =~ a:{ipat}
      echoerr "AlignCtrl: separator<".a:{ipat}."> matches zero-length string"
"      call Decho("return AlignCtrl }")
      return
     endif
     let ipat= ipat + 1
    endwhile
   endif
  endif

  " turn ignorecase off
  set noic

"  call Decho("AlignCtrl() a:0=".a:0)
  if !exists("s:AlignStyle")
   let s:AlignStyle= "l"
  endif
  if !exists("s:AlignPrePad")
   let s:AlignPrePad= 0
  endif
  if !exists("s:AlignPostPad")
   let s:AlignPostPad= 0
  endif
  if !exists("s:AlignLeadKeep")
   let s:AlignLeadKeep= 'w'
  endif

  if a:0 == 0
   " ----------------------
   " List current selection
   " ----------------------
   echo "AlignCtrl<".s:AlignCtrl."> qty=".s:AlignPatQty." AlignStyle<".s:AlignStyle."> Padding<".s:AlignPrePad."|".s:AlignPostPad."> LeadingWS=".s:AlignLeadKeep
"   call Decho("AlignCtrl<".s:AlignCtrl."> qty=".s:AlignPatQty." AlignStyle<".s:AlignStyle."> Padding<".s:AlignPrePad."|".s:AlignPostPad."> LeadingWS=".s:AlignLeadKeep)
   if      exists("s:AlignGPat") && !exists("s:AlignVPat")
	echo "AlignGPat<".s:AlignGPat.">"
   elseif !exists("s:AlignGPat") &&  exists("s:AlignVPat")
	echo "AlignVPat<".s:AlignVPat.">"
   elseif exists("s:AlignGPat") &&  exists("s:AlignVPat")
	echo "AlignGPat<".s:AlignGPat."> AlignVPat<".s:AlignVPat.">"
   endif
   let ipat= 1
   while ipat <= s:AlignPatQty
	echo "Pat".ipat."<".s:AlignPat_{ipat}.">"
"	call Decho("Pat".ipat."<".s:AlignPat_{ipat}.">")
	let ipat= ipat + 1
   endwhile

  else
   " ----------------------------------
   " Process alignment control settings
   " ----------------------------------
"   call Decho("style<".style.">")

   if style ==? "default"
     " Default:  preserve initial leading whitespace, left-justified,
     "           alignment on '=', one space padding on both sides
	 if exists("s:AlignCtrlStackQty")
	  " clear AlignCtrl stack
      while s:AlignCtrlStackQty > 0
	   call AlignPop()
	  endwhile
	  unlet s:AlignCtrlStackQty
	 endif
	 " Set AlignCtrl to its default value
     call AlignCtrl("Ilp1P1=",'=')
	 call AlignCtrl("g")
	 call AlignCtrl("v")
"     call Decho("return AlignCtrl }")
	 return
   endif

   if style =~# 'm'
	" map support: Do an AlignPush now and the next call to Align()
	"              will do an AlignPop at exit
	call AlignPush()
	let s:DoAlignPop= 1
   endif

   " = : record a list of alignment patterns that are equivalent
   if style =~# "="
"    call Decho("AlignCtrl: record list of alignment patterns")
    let s:AlignCtrl  = '='
	if a:0 >= 2
     let s:AlignPatQty= 1
     let s:AlignPat_1 = a:2
     let ipat         = 3
     while ipat <= a:0
      let s:AlignPat_1 = s:AlignPat_1.'\|'.a:{ipat}
      let ipat         = ipat + 1
     endwhile
     let s:AlignPat_1= '\('.s:AlignPat_1.'\)'
"     call Decho("AlignCtrl<".s:AlignCtrl."> AlignPat<".s:AlignPat_1.">")
	endif

    "c : cycle through alignment pattern(s)
   elseif style =~# 'C'
"    call Decho("AlignCtrl: cycle through alignment pattern(s)")
    let s:AlignCtrl  = 'C'
	if a:0 >= 2
     let s:AlignPatQty= a:0 - 1
     let ipat         = 1
     while ipat < a:0
      let s:AlignPat_{ipat}= a:{ipat+1}
"     call Decho("AlignCtrl<".s:AlignCtrl."> AlignQty=".s:AlignPatQty." AlignPat_".ipat."<".s:AlignPat_{ipat}.">")
      let ipat= ipat + 1
     endwhile
	endif
   endif

   if style =~# 'p'
    let s:AlignPrePad= substitute(style,'^.*p\(\d\+\).*$','\1','')
    if s:AlignPrePad == ""
     echoerr "AlignCtrl: 'p' needs to be followed by a numeric argument'
     let @/ = keep_search
	 let &ic= keep_ic
"     call Decho("return AlignCtrl }")
     return
	endif
   endif

   if style =~# 'P'
    let s:AlignPostPad= substitute(style,'^.*P\(\d\+\).*$','\1','')
    if s:AlignPostPad == ""
     echoerr "AlignCtrl: 'P' needs to be followed by a numeric argument'
     let @/ = keep_search
	 let &ic= keep_ic
"     call Decho("return AlignCtrl }")
     return
	endif
   endif

   if     style =~# 'w'
	let s:AlignLeadKeep= 'w'
   elseif style =~# 'W'
	let s:AlignLeadKeep= 'W'
   elseif style =~# 'I'
	let s:AlignLeadKeep= 'I'
   endif

   if style =~# 'g'
	" first list item is a "g" selector pattern
	if a:0 < 2
	 if exists("s:AlignGPat")
	  unlet s:AlignGPat
"	  call Decho("unlet s:AlignGPat")
	 endif
	else
	 let s:AlignGPat= a:2
"	 call Decho("s:AlignGPat<".s:AlignGPat.">")
	endif
   elseif style =~# 'v'
	" first list item is a "v" selector pattern
	if a:0 < 2
	 if exists("s:AlignVPat")
	  unlet s:AlignVPat
"	  call Decho("unlet s:AlignVPat")
	 endif
	else
	 let s:AlignVPat= a:2
"	 call Decho("s:AlignVPat<".s:AlignVPat.">")
	endif
   endif

    "a : set up s:AlignStyle
   if style =~# '[-lrc+:]'
    let s:AlignStyle= substitute(style,'[^-lrc:+]','','g')
"   call Decho("AlignStyle<".s:AlignStyle.">")
   endif
  endif

  " restore search and options
  let @/ = keep_search
  let &ic= keep_ic

"  call Decho("return AlignCtrl }")
  return s:AlignCtrl.'p'.s:AlignPrePad.'P'.s:AlignPostPad.s:AlignLeadKeep.s:AlignStyle
endfunction

" ---------------------------------------------------------------------

" MakeSpace: returns a string with spacecnt blanks
fu! <SID>MakeSpace(spacecnt)
  let str      = ""
  let spacecnt = a:spacecnt
  while spacecnt > 0
   let str      = str . " "
   let spacecnt = spacecnt - 1
  endwhile
  return str
endfunction

" ---------------------------------------------------------------------

" Align: align selected text based on alignment pattern(s)
fu! Align(...) range
"  call Decho("Align() {")

  " Check for bad separator patterns (zero-length matches)
  let ipat= 1
  while ipat <= a:0
   if "" =~ a:{ipat}
	echoerr "Align: separator<".a:{ipat}."> matches zero-length string"
"	call Decho("return Align }")
	return
   endif
   let ipat= ipat + 1
  endwhile

  " record current search pattern for subsequent restoration
  let keep_search= @/
  let keep_ic    = &ic
  set noic

  " Align will accept a list of separator regexps
  if a:0 > 0
   if s:AlignCtrl =~# "="
"   call Decho("AlignCtrl: record list of alignment patterns")
    let s:AlignCtrl  = '='
    let s:AlignPat_1 = a:1
    let s:AlignPatQty= 1
    let ipat         = 2
    while ipat <= a:0
     let s:AlignPat_1 = s:AlignPat_1.'\|'.a:{ipat}
     let ipat         = ipat + 1
    endwhile
    let s:AlignPat_1= '\('.s:AlignPat_1.'\)'
"    call Decho("AlignCtrl<".s:AlignCtrl."> AlignPat<".s:AlignPat_1.">")

    "c : cycle through alignment pattern(s)
   elseif s:AlignCtrl =~# 'C'
"    call Decho("AlignCtrl: cycle through alignment pattern(s)")
    let s:AlignCtrl  = 'C'
    let s:AlignPatQty= a:0
    let ipat         = 1
    while ipat <= a:0
     let s:AlignPat_{ipat}= a:{ipat}
"     call Decho("AlignCtrl<".s:AlignCtrl."> AlignQty=".s:AlignPatQty." AlignPat_".ipat."<".s:AlignPat_{ipat}.">")
     let ipat= ipat + 1
    endwhile
   endif
  endif

  " Initialize so that begline<endline and begcol<endcol.
  " Ragged right: check if the column associated with '< or '>
  "               is greater than the line's string length -> ragged right.
  " Have to be careful about visualmode() -- it returns the last visual
  " mode used whether or not it was used currently.
  let begcol   = virtcol("'<")-1
  let endcol   = virtcol("'>")-1
  if begcol > endcol
   let begcol  = virtcol("'>")-1
   let endcol  = virtcol("'<")-1
  endif
  let begline  = a:firstline
  let endline  = a:lastline
  if begline > endline
   let begline = a:lastline
   let endline = a:firstline
  endif
  let fieldcnt = 0
  if (begline == line("'>") && endline == line("'<")) || (begline == line("'<") && endline == line("'>"))
   let vmode= visualmode()
   if vmode == "\<c-v>"
    let ragged   = ( col("'>") > strlen(getline("'>")) || col("'<") > strlen(getline("'<")) )
   else
	let ragged= 1
   endif
  else
   let ragged= 1
  endif
  if ragged
   let begcol= 0
  endif
"  call Decho("Align() lines[".begline.",".endline."] col[".begcol.",".endcol."] ragged=".ragged." AlignCtrl<".s:AlignCtrl.">")

  " Keep user options
  let etkeep   = &et
  let pastekeep= &paste
  set et paste

  " convert selected range of lines to use spaces instead of tabs
  " but if first line's initial white spaces are to be retained
  " then use 'em
  if begcol <= 0 && s:AlignLeadKeep == 'I'
   " retain first leading whitespace for all subsequent lines
   let bgntxt= substitute(getline(begline),'^\(\s*\).\{-}$','\1','')
"   call Decho("retaining 1st leading ws: bgntxt<".bgntxt.">")
   set noet
  endif
  exe begline.",".endline."ret"

  " Execute two passes
  " First  pass: collect alignment data (max field sizes)
  " Second pass: perform alignment
  let pass= 1
  while pass <= 2
"   call Decho(" ")
"   call Decho("---- Pass ".pass.": ----")

   let line= begline
   while line <= endline
    " Process each line
    let txt = getline(line)
"    call Decho(" ")
"    call Decho("Line ".line." <".txt.">")

    " AlignGPat support: allows a selector pattern (akin to g/selector/cmd )
    if exists("s:AlignGPat")
"	 call Decho("AlignGPat<".s:AlignGPat.">")
	 if match(txt,s:AlignGPat) == -1
"	  call Decho("skipping")
	  let line= line + 1
	  continue
	 endif
    endif

    " AlignVPat support: allows a selector pattern (akin to v/selector/cmd )
    if exists("s:AlignVPat")
"	 call Decho("AlignGPat<".s:AlignGPat.">")
	 if match(txt,s:AlignVPat) != -1
"	  call Decho("skipping")
	  let line= line + 1
	  continue
	 endif
    endif

	" Always skip blank lines
	if match(txt,'^\s*$') != -1
"	  call Decho("skipping")
	 let line= line + 1
	 continue
	endif

    " Extract visual-block selected text (init bgntxt, endtxt)
    let txtlen= strlen(txt)
    if begcol > 0
	 " Record text to left of selected area
     let bgntxt= strpart(txt,0,begcol)
"	  call Decho("record text to left: bgntxt<".bgntxt.">")
    elseif s:AlignLeadKeep == 'W'
	 let bgntxt= substitute(txt,'^\(\s*\).\{-}$','\1','')
"	  call Decho("retaining all leading ws: bgntxt<".bgntxt.">")
    elseif s:AlignLeadKeep == 'w' || !exists("bgntxt")
	 " No beginning text
	 let bgntxt= ""
"	  call Decho("no beginning text")
    endif
    if ragged
	 let endtxt= ""
    else
     " Elide any text lying outside selected columnar region
     let endtxt= strpart(txt,endcol+1,txtlen-endcol)
     let txt   = strpart(txt,begcol,endcol-begcol+1)
    endif
"    call Decho(" ")
"    call Decho("bgntxt<".bgntxt.">")
"    call Decho("   txt<". txt  .">")
"    call Decho("endtxt<".endtxt.">")

    " Initialize for both passes
    let seppat      = s:AlignPat_{1}
    let ifield      = 1
    let ipat        = 1
    let bgnfield    = 0
    let endfield    = 0
    let alignstyle  = s:AlignStyle
    let doend       = 1
	let newtxt      = ""
    let alignprepad = s:AlignPrePad
    let alignpostpad= s:AlignPostPad
	let alignophold = " "
	let alignop     = "l"

    " Process each field on the line
    while doend > 0

	  " C-style: cycle through pattern(s)
     if s:AlignCtrl == 'C' && doend == 1
	  let seppat   = s:AlignPat_{ipat}
"	  call Decho("AlignCtrl=".s:AlignCtrl." ipat=".ipat." seppat<".seppat.">")
	  let ipat     = ipat + 1
	  if ipat > s:AlignPatQty
	   let ipat = 1
	  endif
     endif

	 " cyclic alignment/justification operator handling
	 let alignophold  = alignop
	 let alignop      = strpart(alignstyle,0,1)
	 if alignop == '+'
	  let alignop= alignophold
	 elseif alignop == ':'
	  let seppat  = '$'
	  let doend   = 2
"	  call Decho("alignop<:> case: setting seppat<$> doend==2")
	 else
	  let alignstyle   = strpart(alignstyle,1).strpart(alignstyle,0,1)
	 endif

	 " mark end-of-field and the subsequent end-of-separator.
	 " Extend field if alignop is '-'
     let endfield = match(txt,seppat,bgnfield)
	 let sepfield = matchend(txt,seppat,bgnfield)
     let skipfield= sepfield
"	 call Decho("endfield=match(txt<".txt.">,seppat<".seppat.">,bgnfield=".bgnfield.")=".endfield)
	 while alignop == '-' && endfield != -1
	  let endfield  = match(txt,seppat,skipfield)
	  let sepfield  = matchend(txt,seppat,skipfield)
	  let skipfield = sepfield
	  let alignop   = strpart(alignstyle,0,1)
	  let alignstyle= strpart(alignstyle,1).strpart(alignstyle,0,1)
"	  call Decho("extend field: endfield<".strpart(txt,bgnfield,endfield-bgnfield)."> alignop<".alignop."> alignstyle<".alignstyle.">")
	 endwhile

	 if endfield != -1
	  if pass == 1
	   " ---------------------------------------------------------------------
	   " Pass 1: Update FieldSize to max
"	   call Decho("before lead/trail remove: field<".strpart(txt,bgnfield,endfield-bgnfield).">")
	   let field      = substitute(strpart(txt,bgnfield,endfield-bgnfield),'^\s*\(.\{-}\)\s*$','\1','')
       if s:AlignLeadKeep == 'W'
	    let field = bgntxt.field
	    let bgntxt= ""
	   endif
	   let fieldlen   = strlen(field)
	   let sFieldSize = "FieldSize_".ifield
	   if !exists(sFieldSize)
	    let FieldSize_{ifield}= fieldlen
"	    call Decho(" set FieldSize_{".ifield."}=".FieldSize_{ifield}." <".field.">")
	   elseif fieldlen > FieldSize_{ifield}
	    let FieldSize_{ifield}= fieldlen
"	    call Decho("oset FieldSize_{".ifield."}=".FieldSize_{ifield}." <".field.">")
	   endif

	  else
	   " ---------------------------------------------------------------------
	   " Pass 2: Perform Alignment
	   let prepad       = strpart(alignprepad,0,1)
	   let postpad      = strpart(alignpostpad,0,1)
	   let alignprepad  = strpart(alignprepad,1).strpart(alignprepad,0,1)
	   let alignpostpad = strpart(alignpostpad,1).strpart(alignpostpad,0,1)
	   let field        = substitute(strpart(txt,bgnfield,endfield-bgnfield),'^\s*\(.\{-}\)\s*$','\1','')
       if s:AlignLeadKeep == 'W'
	    let field = bgntxt.field
	    let bgntxt= ""
	   endif
	   if doend == 2
		let alignprepad = 0
		let alignpostpad= 0
	   endif
	   let fieldlen   = strlen(field)
	   let sep        = s:MakeSpace(prepad).strpart(txt,endfield,sepfield-endfield).s:MakeSpace(postpad)
	   let spaces     = FieldSize_{ifield} - fieldlen
"	   call Decho(alignop.": Field #".ifield."<".field."> spaces=".spaces." be[".bgnfield.",".endfield."] pad=".alignprepad.','.alignpostpad." FS_".ifield."<".FieldSize_{ifield}."> sep<".sep."> ragged=".ragged." doend=".doend)

	    " Perform alignment according to alignment style justification
	   if spaces > 0
	    if     alignop == 'c'
		 " center the field
	     let spaceleft = spaces/2
	     let spaceright= FieldSize_{ifield} - spaceleft - fieldlen
	     let newtxt    = newtxt.s:MakeSpace(spaceleft).field.s:MakeSpace(spaceright).sep
	    elseif alignop == 'r'
		 " right justify the field
	     let newtxt= newtxt.s:MakeSpace(spaces).field.sep
	    elseif ragged && doend == 2
		 " left justify rightmost field (no trailing blanks needed)
	     let newtxt= newtxt.field
		else
		 " left justfiy the field
	     let newtxt= newtxt.field.s:MakeSpace(spaces).sep
	    endif
	   elseif ragged && doend == 2
		" field at maximum field size and no trailing blanks needed
	    let newtxt= newtxt.field
	   else
		" field is at maximum field size already
	    let newtxt= newtxt.field.sep
	   endif
"	   call Decho("newtxt<".newtxt.">")
	  endif	" pass 1/2

	  " bgnfield indexes to end of separator at right of current field
	  " Update field counter
	  let bgnfield= sepfield
      let ifield  = ifield + 1
	  if doend == 2
	   let doend= 0
	  endif
	   " handle end-of-text as end-of-field
	 elseif doend == 1
	  let seppat  = '$'
	  let doend   = 2
	 else
	  let doend   = 0
	 endif		" endfield != -1
    endwhile	" doend loop (as well as regularly separated fields)

	if pass == 2
	 " Write altered line to buffer
"     call Decho("bgntxt<".bgntxt."> line=".line)
"     call Decho("newtxt<".newtxt.">")
"     call Decho("endtxt<".endtxt.">")
     let junk = cursor(line,1)
	 exe "norm! 0DA".bgntxt.newtxt.endtxt."\<Esc>"
	endif

    let line = line + 1
   endwhile	" line loop

   let pass= pass + 1
  endwhile	" pass loop

  " Restore user options
  let &et    = etkeep
  let &paste = pastekeep

  if exists("s:DoAlignPop")
   " AlignCtrl Map support
   call AlignPop()
   unlet s:DoAlignPop
  endif

  " restore current search pattern
  let @/ = keep_search
  let &ic= keep_ic
"  call Decho("return Align }")
  return
endfunction

" ---------------------------------------------------------------------

" AlignPush: this command/function pushes an alignment control string onto a stack
fu! AlignPush()
  " initialize the stack
  if !exists("s:AlignCtrlStackQty")
   let s:AlignCtrlStackQty= 1
  else
   let s:AlignCtrlStackQty= s:AlignCtrlStackQty + 1
  endif
  " construct an AlignCtrlStack entry
  let s:AlignCtrlStack_{s:AlignCtrlStackQty}= s:AlignCtrl.'p'.s:AlignPrePad.'P'.s:AlignPostPad.s:AlignLeadKeep.s:AlignStyle
"  call Decho("AlignPush: AlignCtrlStack_".s:AlignCtrlStackQty."<".s:AlignCtrlStack_{s:AlignCtrlStackQty}.">")
  if exists("s:AlignGPat")
   let s:AlignGPat_{s:AlignCtrlStackQty}= s:AlignGPat
  else
   let s:AlignGPat_{s:AlignCtrlStackQty}=  ""
  endif
  if exists("s:AlignVPat")
   let s:AlignVPat_{s:AlignCtrlStackQty}= s:AlignVPat
  else
   let s:AlignVPat_{s:AlignCtrlStackQty}=  ""
  endif
endf

" ---------------------------------------------------------------------

" AlignPop: this command/function pops an alignment pattern from a stack
"           and into the AlignCtrl variables.
fu! AlignPop()
  " sanity check
  if !exists("s:AlignCtrlStackQty")
   echoerr "AlignPush needs to be used prior to AlignPop"
   return ""
  endif

  if s:AlignCtrlStackQty <= 0
   echoerr "AlignPush needs to be used prior to AlignPop"
   return ""
  endif
  let retval=s:AlignCtrlStack_{s:AlignCtrlStackQty}
  unlet s:AlignCtrlStack_{s:AlignCtrlStackQty}
  call AlignCtrl(retval)

  if s:AlignGPat_{s:AlignCtrlStackQty} != ""
   call AlignCtrl('g',s:AlignGPat_{s:AlignCtrlStackQty})
  else
   call AlignCtrl('g')
  endif
  unlet s:AlignGPat_{s:AlignCtrlStackQty}

  if s:AlignVPat_{s:AlignCtrlStackQty} != ""
   call AlignCtrl('v',s:AlignVPat_{s:AlignCtrlStackQty})
  else
   call AlignCtrl('v')
  endif
  unlet s:AlignVPat_{s:AlignCtrlStackQty}

  let s:AlignCtrlStackQty= s:AlignCtrlStackQty - 1
"  call Decho("AlignPop: AlignCtrlStack_".s:AlignCtrlStackQty+1."<".retval.">")
  return retval
endf

" ---------------------------------------------------------------------
" Set up default values
call AlignCtrl("default")
