
! To get the layer number for specific ice sheet thickness
! Layer regime: 1-100m   1cm
!               100-999m 50cm
!               999 and deeper 1m
!************************************************************
! Input: Ice sheet thickness- H [m]
! Output:Number of layers-Layer_num
!************************************************************
! Yuna Duan
! Last Modified:July 7th,2015

Subroutine GetLayerNumber(H,Layer_Num)
Implicit None

REAL,Intent(in)::H
Integer,Intent(out)::Layer_Num

IF(H<=99.99) THEN
   Layer_Num=INT(H/0.01)+1
END IF

IF(H>99.99 .AND. H<=999) THEN
   Layer_Num=INT((H-100)/0.5)+1+10000
END IF

IF(H>999) THEN
   Layer_Num=11799+(INT(H-1000))+1
END IF

END Subroutine
