! Subroutine to add noise to density smooth density profile
!*************************************************************
! Input: 1.the depth array of the ice sheet-z [m] 
!        2.std of noise-std [g/cm3]
!        3.correlation length-lc [m]  
!        4.smooth density profile-rhobar [g/cm3]  
!        5.Number of layers-Layer_Num  
!        6.number of cases-cases
!        7.Seed for generating random number-seed
!
! Output: density with exponentially decay noise -RhoR [g/cm3]
!************************************************************
!Yuna Duan
!Last modified:July 7th,2015


Subroutine DensityRealization(z,std,lc,Layer_Num,cases,rhoR)

Implicit None
Real,Dimension(Layer_Num),Intent(in) :: z
Real,Intent(in)::lc
Integer,Intent(in)::std,cases,Layer_Num
Real,Intent(out)::rhoR(cases,Layer_Num)

Real,Dimension(Layer_Num,Layer_Num) :: c,sigma
!Real*8,Dimension(Layer_Num,Layer_Num) :: temp
Real,Dimension(Layer_Num,1)::rhobar,rhostd
Real,Dimension(cases*Layer_Num)::Rnd
Real,Dimension(cases,Layer_Num)::rhoRall
Integer::i,j,CholFlag

REAL,Parameter::p1=359.7430,p2=42.4020!trend parameters
REAL,Parameter::p3=38.2273!anomaly parameter

! coveriance matrix
Do i=1,Layer_Num
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
!temp=sigma

Do i=1,cases
   RhoR(i,:)=rhobar(:,1)
End Do

!Add the correlated random noise
!Use the subroutine DPOTRF in external library LAPACK to compute
!!cholesky decomposition

CALL SPOTRF('U',Layer_Num,sigma,Layer_Num,CholFlag)
!Check if cholesky decomposition successfully completed 
If (CholFlag .EQ. 0) Then
  print*, 'Cholesky Decomposition successfuly finished'
End If
 
Do i=2,Layer_Num
  Do j=1,i-1
    sigma(i,j)=0.0
  End Do
End DO
    
!generate standard normal distributed random number
CALL RAND_NORMAL(cases*Layer_Num,Rnd)
RhoRall=RESHAPE(Rnd,(/cases,Layer_Num/))
RhoRall=Matmul(RhoRall,sigma)+RhoR

Do i=1,cases
  Do j=1,Layer_Num
    If (z(j)<=100) Then
     RhoR(i,j)=RhoRall(i,j)
    End If
  End Do
End Do

End Subroutine
