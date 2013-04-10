/*REXX program cuts rectangles into two symmetric pieces, the rectangles*/
/*──────────────────── are cut along unit dimensions and may be rotated.*/
numeric digits 20                      /*be able to handle big integers.*/
parse arg N .;    if N=='' then N=10   /*Not specified? Use the default?*/
dir.=0;  dir.0.1=-1;  dir.1.0=-1;  dir.2.1=1;  dir.3.0=1   /*directions.*/

     do   y=2   to N;   say            /*calculate rectangles up to NxN.*/
       do x=1  for y;   if x//2 & y//2 then iterate   /*not if both odd.*/
       _=solve(y,x,1);   _=right(_,max(10,length(_))) /*align the output*/
       say right(y,9) "x" right(x,2) 'rectangle can be cut' _ "way"s(_)'.'
       end   /*x*/
     end     /*y*/
exit                                   /*stick a fork in it, we're done.*/
/*──────────────────────────────────WALK subroutine─────────────────────*/
walk: procedure expose # dir. @. h len next. w;    parse arg y,x
if y==h  then do; #=#+2; return;  end  /* ◄──┐       REXX short circuit.*/
if x==0  then do; #=#+2; return;  end  /* ◄──┤         "    "      "    */
if x==w  then do; #=#+2; return;  end  /* ◄──┤         "    "      "    */
if y==0  then do; #=#+2; return;  end  /* ◄──┤         "    "      "    */
t=x + y*(w+1);   @.t=@.t+1;  _=len-t   /*    │ ordered by most likely►─┐*/
@._=@._+1                              /*    └─────────────────────────┘*/
                   do j=0  for 4;   _ = t+next.j   /*try four directions*/
                   if @._==0        then call walk y+dir.j.0, x+dir.j.1
                   end   /*j*/

@.t=@.t-1;   _=len-t;   @._=@._-1
return
/*──────────────────────────────────S subroutine────────────────────────*/
s: if arg(1)=1  then return arg(3);    return word(arg(2) 's',1)
/*──────────────────────────────────SOLVE subroutine────────────────────*/
solve: procedure expose # dir. @. h len next. w
parse arg hh 1 h,ww 1 w,recur; @. = 0  /*zero the rectangle coördinates.*/
if h//2  then do;   t=w;   w=h;   h=t;  if h//2  then return 0;   end
if w==1  then return 1;    if w==2  then return h;  if h==2  then return w
cy  = h%2;    cx=w%2                   /*cut the  [XY]  rectangle in ½. */
len = (h+1) * (w+1)  - 1               /*extended area of the rectangle.*/
next.0=-1;  next.1=-w-1;  next.2=1;  next.3=w+1 /*compute direction dist*/
if recur then #=0
                     do x=cx+1  to  w-1;    t=x+cy*(w+1)
                     @.t=1;     _=len-t;    @._=1;        call walk cy-1,x
                     end   /*x*/
#=#+1
if h==w  then #=#+#                    /*double count of rectangle cuts.*/
         else if w//2==0 & recur  then call solve w,h,0
return #
