.import source "../../../../vendor/64spec/lib/64spec.asm"
.import source "../../../../src/map.asm"
.import source "../../../../src/util.asm"

sfspec: :init_spec()
    :describe("initViewport")
        :it("sets up copy tables")
            jsr setup
            :assert_equal viewPort.srcTable.msb:#$04
            :assert_equal viewPort.srcTable.lsb:#$23

            :assert_equal viewPort.destTable.msb:#$80
            :assert_equal viewPort.destTable.lsb:#$00

    :finish_spec()

setup:
    viewPort_init($0400,screen,80,25,$23,$0)
    rts

.pc = $8000 "Data"
screen:
    .byte $0