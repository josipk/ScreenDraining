/**********************************************
		Screen Drain Demo
***********************************************/
#import "Libs/MyStdLibs.lib"

BasicUpstart2(mainProg)


.var position = $20
.var color_position = $22
.var position_prev = $24
.var color_position_prev = $26

.label SCNKEY     = $ff9f   // scan keyboard - kernal routine
.label GETIN      = $ffe4   // read keyboard buffer - kernal routine

//This is safe memory location!
//sys49152
//*=$C000

mainProg: {		// <- Here we define a scope


		//set to 25 line text mode and turn on the screen
		lda #$1B
		sta $D011

		//fill screen with data and color
		ldx #0	
	loopc:
		lda screen_color,x
		sta $d800,x

		lda screen_chars,x
		sta $0400,x

		lda screen_color+$100,x
		sta $d900,x

		lda screen_chars+$100,x
		sta $0500,x

		lda screen_color+$200,x
		sta $da00,x

		lda screen_chars+$200,x
		sta $0600,x

		lda screen_color+$300,x
		sta $db00,x

		lda screen_chars+$300,x
		sta $0700,x		

		inx
		bne loopc		

//----------------------------------------------

check_keypress:
        jsr SCNKEY
        jsr GETIN

spacebar_check:
        cmp #$20
        bne check_keypress


		ldy #0
clearnext:
		lda #0
		sta columns_counter,y
		iny
		cpy #40
		bne clearnext

		ldx #0
		stx column_max

		ldx #3
		stx scrloop_max 

		ldx #0
		stx column_start

ag0:
		jsr loopColumnZero2X

		inc column_max

		ldx column_max
		cpx #40
		beq done0


		jsr setDelay2

		jmp ag0

done0:

        rts 
}

loopColumnZero2X: {		// <- Here we define a scope

		ldx column_start
		stx column

		
		inc scrloop_max
		
		lda scrloop_max
		and #%00000111
		cmp #0
		bne continue5

		inc column_start
		lda #5
		

continue5:		
		sta scrloop_max

		lda column_max
		cmp #39
		bne ag3

		ldx #24
		sta scrloop_max	

ag3:
		jsr loopColumnX

		ldx column
		cpx column_max
		beq done3

		inc column

		//jsr setDelay2

		jmp ag3

done3:

        rts 
}

loopColumnX: {		// <- Here we define a scope
	

		ldx scrloop_max  
		stx scrloop

ag1:

		clc
		ldy column
		lda columns_counter,y
		adc #1
		sta columns_counter,y
		cmp #26
		bcs done2


		jsr loopColumn

		clc
		dec scrloop

		ldx scrloop
		cpx #$0
		beq done2 

		jmp ag1

done2:

        rts 
}


loopColumn: {

	ldx #24
	stx row

	jsr getPositionAtXY

	ldy #0
	sty counter
	//sta (position),y


loop1r:

	clc
	lda #$22
	ldy #0
	
	
	ldx position
	stx position_prev
	ldx position+1
	stx position_prev+1

	lda position
	sec
	sbc #40
	sta position
	
	lda position+1
	sbc #0
	sta position+1


	ldy #0
	
	jsr setColorPosition
	jsr setColorPositionPrev


	lda (position),y
	sta (position_prev),y 

	lda (color_position),y
	sta (color_position_prev),y 

	
	clc
	inc counter

	ldy counter
	cpy #25
	bcs done1r

	jmp loop1r

done1r:

	lda #$20
	ldy #0
	sta (position_prev),y 

	//jsr saveCurrentPosition	

	rts
}


getPositionAtXY: { 

	clc
	ldx column 
	stx position
	ldx #$04 
	stx position+1

	ldx #0 
addrow157:
	clc

	lda position
	adc #40       //add 40 colums
	sta position
	bcc skip1188
	inc position+1
skip1188:
	inx
	cpx row
	bcc addrow157

	rts
}


setColorPosition: {

//---------------------------------------set position color--------------------
		lda position
        sta color_position 
		clc
		lda position+1
        adc #$d4
        sta color_position+1 
        clc
        rts
//---------------------------------------set position color--------------------
}


setColorPositionPrev: {

//---------------------------------------set position color--------------------
		lda position_prev
        sta color_position_prev
		clc
		lda position_prev+1
        adc #$d4
        sta color_position_prev+1 
        clc
        rts
//---------------------------------------set position color--------------------
}


setDelay1: {

!:
		lda #$12
		cmp $d012
		bne !-

!:
		lda #$10
		cmp $d012
		bne !-

!:
		lda #$8
		cmp $d012
		bne !-

        rts	
}

setDelay2: {

!:
		lda #$12
		cmp $d012
		bne !-
        rts	
}
//-----------------------------------------------------
columns_counter: .fill 40, 0
column: .byte 00
column_max: .byte 00
column_start: .byte 00
row: .byte 0
scrloop: .byte 0
scrloop_max: .byte 0
tmpchar: .byte 0
counter: .byte 0

