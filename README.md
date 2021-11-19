# ScreenDraining
Commodore 64 Screen Draining effect, Assembly code


## ScreenDraining.asm

Load "ScreenDraining.prg" file (load "ScreenDraining",8,1)

then copy/type this code:

new

10 ? chr$(147);

20 ? "Lorem "; chr$(150); "Ipsum is "; chr$(30); "simply dummy "; chr$(5);

30 ? "text of the "; chr$(129); "printing and "; chr$(150); "typesetting ";

40 ? "industry. Lorem Ipsum has "; chr$(156); "been the industry's standard ";

50 ? "dummy text ever since "; chr$(158); "the 1500s, when an unknown ";

60 ? "printer "; chr$(5); "took a galley of type and scrambled it to ";

70 ? "make a type "; chr$(30); "specimen book."

80 ? chr$(17); chr$(5); "[press any key to start drainging]"

90 poke 198,0: wait 198,1

99 sys49152

run


## ScreenDrainingPlus.asm

Load "ScreenDrainingPlus.prg" file and type:

run
