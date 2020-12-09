#importonce

copyMap2x2LookupTable:
        .byte 0,  4, 8,12,16
        .byte 20,24,28,32,36
        .byte 40,44,48,52,56
        .byte 60,64,68,72,76
        .byte 80,84,88,92,96
        .byte 100,104,108,112,116
        .byte 120,124,128,132,136
        .byte 140,144,148,152,156
        .byte 160,164,168,172,176
        .byte 180,184,188,192,196

charIdx: .byte $00
tileColor: .byte $00
sourceIdx: .byte $00
targetIdx: .byte $00

.macro copyMap2x2(Source, Target, Charset, Colors) {
        
        .label Source2 = Source+60
        .label Source3 = Source+60*2
        .label Source4 = Source+60*3
        .label Source5 = Source+60*4
        .label Target2 = Target + 240
        .label Target3 = Target + 240*2
        .label Target4 = Target + 240*3
        .label Target5 = Target + 240*4
        .label ColorRam = $d800
        .label ColorRam2 = $d800+240
        .label ColorRam3 = $d800+240*2
        .label ColorRam4 = $d800+240*3
        .label ColorRam5 = $d800+240*4
        // find the index if the char ind
        lda #0
        sta sourceIdx
        sta targetIdx
@copyMap2x2Loop:
        ldx sourceIdx

        lda Source,x
        tay
        lda Colors,y
        sta tileColor

        lda copyMap2x2LookupTable,y
        ldy targetIdx
        sta Target,y
        adc #1
        sta Target+1,y
        adc #1
        sta Target+40,y
        adc #1
        sta Target+41,y
        lda tileColor
        sta ColorRam,y
        sta ColorRam+1,y
        sta ColorRam+40,y
        sta ColorRam+41,y

        lda Source2,x
        tay
        lda Colors,y
        sta tileColor
        lda copyMap2x2LookupTable,y
        ldy targetIdx
        sta Target2,y
        adc #1
        sta Target2+1,y
        adc #1
        sta Target2+40,y
        adc #1
        sta Target2+41,y
        lda tileColor
        sta ColorRam2,y
        sta ColorRam2+1,y
        sta ColorRam2+40,y
        sta ColorRam2+41,y

        lda Source3,x
        tay
        lda Colors,y
        sta tileColor
        lda copyMap2x2LookupTable,y
        ldy targetIdx
        sta Target3,y
        adc #1
        sta Target3+1,y
        adc #1
        sta Target3+40,y
        adc #1
        sta Target3+41,y
        lda tileColor
        sta ColorRam3,y
        sta ColorRam3+1,y
        sta ColorRam3+40,y
        sta ColorRam3+41,y

        lda Source4,x
        tay
        lda Colors,y
        sta tileColor
        lda copyMap2x2LookupTable,y
        ldy targetIdx
        sta Target4,y
        adc #1
        sta Target4+1,y
        adc #1
        sta Target4+40,y
        adc #1
        sta Target4+41,y
        lda tileColor
        sta ColorRam4,y
        sta ColorRam4+1,y
        sta ColorRam4+40,y
        sta ColorRam4+41,y

        lda sourceIdx
        cmp #20
        bpl !+
        lda Source5,x
        tay
        lda Colors,y
        sta tileColor
        lda copyMap2x2LookupTable,y
        ldy targetIdx
        sta Target5,y
        adc #1
        sta Target5+1,y
        lda tileColor
        sta ColorRam5,y
        sta ColorRam5+1,y
!:
        clc
        clv
        inc sourceIdx
        inc targetIdx
        inc targetIdx
        lda sourceIdx
        cmp #20
        beq @nextRow
        cmp #40
        beq @nextRow
        cmp #60
        beq @endMapCopy
        jmp @copyMap2x2Loop
@nextRow:
        lda targetIdx
        clc    
        clv
        adc #40
        sta targetIdx
        jmp @copyMap2x2Loop
@endMapCopy:
}

.macro copyMap2x2Multicolor(Source, Target, Charset, Colors, MapCount, MapWidth) {
        .label Source2 = Source+60
        .label Source3 = Source+60*2
        .label Source4 = Source+60*3
        .label Source5 = Source+60*4
        .label Target2 = Target + 240
        .label Target3 = Target + 240*2
        .label Target4 = Target + 240*3
        .label Target5 = Target + 240*4
        .label ColorRam = $d800
        .label ColorRam2 = $d800+240
        .label ColorRam3 = $d800+240*2
        .label ColorRam4 = $d800+240*3
        .label ColorRam5 = $d800+240*4
        // find the index if the char ind
        lda #0
        sta sourceIdx
        sta targetIdx
@copyMap2x2LoopMulti:
        ldy targetIdx
        ldx sourceIdx
        lda Source,x
        sta Target,y
        clc
        adc #$40
        sta Target+1,y
        clc
        adc #$40
        sta Target+40,y
        clc
        adc #$40
        sta Target+41,y

        lda Colors,y
        sta ColorRam,y
        lda Colors+1,y
        sta ColorRam+1,y
        lda Colors+40,y
        sta ColorRam+40,y
        lda Colors+41,y
        sta ColorRam+41,y

        inc targetIdx
        inc targetIdx
        inc sourceIdx
        lda sourceIdx
        cmp #MapWidth
        bne !+
        lda targetIdx
        clc
        adc #40
        sta targetIdx
        jmp @copyMap2x2LoopMulti
!:       cmp #MapCount
        beq !+
        jmp @copyMap2x2LoopMulti
!:       

}
