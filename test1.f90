Program test1

Implicit None

!1.Define variables

REAL,Dimension(3)::G
REAL,Pointer,Dimension(:)::H,M,Ts,temperature
REAL,Pointer,Dimension(:)::z
REAL,Pointer,Dimension(:,:)::density
Integer::i
Integer,Parameter::PointNum=47,N=1
Real,Parameter,Dimension(3)::std=(/20,40,60/)
Real,Parameter::lc=0.4396

CALL tempProfile(280,0.4,3027,zh,0.5,temperature)
End Program