screen_chars:
.byte $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E
.byte $7E,$7E,$7E,$7E,$7E,$14,$08,$09,$13,$20,$09,$13,$20,$13,$09,$0D,$10,$0C,$05,$20,$14,$05,$18,$14,$20,$0F,$0E,$20,$13,$03,$12,$05,$05,$0E,$20,$7E,$7E,$7E,$7E,$7E
.byte $7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E,$7E
.byte $60,$20,$20,$13,$0F,$0D,$05,$20,$0D,$0F,$12,$05,$20,$14,$05,$18,$14,$20,$08,$05,$12,$05,$20,$0F,$0E,$20,$14,$08,$09,$13,$20,$0C,$09,$0E,$05,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$07,$01,$0D,$05,$20,$04,$05,$0D,$0F,$20,$0D,$01,$10,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$68,$20,$20,$20,$20
.byte $20,$20,$20,$D7,$D7,$D7,$D7,$D7,$D7,$D7,$D7,$D7,$D7,$AA,$E6,$D3,$D3,$D3,$D3,$D3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$EE,$66,$20,$20,$20,$20
.byte $20,$20,$20,$D7,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D7,$E6,$D3,$A0,$A0,$C1,$E5,$A0,$D3,$D3,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$C2,$66,$20,$20,$20,$20
.byte $20,$20,$20,$D7,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D7,$E6,$D3,$A0,$C1,$E5,$C1,$A0,$D8,$D3,$D3,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$C2,$66,$20,$20,$20,$20
.byte $20,$20,$20,$D7,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D7,$D3,$D3,$A0,$A0,$C1,$E5,$C1,$A0,$DA,$D3,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$41,$C2,$66,$20,$20,$20,$20
.byte $20,$20,$20,$D7,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D7,$D3,$A0,$C1,$A0,$D8,$C1,$A0,$A0,$A0,$D3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$F3,$66,$20,$20,$20,$20
.byte $20,$20,$20,$D7,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D7,$D3,$A0,$A0,$C1,$A0,$A0,$C1,$C1,$E4,$D3,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$C2,$66,$20,$20,$20,$20
.byte $20,$20,$20,$D7,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D7,$AA,$C1,$A0,$A0,$A0,$A0,$A0,$E5,$E5,$D3,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$C2,$66,$20,$20,$20,$20
.byte $20,$20,$20,$D7,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D6,$D7,$AA,$D3,$D3,$DA,$DA,$D8,$A0,$E5,$D3,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$58,$C2,$66,$20,$20,$20,$20
.byte $20,$20,$20,$D7,$D7,$D7,$D7,$D7,$D7,$D7,$D7,$D7,$D7,$AA,$AA,$AA,$D3,$D3,$D3,$D3,$D3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$C3,$CB,$B0,$20,$20,$20,$20
.byte $20,$20,$20,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$45,$7E,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$10,$12,$05,$13,$13,$20,$13,$10,$01,$03,$05,$20,$14,$0F,$20,$04,$12,$01,$09,$0E,$20,$14,$08,$05,$20,$13,$03,$12,$05,$05,$0E,$21,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$13,$03,$12,$05,$05,$0E,$20,$04,$12,$01,$09,$0E,$20,$04,$05,$0D,$0F,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$00,$0A,$0F,$13,$09,$10,$2C,$32,$30,$32,$31,$20
.byte $DF,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$E9


screen_color:
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0F,$0F,$0F,$0F,$0E,$0A,$0A,$0E,$07,$07,$07,$07,$07,$07,$0E,$08,$08,$08,$08,$0E,$0A,$0A,$0E,$02,$02,$02,$02,$02,$02,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$07,$07,$07,$07,$0E,$0F,$0F,$0F,$0F,$0E,$03,$03,$03,$03,$0E,$01,$01,$01,$01,$0E,$03,$03,$0E,$01,$01,$01,$01,$0E,$0A,$0A,$0A,$0A,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$07,$07,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$07,$07,$07,$07,$07,$07,$07,$07,$07,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0D,$0C,$08,$0E,$01,$04,$05,$07,$0E,$02,$07,$05,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$0E,$0E,$0E
.byte $0E,$0E,$0E,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$08,$0F,$0F,$0A,$0F,$0A,$0F,$0F,$08,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$01,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$03,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$01,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$05,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$01,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0F,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$07,$0E,$01,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0F,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$01,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0F,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$01,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0F,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$01,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$08,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$07,$0E,$01,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$08,$0F,$0F,$04,$0F,$04,$04,$0F,$08,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$03,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$02,$02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03,$02,$02,$03,$07,$07,$07,$07,$07,$03,$03,$03,$03,$03,$0A,$0A,$0A,$0A,$0A,$0A,$02,$0E,$0E,$0E,$0E,$02
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $03,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0D,$0E,$0E,$0E,$0E,$0E,$03