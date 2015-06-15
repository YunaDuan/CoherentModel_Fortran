! Subroutine to add noise to density smooth density profile
! Input: smooth density profile-rhobar [g/cm3]  std of noise-std [g/cm3]
!        correlation length-lc [m]  number of cases-N 
! Output: density with exponentially decay noise -RhoR [g/cm3] 
Subroutine DensityRealization(rhobar,std,lc,N,rhoR)

Use VariDefine
Implicit None

Real,Dimension(:)::rhobar
Real,Pointer,Dimension(:,;)::c,sigma,rhoR
Real,Pointer,Dimension(:)rhostd
Real::std
Integer::Nly,i,j,N

Nly=size(rhobar,1)
Allocate(c(Nly,Nly),sigma(Nly,Nly),rhostd(Nly),rhoR(N,Nly))

! coveriance matrix
Do i=1,Nly
  Do j=1,i
     c(i,j)=abs(z(i)-z(j))
     c(j,i)=c(i,j)
  End DO
End DO

!initial standard deviation 
!The std decay model parameter is fitted from twicker data
c=exp(-c/lc)
rhostd=std*exp(-z/38.2273)
sigma=DOT_PRODUCT(matmul(rhostd,TRANSPOSE(rhostd)),c)


End Subroutine
