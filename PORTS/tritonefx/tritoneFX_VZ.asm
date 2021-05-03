;******************************************************************
;Tritone FX
;3ch beeper engine by utz 09'2015
;original Tritone code by Shiru 03'2011
;******************************************************************


	org $8000


	call	$01c9		; VZ ROM CLS
	ld	hl, MSG1	; Print MENU
	call	$28a7		; VZ ROM Print string.
	ld	hl, MSG3	; Print MENU
	call	$28a7		; VZ ROM Print string.



	di
init
	ei			;detect kempston
	halt
	in a,($1f)
	inc a
	jr nz,_skip
	ld (maskKempston),a
_skip	
	di
	exx
	push hl			;preserve HL' for return to BASIC
	ld (oldSP),sp
	ld hl,musicdata
	ld (seqpntr),hl

;******************************************************************
rdseq
seqpntr equ $+1
	ld sp,0
	xor a
	pop de			;pattern pointer to DE
	or d
	ld (seqpntr),sp
	jr nz,rdptn0
	
	;jp exit		;uncomment to disable looping

	ld sp,loop
	jr rdseq+3

exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret

;******************************************************************
rdptn0
	ld (patpntr),de	
rdptn
;	in a,($1f)		;read joystick
maskKempston equ $+1
	and $1f
	ld c,a
	in a,($fe)		;read kbd
	cpl
	or c
	and $1f
	jr nz,exit


patpntr equ $+1			;fetch pointer to pattern data
	ld sp,0

	pop hl			;speed+noise+duty1
	or l			;A is already 0 from before	
	jp z,rdseq
	
	xor a
	bit 7,h
	jr z,noNoise
	ld a,7			;rlca
noNoise
	ld (noise),a
	
	ld a,h
	and $7f
	ld c,a			;timer			
	ld b,0
	
	ld a,l
	ld (duty1),a
	
	pop hl			;duties
	ld a,h
	ld (duty2),a
	ld a,l
	ld (duty3),a
	
	pop de			;freq3
	
	exx 
	
	pop bc			;freq2	
	pop de			;freq1
	pop hl			;fx table pointer

	ld (patpntr),sp		;preserve data pointer
	
	ld sp,hl		;fx table pointer to sp
	ld hl,0			;reset add counters
	ld ix,0
	ld iy,0
	
	exx
	
	ld a,32

	;HL - add counter ch1
	;DE - base val ch1
	;IX - add counter ch2
	;BC - base val ch2
	;IY - add counter ch2
	;DE' - base val ch2
	;CB' - timer
	;HL' - method jump pointer
	;SP - method table pointer

;******************************************************************
play
	exx		;4
	nop		;4
;	out ($fe),a	;11---ch2: 73t
	and 33
	ld (26624),a


	ld a,0		;7	;waste time	

	add hl,de	;11	;update counter ch1
	ld a,h		;4
noise
	nop		;4	;rlca = $07
	ld h,a		;4
	
duty1 equ $+1
	cp $80		;7
	sbc a,a		;4
;	and $10		;7
;	out ($fe),a	;11---ch3: 59t
	and 33
	ld (26624),a
	
	add ix,bc	;15	;update counter ch2
	ld a,ixh	;8
duty2 equ $+1
	cp $80		;7
	sbc a,a		;4
;	and $10		;7
;	out ($fe),a	;11---ch1: 52t

	and 33
	ld (26624),a
	
	exx		;4
	
	add iy,de	;11	;update counter ch3
	ld a,iyh	;8
duty3 equ $+1
	cp $80		;7
	sbc a,a		;4
;	and $10		;7
	and 33
	
	djnz play	;13
			;184
;******************************************************************
	pop hl			;get fx jump pointer
	jp (hl)

fxNone				;no effect
	dec sp			;waste some time to prevent slowdowns when actual fx are triggered
	inc sp
	dec c
	jp nz,play
	
	jp rdptn	


fxStop				;stop fx table execution
	dec sp
	dec sp		
	dec c
	jp nz,play
	jp rdptn

fxJump				;jump to another fx table position (e.g. loop or jump to another fx table)
	pop hl
	ld sp,hl
	dec c
	jp nz,play
	jp rdptn
	
fxSetFCh1
	dec c
	exx
	pop de
	jp nz,play+1
	jp rdptn
	
fxSetFCh1Cont
	exx
	pop de
	exx
	pop hl
	jp (hl)

