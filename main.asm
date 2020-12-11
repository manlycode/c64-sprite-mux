.segmentdef Data [startAfter="Default", align=$100]


BasicUpstart2(start)

// Entry point
* = $4000
.import source "src/irq_macros.asm"
.import source "src/vchar.asm"
.import source "src/map.asm"
.import source "src/cia.asm"
.import source "src/vic.asm"
// .import source "src/joystick.asm"

start:
    jsr basic.disableRunStop
    sei
    DisableTimers()

    jsr zp.clear

    vic_clearScreen(1)
    vic_SelectBank(0)
    vic_SelectScreenMemory(1)   // $0400
    vic_SelectCharMemory(14)    // $3000
    

    // Set colors for map
    lda #9
    sta vic.cbg0
    lda #0
    sta vic.cbg1
    lda #15
    sta vic.cbg2
    
    lda vic.cborder
    sta bgColors
    lda vic.cbg0
    sta bgColors+1
    
    swizzle bgColors:bgColors+1

    lda #0
    sta nextRaster
    sta irqCounter
    irq_addRasterISR isr:nextRaster
    
    EnableTimers()
    cli
    jmp *

isr:        
    // Begin Code ----------
    swizzle bgColors:bgColors+1

    lda bgColors
    sta vic.cborder
    lda bgColors+1
    sta vic.cbg0


    // End Code -----------
    ldx irqCounter
    inx
    inx
    stx irqCounter

    clc
    clv

    lda irqRows,x
    cmp #$ff
    beq lastIsr

    sta nextRaster+1
    lda irqRows+1,x
    sta nextRaster

    irq_addRasterISR isr:nextRaster
    endISR
    rts

lastIsr:
    lda #0
    sta nextRaster
    sta nextRaster+1
    sta irqCounter

    irq_addRasterISR isr:nextRaster
    endISRFinal    

.pc = * "Data"

bgColors:
    .word $0000

irqCounter:
    .byte $00

nextRaster:
    .word $0000

.const NUM_ROWS = 14
irqRows:
    .fillword NUM_ROWS, i*22
    .byte $ff

.watch  irqCounter
.watch nextRaster
.watch nextRaster+1
.for (var i=0; i < NUM_ROWS*2; i++) {
    .watch irqRows+i
}