Subroutine GetLayerNumber(H)
! To get the layer number for specific ice sheet thickness
! Layer regime: 1-100m   1cm
!               100-999m 50cm
!               999 and deeper 1m
! Input: Ice sheet thickness- H [m]

Use VariDefine
Implicit None

REAL::H
!Layer_Num is defined in common module VariDefine

IF(H<=999) THEN
   Layer_Num=(INT(H)-100)/0.5+1+10000
ELSE
   Layer_Num=11799+(INT(H)-1000)+1
END IF
END Subroutine
