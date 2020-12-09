.segmentdef Data [startAfter="Default", align=$100]


BasicUpstart2(start)

// Entry point
* = $4000
.import source "src/irq_macros.asm"
.import source "src/vchar.asm"
.import source "src/map.asm"
.import source "src/cia.asm"
.import source "src/vic.asm"
.import source "src/joystick.asm"

start:
    sei
    DisableTimers()

    jsr zp.clear
    .break
    jsr joystick.init
    vic_SelectBank(0)
    vic_SelectScreenMemory(1)   // $0400
    vic_SelectCharMemory(14)    // $3000
    

    // Set colors for map
    lda #9
    sta vic.cbg0
    lda #0
    sta vic.cbg1
    lda #15
    sta vic.cbg2

    // copyMap(commando_map,MAP_WIDTH,MAP_HEIGHT,1,1,charset,2048,$0400)

    vic_CopyChars(charset.data,$3000,2048)
    vic_CopyColors(colors)
    // vic_set38ColumnMode()

    jsr initMap
    
    jsr viewPort.renderMap
    // jsr viewPort.copyRight

    EnableTimers()

    addRasterInterrupt irqTop:#0
    cli
    jmp *

irqTop:        
    // Begin Code ----------
    vic_ClearModes()
    vic_StandardCharacterModeOn()
    vic_MultiColorModeOn()
    jsr joystick.check
    
    // End Code -----------
    endISRFinal
    rts

initMap:
    @viewPort_init(commando_map,$0400,80,25,0,0)
    rts

.import source "assets/commando-charset.s"
.import source "assets/commando-colors.s"
.import source "assets/commando-map.s"