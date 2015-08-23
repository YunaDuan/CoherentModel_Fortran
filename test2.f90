!Main Program to run the coherent model.
!Version 1.0 of the program is to test the performance of Coherent Model
!with the same input cluster of MEMLS.

Program RunCoherentModel_v1

Use VariDefine
Implicit None

!1.Define variables

REAL,Pointer,Dimension(:)::H,M,Ts,temperature
REAL,Pointer,Dimension(:)::z,temp
REAL,Pointer,Dimension(:,:)::density
Integer,Parameter::fre=13,angle=3
REAL,Dimension(fre,angle)::TbH,TbV,TbHm,TbVm
REAL,Dimension(fre*2,angle)::Tbm
Integer::LayerNum
Integer::i,j,k,q,r,con
Character(len=10)::fname

Real,Parameter::lc=0.4396 !correlation length
Integer,Parameter,Dimension(3)::std=(/20,40,60/)!density variation standard
REAL,Parameter,Dimension(3)::G=(/0.03,0.06,0.09/)!Geothermal heatflux

Integer,Parameter::PointNum=1 !number of point calculated along the line
Integer,Parameter::N=1!number of the realziations coherent model runs

Allocate(H(PointNum),M(PointNum),Ts(PointNum))

!2.Get Model Input
!2.1 Get ground information
!Read ground info from ./dat folder
open(10,File='dat/Ts.dat',Status='old')!Surface Temperature,RACMO
open(20,File='dat/H.dat',Status='old')!!Icesheet thickness,OIB
open(30,File='dat/M.dat',Status='old')!accumulation rate,RACMO

DO i=1,PointNum
Read(10,*)Ts(i)
Read(20,*)H(i)
Read(30,*)M(i)
END DO

close(10);close(20);close(30)

Ts=Ts-3 !Temperature offset

!3.Calculate Tb for different setting of parameters
DO i=1,PointNum

print*,'Running point',i,'/',PointNum !time step

!3.1 get grid of layers
CALL GetLayerNumber(H(i),LayerNum)
Allocate(z(LayerNum))
CALL GetGrid(H(i),LayerNum,z)
Allocate(temperature(LayerNum),density(N,LayerNum))

!3.2 calculate temperature profile
DO j=1,1 !geothermal heatflux
DO k=1,1 !surface temperature
Ts(i)=Ts(i)+(k-1)*3 !make dTs varies from -3 to 0 and 3
CALL TempProfile(Ts(i),G(j),H(i),M(i),(H(i)-z),temperature,LayerNum)
DO q=1,1!density standard deviation
CALL DensityRealization(z,std(q),lc,LayerNum,N,density)
TbHm=0.0 !tracking the mean of N density realization
TbVm=0.0
DO r=1,1
Allocate(temp(LayerNum))!the input of CoherentTb requires
temp=density(r,:)       !rank 1 array while denisty ranks 2
CALL CoherentTb(z,temp,temperature,LayerNum,TbH,TbV,fre,angle)
TbHm=TbHm+TbH
TbVm=TbVm+TbV
END DO
TbHm=TbHm/N;
TbVM=TbVm/N;
END DO
END DO
Ts(i)=Ts(i)-6
END DO
Deallocate(z,density,temperature,temp)
END DO

Do i=1,fre
print*,TbHm(i,:),TbVm(i,:)
end do
End Program




Subroutine CoherentTb(z,density,temp,LayerNum,TbH,TbV,f,q)

Use VariDefine
Implicit None

Integer,Intent(in)::LayerNum,f,q
REAL,Dimension(LayerNum),Intent(in)::temp,density,z
REAL,Dimension(q,f),Intent(Out)::TbH,TbV

