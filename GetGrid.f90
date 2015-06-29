!Get grid the layer scheme for a specific ice sheet yhickness
!Input: Ice shet thickness H [m]
!Output:Array with depth of each layer

Subroutine GetGrid(H,z)

Use VariDefine
Implicit None

REAL::H
INTEGER::i
Real,Dimension(Layer_Num)::z

IF(H<=999) THEN
  DO i=1,10000
    z(i)=(i-1)*0.01
  END DO
  
  DO i=10001,Layer_Num
    z(i)=100+(i-10000-1)*0.5
  END DO
ELSE 
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
