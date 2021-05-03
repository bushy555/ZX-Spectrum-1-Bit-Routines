	.ORG	$8000


#define db .byte
#define dw .word


;4-channel music generator ZX-10
;Original code JDeak (c)1989 Bytepack Bratislava
;Modified 1tracker version by Shiru 04'12

begin:
	ld hl,musicData
	call play
	ret				

play:
	di
	ld a,(hl)
	inc hl
	ld (speed+1),a
	dec a
	ld (speedCnt),a
	xor a
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (ch1order),de
	ld (de),a
	ld (sc1+3),a
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (ch2order),de
	ld (de),a
	ld (sc2+3),a
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (ch3order),de
	ld (de),a
	ld (sc3+3),a
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld (ch4order),de
	ld (de),a
	ld (sc4+3),a

	ld hl,adst
	ld de,sx
	ld bc,$0400
init0:
	ld (hl),c
	inc hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	djnz init0


playRow:
	ld   ix,sc1
	ld   hl,adst
	ld   de,8
	ld   b,4
decay0:
	ld   a,(hl)
	or   a
	jr   z,decay1
	dec  (hl)
	sla  (ix+3)
	set  4,(ix+3)
decay1:
	add ix,de
	inc  hl
	inc  hl
	inc  hl
	djnz decay0


	ld a,(speedCnt)
	inc a
speed:
	cp 0
	jr nz,noNextRow

	ld   ix,sc1
	ld   hl,adst
	ld   b,4
nextRow0:
	push hl
	inc  hl
	ld   e,(hl)
	inc  hl
	ld   d,(hl)
	ld   a,(de)
	inc  de
	ld   (hl),d
	dec  hl
	ld   (hl),e
	cp   $e0
	jp nz,noNextOrder

	ld   de,12
	add  hl,de
	ld   c,(hl)
	inc  hl
	ld   a,(hl)
	or a
	sbc hl,de
	push hl
	ld l,c
	ld h,a
	ld   a,(hl)
	inc  hl
	cp   (hl)
	dec  hl
	jr   nz,porder1
	;xor  a			;loop channel
	;ld   (hl),a
	;jr   porder2
	pop hl			;exit at end of the song
	pop hl
	jp keyPressed

porder1:
	inc  (hl)
porder2:
	inc  a
	ex   de,hl
	ld   l,a
	ld   h,0
	add  hl,hl
	add  hl,de
	ld   e,(hl)
	inc  hl
	ld   d,(hl)
	pop  hl
	ld   a,(de)
	inc  de
	ld   (hl),d
	dec  hl
	ld   (hl),e

noNextOrder:
	ld   c,a
	and  31
	cp 2
	jr nc,nextRow2
	or a
	jr nz,nextRow1
	pop hl
	jr nextRow4
nextRow1:
	set  4,(ix+2)
	jr nextRow3
nextRow2:
	res  4,(ix+2)
nextRow3:
	ld   e,a
	ld   d,0
	ld   hl,frq			;note
	add  hl,de
	ld   a,(hl)
	ld   (ix+1),a
	ld   a,c			;duration
	rlca
	rlca
	rlca
	rlca
	and  14
	inc  a
	pop  hl
	ld   (hl),a
	ld   (ix+3),$1f
nextRow4:
	ld   de,8
	add  ix,de
	inc  hl
	inc  hl
	inc  hl
	djnz nextRow0

	xor a
noNextRow:
	ld (speedCnt),a


	xor a
	ld a,%10111111				;+ new keyhandler
	out (1),a
	in a,(1)				;read keyboard
	cpl
	bit 6,a

//	jp   nz,keyPressed


	ld   hl,256
sc:
	exx
sc0:
	dec  c
	jp   nz,s1
sc1:
	ld   c,0
	ld   l,0
l1:
	dec  b
	jp   nz,s2
sc2:
	ld   b,0
	ld   l,0
l2:
	dec  e
	jp   nz,s3
sc3:
	ld   e,0
	ld   l,0
l3:
	dec  d
	jp   nz,s4
sc4:
	ld   d,0
	ld   l,0
l4:						;sound loop
	ld   a,l
	and $10
	sla  l

	push af
	bit 4,a
	jr z,$+$04
	ld a,$3c
	xor 33
	ld (30779), a
	ld (30779), a
	ld (30779), a
	ld (30779), a
	ld (30779), a

	nop
	nop
	pop af

	exx
	dec  hl
	ld   a,h
	or   l
	exx
	jp   nz,sc0

	push af
	bit 4,a
	jr z,$+$04
	ld a,$3c
	xor 33
	ld (30779), a
	ld (30779), a
	ld (30779), a
	ld (30779), a
	ld (30779), a
	nop
	nop
	pop af

	exx
	jp   playRow

s1:
	nop
	jp   l1
s2:
	nop
	jp   l2
s3:
	nop
	jp   l3
s4:
	nop
	jp   l4


keyPressed:
	exx
	ei
	ret


frq:
	db   0,255,241,227,214,202,191,180
	db 170,161,152,143,135,127,120,114
	db 107,101, 95, 90, 85, 80, 76, 71
	db  67, 63, 60, 57, 53, 50, 47, 45

sx:
	db   $e0

adst:
	db   0
	dw   0
	db   0
	dw   0
	db   0
	dw   0
	db   0
	dw   0
	db   0
ch1order:
	dw   0
	db   0
ch2order:
	dw   0
	db   0
