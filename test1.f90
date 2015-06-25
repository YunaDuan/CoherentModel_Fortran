Program test1

Implicit None

!1.Define variables
!REAL,Dimension(13827)::z
Integer::i,j,Nly
Integer,Parameter::PointNum=47,N=500
REAL,Dimension(5)::temperature,zh
zh=(/0,10,20,30,40/)
temperature=0
CALL tempProfile(280,0.4,3027,zh,0.5,temperature)
print*,temperature
!CALL GetLayerNumber(H,Nly)
!print*,Nly
!CALL Getgrid(H,z)
!print*,Nly
!DO i=1,Nly,1000
!        print*,z(i)
!END DO
 ! Deallocate(z)
!END DO

END PROGRAM