! Varibale define
REAL,Dimension(q):: theta_p
Integer:: i,j,k,Nl
REAL :: k0,kx,kz0
REAL,Pointer,Dimension(:)::d,d1,klz_p,klz_pp,fv,eps_p_reff,thet,alpha,beta,&
eps_pp_ice,eps_pp_reff
COMPLEX,Pointer,Dimension(:)::eps_eff,eps_reff,kl,klz,AA,BB,CC,DD
COMPLEX,Pointer,Dimension(:,:):: mat
COMPLEX:: V_hl(2,2),V_vl(2,2),A_B(2,1),C_D(2,1),Tb_h(q,f),Tb_v(q,f)
COMPLEX::T_h,T_v,r_hl,r_vl
REAL,Parameter::b=1.0/3
REAL,parameter::eps_h=0.9974,eps_s=3.215

!At the Bottom
REAL::T_bot,kz_pp_bot
REAL,Parameter::eps_p_bot= 3.17
REAL,Parameter::eps_pp_bot= 1.0e-4
COMPLEX,Parameter :: eps_bot=(3.17,1.0e-4)
Complex::K_bot,kz_bot,r_h,r_v

Nl=LayerNum

!Allocate arries
Allocate(d(Nl-1),d1(Nl-1),fv(Nl), eps_p_reff(Nl),alpha(Nl),beta(Nl))
Allocate(eps_pp_ice(Nl),eps_pp_reff(Nl),klz_p(Nl-1),klz_pp(Nl-1),thet(Nl))
Allocate(eps_eff(Nl),eps_reff(Nl-1),kl(Nl-1),klz(Nl-1))
Allocate(AA(Nl-1),BB(Nl-1),CC(Nl-1),DD(Nl-1))
!Change observation angle from deg to rad
theta_p=theta*PI/180

T_bot=temp(Nl)
d=z(2:Nl)
d1(1)=0;d1(2:Nl-1)=d(1:Nl-2)

fv=density/917

IF(MaxVal(density)<=400) THEN
eps_p_reff=1+1.4667*fv+1.435*fv**3
ELSE
eps_p_reff=((1-fv)*eps_h**b+fv*eps_s**b)**(1/b)
End If

!Imaginary ice permittivity from Matzler in the DMRT-ML paper
thet=300/temp-1
alpha=(0.00504+0.0062*thet)*Exp(-22.1*thet)

Do i=1,f
Do j=1,q
K0=2.0*PI/(3.0e8)*frequency(i)! Electromagnetic wavenumber
kx=k0*sin(theta_p(j))!horizontal component of the wavenumber
kz0=sqrt(k0**2-kx**2)

!Imaginary ice permittivity from Matzler in the DMRT-ML paper
beta=0.0207/temp*Exp(335.0/temp)/(Exp(335.0/temp)-1)**2+1.16e-11&
*(frequency(i)*1e-9)**2+exp(-9.963+0.0372*(temp-273.16))

eps_pp_ice=alpha/(frequency(i)*1e-9)+beta*frequency(i)*1e-9
eps_pp_reff=eps_pp_ice*(0.52*density/1e3+0.62*(density/1e3)**2)

eps_eff=dcmplx(eps_p_reff,eps_pp_reff)
eps_reff=eps_eff(2:Nl)

!lectromagnetic wavenumber in each layer
Kl = sqrt(eps_reff)*K0
Klz = sqrt(Kl**2 - Kx**2)
Klz_p = Real(Real(Klz))
Klz_pp = Real(Aimag(Klz))

!At the Bottom

!Try to add water at the base, but to do so, the  eps_pp_bot should
!be very large. And this version of the coherent modeldoes not with
!large eps_pp_bot

K_bot = sqrt(eps_bot)*K0
Kz_bot = sqrt(K_bot**2 - Kx**2)
Kz_pp_bot = REAL(Aimag(Kz_bot))

!Bottom Reflection coefficients
r_h=(Klz(Nl-1)-Kz_bot)/(Klz(Nl-1)+Kz_bot)
r_v=(eps_bot*Klz(Nl-1)-eps_reff(Nl-1)*Kz_bot)/(eps_bot*Klz(Nl-1)&
+eps_reff(Nl-1)*Kz_bot)