fxSetFCh2
	dec c
	exx
	pop bc
	jp nz,play+1
	jp rdptn
	
fxSetFCh2Cont
	exx
	pop bc
	exx
	pop hl
	jp (hl)

fxSetFCh3
	pop de
	dec c
	jp nz,play
	jp rdptn
	
fxSetFCh3Cont
	pop de
	pop hl
	jp (hl)

fxSetFCh12
	dec c
	exx
	pop de
	pop bc
	jp nz,play+1
	jp rdptn
	
fxSetFCh12Cont
	exx
	pop de
	pop bc
	exx
	pop hl
	jp (hl)

fxSetFCh13
	exx
	pop de
	exx
	pop de
	dec c
	jp nz,play
	jp rdptn
	
fxSetFCh13Cont
	exx
	pop de
	exx
	pop de
	pop hl
	jp (hl)

fxSetFCh123
	exx
	pop de
	pop bc
	exx
	pop de
	dec c
	jp nz,play
	jp rdptn
	
fxSetFCh123Cont
	exx
	pop de
	pop bc
	exx
	pop de
	pop hl
	jp (hl)

fxSetFCh23
	exx
	pop bc
	exx
	pop de
	dec c
	jp nz,play
	jp rdptn
	
fxSetFCh23Cont
	exx
	pop bc
	exx
	pop de
	pop hl
	jp (hl)

fxSetDCh1
	ex af,af'
	pop af
	ld (duty1),a
	ex af,af'
	dec c
	jp nz,play
	jp rdptn

fxSetDCh2
	ex af,af'
	pop af
	ld (duty2),a
	ex af,af'
	dec c
	jp nz,play
	jp rdptn

fxSetDCh3
	ex af,af'
	pop af
	ld (duty3),a
	ex af,af'
	dec c
	jp nz,play
	jp rdptn

fxSetDCh12
	ex af,af'
	pop hl
	ld a,h
	ld (duty1),a
	ld a,l
	ld (duty2),a
	ex af,af'
	dec c
	jp nz,play
	jp rdptn

fxSetDCh13
	ex af,af'
	pop hl
	ld a,h
	ld (duty1),a
	ld a,l
	ld (duty3),a
	ex af,af'
	dec c
	jp nz,play
	jp rdptn

fxSetDCh123
	ex af,af'
	pop hl
	ld a,h
	ld (duty1),a
	ld a,l
	ld (duty2),a
	pop af
	ld (duty3),a
	ex af,af'
	dec c
	jp nz,play
	jp rdptn

fxSetDCh23
	ex af,af'
	pop hl
	ld a,h
	ld (duty2),a
	ld a,l
	ld (duty3),a
	ex af,af'
	dec c
	jp nz,play
	jp rdptn
	
fxStopNoise
	dec c
	ex af,af'
	xor a
	ld (noise),a
	exx
	ld d,a
	ld e,a
	ld h,a
	ld l,a
	ex af,af'
	jp nz,play+1
	jp rdptn

fxStopNoiseSetFCh1
	ex af,af'
	xor a
	ld (noise),a
	ex af,af'
	dec c
	exx
	pop de
	jp nz,play+1
	jp rdptn

fxStartNoiseSetFCh1
	ex af,af'
	ld a,7
	ld (noise),a
	ex af,af'
	dec c
	exx
	pop de
	jp nz,play+1
	jp rdptn
	
fxStopNoiseCont
	ex af,af'
	xor a
	ld (noise),a
	ex af,af'
	exx
	ld d,a
	ld e,a
	ld h,a
	ld l,a
	exx
	pop hl
	jp (hl)
	
fxStartNoiseSetFCh1Cont
	ex af,af'
	ld a,7
	ld (noise),a
	ex af,af'
	exx
	pop de
	exx
	pop hl
	jp (hl)
	

fxStartNoiseCont

fxCutCh1
	dec c
	exx
	ld de,0
	ld h,d
	ld l,d
	jp nz,play+1
	jp rdptn

fxCutCh2
	dec c
	exx
	ld bc,0
	ld ix,0
	jp nz,play+1
	jp rdptn

fxCutCh3
	dec c
	ld de,0
	ld iy,0
	jp nz,play
	jp rdptn



MSG1	db "TRITONE FX ENGINE. BY UTZ", $0d
MSG2	db "VZ CONVERSION BY BUSHY.",$0d,0
MSG3	db "SONG: TRITONE FX DEMO.",$0d
	db "AUG 2019.",$0d
	db 0,0,0