ch3order:
	dw   0
	db   0
ch4order:
	dw   0

speedCnt:
	db 0

musicData:

	db $06
	dw order0
	dw order1
	dw order2
	dw order3

order0:
	dw $e100
	dw pattern0
	dw pattern1
	dw pattern0
	dw pattern2
	dw pattern3
	dw pattern1
	dw pattern1
	dw pattern4
	dw pattern0
	dw pattern1
	dw pattern0
	dw pattern2
	dw pattern3
	dw pattern1
	dw pattern1
	dw pattern5
	dw pattern6
	dw pattern1
	dw pattern6
	dw pattern7
	dw pattern8
	dw pattern1
	dw pattern1
	dw pattern9
	dw pattern6
	dw pattern1
	dw pattern6
	dw pattern7
	dw pattern8
	dw pattern1
	dw pattern1
	dw pattern10
	dw pattern2
	dw pattern1
	dw pattern2
	dw pattern11
	dw pattern12
	dw pattern1
	dw pattern1
	dw pattern13
	dw pattern2
	dw pattern1
	dw pattern2
	dw pattern11
	dw pattern14
	dw pattern1
	dw pattern1
	dw pattern15
	dw pattern7
	dw pattern1
	dw pattern7
	dw pattern16
	dw pattern17
	dw pattern1
	dw pattern1
	dw pattern18
	dw pattern7
	dw pattern1
	dw pattern7
	dw pattern16
	dw pattern19
	dw pattern1
	dw pattern1
	dw pattern20
	dw pattern21
	dw pattern1
	dw pattern21
	dw pattern22
	dw pattern12
	dw pattern1
	dw pattern1
	dw pattern23
	dw pattern21
	dw pattern1
	dw pattern21
	dw pattern22
	dw pattern24
	dw pattern1
	dw pattern1
	dw pattern25
	dw pattern21
	dw pattern1
	dw pattern21
	dw pattern22
	dw pattern12
	dw pattern1
	dw pattern1
	dw pattern23
	dw pattern0
	dw pattern1
	dw pattern0
	dw pattern26
	dw pattern27
	dw pattern1
	dw pattern1
	dw pattern28
	dw pattern29
	dw pattern30
	dw pattern31
	dw pattern1
	dw pattern32
	dw pattern33
	dw pattern34
	dw pattern35
	dw pattern36
	dw pattern37
	dw pattern1
	dw pattern38
	dw pattern39
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern40
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern41
	dw pattern1
	dw pattern1
	dw pattern42
	dw pattern39
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern43
	dw pattern44
	dw pattern45
	dw pattern46
	dw pattern47
	dw pattern48
	dw pattern33
	dw pattern8
	dw pattern49
	dw pattern50
	dw pattern51
	dw pattern52
	dw pattern53
	dw pattern54
	dw pattern55
	dw pattern56
	dw pattern43
	dw pattern44
	dw pattern45
	dw pattern46
	dw pattern57
	dw pattern58
	dw pattern33
	dw pattern8
	dw pattern49
	dw pattern50
	dw pattern51
	dw pattern52
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern12
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern17
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern60
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern61
	dw pattern1
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern60
	dw pattern17
	dw pattern12
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern62
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern17
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern63
	dw pattern64
	dw pattern65
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern66
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern61
	dw pattern1
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern60
	dw pattern17
	dw pattern59
order1:
	dw $e100
	dw pattern67
	dw pattern68
	dw pattern69
	dw pattern70
	dw pattern71
	dw pattern1
	dw pattern1
	dw pattern72
	dw pattern67
	dw pattern68
	dw pattern69
	dw pattern70
	dw pattern71
	dw pattern1
	dw pattern1
	dw pattern73
	dw pattern74
	dw pattern3
	dw pattern75
	dw pattern76
	dw pattern77
	dw pattern1
	dw pattern1
	dw pattern78
	dw pattern74
	dw pattern3
	dw pattern75
	dw pattern76
	dw pattern77
	dw pattern1
	dw pattern1
	dw pattern79
	dw pattern80
	dw pattern81
	dw pattern82
	dw pattern83
	dw pattern84
	dw pattern1
	dw pattern1
	dw pattern85
	dw pattern86
	dw pattern48
	dw pattern87
	dw pattern83
	dw pattern84
	dw pattern1
	dw pattern1
	dw pattern88
	dw pattern89
	dw pattern90
	dw pattern91
	dw pattern92
	dw pattern93
	dw pattern1
	dw pattern1
	dw pattern94
	dw pattern95
	dw pattern96
	dw pattern97
	dw pattern92
	dw pattern93
	dw pattern1
	dw pattern1
	dw pattern98
	dw pattern99
	dw pattern100
	dw pattern101
	dw pattern102
	dw pattern103
	dw pattern1
	dw pattern1
	dw pattern104
	dw pattern105
	dw pattern93
	dw pattern106
	dw pattern102
	dw pattern103
	dw pattern1
	dw pattern1
	dw pattern107
	dw pattern99
	dw pattern100
	dw pattern101
	dw pattern102
	dw pattern103
	dw pattern1
	dw pattern1
	dw pattern104
	dw pattern67
	dw pattern68
	dw pattern69
	dw pattern70
	dw pattern71
	dw pattern1
	dw pattern1
	dw pattern108
	dw pattern109
	dw pattern109
	dw pattern109
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern110
	dw pattern111
	dw pattern111
	dw pattern1
	dw pattern17
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern112
	dw pattern109
	dw pattern109
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern110
	dw pattern111
	dw pattern111
	dw pattern1
	dw pattern17
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern113
	dw pattern114
	dw pattern115
	dw pattern116
	dw pattern117
	dw pattern118
	dw pattern119
	dw pattern117
	dw pattern120
	dw pattern61
	dw pattern60
	dw pattern121
	dw pattern122
	dw pattern63
	dw pattern123
	dw pattern124
	dw pattern113
	dw pattern114
	dw pattern115
	dw pattern116
	dw pattern125
	dw pattern126
	dw pattern127
	dw pattern63
	dw pattern120
	dw pattern61
	dw pattern60
	dw pattern121
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern128
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern128
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern128
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern129
	dw pattern1
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern128
	dw pattern130
	dw pattern131
	dw pattern132
	dw pattern133
	dw pattern1
	dw pattern134
	dw pattern1
	dw pattern135
	dw pattern1
	dw pattern136
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern137
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern138
	dw pattern138
	dw pattern138
	dw pattern138
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern129
	dw pattern1
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern128
	dw pattern130
	dw pattern59
