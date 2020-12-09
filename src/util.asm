#importonce
.import source "zero-page.asm"

.pseudocommand setPtr src:dest {
.print "src=$"+toHexString(>src.getValue())+toHexString(<src.getValue())
    lda #<src.getValue()
    sta dest.getValue()
    lda #>src.getValue()
    sta dest.getValue()+1
}

.pseudocommand copyPtr src:dest {
    .print "src=$"+toHexString(>src.getValue())+toHexString(<src.getValue())
    lda src.getValue()
    sta dest.getValue()
    lda src.getValue()+1
    sta dest.getValue()+1
}

.pseudocommand setBits target:bits {
    .if (bits.getType()==AT_IMMEDIATE) {
        lda target
        ora #bits.getValue()
        sta target
    } else {
        lda target
        ora bits.getValue()
        sta target
    }
}

.macro incPtr(PtrAddr) {
    incWord(PtrAddr)
}

.macro decPtr(Ptr) {
    decWord(Ptr)
}

.macro incWord(Word) {
    clv
    inc Word
    bne !+
    inc Word+1
!:
}

.macro decWord(Word) {
    clc
    dec Word
    bpl !+
    dec Word+1
!:
}

.macro addWord(Word, amount) {
    lda Word
    clc
    clv
    adc #amount
    bcc !+
    inc Word+1
!:  sta Word
}

.pseudocommand mov src:dest {
    lda src
    sta dest
}
