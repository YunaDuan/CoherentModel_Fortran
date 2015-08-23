!Subroutine to generate temperature profile from Robin Model
!************************************************************
!Input: 1.Surafce temperature - Ts [K]
!       2.Geothermal heat flux - G [w/m2]
!       3.Ice sheet thickness - H [m]
!       4.Snow accumulation rate - M [m/yr]
!       5.The elevation above surface, should be an attay - zh [m]
!         The snow surface has the zh=H
!       6.The size of the depth array zh - LayerNum
!
!Output: An array that contains the corresponding temperature of the depth
!        calculated from Robin model - temperature

Subroutine TempProfile(Ts,G,H,M,zh,temperature,LayerNum)

Implicit None

REAL,Intent(in)::Ts,G,H,M
Integer,Intent(in)::LayerNum
REAL,Dimension(LayerNum),Intent(in)::zh
REAL,Dimension(LayerNum),Intent(out)::temperature

REAL,Dimension(LayerNum)::erf1
REAL,Parameter::kappa=2.70!thermal conductivity
REAL,Parameter::k=45      !thermal diffusivity
REAL,Parameter::PI=3.1415926
REAL::q,b,coef,erf2

q=sqrt(M/2/k/H)
b=sqrt(PI)/2/kappa

coef=G*b/q

erf1=ERF(zh*q)
erf2=ERF(H*q)
temperature=Ts-coef*(erf1-erf2)

End Subroutine 
