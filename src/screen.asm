.importonce
.import source "util.asm"

.namespace screen {

    .macro @initScreen(addr) {
        ldx addr+1
        sta ptrs+1
        inx
        stx ptrs+3
        inx
        stx ptrs+5
        inx
        stx ptrs+7
    }

    clear:
        ldy $0

        lda #0
        sta (ptrs),y
        rts

    ptrs:
        .word $0000
        .word $0000
        .word $0000
        .word $0000
}
