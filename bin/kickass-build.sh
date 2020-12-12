#!/usr/bin/env bash

/usr/local/opt/openjdk/bin/java -jar \
  /usr/local/opt/KickAssembler/KickAss.jar \
  -libdir ./libs \
  -libdir ./libs/common/lib \
  -libdir ./libs/chipset/lib \
  -libdir ./libs/copper64/lib \
  -libdir ./libs/text/lib \
  -vicesymbols \
  -debugdump \
  -o $1 $2