musicdata


	dw intro
	dw introb
	dw ptn00
	dw ptn01

	dw ptn02
	dw ptn02
	dw ptn03
	dw ptn02
loop	
	dw ptn04
	dw ptn04
	dw ptn05
	dw ptn06	
	dw 0

;example note/modulator frequencies

; 	dw $80, $88, $90, $98, $A1, $AB, $B5, $C0, $CB, $D7, $E4, $F2
; 	dw $100, $10F, $11F, $130, $143, $156, $16A, $180, $196, $1AF, $1C8, $1E3
; 	dw $200, $21E, $23F, $261, $285, $2AB, $2D4, $2FF, $32D, $35D, $390, $3C7
; 	dw $400, $43D, $47D, $4C2, $50A, $557, $5A8, $5FE, $65A, $6BA, $721, $78D
; 	dw $800, $87A, $8FB, $984, $A14, $AAE, $B50, $BFD, $CB3, $D74, $E41, $F1A
; 	dw $1000, $10F4, $11F6, $1307, $1429, $155C, $16A1, $17F9, $1966, $1AE9, $1C82, $1E34
; 	dw $2000, $21E7, $23EB, $260E, $2851, $2AB7, $2D41, $2FF2, $32CC, $35D1, $3905, $3C68
; 	dw $4000, $43CE, $47D6, $4C1C, $50A3, $556E, $5A83, $5FE4, $6598, $6BA3, $7209, $78D1
; 	dw $8000, $879D, $8FAD, $9838, $A145, $AADC, $B505, $BFC9, $CB30, $D745, $E412, $F1A2

;some noise frequency values:
;	dw $cd44, $0cba, $0744, $099a, $188b, $18bb, $dd55, $ed66, $c400, $b400, $0143, $c111	
	
	
	;speed+noiseflag/duty1,duty2/3,freq3,freq2,freq1,fx
	
intro
	dw $1880,$8080,$0800,$0000,$0000,fxtab2
	dw $1880,$8080,$0000,$0000,$0000,fxtab1
	dw $9880,$8080,$0800,$0000,$cd44,fxtab4
	dw $1880,$8080,$0000,$0000,$0000,fxtab1
	
	dw $1880,$8080,$0800,$0000,$0000,fxtab2
	dw $1880,$8080,$0000,$0000,$0000,fxtab1
	dw $9880,$8080,$0800,$0000,$cd44,fxtab4
	dw $1880,$8080,$0000,$0000,$0000,fxtab1
	
	dw $1880,$8080,$0800,$0000,$0000,fxtab2
	dw $1880,$8080,$0000,$0000,$0000,fxtab1
	dw $9880,$8080,$0800,$0000,$cd44,fxtab4
	dw $1880,$8080,$0000,$0000,$0000,fxtab1
	
	dw $1880,$8080,$0800,$0000,$0000,fxtab2
	dw $1880,$8080,$0000,$0000,$0000,fxtab1
	dw $9880,$8080,$0800,$0000,$cd44,fxtab4
	dw $9820,$8080,$0000,$0000,$188b,fxtab3
	db 0
	
introb
	dw $1880,$8080,$0800,$0000,$0000,fxtab2
	dw $1880,$8080,$0000,$0000,$0000,fxtab1
	dw $9880,$8080,$0800,$0000,$cd44,fxtab4
	dw $1880,$8080,$0000,$0000,$0000,fxtab1
	
	dw $1880,$8080,$0800,$0000,$0000,fxtab2
	dw $1880,$8080,$0000,$0000,$0000,fxtab1
	dw $9880,$8080,$0800,$0000,$cd44,fxtab4
	dw $1880,$8080,$0000,$0000,$0000,fxtab1
	
	dw $1880,$8080,$0800,$0000,$0000,fxtab2
	dw $1880,$8080,$0000,$0000,$0000,fxtab1
	dw $9880,$8080,$0800,$0000,$cd44,fxtab4
	dw $1880,$8080,$0000,$0000,$0000,fxtab1
	
	dw $1880,$8080,$0800,$0000,$0000,fxtab2
	dw $1880,$8080,$0000,$0000,$0000,fxtab1
	dw $9880,$8080,$0800,$0000,$cd44,fxtab4
	dw $9820,$8080,$0000,$0080,$188b,fxtab3
	db 0
	
