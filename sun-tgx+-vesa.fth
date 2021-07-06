FCode-version1
offset16

hex


" cgsix"		name
" SUNW,501-2253"	model
" display"		device-type

: copyright	" Copyright (c) 1991 by Sun Microsystems, Inc. " ;
: sccsid	" @(#)TurboGX 2.0" ;


variable legosc-address

: map-slot swap legosc-address @ + swap map-low ;

1	constant dblbuf?
4	constant /vmsize
a1	constant bdrev

8	value ppc
d327e	value strap-value
17300	value delay-value

4	constant lengthloc
10	constant /dac
8000	constant /prom
58a28d4	constant mainosc

-1	value dac-adr
-1	value prom-adr
-1	value alt-adr
-1	value ptr
-1	value logo
-1	value fhc
-1	value thc
-1	value fbc-adr
-1	value fb-addr
-1	value tec
-1	value tmp-len
-1	value tmp-addr
-1	value tmp-flag
-1	value selftest-map
0	value my-reset
0	value mapped?
0	value alt-mapped?
200000	value /frame

100 alloc-mem	constant data-space


external

0	value display-width
0	value display-height
-1	value acceleration

headers


0	value lego-status
0	value sense-id-value
0	value chip-rev


defer (set-fbconfiguration

defer (confused?


: my-attribute
	fcode-revision 2000 < if
		2drop 2drop
	else
		my-reset 0= if
			property
		else
			2drop 2drop
		then
	then
;


: my-xdrint
	my-reset 0= if
		encode-int
	else
		0
	then
;


: my-xdrstring
	my-reset 0= if
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


: fbc-busy-wait begin  10 fbc@ 1000.0000 and 0= until ;
: fbc-draw-wait begin  14 fbc@ 2000.0000 and 0= until ;
: fbc-blit-wait begin  18 fbc@ 2000.0000 and 0= until ;


: background-color
	inverse-screen? if
		ff
	else
		0
	then
;


: rect-fill
	fbc-busy-wait

	100 fbc!
	2swap
	904 fbc! 900 fbc!
	904 fbc! 900 fbc!

	fbc-draw-wait
	fbc-busy-wait

	ff 100 fbc!
;


: >pixel
	swap char-width * window-left + swap char-height * window-top +
;


: char-fill
	2swap >pixel 2swap >pixel background-color rect-fill
;


: init-blit-reg
	fbc-busy-wait

	ffff.ffff 10 fbc!

	0 4 tec!

	0 8 fbc!
	0 c0 fbc!  0 c4 fbc!
	0 d0 fbc!  0 d4 fbc!
	0 e0 fbc!  0 e4 fbc!

	0000.00ff 100 fbc!	0000.0000 104 fbc!

	a980.6c60 108 fbc!

	0000.00ff 10c fbc!	ffff.ffff 110 fbc!
	0000.0000 11c fbc!	ffff.ffff 120 fbc!
	ffff.ffff 124 fbc!	ffff.ffff 128 fbc!
	ffff.ffff 12c fbc!	ffff.ffff 130 fbc!
	ffff.ffff 134 fbc!	ffff.ffff 138 fbc!
	ffff.ffff 13c fbc!

	0022.9540 4 fbc!

	display-width 1 -   f0 fbc!
	display-height 1 -  f4 fbc!

	display-width case
	d# 1024 of  ffff.e3ff 0 fhc@ and 0         fhc!  endof
	d# 1152 of  ffff.e3ff 0 fhc@ and 8000 or 0 fhc!  endof
	d# 1280 of  ffff.e3ff 0 fhc@ and 1000 or 0 fhc!  endof
	d# 1600 of  ffff.e3ff 0 fhc@ and 1800 or 0 fhc!  endof
	d# 1920 of  ffff.e3ff 0 fhc@ and 0400 or 0 fhc!  endof
	d# 2048 of  ffff.e3ff 0 fhc@ and 1400 or 0 fhc!  endof
	endcase
;


: cg6-save
	fbc-busy-wait

	c0 fbc@ c4 fbc@ d0 fbc@ d4 fbc@ e0 fbc@ e4 fbc@ 8 fbc@ 100 fbc@ 104
	fbc@ 108 fbc@ 10c fbc@ 110 fbc@ 4 fbc@ f0 fbc@ f4 fbc@ 80 fbc@ 84 fbc@
	90 fbc@ 94 fbc@ a0 fbc@ a4 fbc@ b0 fbc@ b4 fbc@

	init-blit-reg
;


: cg6-restore
	fbc-busy-wait

	b4 fbc! b0 fbc! a4 fbc! a0 fbc! 94 fbc! 90 fbc! 84 fbc! 80 fbc! f4
	fbc! f0 fbc! 40 or 4 fbc! 110 fbc! 10c fbc! 108 fbc! 104 fbc! 100 fbc!
	8 fbc! e4 fbc! e0 fbc! d4 fbc! d0 fbc! c4 fbc! c0 fbc!
;


variable tmp-blit

: lego-blit
   fbc-busy-wait >pixel 1 - b4 fbc! 1 - b0 fbc! >pixel a4
   fbc! a0 fbc! >pixel 1 - 94 fbc! 1 - 90 fbc! >pixel 84
   fbc! 80 fbc! fbc-blit-wait fbc-busy-wait
;


: lego-delete-lines
   dup #lines < if
      tmp-blit ! cg6-save tmp-blit @ >r 0 line# r@ + #columns #lines 0
      line# #columns #lines r@ - line# r@ + #lines < if
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
   dup #lines < if
      tmp-blit ! cg6-save tmp-blit @ >r 0 line# #columns #lines r@ - 0
      line# r@ + #columns #lines lego-blit 0 line# #columns line# r> +
      char-fill cg6-restore
   else
      tmp-blit ! cg6-save tmp-blit @ 0 swap line# swap #columns swap
      line# swap + char-fill cg6-restore
   then
;


: lego-erase-screen
	cg6-save

	0 0 screen-width screen-height background-color rect-fill

	cg6-restore
;


: lego-video-on  818 thc@ 400 or                818 thc! ;
: lego-video-off 818 thc@ ffff.fbff and 1000 or 818 thc! ;

: lego-sync-on  818 thc@ 80 or         818 thc! ;
: lego-sync-off 818 thc@ ffff.ff7f and 818 thc! ;

: delay-100 3e8 ms ;

: lego-sync-reset 818 thc@ 1000 or 818 thc! delay-100 ;

: prom-map 0 /prom map-slot to prom-adr ;
: prom-unmap prom-adr /prom free-virtual -1 to prom-adr ;

: dac-map 200000 /dac map-slot to dac-adr ;
: dac-unmap dac-adr /dac free-virtual -1 to dac-adr ;

: fhc-thc-map 300000 2000 map-slot to fhc fhc 1000 + to thc ;
: fhc-thc-unmap fhc 2000 free-virtual -1 to fhc -1 to thc ;


: ?fhc-thc-map
	fhc -1 = if
		-1 to mapped?
		fhc-thc-map
	else
		0 to mapped?
	then
;


: ?fhc-thc-unmap
	mapped? if
		fhc-thc-unmap
		0 to mapped?
	then
;


: fb-map 800000 /frame map-slot to fb-addr ;
: fb-unmap fb-addr /frame free-virtual -1 to fb-addr ;

: fbc-map 700000 2000 map-slot to fbc-adr fbc-adr 1000 + to tec ;
: fbc-unmap fbc-adr 2000 free-virtual -1 to fbc-adr ;

: alt-map 280000 2000 map-slot to alt-adr ;
: alt-unmap alt-adr 2000 free-virtual -1 to alt-adr ;


: ?alt-map
	alt-adr -1 = if
		-1 to alt-mapped?
		alt-map
	else
		0 to alt-mapped?
	then
;


: ?alt-unmap
	alt-mapped? if
		alt-unmap
		0 to alt-mapped?
	then
;


: color
	dup rot + swap
	0 dac-adr l!

	do
		i c@ dup 18 lshift +
		dac-adr 4 + l!
	loop
;


: 3color! dac-adr l! swap rot 3 0 do dac-adr 4 + l! loop ;

: color! swap 0 dac! 2dup dac! 2dup dac! dac! ;


: lego-init-dac
   dac-map 4000000 0 dac! ff000000 8 dac! 5000000 0 dac!
   0 8 dac! 6000000 0 dac! 43000000 8 dac! 7000000
   0 dac! 0 8 dac! 9000000 0 dac! 6000000 8 dac! ff000000
   0 4 color! 0 ff000000 4 color! ff000000 1000000
   c color! 0 2000000 c color! 0 3000000 c color!
   64000000 41000000 b4000000 1000000 3color! dac-unmap

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
\ works perfectly
: r1280x1024x60 " 108000000,63981,60,48,112,248,1280,1,3,38,1024,COLOR,0OFFSET" ;
: r1280x1024x67 " 118250000,71691,67,16,112,224,1280,2,8,33,1024,COLOR,0OFFSET" ;
: r1280x1024x76 " 135000000,81128,76,32,64,288,1280,2,8,32,1024,COLOR,0OFFSET" ;
\ works perfectly but gives "memory address not aligned" on .attributes?
: r1440x900x60 " 106500000,55935,60,80,152,232,1440,3,6,25,900,COLOR,0OFFSET" ;
\ out of range
: r1600x900x60 " 108000000,60000,60,24,80,96,1600,1,3,96,900,COLOR,0OFFSET" ;
\ works perfectly
: r1600x1200x60 " 162000000,75000,60,64,192,304,1600,1,3,46,1200,COLOR,0OFFSET" ;
: r1600x1280x76 " 216000000,101890,76,24,216,280,1600,2,8,50,1280,COLOR,0OFFSET" ;
\ out of range
: r1920x1080x60 " 148500000,67500,60,88,44,148,1920,4,5,36,1080,COLOR,0OFFSET" ;
\ out of range
: r1920x1080x50 " 148500000,56250,50,528,44,148,1920,4,5,36,1080,COLOR,0OFFSET" ;
\ very dark, slightly brighter near the top
: r1920x1080x54 " 135000000,61869,54,20,222,20,1920,18,9,18,1080,COLOR,0OFFSET" ;
\ testing
: r1920x1080x72 " 216000000,84375,72,48,216,376,1920,3,3,86,1080,COLOR,0OFFSET" ;
\ recognized as 1600x1200x51
: r1920x1200x51 " 162000000,63281,51,120,200,320,1920,3,6,29,1200,COLOR,0OFFSET" ;
\ works perfectly
: r1920x1200x60 " 193000000,74460,60,136,200,336,1920,3,6,36,1200,COLOR,0OFFSET" ;
\ out of range
: r1920x1200x60r " 154000000,74038,60,48,32,80,1920,3,6,26,1200,COLOR,0OFFSET" ;
\ unsupported but works
: r2048x1152x60r " 162000000,72000,60,26,80,96,2048,1,3,44,1152,COLOR,0OFFSET" ;
\ data access exception
: r2560x1600x60r " 268500000,98713,60,48,32,80,2560,3,6,37,1600,COLOR,0OFFSET" ;

headers


: sense-code
   sense-id-value case
      7 of r1152x900x66 endof
      6 of r1152x900x76 endof
      5 of r1024x768x60 endof
      4 of r1152x900x76 endof
      3 of r1152x900x66 endof
      2 of r1280x1024x76 endof
      1 of r1600x1280x76 endof
      0 of r1024x768x60 endof
      drop r1152x900x66 0
   endcase
;


: ics-write
	\ XXX: just guessing here, but it matches the ICS1562A datasheet
	\ address of the register: negative edge on STROBE .  This is *not*
	\ done on the LX's internal CG6.
	dup
	1c lshift 0800.0000 or 0 alt!
	1c lshift              0 alt!
	\ data for the register: positive edge on STROBE
	dup
	1c lshift              0 alt!
	1c lshift 0800.0000 or 0 alt!
;


: ics47   0 1 0 a c f f 1 8 2 0 0 5 ;
: ics54   0 1 0 a c f f 1 8 2 2 0 4 ;
: ics64   0 1 0 a c f f 1 8 2 1 0 3 ;
: ics74   0 1 0 a d f f 1 8 4 3 0 5 ;
: ics81   0 1 0 a d f f 1 8 5 0 0 6 ;
: ics84   0 1 0 a d f f 1 8 3 1 0 3 ;
: ics94   0 1 0 a d f f 1 8 2 0 0 2 ;
: ics106  0 1 0 a d f f 1 8 a 5 0 8 ;
: ics108  0 1 0 a d f f 1 8 4 2 0 3 ;
: ics118  0 1 0 a d f f 1 8 3 2 0 2 ;
: ics135  0 1 0 a e f f 1 8 5 4 0 3 ;
: ics148  0 0 0 a d f f 1 8 4 3 0 5 ;
: ics154  0 0 0 a d f f 1 9 8 4 1 a ;
: ics162  0 0 0 a d f f 1 8 6 6 0 7 ;
: ics189  0 0 0 a d f f 1 8 2 0 0 2 ;
: ics193  0 0 0 a d f f 1 9 f 1 1 a ;
: ics216  0 0 0 a d f f 1 8 4 2 0 3 ;
: ics268  0 0 0 a e f f 1 9 c 5 1 1 ;


: oscillators
	d# 268.500.000
	d# 216.000.000
	d# 193.000.000
	d# 189.000.000
	d# 162.000.000
	d# 154.000.000
	d# 148.500.000
	d# 135.000.000
	d# 118.125.000
	d# 108.000.000
	d# 106.500.000
	d#  94.500.000
	d#  84.375.000
	d#  81.000.000
	d#  74.250.000
	d#  64.125.000
	d#  54.000.000
	d#  47.250.000
	12
;


: setup-oscillator-ad
	?alt-map

	ff00.0000 0 alt!

	case
	0 of  0000.0000 0 alt!  endof
	1 of  1100.0000 0 alt!  endof
	2 of  2200.0000 0 alt!  endof
	3 of  3300.0000 0 alt!  endof
	4 of  4400.0000 0 alt!  endof
	5 of  5500.0000 0 alt!  endof
	6 of  6600.0000 0 alt!  endof
	7 of  7700.0000 0 alt!  endof
	8 of  8800.0000 0 alt!  endof
	9 of  9900.0000 0 alt!  endof
	a of  aa00.0000 0 alt!  endof
	      2200.0000 0 alt!
	endcase

	94 thc@ 40 or dup 94 thc! to strap-value

	1 ms
	?alt-unmap
;


: setup-oscillator
	?alt-map case
		0  of  ics47   endof
		1  of  ics54   endof
		2  of  ics64   endof
		3  of  ics74   endof
		4  of  ics81   endof
		5  of  ics84   endof
		6  of  ics94   endof
		7  of  ics106  endof
		8  of  ics108  endof
		9  of  ics118  endof
		a  of  ics135  endof
		b  of  ics148  endof
		c  of  ics154  endof
		d  of  ics162  endof
		e  of  ics189  endof
		f  of  ics193  endof
		10 of  ics216  endof
		11 of  ics268  endof
		drop   ics94 0
	endcase

	0 d ics-write

	d 0 do
		i ics-write
	loop

	0 f ics-write

	\ 32 writes as required by the datasheet to enable ICS1562A!
	20 0 do
		0 d ics-write
	loop

	94 thc@
	40 or dup 94 thc! to strap-value

	1 ms

	?alt-unmap
;


variable dpl

: upper
   bounds ?do  i dup c@ upc swap c! loop
;


: compare-strings
   rot tuck < if
      drop 2drop 0
   else
      comp 0=
   then
;


: long? dpl @ 1 + 0<> ;


: convert
	begin
		1 + dup >r c@ a digit
	while
		>r a * r> +
		long? if
			1 dpl +!
		then
		r>
	repeat
	drop r>
;


: number?
   >r 0 r@ dup 1 + c@ 2d = dup >r - -1 dpl ! begin
      convert dup c@ 2e =
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
   left-parse-string 2 pick 0= if
      2swap
   then
;


variable cal-tmp
variable osc-tmp
variable confused?

100 alloc-mem constant tmp-monitor-string
100 alloc-mem constant tmp-pack-string


variable tmp-monitor-len


external

: monitor-string
   tmp-monitor-string tmp-monitor-len @
;

headers


: flag-strings
   " STEREO" " 0OFFSET" " OVERSCAN" " GRAY" 4
;


: mainosc?
	-1 confused? !
	3e8 / osc-tmp !

	oscillators 0 do
		3e8 /
		osc-tmp @ = if
			i setup-oscillator
			0 confused? !
		then
	loop
;


: parse-string
   to tmp-len to tmp-addr to tmp-flag flag-strings 0 do
   tmp-addr tmp-len 2swap compare-strings if
      1 i lshift tmp-flag + to tmp-flag
   then  loop  tmp-flag
;


: parse-flags
   0 >r begin
      2c left-parse-string r> -rot parse-string >r dup 0=
   until
   2drop r>
;


: parse-line
   b 0 do  2c left-parse-string tmp-pack-string pack dup number
   swap drop -rot dup 0= if
      leave
   then  loop  dup 0<> if
      parse-flags
   else
      2drop 0
   then
;


: cycles-per-tran
   1add30 ppc * /mod swap 0<> if
      1 +
   then  4 - dup f > if
      drop f
   then
;


: vert
   to display-height rot dup my-xdrint " vfporch" my-attribute
   1 - dup c0 thc! rot dup my-xdrint " vsync" my-attribute + dup
   c4 thc! swap dup my-xdrint " vbporch" my-attribute + dup c8
   thc! display-height + cc thc!
;


: horz
   to display-width rot dup my-xdrint " hfporch" my-attribute
   dup ppc / 1 - dup a0 thc! 3 pick dup my-xdrint " hsync" my-attribute
   ppc / + dup a4 thc! rot dup my-xdrint " hbporch" my-attribute
   ppc / + dup a8 thc! display-width ppc / + dup b0 thc! -rot
   - ppc / - ac thc!
;


: fbc-res
	display-width 400 < if
		94 thc@
		800000 or 94 thc!
		display-width 2 *
	else
		94 thc@
		800000 invert and
		94 thc!
		display-width
	then

	case
	d# 1024 of  ffff.e3ff 0 fhc@ and         0 fhc!  endof
	d# 1152 of  ffff.e3ff 0 fhc@ and 0800 or 0 fhc!  endof
	d# 1280 of  ffff.e3ff 0 fhc@ and 1000 or 0 fhc!  endof
	d# 1600 of  ffff.e3ff 0 fhc@ and 1800 or 0 fhc!  endof
	d# 1920 of  ffff.e3ff 0 fhc@ and 0400 or 0 fhc!  endof
	d# 2048 of  ffff.e3ff 0 fhc@ and 1400 or 0 fhc!  endof
	            0 to acceleration
	endcase

	cal-tmp @ 4 and 0<> if
		94 thc@  80 or          94 thc!
	else
		94 thc@  80 invert and  94 thc!
	then
;


: cal-tim
	cal-tmp !

	vert horz
	my-xdrint " vfreq" my-attribute
	my-xdrint " hfreq" my-attribute
	dup my-xdrint " pixfreq" my-attribute

	dup mainosc? cycles-per-tran

	818 thc@ ffff.fff0 and or 818 thc!

	0 to dblbuf?
	94 thc@ 0200.0000 invert and

	display-width display-height * 2 * /vmsize 100000 * <= if
		0200.0000 or 1 to dblbuf?
	then

	94 thc!

	fbc-res

	bdrev my-xdrint " boardrev" my-attribute

	cal-tmp @
	my-xdrint " montype" my-attribute

	acceleration if
		" cgsix"
	else
		" cgthree+"
	then
	my-xdrstring " emulation" my-attribute
;


external

: update-string
	2dup tmp-monitor-string swap move dup tmp-monitor-len !
;

headers


: set-fbconfiguration
   update-string parse-line cal-tim
;


' set-fbconfiguration to (set-fbconfiguration
' confused? to (confused?


: enable-disables ;
: disable-disables ;


: lego-init-hc
	?fhc-thc-map

	8000 0 fhc!
	01ff 0 fhc!

	chip-rev case
	5 of  enable-disables 0 fhc@ 10000 or 0 fhc! disable-disables  endof
	6 of  enable-disables 0 fhc@ 10000 or 0 fhc! disable-disables  endof
	7 of  enable-disables 0 fhc@ 10000 or 0 fhc! disable-disables  endof
	8 of  enable-disables 0 fhc@ 10000 or 0 fhc! disable-disables  endof
	      enable-disables 0 fhc@ 10000 or 0 fhc! disable-disables
	endcase

	ffe0.ffe0 8fc thc!

	?fhc-thc-unmap
;


: logo@ 0 swap 4 0 do  dup c@ rot 8 lshift + swap 1 + loop  drop ;


: cg6-move-line
   2 pick 2 pick 2 pick rot move
;


: move-image-to-fb
   rot 0 do  cg6-move-line display-width + swap 2 pick + swap loop
   drop 2drop
;


: lego-draw-logo

	2 pick 92 +
	logo@

	bfdfdfe7 <> if
		fb8-draw-logo
	else
		prom-map

		dac-map
		100 3 * logo-data 4 + color
		dac-unmap

		drop 2drop
		logo-data 2 + c@
		logo-data 3 + c@
		rot

		logo-data
		100 3 * + 4 + swap char-height * window-top + display-width * window-left + fb-addr +

		move-image-to-fb

		prom-unmap
	then
;


: diagnostic-type
	diagnostic-mode? if
		type cr
	else
		2drop
	then
;


: ?lego-error
   2swap <> if
      2 to lego-status diagnostic-type "  r/w failed"
   else
      2drop
   then
;


: lego-register-test
   selftest-map if
      fb-map
   then  8 fbc@ 35 100 fbc! ca 104 fbc! 12345678
   110 fbc! 96969696 84 fbc! 69696969 80 fbc! 3c3c3c3c
   90 fbc! a980cccc 108 fbc! ff 10c fbc! 0 e0 fbc!
   0 e4 fbc! display-width 1 - f0 fbc! display-height 1
   - f4 fbc! 14aac0 4 fbc! 0 8 fbc! 0 4 tec!
   "  FBC register test" diagnostic-type 100 fbc@ 35 " FBC_FCOLOR"
   ?lego-error 104 fbc@ ca " FBC_BCOLOR" ?lego-error 110
   fbc@ 12345678 " FBC_PIXELMASK" ?lego-error 84 fbc@ 96969696
   " FBC_Y0" ?lego-error 80 fbc@ 69696969 " FBC_X0" ?lego-error
   90 fbc@ 3c3c3c3c " FBC_RASTEROP" ?lego-error ff 110
   fbc! 0 84 fbc! 0 80 fbc! 1f 90 fbc! 55555555 1c
   fbc! 8 fbc! selftest-map if
      fb-unmap
   then
;


: lego-fbc-test
   selftest-map if
      fb-map
   then  "  Font test" diagnostic-type 8 0 do  i 4 * fb-addr
   + @ ff00ff <> if
      1 to lego-status " Fonting to DFB error" diagnostic-type

   then  loop  selftest-map if
      fb-unmap
   then
;


: lego-fb-test
   selftest-map if
      fb-map
   then  ffffffff mask ! 0 group-code ! fb-addr /frame memory-test-suite
 if
      1 to lego-status
   then  selftest-map if
      fb-unmap
   then
;


: lego-selftest
   fb-addr -1 = if
      -1 to selftest-map
   else
      0 to selftest-map
   then  " Testing cgsix" diagnostic-type lego-register-test lego-fbc-test
   lego-fb-test lego-status
;


: lego-blink-screen
   lego-video-off 20 ms lego-video-on
;


external

: set-resolution
	$find if
		execute
	then

	lego-init-hc
	(set-fbconfiguration

	(confused? @ if
		sense-code
		(set-fbconfiguration
	then

	lego-sync-reset
	lego-sync-on

	my-reset 0= if
		display-width dup dup
		encode-int " width" property
		encode-int " linebytes" property
		encode-int " awidth" property

		display-height
		encode-int " height" property

		8	encode-int " depth" property
		/vmsize	encode-int " vmsize" property
		dblbuf?	encode-int " dblbuf" property
	then
;


: set-resolution-ext
	$find if
		execute
	then

	-1 to my-reset

	lego-init-hc
	(set-fbconfiguration

	(confused? @ if
	      sense-code (set-fbconfiguration
	then

	lego-sync-reset
	lego-sync-on

	0 to my-reset

	display-width	data-space l!
	display-height	data-space 4 + l!
	8		data-space 8 + l!
	display-width	data-space c + l!
	acceleration	data-space 10 + l!
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
   -1 to my-reset fcode-revision 2000 >= if
      strap-value 94 thc! delay-value 90 thc! lego-erase-screen
      monitor-string set-resolution
   then  lego-video-on 0 to my-reset
;


: lego-draw-char         fbc-busy-wait fb8-draw-character ;
: lego-toggle-cursor     fbc-busy-wait fb8-toggle-cursor ;
: lego-invert-screen     fbc-busy-wait fb8-invert-screen ;
: lego-insert-characters fbc-busy-wait fb8-insert-characters ;
: lego-delete-characters fbc-busy-wait fb8-delete-characters ;

: dfb-delete-lines       fbc-busy-wait fb8-delete-lines ;
: dfb-insert-lines       fbc-busy-wait fb8-insert-lines ;
: dfb-erase-screen       fbc-busy-wait fb8-erase-screen ;


external

: reinstall-console
	display-width display-height
	over char-width / over char-height /
	fb8-install

	['] lego-draw-logo to draw-logo
	['] lego-blink-screen to blink-screen
	['] lego-reset-screen to reset-screen

	acceleration if
		['] lego-delete-lines to delete-lines
		['] lego-insert-lines to insert-lines
		['] lego-erase-screen to erase-screen
	then
;

headers


: lego-install
   fb-map init-blit-reg default-font set-font fb-addr to frame-buffer-adr
   fb-addr encode-int " address" property
   my-args dup 0<> if
      set-resolution
   else
      2drop
   then  reinstall-console lego-video-on
;


: lego-remove
	lego-video-off
	fb-unmap
	-1 to frame-buffer-adr
;


: legoqs-probe
	my-address legosc-address !

	fhc-thc-map
	fbc-map
	alt-map
	strap-value

	94 thc!

	100 ms delay-value

	90 thc!
	fhc @ dup 18 rshift f and 7 swap - to sense-id-value
	14 rshift f and dup encode-int " chiprev" my-attribute to chip-rev

	lego-sync-reset
	lego-sync-on

	" 47250000,54000000,64125000,74250000,81000000,84375000,94500000,106500000,108000000,118250000,135000000,154000000,162000000,189000000,193000000,216000000,268500000" encode-string " oscillators" my-attribute

	data-space encode-int " global-data" property

	/frame encode-int " fbmapped" property
	strap-value 8 and dup to ppc 0= if
		4 to ppc
	then

	sense-code set-resolution

	lego-init-dac

	my-address my-space 1000000 reg 5 0 intr

	['] lego-install is-install
	['] lego-remove is-remove
	['] lego-selftest is-selftest
;


legoqs-probe

end0

