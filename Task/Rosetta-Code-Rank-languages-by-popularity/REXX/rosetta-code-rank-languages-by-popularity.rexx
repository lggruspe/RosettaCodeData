/*REXX pgm reads 2 files, shows a ranked list of Rosetta Code languages.*/
sep='█'; L.=0; #.=0; u.=0; catHeap=; old.= /*assign variable defaults.  */
parse arg cutoff CinFID LinFID outFID .    /*obtain specified options.  */
if cutoff==',' | cutoff==''  then cutoff=0 /*assume no cutoff default.  */
if CinFID==''  then CinFID = 'RC_POP.CAT'  /*Not specified? Use default.*/
if LinFID==''  then LinFID = 'RC_POP.LAN'  /* "      "       "     "    */
if outFID==''  then outFID = 'RC_POP.OUT'  /* "      "       "     "    */
call tell  center('timestamp: '   date()   time('Civil'),79,'═'),  2,  1
call reader 'lang'                               /*assign to   L.ααα    */
call reader 'cat'                                /*append to the catHeap*/
#=0                                              /*number of categories.*/
     do j=1  until  catHeap==''                  /*process heap of cats.*/
     parse var catHeap cat.j  (sep)  catHeap     /*pick off a category. */
     parse var cat.j   cat.j  '<'    "("  mems . /*untangle the string. */
     cat.j=space(cat.j);     _=cat.j;   upper _  /*remove excess blanks.*/
     if _=='' | \L._         then iterate        /*blank or ¬ a language*/
     if \datatype(mems,'W')  then iterate        /*"members"  ¬ numeric.*/
     if u._\==0 then do                          /*[↓] handle duplicates*/
                         do f=1  for #  until  _==@u.f;    end  /*f*/
                     #.f=#.f+mems;  iterate j
                     end   /* [↑] languages that are in different cases.*/
     u._=u._+1
     #=#+1;  #.#=#.#+mems;  @.#=cat.j;  @u.#=_   /*bump counter, assign.*/
     end   /*j=1 until ···*/
!.=                                    /*array holds indication of TIED.*/
call tell   right(#,9)   '(total) number of languages detected.',  ,  1
call eSort #,0                         /*sort the languages along with #*/
r=0                                    /*add true rank (tR) ──► entries.*/
tied=;    do j=#  by -1  for #;   r=r+1;  tR=r;  !tR.j=r;  jp=j+1;  jm=j-1
          if tied=='' then pR=r; tied= /*handle if the  rank  is untied.*/
          if #.j==#.jp | #.j==#.jm  then do; !.j='[tied]'; tied=!.j;   end
          if #.j==#.jp              then do; tR=pR; !tR.j=pR; end
                                    else pR=r
          end   /*j=# by ···*/

call eSort #,1                         /*sort the languages along with @*/
listed=0;  w=length(#);        rank=0  /* [↓]  show by ascending rank.  */

  do j=#  by -1  for #  while  #.j>=cutoff;  listed=listed+1;  rank=rank+1
  call   tell   right('rank:'       right(!tR.j,w),20-1)     right(!.j,7),
                right('('#.j  left("entr"s(#.j,'ies',"y")')', 9),20)   @.j
  end   /*j=# by ···*/              /*  [↑]    s(···)  pluralizes a word*/

call tell left('',27)     '☼  end-of-list.  ☼',  1,  2
if cutoff==0  then exit                /*was there a CUTOFF speciified? */
call tell '  Listing stopped due to a cutoff of'   cutoff".",   1
call tell listed 'language's(#) "found with number of entries ≥" cutoff,1,1
exit                                   /*stick a fork in it, we're done.*/
/*──────────────────────────────────ESORT subroutine────────────────────*/
eSort: procedure expose #. @. !tr.;  arg N,p2;  h=N  /*sort by # entries*/
  do        while h>1;       h=h%2                   /*sort kinda halved*/
    do i=1  for N-h;         j=i;          k=h+i     /*sort this part.  */
    if p2  then do  while !tR.k==!tR.j & @.k>@.j     /*using hard swap ↓*/
                @=@.j;  #=!tR.j;  @.j=@.k;  !tR.j=!tR.k;   @.k=@;  !tR.k=#
                if h>=j  then leave;            j=j-h;      k=k-h
                end    /*while !tR·k==···*/
           else do  while #.k<#.j                    /*using hard swap ↓*/
                @=@.j;   #=#.j;   @.j=@.k;    #.j=#.k;     @.k=@;    #.k=#
                if h>=j  then leave;            j=j-h;     k=k-h
                end    /*while #.k<#.j*/
    end                /*i*/
  end                  /*while h>1*/
return
/*──────────────────────────────────READER subroutine───────────────────*/
reader: arg which 2;      ig_ast=1     /*ARG uppers WHICH, gets 1st char*/
if which=='L'  then inFID=Linfid       /*use this fileID for languages. */
if which=='C'  then inFID=Cinfid       /* "    "     "    "  categories.*/
old.1='╬£C++'    ;  new.1=  "µC++"     /*Unicode ╬£C++ ──►ASCII-8: µC++ */
old.2='UC++'     ;  new.2=  "µC++"     /*old      UC++ ──►ASCII-8: µC++ */
old.3='╨£╨Ü-'    ;  new.3=  "MK-"      /*Unicode ╨£╨Ü- ──►ASCII-8: MK-  */
old.4='D├⌐j├á'   ;  new.4=  'Déjá'     /*Unicode ├⌐j├á ──►ASCII-8: Déjá */
old.5='Cach├⌐'   ;  new.5=  'Caché'    /*Unicode ach├⌐ ──►ASCII-8: Caché*/
old.6='??-61/52' ;  new.6=  'MK-61/52' /*somewhere a mistranslated: MK- */

  do recs=0   while  lines(inFID)\==0  /*read a file,  1 line at a time.*/
  $=translate(linein(inFID),,'9'x)     /*handle any stray tab characters*/
  $$=space($); if $$==''  then iterate /*ignore all blank lines.        */
          do k=1  while old.k\==''     /*translate Unicode variations.  */
          if pos(old.k, $$)  \==0  then  $$=changestr(old.k, $$, new.k)
          end   /*k*/                  /* [↑] handle different spellings*/
  if ig_ast  then do; ig_ast=pos(' * ',$)==0;  if ig_ast then iterate; end
  $u=$$;        upper $u               /*get an uppercase version.      */
  if pos('RETRIEVED FROM',$u)\==0  then leave    /*a pseudo End-Of-Data.*/
  if which=='L'  then do
                      if left($$,1)\=='*'  then iterate      /*legimate?*/
                      parse  upper  var  $$  '*'  $$  "<";    $$=space($$)
                      L.$$=1           /*languages are stored uppercase.*/
                      iterate          /*iterates the DO WHILE LINES(···*/
                      end              /*(above) pick off language name.*/
  if left($$,1)=='*'  then $$=sep || space(substr($$,2))
  catHeap=catHeap $$                   /*append to the (CATegory) heap. */
  end   /*while lines···*/

call   tell     right(recs,9)       'records read from file: '       inFID
return
/*──────────────────────────────────S subroutine────────────────────────*/
s: if arg(1)==1 then return arg(3);  return word(arg(2) 's',1)  /*plural*/
/*──────────────────────────────────TELL subroutine─────────────────────*/
tell:   do '0'arg(2);   call lineout outFID,' '     ;   say         ;  end
                        call lineout outFID,arg(1)  ;   say arg(1)
        do '0'arg(3);   call lineout outFID,' '     ;   say         ;  end
return  /*show before blanks lines (if any), MSG, show after blank lines*/
