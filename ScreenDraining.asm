/**********************************************
		Screen Drain Demo
***********************************************/
/*

BASIC DEMO CODE

10 ? chr$(147);
20 ? "Lorem "; chr$(150); "Ipsum is "; chr$(30); "simply dummy "; chr$(5);
30 ? "text of the "; chr$(129); "printing and "; chr$(150); "typesetting ";
40 ? "industry. Lorem Ipsum has "; chr$(156); "been the industry's standard ";
50 ? "dummy text ever since "; chr$(158); "the 1500s, when an unknown ";
60 ? "printer "; chr$(5); "took a galley of type and scrambled it to ";
70 ? "make a type "; chr$(30); "specimen book."
80 ? chr$(17); chr$(5); "[press any key to start drainging]"
90 poke 198,0: wait 198,1
99 sys49152

*/
.var position = $20
.var color_position = $22
.var position_prev = $24
.var color_position_prev = $26

//This shuld be pretty safe memory location!
//sys49152
*=$C000

//Main program
mainProg: {		



		ldy #0
clearnext:
		lda #0
		sta columns_counter,y
		iny
		cpy #40
		bne clearnext



		ldx #0
		stx column_max

		ldx #2
		stx scrloop_max 

		ldx #0
		stx column_start

ag0:
		jsr loopColumnZero2X

		inc column_max

		ldx column_max
		cpx #40
		beq done0


		//jsr setDelay2

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


loop1r:

	clc
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