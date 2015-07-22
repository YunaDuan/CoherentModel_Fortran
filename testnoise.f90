Program testnoise

Implicit None
REAL::H
Integer::Layer_Num
REAL,Pointer,Dimension(:)::z,Rnd
REAL,Pointer,Dimension(:,:)::rhoR,a,b
Integer,Parameter::N=1
Integer,Parameter,Dimension(3)::std=(/20,40,60/)
Real,Parameter::lc=0.4396
Real,Pointer,dimension(:,:)::c,sigma,T,rhobar,rhostd,rhoRall,randnoise
Real*8,pointer,dimension(:,:)::temp
real :: start, finish

Integer::i,j,CholFlag
REAL,Parameter::p1=359.7430,p2=42.4020!trend parameters
REAL,Parameter::p3=38.2273!anomaly parameter

!2.Get Model Input
!2.1 Set flight line ground info variation

!open(20,File='dat/H.dat',Status='old')!!Icesheet thickness
!Read(20,*)H
H=1000
CALL GetLayerNumber(H,Layer_Num)
print*,layer_num
Allocate(z(Layer_Num),Rnd(N*Layer_Num))
Allocate(c(Layer_Num,Layer_Num),sigma(Layer_Num,Layer_Num),T(Layer_Num,Layer_Num))
Allocate(rhobar(Layer_Num,1),rhostd(Layer_Num,1))
Allocate(rhoRall(N,Layer_Num),randnoise(N,Layer_Num))
CALL GetGrid(H,Layer_num,z)

Allocate(rhoR(N,Layer_Num))

! coveriance matrix
Do i=1,Layer_Num
  Do j=1,i
     c(i,j)=abs(z(i)-z(j))
     c(j,i)=c(i,j)
  End DO
End DO



!Do i=1,Layer_Num,10
!        print*,c(i,1:5)
!end do

!The smooth density profile by Pearce and Walker Model
!CALL HLDensity if using The Herron-longway model(see the HLDensity.f90)
rhobar(:,1)=(p1-917)*exp(-z/p2)+917

!initial standard deviation 
!The std decay model parameter is fitted from twicker data
c=-c/lc
c=exp(c)

rhostd(:,1)=std(1)*exp(-z/p3)
sigma=matmul(rhostd,TRANSPOSE(rhostd))
sigma=sigma*c
allocate(temp(Layer_num,Layer_num))
temp=sigma


Do i=1,N
  RhoR(i,:)=rhobar(:,1)
End Do

allocate(a(N,Layer_Num))
!Add the correlated random noise
!use the subroutine DPOTRF in external library LAPACK to compute 
!cholesky decomposition
CALL cpu_time(start)
!CALL cholesky(sigma,T,Layer_Num)
CALL DPOTRF('U',Layer_num,temp,Layer_num,CholFlag)
CALL cpu_time(finish)
print '("Time = ",f8.3," seconds.")',finish-start
print*, 'Cholesky Flag',CholFlag

Do i=1,5
        print*,temp(i,1:5)
End Do
CALL RAND_NORMAL(N*Layer_Num,Rnd)
a=RESHAPE(Rnd,(/N,Layer_Num/))
RhoRall=MATMUL(a,sigma)+RhoR

Do i=1,N
  Do j=1,Layer_Num
    If (z(j)<=100) Then
     RhoR(i,j)=RhoRall(i,j)
    End If
  End Do
End Do

End Program

