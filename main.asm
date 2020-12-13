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
// .label IRQ_2 = 200
// .label IRQ_3 = 220
// .label IRQ_4 = 300


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
  setSpriteX
  setSpriteY #IRQ_1
  jsr setSpritePtrs
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
.const ROW_HEIGHT = 22

irq1:

.for (var i = 1; i <= MAX_ROW; i += 2) {
    .var currentRow = IRQ_1+((i-1)*ROW_HEIGHT)
    .var row1 = IRQ_1+(i*ROW_HEIGHT)
    .var row2 = IRQ_1+((i+1)*ROW_HEIGHT)
    
.label odd = *    
    setSpriteY #currentRow
    c64lib_irqEnter()
    
    // inc c64lib.BG_COL_0         // change background color 
    // inc c64lib.BORDER_COL       // change border color
    c64lib_irqExit(even, row1, false)

.label even = *
    setSpriteY #row1
    c64lib_irqEnter()
    
    // dec c64lib.BG_COL_0         // change background color 
    // dec c64lib.BORDER_COL       // change border color

    .if (i==MAX_ROW) {
        c64lib_irqExit(irq1, IRQ_1, false)   
    } else {
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
    rts
}

_setSpriteX: {
  .var start = 30
  .for (var i = 0; i < 8; i++) {
    .var xPos = start + i*40

    lda #<xPos
    sta vic.xs0+(2*i)

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
  .for (var i = 0; i < 8; i++) {
    sta vic.ys0+(2*i)
  }
}


setSpritePtrs: {
  .const base = $07F8
    .for (var i = 0; i < 8; i++) {
      lda #spriteData/64
      sta base+i
    }

    rts
}

.label end = *
.print "The end " + toHexString(end)

*  = $4000 - 64
spriteData:
  .fill 64, [$ff, $00]