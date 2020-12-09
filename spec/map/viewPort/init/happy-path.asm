.import source "../../../../vendor/64spec/lib/64spec.asm"
.import source "../../../../src/map.asm"
.import source "../../../../src/util.asm"

sfspec: :init_spec()
    :describe("initViewport")
        :it("sets the pointers")
            jsr setup
            :assert_equal viewPort.mapPtr:#$00
            :assert_equal viewPort.mapPtr+1:#$04
            :assert_equal viewPort.screenPtr:#$00
            :assert_equal viewPort.screenPtr+1:#$80

        :it("sets the dimensions")
            jsr setup
            :assert_equal viewPort.dim.width:#80
            :assert_equal viewPort.dim.height:#25

        :it("sets the position")
            jsr setup
            :assert_equal viewPort.pos.x:#35
            :assert_equal viewPort.pos.y:#0
            :assert_equal viewPort.pos.maxX:#40
            :assert_equal viewPort.pos.maxY:#0

        :it("sets left col")
            jsr setup
            
            :assert_equal viewPort.left.msb:#$04
            :assert_equal viewPort.left.lsb:#$23

            :assert_equal viewPort.left.msb+1:#$04
            :assert_equal viewPort.left.lsb+1:#$72

            :assert_equal viewPort.left.msb+24:#$0B
            :assert_equal viewPort.left.lsb+24:#$8b 

        :it("sets up the right column")
            jsr setup
            :assert_equal viewPort.right.msb:#$04
            :assert_equal viewPort.right.lsb:#$4A

            .watch viewPort.right.msb+1
            .watch viewPort.right.lsb+1
            :assert_equal viewPort.right.msb+1:#$04
            :assert_equal viewPort.right.lsb+1:#$99

            // :assert_equal viewPort.right.msb+24:#$0B
            // :assert_equal viewPort.right.lsb+24:#$CA

    :finish_spec()

setup:
    viewPort_init($0400,screen,80,25,$23,$0)
    rts

.pc = $8000 "Data"
screen:
    .byte $0