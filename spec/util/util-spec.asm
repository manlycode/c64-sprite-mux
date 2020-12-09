.import source "../../vendor/64spec/lib/64spec.asm"
.import source "../../src/util.asm"

sfspec: :init_spec()
    :describe("mov")
        :it("moves the value at src to dest")
            mov src:dest
            :assert_equal #$22:dest

    :describe("setPtr"); {
        :describe("when given an absolute address")
            :it("sets the pointer to the address")
                lda #$00
                sta ptr
                sta ptr+1
                
                setPtr $ddff:ptr
                :assert_equal #$ff:ptr
                :assert_equal #$dd:ptr+1
        :describe("when given a label"); {
            :it("sets the pointer to the address")
                lda #0
                sta ptr
                sta ptr+1

                setPtr src:ptr
                :assert_equal #<src:ptr
                :assert_equal #>src:ptr+1
        }
    }
    :finish_spec()

.pc = * "Data"
// Data labels go here
src: .byte $22
dest: .byte $0
ptr: .word $0000