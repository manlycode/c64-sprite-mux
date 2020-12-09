.importonce

.import source "util.asm"
.import source "zero-page.asm"


.namespace ptrTable {
    copy:
        ldy size
!:      clc
        clv
        dey
        bmi !+
        copyPtr srcLow:zp.tmpPtr1
        copyPtr destLow:zp.tmpPtr2
        lda (zp.tmpPtr1),y
        sta (zp.tmpPtr2),y
        copyPtr srcHigh:zp.tmpPtr1
        copyPtr destHigh:zp.tmpPtr2
        lda (zp.tmpPtr1),y
        sta (zp.tmpPtr2),y
        jmp !-
!:      rts

    decrement:
        // zp.tmpPtr1 - llsb
        // zp.tmpPtr2 - msb
        // y - size
        clc
        clv
        dey
        bmi !++

        clc
        clv
        lda (zp.tmpPtr1),y
        sta zp.tmp1
        dec zp.tmp1
        lda zp.tmp1
        sta (zp.tmpPtr1),y
        clc
        clv
        cmp #$ff
        bne !+
        lda (zp.tmpPtr2),y
        sta zp.tmp1
        dec zp.tmp1
        lda zp.tmp1
        sta (zp.tmpPtr2),y    

    !:  jmp decrement
    !:
        rts

    
    increment:
        // zp.tmpPtr1 - llsb
        // zp.tmpPtr2 - msb
        // y - size
        clc
        clv
        dey
        bmi !++

        clc
        clv
        lda (zp.tmpPtr1),y
        sta zp.tmp1
        inc zp.tmp1
        lda zp.tmp1
        sta (zp.tmpPtr1),y
        clc
        clv
        cmp #$00
        bne !+
        lda (zp.tmpPtr2),y
        sta zp.tmp1
        inc zp.tmp1
        lda zp.tmp1
        sta (zp.tmpPtr2),y    

    !:  jmp increment
    !:
        rts

    tmpPtr: .word $0000
    tmpPtr2: .word $0000
    size: .byte $00
    srcLow: .word $0000
    srcHigh: .word $0000
    destLow: .word $0000
    destHigh: .word $0000
}
