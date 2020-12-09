#importonce
.import source "util.asm"
.import source "zero-page.asm"
.import source "vic.asm"
.import source "ptrTable.asm"


//------------------------------------------------------------------
// Constants
//------------------------------------------------------------------
.label SCREEN_W = 40
.label SCREEN_H = 25
//------------------------------------------------------------------
// Variables
//------------------------------------------------------------------
mapIdx: .byte $00
screenIdx: .byte $00
vpX: .byte $00
vpY: .byte $00
vpXbuffer: .byte $00
vpYbuffer: .byte $00
//------------------------------------------------------------------
// Macros
//------------------------------------------------------------------
.macro copyChars(source,target,size) {
    ldx #0
!:       

    .for (var i=0; i<8; i++) {
        lda source,x
        sta target,x
    }

    inx
    bne !-
}

.macro copyMap(Map, mapW, mapH, tileW, tileH, Charset, charCOUNT, Screen) {
        lda vpX
        sta mapIdx
        lda #0
        sta screenIdx
!:      ldy screenIdx
        ldx mapIdx

    .for (var i=0; i<(25 / tileH); i++) {
        lda Map+(mapW*tileH*i),x
        sta Screen+((SCREEN_W*tileH)*i),y     
    }

    inc mapIdx
    clc
    inc screenIdx
    lda screenIdx
    cmp #40
    beq !+
    // Not a screen bounds, normal map index inc
    jmp !-
    
    clc
    lda mapIdx
    adc #(mod(SCREEN_W,mapW))
    sta mapIdx
    jmp !-
!:
}

.macro copyBuffer(Map, mapW, mapH, tileW, tileH, Charset, charCOUNT, Screen) {
    lda vpXbuffer
    sta mapIdx
    lda #0
    sta screenIdx

!:      ldy screenIdx
    ldx mapIdx

    .for (var i=0; i<(25 / tileH); i++) {
        lda Map+(mapW*tileH*i),x
        sta Screen+((SCREEN_W*tileH)*i),y
    }

    inc mapIdx
    clc
    inc screenIdx
    lda screenIdx
    cmp #40
    beq !+
    // Not a screen bounds, normal map index inc
    jmp !-
    
    clc
    lda mapIdx
    adc #(mod(SCREEN_W,mapW))
    sta mapIdx
    jmp !-
!:
}

.macro copyColumn(Map, mapW, mapH, tileW, tileH, Charset, charCOUNT, Screen, ScreenCol) {
    lda vpX
    adc #ScreenCol
    tax

    lda #ScreenCol
    tay

    .for (var i=0; i<(25 / tileH); i++) {
        lda Map+(mapW*tileH*i),x
        sta Screen+((SCREEN_W*tileH)*i),y   
    }
}
//------------------------------------------------------------------
// Subroutines
//------------------------------------------------------------------
// .namespace map {
//     copyRight:
//         lda #0
//         sta zp.tmp1

//         .for (var row = 0; row <= 25; row++) {
        
//             .for (var i=39; i >= 0; i--) {
//                 lda zp.tmp1
//                 sta zp.tmp2

//                 lda $0400+(40*row)+i
//                 sta zp.tmp1
//                 lda zp.tmp2
//                 sta $0400+(40*row)+i
//             }
//         }

//         rts
// }


.macro viewPort_init(mapPtr, screenPtr, width, height, _x, _y) {
    .var _maxX = (width - SCREEN_W)
    .var _maxY = (height - SCREEN_H)
    .var x = min(_x, _maxX)
    .var y = min(_y, _maxY)

    setPtr mapPtr:viewPort.mapPtr
    setPtr screenPtr:viewPort.screenPtr

    lda #width
    sta viewPort.dim.width

    lda #height
    sta viewPort.dim.height

    lda #x
    sta viewPort.pos.x

    lda #y
    sta viewPort.pos.y

    lda #_maxX
    sta viewPort.pos.maxX

    lda #_maxY
    sta viewPort.pos.maxY

    .var currentPtrLeft = mapPtr+(width*y)+x
    .var currentPtrRight = mapPtr+(width*y)+x+39
    .var currentScrnPtrLeft = screenPtr+0
    .var currentScrnPtrRight = screenPtr+39
.print "currentScrnPtrRight="+toHexString(currentScrnPtrRight)

    .for (var i=0; i<25; i++) {
        lda #>currentPtrLeft
        sta viewPort.left.msb+i
        sta viewPort.srcTable.msb+i
        lda #<currentPtrLeft
        sta viewPort.left.lsb+i
        sta viewPort.srcTable.lsb+i
        
        lda #>currentPtrLeft
        sta zp.tmpPtr1
        lda #<currentPtrLeft
        sta zp.tmpPtr1+1
        
        lda #>currentScrnPtrLeft
        sta viewPort.screenLeft.msb+i
        sta viewPort.destTable.msb+i
        lda #<currentScrnPtrLeft
        sta viewPort.screenLeft.lsb+i
        sta viewPort.destTable.lsb+i

        lda #>currentPtrRight
        sta viewPort.right.msb+i
        lda #<currentPtrRight
        sta viewPort.right.lsb+i

        lda #>currentScrnPtrRight
        sta viewPort.screenRight.msb+i
        lda #<currentScrnPtrRight
        sta viewPort.screenRight.lsb+i

        .eval currentPtrLeft = currentPtrLeft + width - 1
        .eval currentPtrRight = currentPtrRight + width - 1
        .eval currentScrnPtrLeft = currentScrnPtrLeft + 39
        .eval currentScrnPtrRight = currentScrnPtrRight + 39
    }
}

