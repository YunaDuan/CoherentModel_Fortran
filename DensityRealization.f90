! Subroutine to add noise to density smooth density profile
! Input: smooth density profile-rhobar [g/cm3]  std of noise-std [g/cm3]
!        correlation length-lc [m]  number of cases-N 
! Output: density with exponentially decay noise -RhoR [g/cm3] 
Subroutine DensityRealization(z,std,lc,N,seed,rhoR)

Implicit None

Real,Dimension(:)::z,randnoise
Real,Pointer,Dimension(:,;)::c,sigma,rhoR,rhoRall,T
Real,Pointer,Dimension(:)rhostd,rhobar
Real::std
Integer::Nly,i,j,N
REAL,Parameter::p1=359.7430,p2=42.4020!trend parameters
REAL,Parameter::p3=38.2273!anomaly parameter


Nly=size(rhobar,1)
Allocate(rhobar(Nly),c(Nly,Nly),sigma(Nly,Nly),rhostd(Nly),)
Allocate(rhoRall(N,Nly),T(Nly,Nly),randnoise(N*Nly))

! coveriance matrix
Do i=1,Nly
  Do j=1,i
     c(i,j)=abs(z(i)-z(j))
     c(j,i)=c(i,j)
  End DO
End DO

!The smooth density profile by Pearce and Walker Model
!CALL HLDensity if using The Herron-longway model(see the HLDensity.f90)
rhobar=(p1-917)*exp(-z/p2)+917

!initial standard deviation 
!The std decay model parameter is fitted from twicker data
c=exp(-c/lc)
rhostd=std*exp(-z/p3)
sigma=DOT_PRODUCT(matmul(rhostd,TRANSPOSE(rhostd)),c)

Do i=1,N
   RhoR(i,:)=rhobar
End Do

!Add the correlated random noise
!Since the sigma here is a square matrix, the steps for checking in mvnrd
!is skipped for efficiency
CALL CHOLESKY(sigma,T,Nly)
CALL RAND_NORMAL(N*Nly,randnoise,seed)
rhoRall=RESHAPE(randnoise,(/N,Nly/))
rhoRall=matmul(rhoRall,T)+rhobar

Do i=1,N
   Forall(z<=100)RhoR(i,z)=RhoRall(i,z)
End Do

End Subroutine