ptn00
	dw $1880,$8080,$0800,$0000,$0000,fxtab2
	dw $1880,$8080,$0000,$0080,$0200,fxtab1
	dw $9880,$8080,$0800,$0000,$cd44,fxtab4
	dw $1880,$8080,$0000,$0080,$0200,fxtab1
	
	dw $1880,$8080,$0800,$0000,$0000,fxtab2
	dw $1880,$8080,$0000,$0080,$0200,fxtab1
	dw $9880,$8080,$0800,$0000,$cd44,fxtab4
	dw $1880,$8080,$0000,$0080,$0200,fxtab1
	
	dw $1880,$8080,$0800,$0000,$0000,fxtab2
	dw $1880,$8080,$0000,$0080,$0200,fxtab1
	dw $9880,$8080,$0800,$0000,$cd44,fxtab4
	dw $1880,$8080,$0000,$0080,$0200,fxtab1
	
	dw $1880,$8080,$0800,$0000,$0000,fxtab2
	dw $1880,$8080,$0000,$0080,$0200,fxtab1
	dw $9880,$8080,$0800,$0000,$cd44,fxtab4
	dw $9820,$8080,$0000,$0080,$188b,fxtab3
	db 0
	
ptn01
	dw $1880,$8080,$0800,$0000,$0000,fxtab2
	dw $1880,$8080,$0000,$0080,$0200,fxtab1
	dw $9880,$8080,$0800,$0000,$cd44,fxtab4
	dw $1880,$8080,$0000,$0080,$0200,fxtab1
	
	dw $1880,$8080,$0800,$0000,$0000,fxtab2
	dw $1880,$8080,$0000,$0080,$0200,fxtab1
	dw $9880,$8080,$0800,$0000,$cd44,fxtab4
	dw $1880,$8080,$0000,$0080,$0200,fxtab1

	dw $1880,$8080,$0000,$0400,$0000,fxtab5
	dw $1880,$4080,$0000,$0400,$0000,fxtab5
	dw $1880,$2080,$0000,$0400,$0000,fxtab5
	dw $1880,$1080,$0000,$0400,$0000,fxtab5
	
	dw $1880,$0880,$0000,$0400,$0000,fxtab5
	dw $1880,$1080,$0000,$0400,$0000,fxtab5
	dw $1880,$2080,$0000,$0400,$0000,fxtab5
	dw $1880,$4080,$0000,$0400,$0000,fxtab5
	db 0
	
ptn02
	dw $1880,$8080,$0800,$0400,$0000,fxtab6
	dw $1880,$4080,$0080,$0400,$0000,fxtab5
	dw $9880,$2080,$0800,$0000,$cd44,fxtab7
	dw $1880,$1080,$0080,$0400,$0000,fxtab5
	
	dw $1880,$0880,$0800,$0400,$0000,fxtab6
	dw $1880,$1080,$0080,$0400,$0000,fxtab5
	dw $9880,$2080,$0800,$0000,$cd44,fxtab7
	dw $1880,$4080,$0080,$0400,$0000,fxtab5
	
	dw $1880,$8080,$0800,$0400,$0000,fxtab6
	dw $1880,$4080,$0080,$0400,$0000,fxtab5
	dw $9880,$2080,$0800,$0000,$cd44,fxtab7
	dw $1880,$1080,$0080,$0400,$0000,fxtab5
	
	dw $1880,$0880,$0800,$0400,$0000,fxtab6
	dw $1880,$1080,$0080,$0400,$0000,fxtab5
	dw $9880,$2080,$0800,$0000,$cd44,fxtab7
	dw $9820,$4080,$0080,$0400,$188b,fxtab8
	db 0
	

ptn03
	dw $1880,$8080,$0800,$0557,$0000,fxtab6
	dw $1880,$4080,$00ab,$0557,$0000,fxtab5
	dw $9880,$2080,$0800,$0557,$cd44,fxtab7
	dw $1880,$1080,$00ab,$0557,$0000,fxtab15
	
	dw $1880,$0880,$0800,$0557,$0000,fxtab16
	dw $1880,$1080,$00ab,$0557,$0000,fxtab15
	dw $9880,$2080,$0800,$0557,$cd44,fxtab17
	dw $1880,$4080,$00ab,$0557,$0000,fxtab15
	
	dw $1880,$8080,$0800,$0557,$0000,fxtab16
	dw $1880,$4080,$00ab,$0557,$0000,fxtab15
	dw $9880,$2080,$0800,$0557,$cd44,fxtab17
	dw $1880,$1080,$00ab,$0557,$0000,fxtab15
	
	dw $1880,$0880,$0800,$0557,$0000,fxtab16
	dw $1880,$1080,$00ab,$0557,$0000,fxtab15
	dw $9880,$2080,$0800,$0557,$cd44,fxtab17
	dw $9820,$4080,$00ab,$0557,$188b,fxtab18
	db 0


