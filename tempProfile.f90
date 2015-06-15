! Calculate temperature profile with Robin Model
! Input: Surface temperaure Ts [k]  Geothermal Heatflux G [w/m2]
!        Ice sheet thickness H [m]  Elevation above surface z [m]
!        Netbalance(Accumulation rate) M [m/y]
Subroutine TempProfile(Ts,G,H,zh,M,temperature)

Use VariDefine
Implicit None

REAL::Ts,G,H,S,M
REAL,Dimension(:)::zh,temperature
REAL,Pointer,Dimension(:)erf1
REAL,Parameter::kappa=2.70!thermal conductivity
REAL,Parameter::k=45      !thermal diffusivity
REAL::q,b,coef,erf2

Nl=size(Zh,1)
allocate(erf1(Nl))

q=sqrt(M/2/k/H)
b=sqrt(PI)/2/kappa

coef=G*b/q

erf1=ERF(zh*q)
erf2=ERF(H*q)
temperature=Ts-coef*(erf1-erf2)

End Subroutine 
