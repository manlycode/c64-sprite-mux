.import source "../../../../vendor/64spec/lib/64spec.asm"
.import source "../../../../src/map.asm"
.import source "../../../../src/util.asm"

sfspec: :init_spec()
    :describe("initViewport")
        :it("sets the dimensions")
            jsr setupWYPos
            :assert_equal viewPort.dim.width:#80
            :assert_equal viewPort.dim.height:#26

        :it("sets the position")
            jsr setupWYPos
            :assert_equal viewPort.pos.x:#$23
            :assert_equal viewPort.pos.y:#$1
            :assert_equal viewPort.pos.maxX:#40
            :assert_equal viewPort.pos.maxY:#$1

        :it("sets left col")
            jsr setupWYPos
            :assert_equal viewPort.left.msb:#$04
            :assert_equal viewPort.left.lsb:#$73

            :assert_equal viewPort.screenLeft.msb:#$80
            :assert_equal viewPort.screenLeft.lsb:#$00
            :assert_equal viewPort.screenLeft.msb+1:#$80
            :assert_equal viewPort.screenLeft.lsb+1:#$28            

            :assert_equal viewPort.left.msb+24:#$0B
            :assert_equal viewPort.left.lsb+24:#$f3

        :it("sets up the right column")
            jsr setupWYPos
            :assert_equal viewPort.right.msb:#$04
            :assert_equal viewPort.right.lsb:#$9A
            :assert_equal viewPort.screenRight.msb:#$80
            :assert_equal viewPort.screenRight.lsb:#$27
            

            :assert_equal viewPort.screenRight.msb:#$80
            :assert_equal viewPort.screenRight.lsb:#$27

            :assert_equal viewPort.right.msb+1:#$04
            :assert_equal viewPort.right.lsb+1:#$EA

            :assert_equal viewPort.screenLeft.msb+1:#$80
            :assert_equal viewPort.screenLeft.lsb+1:#$28

            :assert_equal viewPort.right.msb+24:#$0C
            :assert_equal viewPort.right.lsb+24:#$1A

            .watch viewPort.screenRight.msb
            .watch viewPort.screenRight.lsb

    :finish_spec()

setupWYPos:
    viewPort_init($0400,screen,80,26,$23,$1)
    rts

.pc = $8000
screen:
    .byte $0