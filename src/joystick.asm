
.importonce
.import source "cia.asm"
.import source "vic.asm"
.import source "map.asm"

.namespace joystick {
    init:
            lda cia1.PRB
            jmp saveJoyState

    check:
        clc
        clv
        lda cia1.PRB
        sta joy_currentState
        cmp joy_prevState
        beq saveJoyState        // The state didn't change no need for other checks
        
        cmp #$f5                // Right
        bne !+
        jsr doRight
        jmp saveJoyState

    !:  cmp #$fb                // Left
        bne !+
        jsr doLeft
        jmp saveJoyState

    !:  cmp #$ff                //released
        ldx #3
        stx vic.cborder

    saveJoyState:
            lda joy_currentState
            sta joy_prevState
            rts

    doRight:
        ldx #1
        stx vic.cborder

        

        rts

    doLeft:
        ldx #2
        stx vic.cborder
        jsr viewPort.copyRight
        rts

    joy_currentState:
            .byte $00
    joy_prevState:
            .byte $00    
}

