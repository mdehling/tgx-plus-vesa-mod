FCode-version1
offset16

hex


" cgsix" encode-string " name" property
" SUNW,501-2253" model " display" device-type 

: copyright " Copyright (c) 1991 by Sun Microsystems, Inc. " ;
: sccsid " @(#)TurboGX 2.0" ;

 
variable legosc-address  
 
: map-slot swap legosc-address @ + swap map-low ;

1 constant dblbuf? 
h# 4 constant /vmsize 
h# a1 constant bdrev 

h# 8 value ppc 
h# d327e value strap-value 
h# 17300 value delay-value 

h# 4 constant lengthloc
h# 10 constant /dac
h# 8000 constant /prom
h# 58a28d4 constant mainosc

-1 value dac-adr 
-1 value prom-adr 
-1 value alt-adr 
-1 value ptr 
-1 value logo 
-1 value fhc 
-1 value thc 
-1 value fbc-adr 
-1 value fb-addr 
-1 value tec 
-1 value tmp-len 
-1 value tmp-addr 
-1 value tmp-flag 
-1 value selftest-map 
0 value my-reset 
0 value mapped? 
0 value alt-mapped? 
h# 200000 value /frame 
h# 100 alloc-mem constant data-space 


external

0 value display-width 
0 value display-height 
-1 value acceleration 

headers


