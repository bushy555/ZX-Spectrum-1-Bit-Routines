    device zxspectrum48

	org #c000

begin
	ld hl,musicData
	call tritone.play
	jp begin


	include "tritone.asm"

musicData
	include "music.asm"

end
	display /d,end-begin

	savesna "test.sna",begin