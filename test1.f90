Program test1

Implicit None

!1.Define variables
<<<<<<< HEAD
REAL,Dimension(3)::G
REAL,Pointer,Dimension(:)::H,M,Ts,temperature
REAL,Pointer,Dimension(:)::z
REAL,Pointer,Dimension(:,:)::density
Integer::i
Integer,Parameter::PointNum=47,N=1
Real,Parameter,Dimension(3)::std=(/20,40,60/)
Real,Parameter::lc=0.4396
=======
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
>>>>>>> origin/master

END PROGRAM







<<<<<<< HEAD
!CALL DensityRealization(z,std(1),lc,N,100,density)
DO i=1,Layer_Num,500
        print*,z(i),temperature(i)!,density(1,i)
END DO
END PROGRAM
=======




>>>>>>> origin/master
