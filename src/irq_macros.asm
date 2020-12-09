// Args:
//       @param irq - address of subroutine for interrupt
//       @param row - row at which to trigger subroutine
.import source "vic.asm"
.import source "basic.asm"
.import source "util.asm"

.pseudocommand addRasterInterrupt IRQ:aRow {
    .var row = aRow.getValue()
    .if (aRow.getType()==AT_IMMEDIATE) {

        // Set Interrupt Request Mask
        .var HI_BIT = 0
        .var LO_BYTE = 0
        .if (row>$ff) {
            .eval HI_BIT = %10000000
            .eval LO_BYTE = mod(row,256)
        } else {
            .eval HI_BIT = 0
            .eval LO_BYTE = row
        }
        
        lda #$01                // set mask to enable by raster beam
        sta vic.irqmask         // VIC_IRQEN
        lda #<IRQ.getValue()               // Point the system routine to our new irq
        ldx #>IRQ.getValue()
        sta basic.isrAddr
        stx basic.isrAddr+1

        lda #LO_BYTE          // trigger first interrupt at row 0
        sta vic.line          // VIC_RSTCMP
        setBits vic.ctrlV:HI_BIT
    } else {        
        ldy row+1
        ror row+1
        ror row+1

        lda #$01                // set mask to enable by raster beam
        sta vic.irqmask         // VIC_IRQEN
        lda #<IRQ.getValue()               // Point the system routine to our new irq
        ldx #>IRQ.getValue()
        sta basic.isrAddr
        stx basic.isrAddr+1

        lda row          // trigger first interrupt at row 0
        sta vic.line     
        setBits vic.ctrlV:row+1

        sty row+1
    }
}

.macro irq_endISR() {
    dec $d019
    jmp $ea81
}

.pseudocommand endISR {
    dec vic.irq
    jmp $ea31
}

.pseudocommand endISRFinal {
    dec vic.irq
    jmp $ea81
}
