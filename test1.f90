Program test1

Use VariDefine
Implicit None

!1.Define variables
REAL,Dimension(3)::G
REAL,Pointer,Dimension(:)::H,M,Ts,temperature
REAL,Pointer,Dimension(:)::z
REAL,Pointer,Dimension(:,:)::density
Integer::i
Integer,Parameter::PointNum=47,N=500
Real,Parameter,Dimension(3)::std=(/20,40,60/)
Real,Parameter::lc=0.4396

Allocate(H(PointNum),M(PointNum),Ts(PointNum))

!2.Get Model Input
!2.1 Set flight line ground info variation
G=(/0.03,0.06,0.09/)!geothermal heat flux,[w/m2]

open(10,File='dat/Ts.dat',Status='old')!Surface Temperature
open(20,File='dat/H.dat',Status='old')!!Icesheet thickness
open(30,File='dat/M.dat',Status='old')!accumulation rate

DO i=1,PointNum
        Read(10,*)Ts(i)
        Read(20,*)H(i)
        Read(30,*)M(i)
END DO
close(10);close(20);close(30)

CALL GetLayerNumber(H(1))
Allocate(temperature(Layer_Num),z(Layer_Num))

CALL GetGrid(H(1),z)
CALL tempProfile(Ts(1),G(1),H(1),z,M(1),temperature)

Allocate(density(N,Layer_Num))

CALL DensityRealization(z,std(1),lc,N,100,density)
DO i=1,Layer_Num,1000
        print*,z(i),temperature(i),density(i,1)
END DO
END PROGRAM




