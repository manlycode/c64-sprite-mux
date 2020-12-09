.import source "../../vendor/64spec/lib/64spec.asm"
.import source "../../src/map.asm"
.import source "../../src/util.asm"

sfspec: :init_spec()
    :describe("shiftRight")
        :it("shifts the x position")
            jsr setup
            jsr viewPort.shiftRight
            :assert_equal viewPort.pos.x:#$24

        :it("updates the left col")
            :assert_equal viewPort.left.msb:#$04
            :assert_equal viewPort.left.lsb:#$24
            :assert_equal viewPort.left.msb+1:#$04
            :assert_equal viewPort.left.lsb+1:#$74
            :assert_equal viewPort.left.msb+24:#$0B
            :assert_equal viewPort.left.lsb+24:#$A4

            jsr setupOverflow
            jsr viewPort.shiftRight
            :assert_equal viewPort.left.msb:#$05
            :assert_equal viewPort.left.lsb:#$00
            :assert_equal viewPort.left.msb+1:#$05
            :assert_equal viewPort.left.lsb+1:#$50
            :assert_equal viewPort.left.msb+24:#$0c
            :assert_equal viewPort.left.lsb+24:#$80

        :it("updates the right col")
            jsr setup
            jsr viewPort.shiftRight
            :assert_equal viewPort.right.msb:#$04
            :assert_equal viewPort.right.lsb:#$4b
            :assert_equal viewPort.right.msb+1:#$04
            :assert_equal viewPort.right.lsb+1:#$9b
            :assert_equal viewPort.right.msb+24:#$0b
            :assert_equal viewPort.right.lsb+24:#$cb

    :describe("when the viewport is all the way to the right")
        :it("won't shift the position, or update the columns")
            jsr setupRightBounds
            jsr viewPort.shiftRight
            
            :assert_equal viewPort.pos.x:#$28
            .watch viewPort.left.msb
            .watch viewPort.left.lsb

            :assert_equal viewPort.left.msb:#$04
            :assert_equal viewPort.left.lsb:#$28
            :assert_equal viewPort.right.msb:#$04
            :assert_equal viewPort.right.lsb:#$4f
    :finish_spec()

setup:
    viewPort_init($0400,80,25,$23,$0)
    rts
setupOverflow:
    viewPort_init($04ff,80,25,$0,$0)
    rts

setupRightBounds:
    viewPort_init($0400,80,25,$28,$0)
    rts