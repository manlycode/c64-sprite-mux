.import source "../../vendor/64spec/lib/64spec.asm"
.import source "../../src/util.asm"
.segmentdef DATA [startAfter="Default"]

.import source "../../src/sprite-table.asm"

sfspec: :init_spec()
    :describe("screen.clear")
        :it("sorts the table")
            :assert_equal #4:#5

    :finish_spec()


.pc = $8000 "Data"

currentHighest:
    .byte 0
// Data labels go here
unsortedTable:
    .byte 5, 4, 3, 2, 1

expectedTable:
    .byte 1, 2, 3, 4, 5

targetTable:
    .byte 0, 0, 0, 0, 0