.namespace viewPort {
    .label dest = zp.tmpPtr1
    .label source = zp.tmpPtr2
    shiftRight:
        clc
        clv
        lda pos.x
        cmp pos.maxX
        beq endShiftRight
        inc pos.x

        ldx #24
    loopShiftRight:
        clc
        clv
        inc left.lsb,x
        bne !+
        inc left.msb,x
!:
        clc
        clv
        inc right.lsb,x
        bne !+
        inc right.msb,x    

!:      clc
        clv
        dex
        bmi endShiftRight

        jmp loopShiftRight
    endShiftRight:
        rts

    shiftLeft:
        clc
        clv
        lda pos.x
        cmp #0
        beq endShiftLeft
        dec pos.x

        ldx #24
    shiftLeftLoop:        
        clc
        clv
        dec left.lsb,x
        
        clc
        clv
        lda left.lsb,x
        cmp #$ff
        bne !+
        dec left.msb,x

    !:  clc
        clv
        dec right.lsb,x
        
        clc
        clv
        lda right.lsb,x
        cmp #$ff
        bne !+
        dec right.msb,x

    !:  clc
        clv
        dex
        bmi endShiftLeft
        jmp shiftLeftLoop
    endShiftLeft:    
        rts

    renderColLeft:
        

        ldy #0
    renderColLeftLoop:
        lda left.lsb,y
        sta source
        lda left.msb,y
        sta source+1

        lda screenLeft.lsb,y
        sta dest
        lda screenLeft.msb,y
        sta dest+1

        lda (source),y
        sta (dest),y


        clc
        clv
        iny
        cpy #25
        bne renderColLeftLoop
        
        rts
        
    renderColRight:
        .label rightDest = zp.tmpPtr1
        .label rightSource = zp.tmpPtr2

        ldy #0
    renderColRightLoop:
        lda right.lsb,y
        sta rightSource
        lda right.msb,y
        sta rightSource+1

        lda screenRight.lsb,y
        sta rightDest
        lda screenRight.msb,y
        sta rightDest+1

        lda (rightSource),y
        sta (rightDest),y


        clc
        clv
        iny
        cpy #25
        bne renderColRightLoop
        
        rts

    renderMap:
        lda #40
        sta idx

    !:
        jsr renderCurrentCol

        ldy #25
        setPtr srcTable.lsb:zp.tmpPtr1
        setPtr srcTable.msb:zp.tmpPtr2
        jsr ptrTable.increment

        ldy #25
        setPtr destTable.lsb:zp.tmpPtr1
        setPtr destTable.msb:zp.tmpPtr2
        jsr ptrTable.increment

        clc
        clv
        dec idx
        bne !-
        rts

    renderCurrentCol:
        ldy #0
    renderCurrentColLoop:
        lda srcTable.lsb,y
        sta source
        lda srcTable.msb,y
        sta source+1

        lda destTable.lsb,y
        sta dest
        lda destTable.msb,y
        sta dest+1

        lda (source),y
        sta (dest),y

        clc
        clv
        iny
        cpy #25
        bne renderCurrentColLoop
        
        rts

    copyRight:
        // src = right col - 1
        // dest = right col - 2

        ldy #25
        sta ptrTable.size
        setPtr screenRight.lsb:ptrTable.srcLow
        setPtr screenRight.msb:ptrTable.srcHigh
        
        setPtr srcTable.lsb:ptrTable.destLow
        setPtr srcTable.msb:ptrTable.destHigh
        jsr ptrTable.copy
        
        setPtr destTable.lsb:ptrTable.destLow
        setPtr destTable.msb:ptrTable.destHigh
        jsr ptrTable.copy
        
        ldy #25
        setPtr srcTable.lsb:zp.tmpPtr1
        setPtr srcTable.msb:zp.tmpPtr2
        jsr ptrTable.decrement

        lda #40
        sta copyIdx

    !:  clc
        clv
        .watch copyIdx
        .break
        
        dec copyIdx
        bne !+
        .break
        rts

    !:  
        .break
        ldy #25
        sta ptrTable.size
        jsr ptrTable.copy

        ldy #25
        setPtr srcTable.lsb:zp.tmpPtr1
        setPtr srcTable.msb:zp.tmpPtr2
        jsr ptrTable.decrement

        ldy #25
        setPtr destTable.lsb:zp.tmpPtr1
        setPtr destTable.msb:zp.tmpPtr2
        jsr ptrTable.decrement
        jmp !--

    !:
        rts

    .pc = * "Data"
    mapPtr: .word $0000
    screenPtr: .word $0000
    copyIdx: .byte $00
    idx: .byte $00

    .namespace dim {
        width:  .byte $00        // Width in tiles
        height: .byte $00       // Height in tiles    
    }
    .namespace pos {
        x: .byte $00
        y: .byte $00
        maxX: .byte $00    
        maxY: .byte $00
    }

    .namespace left {
        msb: .fill 25,0
        lsb: .fill 25,0
    }

    .namespace right {
        msb: .fill 25,0
        lsb: .fill 25,0
    }

    .namespace screenLeft {
        msb: .fill 25,0
        lsb: .fill 25,0
    }

    .namespace screenRight {
        msb: .fill 25,0
        lsb: .fill 25,0
    }

    .namespace srcTable {
        msb: .fill 25,0
        lsb: .fill 25,0
    }
    
    .namespace destTable {
        msb: .fill 25,0
        lsb: .fill 25,0
    }


    
}
