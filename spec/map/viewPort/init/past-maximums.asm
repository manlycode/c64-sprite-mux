.import source "../../../../vendor/64spec/lib/64spec.asm"
.import source "../../../../src/map.asm"
.import source "../../../../src/util.asm"

sfspec: :init_spec()
    :describe("initViewport")
        :it("sets the position")
            jsr setupPastMaximums
            :assert_equal viewPort.pos.x:#40
            :assert_equal viewPort.pos.y:#25
            :assert_equal viewPort.pos.maxX:#40
            :assert_equal viewPort.pos.maxY:#25

    :finish_spec()

setupPastMaximums:
    viewPort_init($0400,screen,80,50,80,50)
    rts
.pc = $8000
screen:
    .byte $0