!Find surface reflection coeff
!reflection coefficients on the bottom already calculated
Do k=Nl-2,1,-1
r_hl=(Klz(k)-Klz(k+1))/(Klz(k)+Klz(k+1))
r_vl=(eps_reff(k+1)*Klz(k)-eps_reff(k)*Klz(k+1))/(eps_reff(k+1)&
*Klz(k)+eps_reff(k)*Klz(k+1));

!Matrix coefficients
r_h=(r_h*exp((0,1)*2*Klz(k+1)*(d(k+1)-d(k)))+r_hl)/(r_h*&
exp((0,1)*2*Klz(k+1)*(d(k+1)-d(k)))*r_hl+1)
r_v=(r_v*exp((0,1)*2*Klz(k+1)*(d(k+1)-d(k)))+r_vl)/(r_v*&
exp((0,1)*2*Klz(k+1)*(d(k+1)-d(k)))*r_vl+1);
End Do

r_hl=(Kz0-Klz(1))/(Kz0+Klz(1))
r_vl=(eps_reff(1)*Kz0-Klz(1))/(eps_reff(1)*Kz0+Klz(1))

r_h=(r_h*exp((0,1)*2*Klz(1)*d(1))+r_hl)/(r_h*exp((0,1)*2*&
Klz(1)*d(1))*r_hl+1)

r_v=(r_v*exp((0,1)*2*Klz(1)*d(1))+r_vl)/(r_v*exp((0,1)*2*&
Klz(1)*d(1))*r_vl+1)

!Calculate up/down going amps in each region
r_hl=(Klz(1)-Kz0)/(Klz(1)+Kz0)
r_vl=(Klz(1)-eps_reff(1)*Kz0)/(Klz(1)+eps_reff(1)*Kz0)

!Recurrence Matrix
!First layer
Allocate(mat(2,2))
mat(1,1)=exp((0,-1)*Klz(1)*d(1))
mat(2,1)=r_hl*exp((0,1)*Klz(1)*d(1))
mat(1,2)=r_hl*exp((0,-1)*Klz(1)*d(1))
mat(2,2)=exp((0,1)*Klz(1)*d(1))
V_hl=1.0/2.0*(1+Kz0/Klz(1))*mat
mat(2,1)=r_vl*exp((0,1)*Klz(1)*d(1))
mat(1,2)=r_vl*exp((0,-1)*Klz(1)*d(1))
V_vl=1.0/2.0*K0/Kl(1)*(1+eps_reff(1)*Kz0/Klz(1))*mat
deallocate(mat)

Allocate(mat(2,1))
mat(1,1)=r_h;mat(2,1)=1.0
A_B=matmul(V_hl,mat)
mat(1,1)=r_v
C_D=matmul(V_vl,mat)
Deallocate(mat)

AA(1)=A_B(1,1)*exp((0,1)*Klz(1)*d(1))
BB(1)=A_B(2,1)*exp((0,-1)*Klz(1)*d(1))
CC(1)=C_D(1,1)*exp((0,1)*Klz(1)*d(1))
DD(1)=C_D(2,1)*exp((0,-1)*Klz(1)*d(1))

! The other layers
allocate(mat(2,2))
Do k=1,Nl-2
r_hl=(Klz(k+1)-Klz(k))/(Klz(k+1)+Klz(k))
r_vl=(eps_reff(k)*Klz(k+1)-eps_reff(k+1)*Klz(k))/(eps_reff(k)&
*Klz(k+1)+eps_reff(k+1)*Klz(k));

mat(1,1)=exp((0,-1)*Klz(k+1)*(d(k+1)-d(k)))
mat(2,1)=r_hl*exp((0,1)*Klz(k+1)*(d(k+1)-d(k)))
mat(1,2)=r_hl*exp((0,-1)*Klz(k+1)*(d(k+1)-d(k)))
mat(2,2)=exp((0,1)*Klz(k+1)*(d(k+1)-d(k)))
V_hl=1.0/2*(1+Klz(k)/Klz(k+1))*mat

mat(2,1)=r_vl*exp((0,1)*Klz(k+1)*(d(k+1)-d(k)))
mat(1,2)=r_vl*exp((0,-1)*Klz(k+1)*(d(k+1)-d(k)))
V_vl=1.0/2*Kl(k)/Kl(k+1)*(1+eps_reff(k+1)/eps_reff(k)*Klz(k)&
/Klz(k+1))*mat

