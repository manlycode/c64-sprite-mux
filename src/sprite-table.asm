.import source "util.asm"
.import source "vic.asm"

.const ZONE_COUNT = vic.SCREEN_HEIGHT/vic.SPRITE_HEIGHT
.print "ZONE_COUNT: "+ZONE_COUNT

.segment DATA
spritePtrLsb:
spritePtrMsb:
spriteYPosition:
