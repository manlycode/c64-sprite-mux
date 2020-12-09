.importonce

.namespace zp {

    .label tmp1 = $02
    .label tmp2 = $fb
    .label tmp3 = $fc
    .label tmp4 = $fd
    .label tmp5 = $fe      

    .label tmpPtr1 = tmp2
    .label tmpPtr2 = tmp4

    clear:
        lda #0
        ldx #$70

    !:
        sta $02, x
        dex
        bpl !-
        rts
}