0 value lego-status 
0 value sense-id-value 
0 value chip-rev 

 
defer (set-fbconfiguration 

 
defer (confused? 

 
: my-attribute 
   fcode-revision h# 2000 <  if  
      2drop 2drop 
   else 
      my-reset 0 =  if  
         property
         
      else 
         2drop 2drop 
      then  
   then  
;

 
: my-xdrint 
   my-reset 0=  if  
      encode-int 
   else 
      0 
   then  
;

 
: my-xdrstring 
   my-reset 0=  if  
      encode-string 
   then  
;

 
: length@ prom-adr lengthloc + l@ ;

 
: logo-data 
	prom-adr length@ +

	begin
		dup 3 and
	while
		1 +
	repeat
;

 
: fbc! fbc-adr + l! ;
: fbc@ fbc-adr + l@ ;

: fhc! fhc + l! ;
: fhc@ fhc + l@ ;

: tec! tec + l! ;

: thc! thc + l! ;
: thc@ thc + l@ ;

: dac! dac-adr + l! ;
: dac@ dac-adr + l@ ;
 
: alt! alt-adr + l! ;


: fbc-busy-wait begin  h# 10 fbc@ h# 10000000 and 0= until ;

: fbc-draw-wait begin  h# 14 fbc@ h# 20000000 and 0= until ;

: fbc-blit-wait begin  h# 18 fbc@ h# 20000000 and 0= until ;

 
: background-color 
   inverse-screen?  if  
      h# ff 
   else 
      0 
   then  
;

 
: rect-fill 
   fbc-busy-wait h# 100 fbc! 2swap h# 904 fbc! h# 900 fbc! h# 904 
   fbc! h# 900 fbc! fbc-draw-wait fbc-busy-wait h# ff h# 100 fbc! 
;

 
: >pixel 
   swap char-width * window-left + swap char-height * window-top 
   + 
;

 
: char-fill 
   2swap >pixel 2swap >pixel background-color rect-fill 
;

 
: init-blit-reg 
   fbc-busy-wait h# ffffffff h# 10 fbc! 0 h# 4 tec! h# 0 h# 8 fbc! 
   h# 0 h# c0 fbc! h# 0 h# c4 fbc! h# 0 h# d0 fbc! h# 0 h# d4 fbc! 
   h# 0 h# e0 fbc! h# 0 h# e4 fbc! h# ff h# 100 fbc! h# 0 h# 104 
   fbc! h# a9806c60 h# 108 fbc! h# ff h# 10c fbc! h# ffffffff h# 110 
   fbc! h# 0 h# 11c fbc! h# ffffffff h# 120 fbc! h# ffffffff h# 124 
   fbc! h# ffffffff h# 128 fbc! h# ffffffff h# 12c fbc! h# ffffffff 
   h# 130 fbc! h# ffffffff h# 134 fbc! h# ffffffff h# 138 fbc! h# ffffffff 
   h# 13c fbc! h# 229540 h# 4 fbc! display-width 1 - h# f0 fbc! display-height 
   1 - h# f4 fbc!
   display-width case 
      h# 400 of h# ffffe3ff 0 fhc@ and 0 fhc! endof 
      h# 480 of h# ffffe3ff 0 fhc@ and h# 800 or 0 fhc! endof 
      h# 500 of h# ffffe3ff 0 fhc@ and h# 1000 or 0 fhc! endof 
      h# 640 of h# ffffe3ff 0 fhc@ and h# 1800 or 0 fhc! endof 
      h# 780 of h# ffffe3ff 0 fhc@ and h# 400 or 0 fhc! endof 
   endcase 
;

 
: cg6-save 
   fbc-busy-wait h# c0 fbc@ h# c4 fbc@ h# d0 fbc@ h# d4 fbc@ h# e0 
   fbc@ h# e4 fbc@ h# 8 fbc@ h# 100 fbc@ h# 104 fbc@ h# 108 fbc@ 
   h# 10c fbc@ h# 110 fbc@ h# 4 fbc@ h# f0 fbc@ h# f4 fbc@ h# 80 
   fbc@ h# 84 fbc@ h# 90 fbc@ h# 94 fbc@ h# a0 fbc@ h# a4 fbc@ h# b0 
   fbc@ h# b4 fbc@ init-blit-reg 
;

 
: cg6-restore 
   fbc-busy-wait h# b4 fbc! h# b0 fbc! h# a4 fbc! h# a0 fbc! h# 94 
   fbc! h# 90 fbc! h# 84 fbc! h# 80 fbc! h# f4 fbc! h# f0 fbc! h# 40 
   or h# 4 fbc! h# 110 fbc! h# 10c fbc! h# 108 fbc! h# 104 fbc! h# 100 
   fbc! h# 8 fbc! h# e4 fbc! h# e0 fbc! h# d4 fbc! h# d0 fbc! h# c4 
   fbc! h# c0 fbc! 
;

 
variable tmp-blit  
 
: lego-blit 
   fbc-busy-wait >pixel 1 - h# b4 fbc! 1 - h# b0 fbc! >pixel h# a4 
   fbc! h# a0 fbc! >pixel 1 - h# 94 fbc! 1 - h# 90 fbc! >pixel h# 84 
   fbc! h# 80 fbc! fbc-blit-wait fbc-busy-wait 
;

 
: lego-delete-lines 
   dup #lines <  if  
      tmp-blit ! cg6-save tmp-blit @ >r 0 line# r@ + #columns #lines 0 
      line# #columns #lines r@ - line# r@ + #lines <  if  
         lego-blit 
      else 
         2drop 2drop 2drop 2drop 
      then
      0 #lines r> - #columns #lines char-fill cg6-restore 
   else 
      tmp-blit ! cg6-save tmp-blit @ 0 swap #lines swap - #columns 
      #lines char-fill cg6-restore 
   then  
;

 
: lego-insert-lines 
   dup #lines <  if  
      tmp-blit ! cg6-save tmp-blit @ >r 0 line# #columns #lines r@ - 0 
      line# r@ + #columns #lines lego-blit 0 line# #columns line# r> + 
      char-fill cg6-restore 
   else 
      tmp-blit ! cg6-save tmp-blit @ 0 swap line# swap #columns swap 
      line# swap + char-fill cg6-restore 
   then  
;

 
: lego-erase-screen 
   cg6-save 0 0 screen-width screen-height background-color rect-fill 
   cg6-restore 
;

 
: lego-video-on h# 818 thc@ h# 400 or h# 818 thc! ;
: lego-video-off h# 818 thc@ h# fffffbff and h# 1000 or h# 818 thc! ;

: lego-sync-on h# 818 thc@ h# 80 or h# 818 thc! ;
: lego-sync-off h# 818 thc@ h# ffffff7f and h# 818 thc! ;

: delay-100 h# 3e8 ms ;

: lego-sync-reset h# 818 thc@ h# 1000 or h# 818 thc! delay-100 ;

: prom-map 0 /prom map-slot b(to) prom-adr ;
: prom-unmap prom-adr /prom free-virtual -1 b(to) prom-adr ;

: dac-map h# 200000 /dac map-slot b(to) dac-adr ;
: dac-unmap dac-adr /dac free-virtual -1 b(to) dac-adr ;

: fhc-thc-map h# 300000 h# 2000 map-slot b(to) fhc fhc h# 1000 + b(to) thc ;
: fhc-thc-unmap fhc h# 2000 free-virtual -1 b(to) fhc -1 b(to) thc ;


: ?fhc-thc-map 
   fhc -1 =  if  
      -1 b(to) mapped? fhc-thc-map 
   else 
      0 b(to) mapped? 
   then  
;

 
: ?fhc-thc-unmap 
   mapped?  if  
      fhc-thc-unmap 0 b(to) mapped? 
   then  
;

 
: fb-map h# 800000 /frame map-slot b(to) fb-addr ;
: fb-unmap fb-addr /frame free-virtual -1 b(to) fb-addr ;

: fbc-map h# 700000 h# 2000 map-slot b(to) fbc-adr fbc-adr h# 1000 + b(to) tec ;
: fbc-unmap fbc-adr h# 2000 free-virtual -1 b(to) fbc-adr ;

: alt-map h# 280000 h# 2000 map-slot b(to) alt-adr ;
: alt-unmap alt-adr h# 2000 free-virtual -1 b(to) alt-adr ;


: ?alt-map
   alt-adr -1 =  if
      -1 b(to) alt-mapped? alt-map
   else 
      0 b(to) alt-mapped? 
   then  
;


: ?alt-unmap 
   alt-mapped?  if  
      alt-unmap 0 b(to) alt-mapped? 
   then  
;

 
: color 
	dup rot + swap
	0 dac-adr l!

	do
		i c@ dup h# 18 lshift +
		dac-adr h# 4 + l!
	loop  
;

 
: 3color! dac-adr l! swap rot 3 0 do dac-adr h# 4 + l! loop ;

: color! swap 0 dac! 2dup dac! 2dup dac! dac! ;

 
: lego-init-dac 
   dac-map h# 4000000 0 dac! h# ff000000 h# 8 dac! h# 5000000 0 dac! 
   h# 0 h# 8 dac! h# 6000000 0 dac! h# 43000000 h# 8 dac! h# 7000000 
   0 dac! h# 0 h# 8 dac! h# 9000000 0 dac! h# 6000000 h# 8 dac! h# ff000000 
   h# 0 h# 4 color! h# 0 h# ff000000 h# 4 color! h# ff000000 h# 1000000 
   h# c color! h# 0 h# 2000000 h# c color! h# 0 h# 3000000 h# c color! 
   h# 64000000 h# 41000000 h# b4000000 h# 1000000 3color! dac-unmap 
   
;


external

: r1024x768x60 " 64125000,48286,60,16,128,160,1024,2,6,29,768,COLOR" ;
: r1024x768x70 " 74250000,56593,70,16,136,136,1024,2,6,32,768,COLOR" ;
: r1024x768x76 " 81000000,61990,76,40,128,136,1024,2,4,31,768,COLOR,0OFFSET" ;
: r1024x768x77 " 84375000,62040,77,32,128,176,1024,2,4,31,768,COLOR,0OFFSET" ;
: r1024x800x72 " 81000000,60994,73,40,128,136,1024,2,4,31,800,COLOR,0OFFSET" ;
: r1024x800x74 " 84375000,62040,74,32,128,176,1024,2,4,31,800,COLOR,0OFFSET" ;
: r1024x800x85 " 94500000,71590,85,16,128,152,1024,2,4,31,800,COLOR,0OFFSET" ;
: r1152x900x66 " 94500000,61845,66,40,128,208,1152,2,4,31,900,COLOR" ;
: r1152x900x76 " 108000000,71808,76,32,128,192,1152,2,4,31,900,COLOR,0OFFSET" ;
: r1280x1024x67 " 117000000,71691,67,16,112,224,1280,2,8,33,1024,COLOR,0OFFSET" ;
: r1280x1024x76 " 135000000,81128,76,32,64,288,1280,2,8,32,1024,COLOR,0OFFSET" ;
: r1600x1280x76 " 216000000,101890,76,24,216,280,1600,2,8,50,1280,COLOR,0OFFSET" ;

headers


: sense-code 
   sense-id-value case 
      h# 7 of r1152x900x66 endof 
      h# 6 of r1152x900x76 endof 
      h# 5 of r1024x768x60 endof 
      h# 4 of r1152x900x76 endof 
      3 of r1152x900x66 endof 
      2 of r1280x1024x76 endof 
      1 of r1600x1280x76 endof 
      0 of r1024x768x77 endof 
      drop r1152x900x66 0 
   endcase 
;

 
: ics-write 
	\ XXX: just guessing here, but it matches the ICS1562A datasheet
	\ address of the register: negative edge on STROBE .  This is *not*
	\ done on the LX's internal CG6.
	dup
	h# 1c lshift h# 0800.0000 or 0 alt!
	h# 1c lshift                 0 alt!
	\ data for the register: positive edge on STROBE
	dup 
	h# 1c lshift                 0 alt!
	h# 1c lshift h# 0800.0000 or 0 alt! 
;


: ics47  0 1 0 h# a h# c h# f h# f 1 h# 8    2    0 0 h# 5 ;
: ics54  0 1 0 h# a h# c h# f h# f 1 h# 8    2    2 0 h# 4 ;
: ics64  0 1 0 h# a h# c h# f h# f 1 h# 8    2    1 0    3 ;
: ics74  0 1 0 h# a h# d h# f h# f 1 h# 8 h# 4    3 0 h# 5 ;
: ics81  0 1 0 h# a h# d h# f h# f 1 h# 8 h# 5    0 0 h# 6 ;
: ics84  0 1 0 h# a h# d h# f h# f 1 h# 8    3    1 0    3 ;
: ics94  0 1 0 h# a h# d h# f h# f 1 h# 8    2    0 0    2 ;
: ics108 0 1 0 h# a h# d h# f h# f 1 h# 8 h# 4    2 0    3 ;
: ics117 0 1 0 h# a h# d h# f h# f 1 h# 8    3    2 0    2 ;
: ics135 0 1 0 h# a h# e h# f h# f 1 h# 8 h# 5 h# 4 0    3 ;
: ics189 0 0 0 h# a h# d h# f h# f 1 h# 8    2    0 0    2 ;
: ics216 0 0 0 h# a h# d h# f h# f 1 h# 8 h# 4    2 0    3 ;


: oscillators 
   h# 50775d8 h# 4d3f640 h# 46cf710 h# 3d27848 h# cdfe600 h# b43e940 
   h# 80befc0 h# 6f94740 h# 66ff300 h# 5a1f4a0 h# 337f980 h# 2d0fa50 
   h# c 
;

 
: setup-oscillator-ad 
   ?alt-map h# ff000000 0 alt! case 
      0 of h# 0 0 alt! endof 
      1 of h# 11000000 0 alt! endof 
      2 of h# 22000000 0 alt! endof 
      3 of h# 33000000 0 alt! endof 
      h# 4 of h# 44000000 0 alt! endof 
      h# 5 of h# 55000000 0 alt! endof 
      h# 6 of h# 66000000 0 alt! endof 
      h# 7 of h# 77000000 0 alt! endof 
      h# 8 of h# 88000000 0 alt! endof 
      h# 9 of h# 99000000 0 alt! endof 
      h# a of h# aa000000 0 alt! endof 
      h# 22000000 0 alt! 
   endcase 
   h# 94 thc@ h# 40 or dup h# 94 thc! b(to) strap-value 1 ms ?alt-unmap 
;

 
: setup-oscillator 
	?alt-map case 
		0 of ics47 endof 
		1 of ics54 endof 
		2 of ics94 endof 
		3 of ics108 endof 
		h# 4 of ics117 endof 
		h# 5 of ics135 endof 
		h# 6 of ics189 endof 
		h# 7 of ics216 endof 
		h# 8 of ics64 endof 
		h# 9 of ics74 endof 
		h# a of ics81 endof 
		h# b of ics84 endof 
		drop ics94 0 
	endcase 

	0 h# d ics-write

	h# d 0 do
		i ics-write
	loop

	0 h# f ics-write 

	\ 32 writes as required by the datasheet to enable ICS1562A!
	h# 20 0 do
		0 h# d ics-write
	loop

	h# 94 thc@
	h# 40 or dup h# 94 thc! b(to) strap-value

	1 ms

	?alt-unmap 
;

 
variable dpl  
 
: upper 
   bounds ?do  i dup c@ upc swap c! loop  
;

 
: compare-strings 
   rot tuck <  if  
      drop 2drop 0 
   else 
      comp 0= 
   then  
;

 
: long? dpl @ 1 + 0<> ;

 
: convert 
	begin  
		1 + dup >r c@ h# a digit
	while 
		>r h# a * r> +
		long? if
			1 dpl +!
		then
		r>
	repeat
	drop r>
;

 
: number? 
   >r 0 r@ dup 1 + c@ h# 2d = dup >r - -1 dpl ! begin  
      convert dup c@ h# 2e = 
   while 
      0 dpl ! 
   repeat r> if  
      swap negate swap 
   then r> count + = 
;

 
: number number? drop ;
 
: /string over min >r swap r@ + swap r> - ;
: +string 1 + ;
: -string swap 1 + swap 1 - ;

 
: left-parse-string 
   >r over 0 2swap
   begin  
      dup 
   while 
      over c@ r@ = if
         r> drop -string 2swap exit 
      then
      2swap +string 2swap -string 
   repeat
   2swap r> drop 
;

 
: left-parse-string' 
   left-parse-string 2 pick 0=  if  
      2swap 
   then  
;

 
variable cal-tmp  
variable osc-tmp  
variable confused?

h# 100 alloc-mem constant tmp-monitor-string 
h# 100 alloc-mem constant tmp-pack-string 

 
variable tmp-monitor-len  
 

external

: monitor-string 
   tmp-monitor-string tmp-monitor-len @ 
;

headers

 
: flag-strings 
   " STEREO" " 0OFFSET" " OVERSCAN" " GRAY" h# 4 
;

 
: mainosc? 
	-1 confused? ! h# 3e8 / osc-tmp !

	oscillators 0 do
		h# 3e8 /
		osc-tmp @ = if
			i setup-oscillator
			0 confused? !
		then
	loop
;

 
: parse-string 
   b(to) tmp-len b(to) tmp-addr b(to) tmp-flag flag-strings 0 do  
   tmp-addr tmp-len 2swap compare-strings  if  
      1 i lshift tmp-flag + b(to) tmp-flag 
   then  loop  tmp-flag 
;

 
: parse-flags 
   0 >r begin  
      h# 2c left-parse-string r> -rot parse-string >r dup 0= 
   until
   2drop r>
;

 
: parse-line 
   h# b 0 do  h# 2c left-parse-string tmp-pack-string pack dup number 
   swap drop -rot dup 0=  if  
      leave 
   then  loop  dup 0<>  if  
      parse-flags 
   else 
      2drop 0 
   then  
;

 
: cycles-per-tran 
   h# 1add30 ppc * /mod swap 0<>  if  
      1 + 
   then  h# 4 - dup h# f >  if  
      drop h# f 
   then  
;

 
: vert 
   b(to) display-height rot dup my-xdrint " vfporch" my-attribute 
   1 - dup h# c0 thc! rot dup my-xdrint " vsync" my-attribute + dup 
   h# c4 thc! swap dup my-xdrint " vbporch" my-attribute + dup h# c8 
   thc! display-height + h# cc thc! 
;

 
: horz 
   b(to) display-width rot dup my-xdrint " hfporch" my-attribute 
   dup ppc / 1 - dup h# a0 thc! 3 pick dup my-xdrint " hsync" my-attribute 
   ppc / + dup h# a4 thc! rot dup my-xdrint " hbporch" my-attribute 
   ppc / + dup h# a8 thc! display-width ppc / + dup h# b0 thc! -rot 
   - ppc / - h# ac thc! 
;

 
: fbc-res 
	display-width h# 400 < if
		h# 94 thc@
		h# 800000 or h# 94 thc!
		display-width 2 * 
	else 
		h# 94 thc@
		h# 800000 invert and
		h# 94 thc!
		display-width
	then

	case
		h# 400 of h# ffffe3ff 0 fhc@ and 0 fhc! endof 
		h# 480 of h# ffffe3ff 0 fhc@ and h# 800 or 0 fhc! endof 
		h# 500 of h# ffffe3ff 0 fhc@ and h# 1000 or 0 fhc! endof 
		h# 800 of h# ffffe3ff 0 fhc@ and h# 1400 or 0 fhc! endof 
		h# 640 of h# ffffe3ff 0 fhc@ and h# 1800 or 0 fhc! endof 
		h# 780 of h# ffffe3ff 0 fhc@ and h# 400 or 0 fhc! endof 
		0 b(to) acceleration 
	endcase 

	cal-tmp @ h# 4 and 0<> if
		h# 94 thc@ h# 80 or h# 94 thc!
	else
		h# 94 thc@ h# 80 invert and h# 94 thc!
	then
;

 
: cal-tim 
   cal-tmp ! vert horz my-xdrint " vfreq" my-attribute my-xdrint 
   " hfreq" my-attribute dup my-xdrint " pixfreq" my-attribute dup 
   mainosc? cycles-per-tran h# 818 thc@ h# fffffff0 and or h# 818 
   thc! 0 b(to) dblbuf? h# 94 thc@ h# 2000000 invert and display-width 
   display-height * 2 * /vmsize h# 100000 * <=  if  
      h# 2000000 or 1 b(to) dblbuf? 
   then  h# 94 thc! fbc-res bdrev my-xdrint " boardrev" my-attribute 
   cal-tmp @ my-xdrint " montype" my-attribute acceleration  if  
      " cgsix" 
   else 
      " cgthree+" 
   then  my-xdrstring " emulation" my-attribute 
;

 
external

: update-string 
	2dup tmp-monitor-string swap move dup tmp-monitor-len !
;

headers

 
: set-fbconfiguration 
   update-string parse-line cal-tim 
;


' set-fbconfiguration b(to) (set-fbconfiguration
' confused? b(to) (confused? 
 

: enable-disables ;
: disable-disables ;

 
: lego-init-hc 
	?fhc-thc-map

	h# 8000 0 fhc!
	h# 1ff 0 fhc!

	chip-rev case
	h# 5 of enable-disables 0 fhc@ h# 10000 or 0 fhc! disable-disables endof
	h# 6 of enable-disables 0 fhc@ h# 10000 or 0 fhc! disable-disables endof
	h# 7 of enable-disables 0 fhc@ h# 10000 or 0 fhc! disable-disables endof
	h# 8 of enable-disables 0 fhc@ h# 10000 or 0 fhc! disable-disables endof
	enable-disables 0 fhc@ h# 10000 or 0 fhc! disable-disables
	endcase

	h# ffe0ffe0 h# 8fc thc!

	?fhc-thc-unmap 
;

 
: logo@ 0 swap h# 4 0 do  dup c@ rot h# 8 lshift + swap 1 + loop  drop ;

 
: cg6-move-line 
   2 pick 2 pick 2 pick rot move 
;

 
: move-image-to-fb 
   rot 0 do  cg6-move-line display-width + swap 2 pick + swap loop  
   drop 2drop 
;

 
: lego-draw-logo

	2 pick h# 92 +
	logo@

	bfdfdfe7 <> if
		fb8-draw-logo
	else
		prom-map

		dac-map
		h# 100 3 * logo-data h# 4 + color
		dac-unmap

		drop 2drop
		logo-data 2 + c@
		logo-data 3 + c@
		rot

		logo-data
		h# 100 3 * + h# 4 + swap char-height * window-top + display-width * window-left + fb-addr +

		move-image-to-fb

		prom-unmap
	then
;

 
: diagnostic-type 
   diagnostic-mode?  if  
      type cr 
   else 
      2drop 
   then  
;

 
: ?lego-error 
   2swap <>  if  
      2 b(to) lego-status diagnostic-type "  r/w failed" 
   else 
      2drop 
   then  
;

 
: lego-register-test 
   selftest-map  if  
      fb-map 
   then  h# 8 fbc@ h# 35 h# 100 fbc! h# ca h# 104 fbc! h# 12345678 
   h# 110 fbc! h# 96969696 h# 84 fbc! h# 69696969 h# 80 fbc! h# 3c3c3c3c 
   h# 90 fbc! h# a980cccc h# 108 fbc! h# ff h# 10c fbc! 0 h# e0 fbc! 
   h# 0 h# e4 fbc! display-width 1 - h# f0 fbc! display-height 1 
   - h# f4 fbc! h# 14aac0 h# 4 fbc! h# 0 h# 8 fbc! h# 0 h# 4 tec! 
   "  FBC register test" diagnostic-type h# 100 fbc@ h# 35 " FBC_FCOLOR" 
   ?lego-error h# 104 fbc@ h# ca " FBC_BCOLOR" ?lego-error h# 110 
   fbc@ h# 12345678 " FBC_PIXELMASK" ?lego-error h# 84 fbc@ h# 96969696 
   " FBC_Y0" ?lego-error h# 80 fbc@ h# 69696969 " FBC_X0" ?lego-error 
   h# 90 fbc@ h# 3c3c3c3c " FBC_RASTEROP" ?lego-error h# ff h# 110 
   fbc! 0 h# 84 fbc! 0 h# 80 fbc! h# 1f h# 90 fbc! h# 55555555 h# 1c 
   fbc! h# 8 fbc! selftest-map  if  
      fb-unmap 
   then  
;

 
: lego-fbc-test 
   selftest-map  if  
      fb-map 
   then  "  Font test" diagnostic-type h# 8 0 do  i h# 4 * fb-addr 
   + @ h# ff00ff <>  if  
      1 b(to) lego-status " Fonting to DFB error" diagnostic-type 
      
   then  loop  selftest-map  if  
      fb-unmap 
   then  
;

 
: lego-fb-test 
   selftest-map  if  
      fb-map 
   then  h# ffffffff mask ! 0 group-code ! fb-addr /frame memory-test-suite 
    if  
      1 b(to) lego-status 
   then  selftest-map  if  
      fb-unmap 
   then  
;

 
: lego-selftest 
   fb-addr -1 =  if  
      -1 b(to) selftest-map 
   else 
      0 b(to) selftest-map 
   then  " Testing cgsix" diagnostic-type lego-register-test lego-fbc-test 
   lego-fb-test lego-status 
;

 
: lego-blink-screen 
   lego-video-off h# 20 ms lego-video-on 
;

 
external

: set-resolution 
   $find  if  
      execute 
   then  lego-init-hc (set-fbconfiguration (confused? @  if  
      sense-code (set-fbconfiguration 
   then  lego-sync-reset lego-sync-on my-reset 0 =  if  
      display-width dup dup encode-int " width" property
      encode-int " linebytes" property
      encode-int " awidth" property
      display-height encode-int " height" property
      h# 8 encode-int " depth" property
      /vmsize encode-int " vmsize" property
      dblbuf? encode-int " dblbuf" property
   then  
;

 
: set-resolution-ext 
   $find  if  
      execute 
   then  -1 b(to) my-reset lego-init-hc (set-fbconfiguration (confused? 
   @  if  
      sense-code (set-fbconfiguration 
   then  lego-sync-reset lego-sync-on 0 b(to) my-reset display-width 
   data-space l! display-height data-space h# 4 + l! h# 8 data-space 
   h# 8 + l! display-width data-space h# c + l! acceleration data-space 
   h# 10 + l! 
;

 
: override
	sense-id-value = if
		set-resolution
	else
		2drop
	then
;

headers

 
: lego-reset-screen 
   -1 b(to) my-reset fcode-revision h# 2000 >=  if  
      strap-value h# 94 thc! delay-value h# 90 thc! lego-erase-screen 
      monitor-string set-resolution 
   then  lego-video-on 0 b(to) my-reset 
;

 
: lego-draw-char 
   fbc-busy-wait fb8-draw-character 
;

 
: lego-toggle-cursor 
   fbc-busy-wait fb8-toggle-cursor 
;

 
: lego-invert-screen 
   fbc-busy-wait fb8-invert-screen 
;

 
: lego-insert-characters 
   fbc-busy-wait fb8-insert-characters 
;

 
: lego-delete-characters 
   fbc-busy-wait fb8-delete-characters 
;

 
: dfb-delete-lines 
   fbc-busy-wait fb8-delete-lines 
;

 
: dfb-insert-lines 
   fbc-busy-wait fb8-insert-lines 
;

 
: dfb-erase-screen 
   fbc-busy-wait fb8-erase-screen 
;

 
external

: reinstall-console 
   display-width display-height over char-width / over char-height 
   / fb8-install ['] lego-draw-logo b(to) draw-logo ['] lego-blink-screen 
   b(to) blink-screen ['] lego-reset-screen b(to) reset-screen acceleration 
    if  
      ['] lego-delete-lines b(to) delete-lines ['] lego-insert-lines 
      b(to) insert-lines ['] lego-erase-screen b(to) erase-screen 
      
   then  
;

headers

 
: lego-install 
   fb-map init-blit-reg default-font set-font fb-addr b(to) frame-buffer-adr 
   fb-addr encode-int " address" property
   my-args dup 0<>  if  
      set-resolution 
   else 
      2drop 
   then  reinstall-console lego-video-on 
;

 
: lego-remove 
   lego-video-off fb-unmap -1 b(to) frame-buffer-adr 
;

 
: legoqs-probe 
   my-address legosc-address ! fhc-thc-map fbc-map alt-map strap-value 
   h# 94 thc! h# 100 ms delay-value h# 90 thc! fhc @ dup h# 18 rshift 
   h# f and h# 7 swap - b(to) sense-id-value h# 14 rshift h# f and 
   dup encode-int " chiprev" my-attribute b(to) chip-rev lego-sync-reset 
   lego-sync-on " 74250000,64125000,216000000,189000000,135000000,117000000,108000000,94500000,54000000,47250000,81000000,84375000" 
   encode-string " oscillators" my-attribute data-space encode-int 
   " global-data" property
   /frame encode-int " fbmapped" property
   strap-value h# 8 and dup b(to) ppc 0=  if  
      h# 4 b(to) ppc 
   then  sense-code set-resolution lego-init-dac my-address my-space 
   h# 1000000 reg h# 5 0 intr ['] lego-install is-install 
   ['] lego-remove is-remove ['] lego-selftest is-selftest 
;

legoqs-probe 

end0 