ptn04
	dw $1880,$8080,$0800,$0400,$0800,fxtab6
	dw $1880,$4080,$0080,$0400,$0800,fxtab5
	dw $9880,$2080,$0800,$0000,$cd44,fxtab7
	dw $1880,$1080,$0080,$0400,$0800,fxtab5
	
	dw $1880,$0880,$0800,$0400,$0000,fxtab6
	dw $1880,$1080,$0080,$0400,$0000,fxtab5
	dw $9880,$2080,$0800,$0000,$cd44,fxtab7
	dw $1880,$4080,$0080,$0400,$0800,fxtab5
	
	dw $1880,$8080,$0800,$0400,$0aae,fxtab6
	dw $1880,$4080,$0080,$0400,$0000,fxtab5
	dw $9880,$2080,$0800,$0000,$cd44,fxtab7
	dw $1880,$1080,$0080,$0400,$0984,fxtab5
	
	dw $1880,$0880,$0800,$0400,$08fb,fxtab6
	dw $1880,$1080,$0080,$0400,$0984,fxtab5
	dw $9880,$2080,$0800,$0000,$cd44,fxtab7
	dw $9820,$4080,$0080,$0400,$188b,fxtab8
	db 0
	

ptn05
	dw $1880,$8080,$0800,$0557,$0aae,fxtab6
	dw $1880,$4080,$00ab,$0557,$0aae,fxtab5
	dw $9880,$2080,$0800,$0aae,$cd44,fxtab7
	dw $1880,$1080,$00ab,$0557,$0000,fxtab15
	
	dw $1880,$0880,$0800,$0557,$0000,fxtab16
	dw $1880,$1080,$00ab,$0557,$0000,fxtab15
	dw $9880,$2080,$0800,$0557,$cd44,fxtab17
	dw $1880,$4080,$00ab,$0557,$0984,fxtab15
	
	dw $1880,$8080,$0800,$0557,$0b50,fxtab16
	dw $1880,$4080,$00ab,$0557,$0000,fxtab15
	dw $9880,$2080,$0800,$0557,$cd44,fxtab17
	dw $1880,$1080,$00ab,$0557,$0b50,fxtab15
	
	dw $1880,$0880,$0800,$0557,$0aae,fxtab16
	dw $1880,$1080,$00ab,$0557,$0984,fxtab15
	dw $9880,$2080,$0800,$0557,$cd44,fxtab17
	dw $9820,$4080,$00ab,$0557,$188b,fxtab18
	db 0

ptn06
	dw $1880,$8080,$0800,$0400,$0800,fxtab6
	dw $1880,$4080,$0080,$0400,$0800,fxtab5
	dw $9880,$2080,$0800,$0000,$cd44,fxtab7
	dw $1880,$1080,$0080,$0400,$0000,fxtab5
	
	dw $1880,$0880,$0800,$0400,$0000,fxtab6
	dw $1880,$1080,$0080,$0400,$0000,fxtab5
	dw $9880,$2080,$0800,$0000,$cd44,fxtab7
	dw $1880,$4080,$0080,$0400,$0000,fxtab5
	
	dw $1880,$8080,$0800,$0400,$0000,fxtab6
	dw $1880,$4080,$0080,$0400,$0000,fxtab5
	dw $9880,$2080,$0800,$0000,$cd44,fxtab7
	dw $1880,$1080,$0080,$0400,$0000,fxtab5
	
	dw $1880,$0880,$0800,$0400,$0000,fxtab6
	dw $1880,$1080,$0080,$0400,$0000,fxtab5
	dw $9880,$2080,$0800,$0000,$cd44,fxtab7
	dw $9820,$4080,$0080,$0400,$188b,fxtab8
	db 0


fxtab15
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxSetFCh2,$65A
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxSetFCh2,$800
	dw fxNone
	dw fxNone
	dw fxNone
fx15lp
	dw fxSetFCh2,$984
	dw fxNone
	dw fxNone
	dw fxNone
fx15lp2
	dw fxSetFCh2,$557
	dw fxJump,fxtab15+2



fxtab5
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxSetFCh2,$4C2
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxSetFCh2,$5FE
	dw fxNone
	dw fxNone
	dw fxNone