order2:
	dw $e100
	dw pattern140
	dw pattern141
	dw pattern31
	dw pattern1
	dw pattern142
	dw pattern143
	dw pattern144
	dw pattern145
	dw pattern146
	dw pattern141
	dw pattern31
	dw pattern1
	dw pattern147
	dw pattern143
	dw pattern144
	dw pattern148
	dw pattern149
	dw pattern150
	dw pattern151
	dw pattern1
	dw pattern152
	dw pattern153
	dw pattern154
	dw pattern155
	dw pattern156
	dw pattern150
	dw pattern151
	dw pattern1
	dw pattern157
	dw pattern153
	dw pattern154
	dw pattern158
	dw pattern159
	dw pattern160
	dw pattern161
	dw pattern12
	dw pattern162
	dw pattern163
	dw pattern164
	dw pattern165
	dw pattern166
	dw pattern160
	dw pattern161
	dw pattern1
	dw pattern162
	dw pattern163
	dw pattern164
	dw pattern167
	dw pattern168
	dw pattern169
	dw pattern170
	dw pattern17
	dw pattern171
	dw pattern163
	dw pattern172
	dw pattern173
	dw pattern174
	dw pattern169
	dw pattern170
	dw pattern1
	dw pattern171
	dw pattern163
	dw pattern172
	dw pattern175
	dw pattern176
	dw pattern177
	dw pattern178
	dw pattern12
	dw pattern179
	dw pattern130
	dw pattern128
	dw pattern180
	dw pattern181
	dw pattern177
	dw pattern178
	dw pattern1
	dw pattern179
	dw pattern130
	dw pattern128
	dw pattern182
	dw pattern183
	dw pattern177
	dw pattern178
	dw pattern12
	dw pattern179
	dw pattern130
	dw pattern128
	dw pattern180
	dw pattern184
	dw pattern185
	dw pattern186
	dw pattern1
	dw pattern187
	dw pattern188
	dw pattern144
	dw pattern189
	dw pattern190
	dw pattern191
	dw pattern191
	dw pattern192
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern193
	dw pattern194
	dw pattern194
	dw pattern195
	dw pattern1
	dw pattern1
	dw pattern196
	dw pattern1
	dw pattern190
	dw pattern191
	dw pattern191
	dw pattern192
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern193
	dw pattern194
	dw pattern194
	dw pattern195
	dw pattern1
	dw pattern1
	dw pattern196
	dw pattern1
	dw pattern197
	dw pattern198
	dw pattern199
	dw pattern200
	dw pattern200
	dw pattern198
	dw pattern199
	dw pattern200
	dw pattern201
	dw pattern202
	dw pattern203
	dw pattern201
	dw pattern201
	dw pattern202
	dw pattern203
	dw pattern201
	dw pattern197
	dw pattern198
	dw pattern199
	dw pattern200
	dw pattern200
	dw pattern198
	dw pattern199
	dw pattern200
	dw pattern201
	dw pattern202
	dw pattern203
	dw pattern201
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern129
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern204
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern164
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern172
	dw pattern1
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern164
	dw pattern204
	dw pattern205
	dw pattern206
	dw pattern206
	dw pattern207
	dw pattern208
	dw pattern209
	dw pattern209
	dw pattern209
	dw pattern210
	dw pattern211
	dw pattern212
	dw pattern212
	dw pattern213
	dw pattern213
	dw pattern213
	dw pattern213
	dw pattern214
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern77
	dw pattern1
	dw pattern1
	dw pattern1
	dw pattern172
	dw pattern1
	dw pattern1
	dw pattern59
	dw pattern1
	dw pattern1
	dw pattern164
	dw pattern204
	dw pattern59
