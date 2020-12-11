#importonce

.namespace basic {
    .label isrAddr = $0314
    .namespace routine {
        .label stop = $0328
    }

    disableRunStop:
        // Disable run/stop + restore buttons
        lda #$FC        // Low byte for pointer to  routine. Result -> $F6FC
        sta routine.stop
    	rts
}