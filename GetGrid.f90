!Get grid the layer scheme for a specific ice sheet yhickness
!Input: Ice shet thickness H [m]
!Output:Array with depth of each layer

Subroutine GetGrid(H,z)

Implicit None

REAL::H
INTEGER::Nly,i
Real,Pointer,Dimension(:)::z

IF(H<=999) THEN
  Nly=(INT(H)-100)/0.5+1+10000
  Allocate(z(Nly))
  DO i=1,10000
    z(i)=(i-1)*0.01
  END DO
  
  DO i=10001,Nly
    z(i)=100+(i-10000-1)*0.5
  END DO
ELSE 
  Nly=11799+(INT(H)-1000)+1
  Allocate(z(Nly))
  DO i=1,10000
    z(i)=(i-1)*0.01
  END DO
  
  DO i=10001,11799
    z(i)=100+(i-10000-1)*0.5
  END DO

  DO i=11800,Nly
    z(i)=1000+(i-11799-1)
  END DO
END IF

END Subroutine