order3:
	dw $e100
	dw pattern187
	dw pattern143
	dw pattern215
	dw pattern216
	dw pattern153
	dw pattern129
	dw pattern217
	dw pattern218
	dw pattern187
	dw pattern143
	dw pattern215
	dw pattern216
	dw pattern153
	dw pattern129
	dw pattern217
	dw pattern219
	dw pattern220
	dw pattern153
	dw pattern221
	dw pattern222
	dw pattern223
	dw pattern204
	dw pattern224
	dw pattern225
	dw pattern220
	dw pattern153
	dw pattern221
	dw pattern222
	dw pattern223
	dw pattern226
	dw pattern224
	dw pattern227
	dw pattern162
	dw pattern163
	dw pattern228
	dw pattern229
	dw pattern163
	dw pattern130
	dw pattern230
	dw pattern231
	dw pattern162
	dw pattern163
	dw pattern228
	dw pattern229
	dw pattern163
	dw pattern130
	dw pattern230
	dw pattern232
	dw pattern171
	dw pattern163
	dw pattern233
	dw pattern234
	dw pattern163
	dw pattern235
	dw pattern236
	dw pattern237
	dw pattern171
	dw pattern163
	dw pattern233
	dw pattern234
	dw pattern163
	dw pattern235
	dw pattern236
	dw pattern238
	dw pattern179
	dw pattern130
	dw pattern239
	dw pattern240
	dw pattern130
	dw pattern241
	dw pattern242
	dw pattern243
	dw pattern179
	dw pattern130
	dw pattern239
	dw pattern240
	dw pattern130
	dw pattern241
	dw pattern242
	dw pattern244
	dw pattern179
	dw pattern130
	dw pattern239
	dw pattern240
	dw pattern130
	dw pattern241
	dw pattern242
	dw pattern243
	dw pattern245
	dw pattern188
	dw pattern215
	dw pattern246
	dw pattern247
	dw pattern248
	dw pattern249
	dw pattern219
	dw pattern250
	dw pattern251
	dw pattern252
	dw pattern250
	dw pattern250
	dw pattern251
	dw pattern252
	dw pattern250
	dw pattern253
	dw pattern254
	dw pattern255
	dw pattern253
	dw pattern253
	dw pattern254
	dw pattern255
	dw pattern253
	dw pattern250
	dw pattern251
	dw pattern252
	dw pattern250
	dw pattern250
	dw pattern251
	dw pattern252
	dw pattern250
	dw pattern253
	dw pattern254
	dw pattern255
	dw pattern253
	dw pattern253
	dw pattern254
	dw pattern255
	dw pattern253
	dw pattern250
	dw pattern251
	dw pattern252
	dw pattern250
	dw pattern250
	dw pattern251
	dw pattern252
	dw pattern250
	dw pattern253
	dw pattern254
	dw pattern255
	dw pattern253
	dw pattern253
	dw pattern254
	dw pattern255
	dw pattern253
	dw pattern250
	dw pattern251
	dw pattern252
	dw pattern250
	dw pattern250
	dw pattern251
	dw pattern252
	dw pattern250
	dw pattern253
	dw pattern254
	dw pattern255
	dw pattern253
	dw pattern253
	dw pattern254
	dw pattern256
	dw pattern257
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern258
	dw pattern258
	dw pattern259
	dw pattern259
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern259
	dw pattern259
	dw pattern258
	dw pattern258
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern259
	dw pattern259
	dw pattern259
	dw pattern259
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern260
	dw pattern260
	dw pattern260
	dw pattern260
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern139
	dw pattern59

