.import source "../../vendor/64spec/lib/64spec.asm"
.import source "../../src/ptrTable.asm"
.import source "../../src/util.asm"
.import source "../../src/util.asm"

sfspec: :init_spec()
    :describe("ptrTable.copy")
        :it("copies a table")
            lda #2
            sta ptrTable.size
            setPtr srcLsb:ptrTable.srcLow
            setPtr destLsb:ptrTable.destLow
            setPtr srcMsb:ptrTable.srcHigh
            setPtr destMsb:ptrTable.destHigh
            jsr ptrTable.copy

            :assert_equal destLsb+1:#$ff
            :assert_equal destLsb:#$03

            :assert_equal destMsb+1:#$05
            :assert_equal destMsb:#$04

:finish_spec()



.pc = * "Data"
// Data labels go here
srcMsb:
    .byte $04
    .byte $05

srcLsb:
    .byte $03
    .byte $ff

destMsb:
    .byte $00
    .byte $00

destLsb:
    .byte $00
    .byte $00