A_B=matmul(V_hl,A_B)
C_D=matmul(V_vl,C_D)

AA(k+1)=A_B(1,1)*exp((0,1)*Klz(k+1)*d(k+1))
BB(k+1)=A_B(2,1)*exp((0,-1)*Klz(k+1)*d(k+1))
CC(k+1)=C_D(1,1)*exp((0,1)*Klz(k+1)*d(k+1))
DD(k+1)=C_D(2,1)*exp((0,-1)*Klz(k+1)*d(k+1))
End Do
Deallocate(mat)

T_h=(BB(Nl-1)*exp((0,1)*Klz(Nl-1)*d(Nl-1))-AA(Nl-1)*&
exp((0,-1)*Klz(Nl-1)*d(Nl-1)))*Klz(Nl-1)/Kz_bot&
*exp((0,-1)*Kz_bot*d(Nl-1))
T_v=(DD(Nl-1)*exp((0,1)*Klz(Nl-1)*d(Nl-1))-CC(Nl-1)*&
exp((0,-1)*Klz(Nl-1)*d(Nl-1)))*Klz(Nl-1)/Kz_bot&
*exp((0,-1)*Kz_bot*d(Nl-1))*sqrt(eps_bot/eps_reff(Nl-1))

!Add up Tb's
Tb_h(j,i)=K0/cos(theta_p(j))*sum(Real(Aimag(eps_reff))/2*&
temp(2:Nl)*(AA*Conjg(AA)/Klz_pp*(exp(2*Klz_pp*d)-exp(2*&
Klz_pp*d1))-BB*Conjg(BB)/Klz_pp*(exp(-2*Klz_pp*d)-exp(-2*Klz_pp&
*d1))+(0,1)*AA*Conjg(BB)/Klz_p*(exp((0,-1)*2*Klz_p*d)-exp((0,-1)&
*2*Klz_p*d1))-(0,1)*BB*Conjg(AA)/Klz_p*(exp((0,1)*2*Klz_p*d)&
-exp((0,1)*2*Klz_p*d1))))+K0/cos(theta_p(j))*Real(Aimag(eps_bot))&
/2*T_bot/Kz_pp_bot*T_h*conjg(T_h)*exp(-2*Kz_pp_bot*d(Nl-1))

Tb_v(j,i)=K0/cos(theta_p(j))*sum(Real(Aimag(eps_reff))/2*&
temp(2:Nl)*(Klz*conjg(Klz)+Kx**2)/Kl/conjg(Kl)*&
(CC*Conjg(CC)/klz_pp*(exp(2*klz_pp*d)-exp(2*klz_pp*d1))-&
DD*conjg(DD)/Klz_pp*(exp(-2*Klz_pp*d)-exp(-2*Klz_pp*d1))&
+(Klz*conjg(Klz)-Kx**2)/(Klz*conjg(Klz)+Kx**2)*CC*conjg(DD)/(0,1)&
/Klz_p*(exp((0,-1)*2*Klz_p*d)-exp((0,-1)*2*Klz_p*d1))&
-(Klz*conjg(Klz)-Kx**2)/(Klz*conjg(Klz)+Kx**2)*DD*conjg(CC)/(0,1)&
/Klz_p*(exp((0,1)*2*Klz_p*d)-exp((0,1)*2*Klz_p*d1))))+&
K0/cos(theta_p(j))*Real(Aimag(eps_bot))/2*T_bot*(Kz_bot*&
conjg(Kz_bot)+Kx**2)/Kz_pp_bot/K_bot/conjg(K_bot)*T_v*conjg(T_v)*&
exp(-2*Kz_pp_bot*d(Nl-1))
End Do
End Do
!Tb_h0=1-abs(r_h)**2
!Tb_v0=1-abs(r_v)**2
TbH = REAL(real(Tb_h))
TbV = REAL(real(Tb_v))

End Subroutine