fx5lp
	dw fxSetFCh2,$721
	dw fxNone
	dw fxNone
	dw fxNone
fx5lp2
	dw fxSetFCh2,$400
	dw fxJump,fxtab5+2

fxtab16
	dw fxSetFCh3,$400
	dw fxSetFCh3,$200
	dw fxSetFCh3,$100
	dw fxSetFCh23,$65a,$c0
	dw fxSetFCh3,$80
	dw fxNone
	dw fxSetFCh3,$40
	dw fxSetFCh2,$800
	dw fxNone
	dw fxCutCh3
	dw fxJump,fx15lp



fxtab6
	dw fxSetFCh3,$400
	dw fxSetFCh3,$200
	dw fxSetFCh3,$100
	dw fxSetFCh23,$4C2,$c0
	dw fxSetFCh3,$80
	dw fxNone
	dw fxSetFCh3,$40
	dw fxSetFCh2,$5FE
	dw fxNone
	dw fxCutCh3
	dw fxJump,fx5lp

fxtab17
	dw fxSetFCh3,$400
	dw fxSetFCh3,$200
	dw fxSetFCh3,$100
	dw fxSetFCh23,$65a,$c0
	dw fxSetFCh3,$80
	dw fxSetDCh1,$4000
	dw fxSetFCh3,$40
	dw fxSetFCh2,$800
	dw fxSetDCh1,$2000
	dw fxCutCh3
	dw fxSetDCh1,$1000
	dw fxSetFCh2,$984
	dw fxSetDCh1,$0800
	dw fxStopNoise
	dw fxJump,fx15lp2


fxtab7
	dw fxSetFCh3,$400
	dw fxSetFCh3,$200
	dw fxSetFCh3,$100
	dw fxSetFCh23,$4c2,$c0
	dw fxSetFCh3,$80
	dw fxSetDCh1,$4000
	dw fxSetFCh3,$40
	dw fxSetFCh2,$5FE
	dw fxSetDCh1,$2000
	dw fxCutCh3
	dw fxSetDCh1,$1000
	dw fxSetFCh2,$721
	dw fxSetDCh1,$0800
	dw fxStopNoise
	dw fxJump,fx5lp2

fxtab18
	dw fxSetFCh3,$400
	dw fxSetFCh3,$200
	dw fxSetFCh3,$100
	dw fxSetFCh23,$65a,$c0
	dw fxSetFCh3,$80
	dw fxStopNoise
	dw fxSetFCh3,$40
	dw fxSetFCh2,$800
	dw fxNone
	dw fxCutCh3
	dw fxStartNoiseSetFCh1,$188b
	dw fxSetFCh2,$984
	dw fxNone
	dw fxStopNoise
	dw fxJump,fx15lp2

fxtab8
	dw fxSetFCh3,$400
	dw fxSetFCh3,$200
	dw fxSetFCh3,$100
	dw fxSetFCh23,$4c2,$c0
	dw fxSetFCh3,$80
	dw fxStopNoise
	dw fxSetFCh3,$40
	dw fxSetFCh2,$5FE
	dw fxNone
	dw fxCutCh3
	dw fxStartNoiseSetFCh1,$188b
	dw fxSetFCh2,$721
	dw fxNone
	dw fxStopNoise
	dw fxJump,fx5lp2


fxtab4
	dw fxSetFCh3,$400
	dw fxSetFCh3,$200
	dw fxSetFCh3,$100
	dw fxSetFCh3,$c0
	dw fxSetFCh3,$80
	dw fxSetDCh1,$4000
	dw fxSetFCh3,$40
	dw fxNone
	dw fxSetDCh1,$2000
	dw fxCutCh3
	dw fxSetDCh1,$1000
	dw fxNone
	dw fxNone
	dw fxSetDCh1,$0800
	dw fxStopNoise
	dw fxStop


fxtab3
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxStopNoise
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxNone
	dw fxStartNoiseSetFCh1,$188b
	dw fxJump,fxtab3+2
	
	
fxtab1
	dw fxStop
	
fxtab2	;drum
	;dw fxSetFCh2,$800
	dw fxSetFCh3,$400
	dw fxSetFCh3,$200
	dw fxSetFCh3,$100
	dw fxSetFCh3,$c0
	dw fxSetFCh3,$80
	dw fxNone
	dw fxSetFCh3,$40
	dw fxNone
	dw fxNone
	dw fxCutCh3
	dw fxStop
