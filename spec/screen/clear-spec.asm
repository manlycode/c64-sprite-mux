.import source "../../vendor/64spec/lib/64spec.asm"
.import source "../../src/screen.asm"

sfspec: :init_spec()
    :describe("screen.clear")
        :it("sets the msb")
            @initScreen(myScreen)

            :assert_equal screen.ptrs:#$8000
            :assert_equal screen.ptrs:#$8100
            :assert_equal screen.ptrs:#$8200
            :assert_equal screen.ptrs:#$8300
            jsr screen.clear

            :assert_equal myScreen:#$00

    :finish_spec()

.pc = $8000 "Data"
// Data labels go here
myScreen:
    .fill 1000, $fe