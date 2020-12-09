.import source "../../../vendor/64spec/lib/64spec.asm"
.import source "../../../src/map.asm"
.import source "../../../src/util.asm"

sfspec: :init_spec()
    :describe("renderColLeft")
        :it("renders the leftmost column to the screen")
            jsr setup

            jsr viewPort.renderColLeft
            .watch viewPort.left.lsb
            .watch viewPort.left.msb
            .watch viewPort.left.lsb+1
            .watch viewPort.left.msb+1
            .watch viewPort.left.lsb+2
            .watch viewPort.left.msb+2
            .watch viewPort.left.lsb+3
            .watch viewPort.left.msb+3

.print "testMap="+toHexString(testMap)

            
            
            .print "screen+40=$"+toHexString(screen+40)
            :assert_equal screen:#$03
            :assert_equal screen+40:#$04

    :finish_spec()

setup:
    @viewPort_init(testMap,screen,80,26,3,0)
    rts

.pc = * "Data"

*=$6000
screen:
    .fill 1000, $0

*=$8000
testMap:
    .for (var row=0; row<28; row++) {
        .for (var col=0; col<80; col++) {
            .byte col+row
        }
    }
    