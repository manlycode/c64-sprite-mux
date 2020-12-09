.import source "../../vendor/64spec/lib/64spec.asm"
.import source "../../src/util.asm"
.import source "../../src/zero-page.asm"
.import source "../../src/ptrTable.asm"



sfspec: :init_spec()
    :describe("given a small table")
        :it("increments the table")
            ldy #2
            setPtr lsbTable:zp.tmpPtr1
            setPtr msbTable:zp.tmpPtr2
            
            jsr ptrTable.decrement

            :assert_equal msbTable:#$03
            :assert_equal lsbTable:#$ff

            :assert_equal msbTable+1:#$04
            :assert_equal lsbTable+1:#$00


    :describe("when the lsb rolls over")

:finish_spec()



.pc = * "Data"
// Data labels go here
msbTable:
    .byte $04
    .byte $04

lsbTable:
    .byte $00
    .byte $01


lsbTableRollover:
    .byte $04
    .byte $04
msbTableRollover:
    .byte $00
    .byte $ff
