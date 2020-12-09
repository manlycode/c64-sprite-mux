#importonce

.namespace cia1 {
    .label CIA        = $DC00
    .label PRA        = $DC00        // Port A
    .label PRB        = $DC01        // Port B
    .label DDRA       = $DC02        // Data direction register for port A
    .label DDRB       = $DC03        // Data direction register for port B
    .label TA         = $DC04        // 16-bit timer A
    .label TB         = $DC06        // 16-bit timer B
    .label TOD10      = $DC08        // Time-of-day tenths of a second
    .label TODSEC     = $DC09        // Time-of-day seconds
    .label TODMIN     = $DC0A        // Time-of-day minutes
    .label TODHR      = $DC0B        // Time-of-day hours
    .label SDR        = $DC0C        // Serial data register
    .label ICR        = $DC0D        // Interrupt control register
    .label CRA        = $DC0E        // Control register for timer A
    .label CRB        = $DC0F        // Control register for timer B
}

.namespace cia2 {
    .label CIA2       = $DD00
    .label PRA        = $DD00
    .label PRB        = $DD01
    .label DDRA       = $DD02
    .label DDRB       = $DD03
    .label TA         = $DD04
    .label TB         = $DD06
    .label TOD10      = $DD08
    .label TODSEC     = $DD09
    .label TODMIN     = $DD0A
    .label TODHR      = $DD0B
    .label SDR        = $DD0C
    .label ICR        = $DD0D
    .label CRA        = $DD0E
    .label CRB        = $DD0
}



.macro DisableTimers() {
    ldy #$7f        // bit maskf
                    // 7 - Set or Clear the following bits in the mask.
                    // in this case, we're clearing them
    sty cia1.ICR    // CIA1_ICR
    sty cia2.ICR    // CIA2_ICR
}

.macro EnableTimers() {
    lda cia1.ICR
    lda cia2.ICR
}