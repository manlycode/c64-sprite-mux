#importonce

.namespace vic {
  .label xs0        = $d000
  .label ys0        = $d001
  .label xs1        = $d002
  .label ys1        = $d003
  .label xs2        = $d004
  .label ys2        = $d005
  .label xs3        = $d006
  .label ys3        = $d007
  .label xs4        = $d008
  .label ys4        = $d009
  .label xs5        = $d00a
  .label ys5        = $d00b
  .label xs6        = $d00c
  .label ys6        = $d00d
  .label xs7        = $d00e
  .label ys7        = $d00f
  .label msbXs      = $d010
  .label ctrlV      = $d011 //VIC_CTRL1
  .label line	    = $d012	// raster line
  .label xlp        = $d013	// light pen coordinates
  .label ylp        = $d014
  .label sactive    = $d015	// sprites: active
  .label ctrlH      = $d016
  .label sdy        = $d017	// sprites: double height
  .label ram        = $d018	// RAM pointer
  .label irq        = $d019
  .label irqmask	= $d01a
  .label sback	    = $d01b	// sprites: background mode
  .label smc		= $d01c	// sprites: multi color mode
  .label sdx		= $d01d	// sprites: double width
  .label ss_collided    = $d01e	// sprite-sprite collision detect
  .label sd_collided	= $d01f	// sprite-data collision detect
  // color registers
  .label cborder	= $d020	// border color
  .label cbg		  = $d021	// general background color
  .label cbg0	    = $d021
  .label cbg1	    = $d022	// background color 1 (for EBC and MC text mode)
  .label cbg2	    = $d023	// background color 2 (for EBC and MC text mode)
  .label cbg3	    = $d024	// background color 3 (for EBC mode)
  .label sc01	    = $d025	// sprite color for MC-bitpattern %01
  .label sc11	    = $d026	// sprite color for MC-bitpattern %11
  .label cs0		  = $d027	// sprite colors
  .label cs1		  = $d028
  .label cs2		  = $d029
  .label cs3		  = $d02a
  .label cs4		  = $d02b
  .label cs5		  = $d02c
  .label cs6		  = $d02d   
  .label cs7		  = $d02e
  .label COLOR_RAM	= $d800
  .label SCREEN_WIDTH = 40
  .label SCREEN_HEIGHT = 21
}
// See <cbm/c128/vica> for the C128's two additional registers at $d02f/$d030
// They are accessible even in C64 mode and $d030 can garble the video output,
// so be careful not to write to it accidentally in a C64 program!

//========================================================================
// vicSelectBank
//========================================================================
// 0 $0000-$3FFF (Default)
// 1 $4000-$7FFF (Charset not available)
// 2 $8000-$BFFF
// 3 $C000-$FFFF (Charset not available)
//========================================================================
.macro vic_SelectBank(bankNum) {
  _selectBank(bankNum,$dd02,$dd00)
}


.macro _selectBank(bankNum, cia_data_direction, cia_pra) {
  lda cia_data_direction
  ora #$03
  sta cia_data_direction
  lda cia_pra
  and %11111100
  ora #3-bankNum
  sta cia_pra
}

//========================================================================
// Screen Memory pg 102
//========================================================================
// Bank - 0         Bank - 1           Bank - 2           Bank - 3       
// -----------      -------------      -------------      -------------
// 1  -- $0000      // 17 -- $4000      // 33 -- $8000     // 45 -- $c000
// 2  -- $0400      // 18 -- $4400      // 34 -- $8400     // 46 -- $c400
// 3  -- $0800      // 19 -- $4800      // 35 -- $8800     // 47 -- $c800
// 4  -- $0C00      // 20 -- $4C00      // 36 -- $8C00     // 48 -- $cC00
// 5  -- $1000      // 21 -- $5000      // 37 -- $A000
// 6  -- $1400      // 22 -- $5400      // 38 -- $A400
// 7  -- $1800      // 23 -- $5800      // 39 -- $A800
// 8  -- $1C00      // 24 -- $5C00      // 40 -- $AC00
// 9  -- $2000      // 25 -- $6000      // 41 -- $B000
// 10 -- $2400      // 26 -- $6400      // 42 -- $B400
// 11 -- $2800      // 27 -- $6800      // 43 -- $B800
// 12 -- $2C00      // 28 -- $6C00      // 44 -- $BC00
// 13 -- $3000      // 29 -- $7000      
// 14 -- $3400      // 30 -- $7400      
// 15 -- $3800      // 31 -- $7800      
// 16 -- $3C00      // 32 -- $7C00      
.macro vic_SelectScreenMemory(idx) {
  pVicSelectScreenMemory(idx, vic.ram)
}