pattern0:	db $47,$00,$4a,$00,$4e,$00,$51,$00,$e0
pattern1:	db $00,$00,$00,$00,$00,$00,$00,$00,$e0
pattern2:	db $4e,$00,$51,$00,$55,$00,$58,$00,$e0
pattern3:	db $53,$00,$00,$00,$00,$00,$00,$00,$e0
pattern4:	db $4c,$4e,$4c,$00,$5a,$5b,$5d,$00,$e0
pattern5:	db $58,$56,$55,$00,$58,$56,$55,$53,$e0
pattern6:	db $49,$00,$4c,$00,$50,$00,$53,$00,$e0
pattern7:	db $50,$00,$53,$00,$57,$00,$5a,$00,$e0
pattern8:	db $55,$00,$00,$00,$00,$00,$00,$00,$e0
pattern9:	db $4e,$50,$4e,$00,$5c,$5d,$5f,$00,$e0
pattern10:	db $5a,$58,$57,$00,$5a,$58,$57,$55,$e0
pattern11:	db $55,$00,$58,$00,$5c,$00,$5f,$00,$e0
pattern12:	db $02,$00,$00,$00,$00,$00,$00,$00,$e0
pattern13:	db $13,$15,$13,$00,$1f,$1f,$1f,$00,$e0
pattern14:	db $5a,$00,$02,$00,$00,$00,$00,$00,$e0
pattern15:	db $1f,$1d,$1c,$00,$1f,$1d,$1c,$1a,$e0
pattern16:	db $57,$00,$5a,$00,$5e,$00,$5f,$00,$e0
pattern17:	db $04,$00,$00,$00,$00,$00,$00,$00,$e0
pattern18:	db $15,$17,$15,$00,$1f,$1f,$1f,$00,$e0
pattern19:	db $5c,$00,$04,$00,$00,$00,$00,$00,$e0
pattern20:	db $1f,$1f,$1e,$00,$1f,$1f,$1e,$00,$e0
pattern21:	db $46,$00,$49,$00,$4d,$00,$50,$00,$e0
pattern22:	db $4d,$00,$50,$00,$54,$00,$55,$00,$e0
pattern23:	db $0b,$0d,$0b,$00,$15,$15,$15,$00,$e0
pattern24:	db $52,$00,$06,$00,$00,$00,$00,$00,$e0
pattern25:	db $15,$15,$14,$00,$15,$15,$14,$00,$e0
pattern26:	db $4e,$00,$51,$00,$55,$00,$56,$00,$e0
pattern27:	db $53,$00,$07,$00,$00,$00,$00,$00,$e0
pattern28:	db $16,$16,$15,$00,$16,$16,$15,$00,$e0
pattern29:	db $42,$42,$00,$00,$47,$00,$4c,$00,$e0
pattern30:	db $55,$00,$56,$00,$00,$00,$56,$56,$e0
pattern31:	db $56,$00,$53,$00,$51,$00,$53,$00,$e0
pattern32:	db $53,$00,$53,$00,$53,$00,$53,$00,$e0
pattern33:	db $56,$00,$00,$00,$00,$00,$00,$00,$e0
pattern34:	db $4a,$00,$00,$00,$00,$00,$00,$00,$e0
pattern35:	db $56,$56,$56,$00,$56,$56,$56,$55,$e0
pattern36:	db $57,$37,$00,$00,$2e,$2e,$00,$00,$e0
pattern37:	db $30,$04,$00,$00,$00,$00,$00,$00,$e0
pattern38:	db $03,$04,$05,$06,$07,$08,$09,$0a,$e0
pattern39:	db $2b,$00,$00,$00,$00,$00,$00,$00,$e0
pattern40:	db $42,$42,$00,$00,$00,$00,$00,$00,$e0
pattern41:	db $44,$24,$00,$00,$00,$00,$00,$00,$e0
pattern42:	db $23,$24,$25,$26,$27,$28,$29,$2a,$e0
pattern43:	db $29,$29,$09,$00,$09,$0a,$0b,$0c,$e0
pattern44:	db $2c,$2c,$0c,$00,$00,$00,$00,$4c,$e0
pattern45:	db $0a,$00,$00,$00,$00,$00,$00,$4a,$e0
pattern46:	db $49,$00,$00,$00,$00,$00,$00,$49,$e0
pattern47:	db $35,$35,$15,$00,$00,$00,$00,$55,$e0
pattern48:	db $58,$00,$00,$00,$00,$00,$00,$00,$e0
pattern49:	db $00,$2b,$2b,$0b,$00,$00,$0b,$0c,$e0
pattern50:	db $0d,$2e,$2e,$0e,$00,$2e,$2e,$00,$e0
pattern51:	db $4e,$0c,$00,$00,$00,$00,$00,$00,$e0
pattern52:	db $4c,$0b,$00,$00,$00,$00,$00,$4b,$e0
pattern53:	db $0b,$00,$00,$00,$00,$00,$00,$4b,$e0
pattern54:	db $0e,$00,$00,$00,$00,$00,$00,$4e,$e0
pattern55:	db $0c,$00,$00,$00,$00,$00,$00,$4c,$e0
pattern56:	db $0b,$00,$00,$00,$00,$00,$00,$00,$e0
pattern57:	db $35,$33,$15,$00,$00,$00,$00,$55,$e0
pattern58:	db $5d,$00,$00,$00,$00,$00,$5f,$5d,$e0
pattern59:	db $01,$00,$00,$00,$00,$00,$00,$00,$e0
pattern60:	db $05,$00,$00,$00,$00,$00,$00,$00,$e0
pattern61:	db $07,$00,$00,$00,$00,$00,$00,$00,$e0
pattern62:	db $5d,$00,$00,$00,$00,$00,$00,$00,$e0
pattern63:	db $15,$00,$00,$00,$00,$00,$00,$00,$e0
pattern64:	db $00,$00,$00,$00,$11,$10,$0f,$0c,$e0
pattern65:	db $0b,$0a,$07,$06,$05,$00,$00,$00,$e0
pattern66:	db $10,$00,$00,$00,$01,$00,$00,$00,$e0
pattern67:	db $00,$00,$47,$00,$4a,$00,$4e,$00,$e0
pattern68:	db $51,$00,$00,$00,$00,$00,$00,$00,$e0
pattern69:	db $00,$00,$47,$00,$4e,$00,$4f,$00,$e0
pattern70:	db $4e,$00,$4c,$00,$4a,$00,$4c,$00,$e0
pattern71:	db $47,$00,$00,$00,$00,$00,$00,$00,$e0
pattern72:	db $51,$53,$55,$00,$53,$55,$56,$00,$e0
pattern73:	db $55,$56,$55,$00,$55,$53,$55,$53,$e0
pattern74:	db $00,$00,$49,$00,$4c,$00,$50,$00,$e0
pattern75:	db $00,$00,$49,$00,$50,$00,$51,$00,$e0
pattern76:	db $50,$00,$4e,$00,$4c,$00,$4e,$00,$e0
pattern77:	db $49,$00,$00,$00,$00,$00,$00,$00,$e0
pattern78:	db $53,$55,$57,$00,$55,$57,$58,$00,$e0
pattern79:	db $57,$58,$57,$00,$57,$55,$57,$55,$e0
pattern80:	db $02,$00,$0e,$00,$11,$00,$15,$00,$e0
pattern81:	db $18,$00,$02,$00,$00,$00,$00,$00,$e0
pattern82:	db $00,$00,$0e,$00,$15,$00,$16,$00,$e0
pattern83:	db $55,$00,$53,$00,$51,$00,$53,$00,$e0
pattern84:	db $4e,$00,$00,$00,$00,$00,$00,$00,$e0
pattern85:	db $58,$5a,$5c,$00,$5a,$5c,$5d,$00,$e0
pattern86:	db $00,$00,$4e,$00,$51,$00,$55,$00,$e0
pattern87:	db $00,$00,$4e,$00,$55,$00,$56,$00,$e0
pattern88:	db $5c,$5d,$5c,$00,$5c,$5a,$5c,$5a,$e0
pattern89:	db $04,$00,$10,$00,$13,$00,$17,$00,$e0
pattern90:	db $1a,$00,$04,$00,$00,$00,$00,$00,$e0
pattern91:	db $00,$00,$10,$00,$17,$00,$18,$00,$e0
pattern92:	db $57,$00,$55,$00,$53,$00,$55,$00,$e0
pattern93:	db $50,$00,$00,$00,$00,$00,$00,$00,$e0
pattern94:	db $5a,$5c,$5e,$00,$5c,$5e,$5f,$00,$e0
pattern95:	db $00,$00,$50,$00,$53,$00,$57,$00,$e0
pattern96:	db $5a,$00,$00,$00,$00,$00,$00,$00,$e0
pattern97:	db $00,$00,$50,$00,$57,$00,$58,$00,$e0
pattern98:	db $5e,$5f,$5e,$00,$5e,$5c,$5e,$00,$e0
pattern99:	db $02,$00,$06,$00,$09,$00,$0d,$00,$e0
pattern100:	db $10,$00,$02,$00,$00,$00,$00,$00,$e0
pattern101:	db $00,$00,$06,$00,$0d,$00,$0e,$00,$e0
pattern102:	db $4d,$00,$4b,$00,$49,$00,$4b,$00,$e0
pattern103:	db $46,$00,$00,$00,$00,$00,$00,$00,$e0
pattern104:	db $50,$52,$54,$00,$52,$54,$55,$00,$e0
pattern105:	db $00,$00,$46,$00,$49,$00,$4d,$00,$e0
pattern106:	db $00,$00,$46,$00,$4d,$00,$4e,$00,$e0
pattern107:	db $54,$55,$54,$00,$54,$52,$54,$00,$e0
pattern108:	db $55,$56,$55,$00,$55,$53,$55,$00,$e0
pattern109:	db $02,$00,$00,$00,$0e,$00,$00,$00,$e0
pattern110:	db $04,$00,$00,$00,$0e,$00,$00,$00,$e0
pattern111:	db $04,$00,$00,$00,$10,$00,$00,$00,$e0
pattern112:	db $13,$00,$11,$00,$0e,$00,$00,$00,$e0
pattern113:	db $02,$00,$00,$00,$03,$04,$05,$06,$e0
pattern114:	db $05,$00,$00,$00,$00,$00,$00,$01,$e0
pattern115:	db $03,$00,$00,$00,$00,$00,$00,$01,$e0
pattern116:	db $02,$00,$00,$00,$00,$00,$00,$01,$e0
pattern117:	db $0e,$00,$00,$00,$00,$00,$00,$00,$e0
pattern118:	db $11,$00,$00,$00,$00,$00,$00,$00,$e0
pattern119:	db $0f,$00,$00,$00,$00,$00,$00,$00,$e0
pattern120:	db $04,$00,$00,$00,$00,$00,$05,$06,$e0
pattern121:	db $04,$00,$00,$00,$00,$00,$15,$16,$e0
pattern122:	db $17,$00,$00,$00,$00,$00,$18,$17,$e0
pattern123:	db $0f,$11,$00,$00,$00,$00,$13,$11,$e0
pattern124:	db $04,$00,$00,$00,$00,$00,$00,$01,$e0
pattern125:	db $0e,$0c,$0e,$00,$00,$00,$16,$17,$e0
pattern126:	db $18,$00,$00,$00,$00,$00,$1a,$18,$e0
pattern127:	db $16,$00,$00,$00,$00,$00,$18,$16,$e0
pattern128:	db $29,$00,$00,$00,$00,$00,$00,$00,$e0
pattern129:	db $2e,$00,$00,$00,$00,$00,$00,$00,$e0
pattern130:	db $35,$00,$00,$00,$00,$00,$00,$00,$e0
pattern131:	db $15,$09,$00,$00,$35,$09,$00,$00,$e0
pattern132:	db $15,$09,$00,$00,$15,$09,$00,$00,$e0
pattern133:	db $00,$09,$00,$00,$15,$09,$00,$00,$e0
pattern134:	db $3a,$00,$3c,$00,$00,$00,$00,$00,$e0
pattern135:	db $3c,$00,$3d,$00,$00,$00,$00,$00,$e0
pattern136:	db $09,$00,$00,$00,$00,$00,$00,$00,$e0
pattern137:	db $1c,$00,$00,$00,$00,$00,$00,$00,$e0
pattern138:	db $55,$49,$00,$00,$55,$49,$00,$00,$e0
pattern139:	db $15,$13,$10,$11,$15,$13,$10,$11,$e0
pattern140:	db $00,$00,$47,$00,$00,$00,$4c,$00,$e0
pattern141:	db $55,$00,$58,$00,$00,$00,$5a,$58,$e0
pattern142:	db $33,$00,$00,$00,$00,$00,$33,$00,$e0
pattern143:	db $38,$00,$00,$00,$00,$00,$00,$00,$e0
pattern144:	db $2a,$00,$00,$00,$00,$00,$00,$00,$e0
pattern145:	db $35,$36,$38,$00,$38,$3a,$3b,$00,$e0
pattern146:	db $47,$00,$00,$00,$47,$00,$4c,$00,$e0
pattern147:	db $33,$00,$00,$00,$33,$00,$33,$33,$e0
pattern148:	db $3a,$38,$3a,$00,$3a,$38,$36,$35,$e0
pattern149:	db $00,$00,$00,$00,$49,$00,$4e,$00,$e0
pattern150:	db $57,$00,$5a,$00,$00,$00,$5c,$5a,$e0
pattern151:	db $58,$00,$55,$00,$53,$00,$55,$00,$e0
pattern152:	db $35,$00,$35,$00,$00,$00,$35,$00,$e0
pattern153:	db $3a,$00,$00,$00,$00,$00,$00,$00,$e0
pattern154:	db $2c,$00,$00,$00,$00,$00,$00,$00,$e0
pattern155:	db $37,$38,$3a,$00,$3a,$3c,$3d,$00,$e0
pattern156:	db $49,$00,$00,$00,$49,$00,$4e,$00,$e0
pattern157:	db $35,$38,$3c,$3f,$33,$37,$3a,$3d,$e0
pattern158:	db $3c,$3a,$3c,$00,$3c,$3a,$38,$37,$e0
pattern159:	db $00,$00,$00,$00,$4e,$00,$53,$00,$e0
pattern160:	db $5c,$00,$5f,$00,$00,$00,$5f,$5f,$e0
pattern161:	db $5d,$00,$5a,$00,$58,$00,$5a,$00,$e0
pattern162:	db $3a,$00,$3a,$00,$3a,$00,$3a,$00,$e0
pattern163:	db $3f,$00,$00,$00,$00,$00,$00,$00,$e0
pattern164:	db $31,$00,$00,$00,$00,$00,$00,$00,$e0
pattern165:	db $3c,$3d,$3f,$00,$3f,$3f,$3f,$00,$e0
pattern166:	db $4e,$00,$00,$00,$4e,$00,$53,$00,$e0
pattern167:	db $3f,$3f,$3f,$00,$3f,$3f,$3d,$3c,$e0
pattern168:	db $00,$00,$00,$00,$50,$00,$55,$00,$e0
pattern169:	db $5e,$00,$5f,$00,$00,$00,$5f,$5f,$e0
pattern170:	db $5f,$00,$5c,$00,$5a,$00,$5c,$00,$e0
pattern171:	db $3c,$00,$3c,$00,$3c,$00,$3c,$00,$e0
pattern172:	db $33,$00,$00,$00,$00,$00,$00,$00,$e0
pattern173:	db $3e,$3f,$3f,$00,$3f,$3f,$3f,$00,$e0
pattern174:	db $50,$00,$00,$00,$50,$00,$55,$00,$e0
pattern175:	db $3f,$3f,$3f,$00,$3f,$3f,$3f,$3e,$e0
pattern176:	db $51,$00,$00,$00,$46,$00,$4b,$00,$e0
pattern177:	db $54,$00,$55,$00,$00,$00,$55,$55,$e0
pattern178:	db $55,$00,$52,$00,$50,$00,$52,$00,$e0
pattern179:	db $32,$00,$32,$00,$32,$00,$32,$00,$e0
pattern180:	db $34,$35,$35,$00,$35,$35,$35,$00,$e0
pattern181:	db $46,$00,$00,$00,$46,$00,$4b,$00,$e0
pattern182	db $35,$35,$35,$00,$35,$35,$35,$34,$e0
pattern183:	db $00,$00,$00,$00,$46,$00,$4b,$00,$e0
pattern184:	db $07,$00,$00,$00,$07,$00,$0c,$00,$e0
pattern185:	db $15,$00,$16,$00,$00,$00,$16,$16,$e0
pattern186:	db $16,$00,$13,$00,$11,$00,$13,$00,$e0
pattern187:	db $33,$00,$33,$00,$33,$00,$33,$00,$e0
pattern188:	db $36,$00,$00,$00,$00,$00,$00,$00,$e0
pattern189:	db $36,$36,$36,$00,$36,$36,$36,$35,$e0
pattern190:	db $0e,$01,$0e,$01,$0e,$00,$02,$00,$e0
pattern191:	db $0e,$00,$02,$00,$0e,$00,$02,$00,$e0
pattern192:	db $02,$00,$0e,$00,$02,$00,$0e,$00,$e0
pattern193:	db $10,$01,$10,$01,$10,$00,$04,$00,$e0
pattern194:	db $10,$00,$04,$00,$10,$00,$04,$00,$e0
pattern195:	db $04,$00,$10,$00,$04,$00,$10,$00,$e0
pattern196:	db $00,$00,$00,$00,$3a,$00,$30,$00,$e0
pattern197:	db $22,$00,$2e,$00,$22,$2e,$00,$38,$e0
pattern198:	db $25,$31,$00,$3d,$25,$31,$00,$3b,$e0
pattern199:	db $23,$2f,$00,$3b,$23,$2f,$00,$39,$e0
pattern200:	db $22,$2e,$00,$3a,$22,$2e,$00,$38,$e0
pattern201:	db $24,$30,$3c,$30,$24,$30,$3a,$30,$e0
pattern202:	db $27,$33,$3f,$33,$27,$33,$3d,$33,$e0
pattern203:	db $25,$31,$3d,$31,$25,$31,$3b,$31,$e0
pattern204:	db $30,$00,$00,$00,$00,$00,$00,$00,$e0
pattern205:	db $35,$3f,$3c,$3d,$15,$3f,$3c,$3d,$e0
pattern206:	db $35,$3f,$3c,$3d,$35,$3f,$3c,$3d,$e0
pattern207:	db $00,$00,$00,$00,$00,$39,$38,$37,$e0
pattern208:	db $36,$35,$33,$30,$31,$35,$33,$30,$e0
pattern209:	db $31,$35,$33,$30,$31,$35,$33,$30,$e0
pattern210:	db $15,$1f,$1c,$1d,$15,$1f,$1c,$1d,$e0
pattern211:	db $15,$1f,$1c,$00,$1c,$1f,$1c,$1d,$e0
pattern212:	db $1c,$1f,$1c,$1d,$1c,$1f,$1c,$1d,$e0
pattern213:	db $35,$3f,$3c,$31,$35,$3f,$3c,$31,$e0
pattern214:	db $15,$13,$11,$00,$00,$00,$00,$00,$e0
pattern215:	db $27,$00,$27,$00,$27,$00,$27,$00,$e0
pattern216:	db $3d,$38,$33,$38,$3d,$38,$33,$38,$e0
pattern217:	db $2f,$00,$00,$00,$2e,$00,$2c,$00,$e0
pattern218:	db $29,$2a,$2c,$00,$2c,$2e,$2f,$00,$e0
pattern219:	db $2e,$2c,$2e,$00,$2e,$2c,$2a,$29,$e0
pattern220:	db $35,$00,$35,$00,$35,$00,$35,$00,$e0
pattern221:	db $29,$00,$29,$00,$29,$00,$29,$00,$e0
pattern222:	db $3f,$3a,$35,$3a,$3f,$3a,$35,$3a,$e0
pattern223:	db $3c,$00,$00,$00,$00,$00,$00,$00,$e0
pattern224:	db $31,$00,$00,$00,$30,$00,$2e,$00,$e0
pattern225:	db $2b,$2c,$2e,$00,$2e,$30,$31,$00,$e0
pattern226:	db $2e,$31,$35,$38,$2e,$31,$35,$38,$e0
pattern227:	db $30,$2e,$30,$00,$30,$2e,$2c,$2b,$e0
pattern228:	db $2e,$00,$2e,$00,$2e,$00,$2e,$00,$e0
pattern229:	db $3f,$3f,$3a,$3f,$3f,$3f,$3a,$3f,$e0
pattern230:	db $36,$00,$00,$00,$35,$00,$33,$00,$e0
pattern231:	db $30,$31,$33,$00,$33,$35,$36,$00,$e0
pattern232:	db $35,$33,$35,$00,$35,$33,$31,$30,$e0
pattern233:	db $30,$00,$30,$00,$30,$00,$30,$00,$e0
pattern234:	db $3f,$3f,$3c,$3f,$3f,$3f,$3c,$3f,$e0
pattern235:	db $37,$00,$00,$00,$00,$00,$00,$00,$e0
pattern236:	db $38,$00,$00,$00,$37,$00,$35,$00,$e0
pattern237:	db $32,$33,$35,$00,$35,$37,$38,$00,$e0
pattern238:	db $37,$35,$37,$00,$37,$35,$33,$32,$e0
pattern239:	db $26,$00,$26,$00,$26,$00,$26,$00,$e0
pattern240:	db $35,$35,$32,$35,$35,$35,$32,$35,$e0
pattern241:	db $2d,$00,$00,$00,$00,$00,$00,$00,$e0
pattern242:	db $2e,$00,$00,$00,$2d,$00,$2b,$00,$e0
pattern243:	db $28,$29,$2b,$00,$2b,$2d,$2e,$00,$e0
pattern244:	db $2d,$2b,$2d,$00,$2d,$2b,$29,$28,$e0
pattern245:	db $3f,$00,$3a,$00,$36,$00,$33,$00,$e0
pattern246:	db $36,$36,$33,$36,$36,$36,$33,$36,$e0
pattern247:	db $5f,$00,$5a,$00,$58,$00,$56,$00,$e0
pattern248:	db $5d,$00,$5a,$00,$56,$00,$53,$00,$e0
pattern249:	db $5a,$00,$56,$00,$53,$00,$4e,$00,$e0
pattern250:	db $3a,$00,$35,$00,$31,$00,$35,$00,$e0
pattern251:	db $3d,$00,$35,$00,$31,$00,$35,$00,$e0
pattern252:	db $3b,$00,$35,$00,$31,$00,$35,$00,$e0
pattern253:	db $3c,$00,$37,$00,$33,$00,$37,$00,$e0
pattern254:	db $3f,$00,$37,$00,$33,$00,$37,$00,$e0
pattern255:	db $3d,$00,$37,$00,$33,$00,$37,$00,$e0
pattern256:	db $3d,$01,$37,$01,$33,$01,$37,$01,$e0
pattern257:	db $3c,$01,$37,$01,$53,$53,$57,$57,$e0
pattern258:	db $55,$53,$50,$51,$55,$53,$50,$51,$e0
pattern259:	db $35,$33,$30,$31,$35,$33,$30,$31,$e0
pattern260:	db $1a,$18,$15,$16,$1a,$18,$15,$16,$e0

.DB "ZX10 TI 0.1", 0

.END
