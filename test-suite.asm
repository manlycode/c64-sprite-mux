.import source "vendor/64spec/lib/64spec.asm"

.segmentdef Data [startAfter="Default"]

sfspec: :init_spec()
    .import source "spec/util-spec.asm"
    .import source "spec/map-spec.asm"

    :finish_spec()