.macro pVicSelectScreenMemory(idx, vic_ram_register) {
  lda vic_ram_register
  and #%00001111	// clear high bits
  ora #16*idx
  sta vic_ram_register
}

//========================================================================
// Character Memory pg 103 - 106
//========================================================================
.macro vic_SelectCharMemory(idx) {
  _vicSelectCharMemory(idx, vic.ram)
}

.macro _vicSelectCharMemory(idx, vic_ram_register) {
  lda vic_ram_register
  and #%11110001	// clear bits 3-1
  ora #2*idx
  sta vic_ram_register
}

//========================================================================
// Multi-color Mode pg 115
//========================================================================
.macro vic_ClearModes() {
    clc
    clv
    lda vic.ctrlV
    and #%10011111
    sta vic.ctrlV
    
    lda vic.ctrlH
    and #%11101111
    sta vic.ctrlH
}

.macro vic_MultiColorModeOn() {
  .print "vic.ctrlH="+vic.ctrlH
.print "vic.ctrlH="+vic.ctrlH
  
  lda vic.ctrlH
  ora #%00010000
  sta vic.ctrlH
}

.macro vic_MultiColorModeOff() {
  .print "vic.ctrlH="+vic.ctrlH
  .print "vic.ctrlV="+vic.ctrlV
  
  lda vic.ctrlH
  and #239
  sta vic.ctrlH
}


.macro vic_StandardCharacterModeOn() {
  lda vic.ctrlH
  and #%11101111
  sta vic.ctrlH
}

.macro vic_BitmapModeOn() {
  lda vic.ctrlV
  ora #32
  sta vic.ctrlV
}

.macro vic_BitmapModeOff() {
  lda vic.ctrlV
  and #223
  sta vic.ctrlV
}

.macro vic_set38ColumnMode() {
  lda vic.ctrlH
  clc
  clv
  and #247
  sta vic.ctrlH
}

.macro vic_set40ColumnMode() {
  lda vic.ctrlH
  ora #8
  sta vic.ctrlH
}

//========================================================================
// Color RAM
//========================================================================
.macro vic_CopyColors(source) {
    ldx #0
copyColorsLoop:
    lda source,x
    .for (var i=0; i<4; i++) {
        sta vic.COLOR_RAM+(i*$100),x
    }
  
    inx
    bne copyColorsLoop
}

.macro vic_CopyChars(source, dest, SIZE) {
    .var size = SIZE

    ldx #0
!:  lda source,x
    sta dest,x
    
    .for (var i=0; i<(size/256); i++) {
        lda source+(i*$100),x
        sta dest+(i*$100),x
    }

    clc
    clv
    inx
    bne !-
}

vic_clearColorRam:
	ldx #0
@clearColorRamLoop:
        sta $D800,x
        sta $D900,x
        sta $DA00,x
        sta $DB00,x
        inx
        bne @clearColorRamLoop
      	rts
scrollVal:
        .byte $00

.macro vic_clearScreen(target) {
        ldx #0
        lda #0
!:       
        .for (var i=0; i<(1000/256); i++) {
          sta target,x
        }
        
        inx
        bne !-
}

incScroll:
        clc
        clv
        lda scrollVal
        adc #1
        and #%00000111
        sta scrollVal
        rts

decScroll:
        dec scrollVal
        lda scrollVal
        and #%00000111
        sta scrollVal
        rts

updateScroll:
        lda vic.ctrlH
        and #248
        clc
        adc scrollVal
        sta vic.ctrlH
        rts