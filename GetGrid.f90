!Get grid the layer scheme for a specific ice sheet yhickness
!*************************************************************
!Input: Ice shet thickness- H [m]
!       Number of layers-Layer_num

!Output:Array with depth of each layer
!*************************************************************
!Yuna Duan
!last modified: July 7th,2015

Subroutine GetGrid(H,Layer_num,z)

Implicit None

REAL,Intent(in)::H
Integer,Intent(in)::Layer_Num
Real,Dimension(Layer_Num),Intent(out)::z

INTEGER::i

IF(H<=99.99) THEN
  DO i=1,Layer_Num
    z(i)=(i-1)*0.01
  END DO
END IF

IF(H>99.99 .AND. H<=999) THEN
  DO i=1,10000
    z(i)=(i-1)*0.01
  END DO
  
  DO i=10001,Layer_Num
    z(i)=100+(i-10000-1)*0.5
  END DO
END IF

IF(H>999) THEN
  DO i=1,10000
    z(i)=(i-1)*0.01
  END DO
  
  DO i=10001,11799
    z(i)=100+(i-10000-1)*0.5
  END DO

  DO i=11800,Layer_Num
    z(i)=1000+(i-11799-1)
  END DO
END IF

END Subroutine
