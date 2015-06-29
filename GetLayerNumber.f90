Subroutine GetLayerNumber(H,Nly)
Integer::Nly
REAL::H

IF(H<=999) THEN
   Nly=(INT(H)-100)/0.5+1+10000
ELSE
   Nly=11799+(INT(H)-1000)+1
END IF
END Subroutine
