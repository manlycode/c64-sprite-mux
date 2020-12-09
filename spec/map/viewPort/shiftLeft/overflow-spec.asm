.import source "../../../../vendor/64spec/lib/64spec.asm"
.import source "../../../../src/map.asm"
.import source "../../../../src/util.asm"

sfspec: :init_spec()
    :describe("shiftLeft")
        :it("shifts the x position")
            jsr setupOverflow
            jsr viewPort.shiftLeft
            :assert_equal viewPort.pos.x:#$00

        :it("updates the left col")
            jsr setupOverflow
            jsr viewPort.shiftLeft
            :assert_equal viewPort.left.msb:#$03
            :assert_equal viewPort.left.lsb:#$ff
            :assert_equal viewPort.left.msb+1:#$04
            :assert_equal viewPort.left.lsb+1:#$4f
            :assert_equal viewPort.left.msb+24:#$0b
            :assert_equal viewPort.left.lsb+24:#$7f

        :it("updates the right col")
            jsr setupOverflow
            jsr viewPort.shiftLeft
            :assert_equal viewPort.right.msb:#$04
            :assert_equal viewPort.right.lsb:#$26
            :assert_equal viewPort.right.msb+1:#$04
            :assert_equal viewPort.right.lsb+1:#$76
            :assert_equal viewPort.right.msb+24:#$0b
            :assert_equal viewPort.right.lsb+24:#$a6
    
    :finish_spec()

setupOverflow:
    viewPort_init($03ff,screen,80,26,$1,$0)
    rts

.pc = $8000 "Data"
screen:
    .byte $0