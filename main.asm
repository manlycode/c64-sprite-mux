/*
 * Copper demo 1.
 */


#import "common/lib/mem-global.asm"
#import "chipset/lib/cia.asm"
#import "chipset/lib/vic2-global.asm"
#import "chipset/lib/mos6510-global.asm"
#import "src/cia.asm"
#import "src/vic.asm"
.label IRQ_1 = 16

BasicUpstart2(start) // Basic start routine

start:
  sei                         // disable IRQ, otherwise C64 will crash
  jsr cia.stopIRQ

  lda #c64lib.IMR_RASTER      // VIC-II is about to produce raster interrupt
  sta c64lib.IMR
  lda #0
  sta c64lib.BG_COL_0         // change background color 
  sta c64lib.BORDER_COL       // change border color
  jsr enableSprites

  lda #$0a // sprite multicolor 1
  sta vic.sc01
  lda #$09 // sprite multicolor 2
  sta vic.sc11

  setSpriteX
  setSpriteY #100

  jsr updateSpritePointers
  c64lib_setRaster(IRQ_1)
  lda #<irq1
  sta c64lib.IRQ_LO
  lda #>irq1
  sta c64lib.IRQ_HI
  lda #<irqFreeze
  sta c64lib.NMI_LO
  lda #>irqFreeze
  sta c64lib.NMI_HI
  c64lib_configureMemory(c64lib.RAM_IO_RAM)  // turn off kernal, so that our vector becomes visible
  cli


  jmp *                  // go into endless loop
  

.const MAX_ROW=9
.const ROW_HEIGHT = 21

irq1:

.for (var i = 1; i <= MAX_ROW; i += 2) {
    .var currentRow = IRQ_1+((i-1)*ROW_HEIGHT)
    .var row1 = IRQ_1+(i*ROW_HEIGHT)
    .var row2 = IRQ_1+((i+1)*ROW_HEIGHT)
    
.label odd = *    
    c64lib_irqEnter()
    c64lib_irqExit(even, row1, false)

.label even = *
    .if (i==MAX_ROW) {
      jsr updateSpritePointers
      c64lib_irqEnter()
      c64lib_irqExit(irq1, IRQ_1, false)   
    } else {
      c64lib_irqEnter()
      c64lib_irqExit(oddNext, row2, false)
    }
.label oddNext = *
}
  
irqFreeze: {
  rti
}

enableSprites:  {
    lda #$ff
    sta vic.spriteEnable
    sta vic.smc
    rts
}

_setSpriteX: {
  .var start = 30
  .for (var i = 0; i < 1; i++) {
    .var xPos = start + i*40

    lda #<xPos
    sta vic.xs0+(2*i)
    sta vic.xs1+(2*i)

    .var mask = $00000001<<i
    
    .if (xPos > 255) {
      lda #mask
      ora vic.spriteMSB
    } else {
      lda #mask^$ff
      and vic.spriteMSB
    }
    sta vic.spriteMSB
  }

  rts
}

.pseudocommand setSpriteX {
  jsr _setSpriteX
}


.pseudocommand setSpriteY pos {
  lda pos
  sta vic.ys0
  adc #21
  sta vic.ys0+2
}


oddSpritePtrs: {
  .const base = $07F8
    .for (var i = 0; i < 1; i++) {
      lda #frame1/64
      sta base+i
      lda #frame1/64  + 9
      sta base+i+1
    }

    rts
}

evenSpritePtrs: {
  .const base = $07F8
    .for (var i = 0; i < 1; i++) {
      lda #frame1/64+9
      sta base+i
    }

    rts
}

.const spritePtrBase = $07F8
updateSpritePointers:
  inc frameIdx
  lda frameIdx
  and #%00000111

  adc #frame1/64
  sta spritePtrBase

  adc #8
  sta spritePtrBase+1
  rts



// incSpritePtrs: {
//   .const base = $07F8
//   clc
//   clv
//   lda base
//   cmp #frame3/64
//   bne !+
//   lda #frame1/64  
//   sta base

//   jmp !++
// !:
//   inc base
// !:  

//   rts
// }

.label end = *
.print "The end " + toHexString(end)

frameIdx: .byte $00

*  = $4000 - (100*64)

frame1:
.import source "assets/caveman.asm"


//   .fill 64, [$ff, $00]
// frame2:
//   .fill 64, [$00, $ff]
// frame3:
//   .fill 64, [$fd, $02]