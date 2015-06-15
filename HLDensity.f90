! Get density profile from the Herron-longway model
! Input: the layer depth z[m]   mean temperature T [K]
!        accumulation rate a [m/year]
! Output: smooth density profile density [kg/m3]
Subroutine HLDensity(z,T,a,density)

Implicit None
REAL,Dimension(:)z,density

REAL,Parameter::rhoi=0.917 !the density of pure ice kg/m3
REAL,Parameter::rho0=0.32 !fitted surface density,may be different from   
                          !actual surface density
REAL,Parameter::R=8.3144621 !gas constant j/mol/k
REAL::h55! the depth where the density reaches 550 g/cm3
REAL::expon,k0,k1,Z0,Z1

Integer::i,j,Num
REAL::T,a

Num=size(z,1)
density=0.917!initinate the density array with the density of ice

! Density profile is divided into two part by the depth h55
! h55 is the depth where the density reaches 550 g/cm3
k0=11*exp(-10160/R/T)
k1=575*exp(-21400/R/T)
h55=(1.0/rhoi/k0*(log(.55/(rhoi-.55))-log(rho0/(rhoi-rho0))))

DO i=1,Num
  IF(z(i)<h55) THEN
    expon=k0*rhoi*z(i)+log(rho0/(rhoi-rho0))
    Z0=exp(expon)
    density(i)=rhoi*Z0/(1+Z0)
  ELSE
    expon=k1*rhoi*(z(i)-h55)/sqrt(A)+log(0.55/(rhoi-0.55))
    Z1=exp(expon)
    density(i)=rhoi*Z1/(1+Z1)
  END IF
  
  IF((density(i)-rhoi)<1e-5) EXIT !exit the loop if the density reaches rhoi
END DO

End Subroutine
