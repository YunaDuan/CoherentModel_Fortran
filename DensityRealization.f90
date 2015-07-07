! Subroutine to add noise to density smooth density profile
!*************************************************************
! Input: 1.the depth array of the ice sheet-z [m] 
!        2.std of noise-std [g/cm3]
!        3.correlation length-lc [m]  
!        4.smooth density profile-rhobar [g/cm3]  
!        5.Number of layers-Layer_Num  
!        6.number of cases-N
!        7.Seed for generating random number-seed
!
! Output: density with exponentially decay noise -RhoR [g/cm3]
!************************************************************
!Yuna Duan
!Last modified:July 7th,2015


Subroutine DensityRealization(z,std,lc,Layer_Num,N,seed,rhoR)

Implicit None

Real,Dimension(Layer_Num),Intent(in) :: z
Real,Intent(in)::std,lc
Integer,Intent(in)::N,seed,Layer_Num
Real,Intent(out)::rhoR(N,Layer_Num)

Real,Dimension(Layer_Num,Layer_Num) :: c,sigma,T
Real,Dimension(Layer_Num,1)::rhobar,rhostd
Real,Dimension(N,Layer_Num)::rhoRall,randnoise
Integer::i,j

REAL,Parameter::p1=359.7430,p2=42.4020!trend parameters
REAL,Parameter::p3=38.2273!anomaly parameter

! coveriance matrix
Do i=1,Nly
  Do j=1,i
     c(i,j)=abs(z(i)-z(j))
     c(j,i)=c(i,j)
  End DO
End DO

!The smooth density profile by Pearce and Walker Model
!CALL HLDensity if using The Herron-longway model(see the HLDensity.f90)
rhobar(:,1)=(p1-917)*exp(-z/p2)+917

!initial standard deviation 
!The std decay model parameter is fitted from twicker data
c=-c/lc
c=exp(c)
rhostd(:,1)=std*exp(-z/p3)
sigma=matmul(rhostd,TRANSPOSE(rhostd))
sigma=sigma*c

Do i=1,N
   RhoR(i,:)=rhobar(i,:)
End Do

!Add the correlated random noise
CALL MVNRND(rhobar,sigma,rhoRall,N,Layer_Num,1,Layer_Num,Layer_Num,seed)

Do i=1,N
  Do j=1,Layer_Num
    If (z(j)<=100) Then
     RhoR(i,j)=RhoRall(i,j)
    End If
  End Do
End Do

End Subroutine
