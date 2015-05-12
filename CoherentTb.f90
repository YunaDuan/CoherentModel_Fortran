!Calculation of the Brightness Temperature with the coherent model.
!Based on Alexander's Matlab code
!Yuna Duan May 8th
!Input: temperature [K]; density [kgm-3] 
!       z denpth of the layer [m]

Function CoherentTb(z,temp,density)

Implicit None
Use Module Varidefine

Type(BrightnessTemperature)::CoherentTb
REAL :: z(:),density(:),temperature(:)
REAL :: theta_p(3)
Integer:: Nl=Size(z)
Integer::i,j,k
REAL :: d(Nl-1),d1(Nl-1),fv(Nl), eps_p_reff(Nl),alpha(Nl),beta(Nl)
REAL :: eps_pp_ice(Nl),eps_pp_reff(Nl),klz_p(Nl-1),klz_pp
COMPLEX,Pointer:: mat(:,:)
COMPLEX:: eps_eff(Nl),eps_reff(Nl-1)，kl(Nl-1),klz(Nl-1)
COMPLEX:: r_hl,r_vl,V_hl(2,2),V_vl(2,2),A_B(2,1),C_D(2,1)
COMPLEX::A(Nl-1),B(Nl-1),C(Nl-1),D(Nl-1),Tb_h(3,13),Tb_v(3,13)
COMPLEX::T_h,T_v
REAL :: k0,kx,kz0
Parameter(b=1.0/3)
parameter(eps_h=0.9974,eps_s=3.215)

!At the Bottom
REAL::T_bot = Ubound(temp),kz_pp_bot
Parameter(eps_p_bot)= 3.17
Parameter(eps_pp_bot)= 1.0e-4
Complex :: eps_bot=(eps_p_bot,eps_pp_bot)
Complex::kbot,kz_bot,r_h,r_v

d=z(2:ubound(z))
d1(1)=0;d1(2:ubound(d1))=d(1:ubound(d))

!Change observation angle from deg to rad
theta_p=theta*PI/180

Do i=1,13
  Do j=1,3
       K0=2.0*PI/(3.0e8)*frequency(i)! Electromagnetic wavenumber
       kx=k0*sin(theta_p(j))!horizontal component of the wavenumber
       kz0=sqrt(k0**2-kx**2)
       fv=density/917

       IF( density<=400)
         eps_p_reff=1+1.4667*fv+1.435*fv**3
       else
         eps_p_reff=((1-fv)*eps_h**b+fv*eps_s**b)**(1/b)
       End If

        !Imaginary ice permittivity from Matzler in the DMRT-ML paper
        alpha=0.00504+0.0062*(300.0/temp-1)*Exp(-22.1*(300.0/temp-1))
        beta=0.0207/temp*Exp(335.0/temp)/(Exp(335.0/temp)-1)**2+1.16e-11&
        *(frequency(i)*1e-9)**2+exp(-9.963+0.0372*(temp-273.16))
        
        eps_pp_ice=alpha/(freq(i)*1e-9)+beta*freq(i)*1e-9
        eps_pp_reff=eps_pp_ice*0.52*density/1e3+0.62*density/1e6

        eps_eff=(eps_p_reff,eps_pp_reff) 
        eps_reff=eps_eff(2:ubound(eps_eff))

        !lectromagnetic wavenumber in each layer
        Kl = sqrt(eps_reff)*K0
        Klz = sqrt(Kl**2 - Kx**2)
        Klz_p = Real(Real(Klz))
        Klz_pp = Real(Aimag(Klz))

        !At the Bottom
        T_bot = temp(end);
        eps_p_bot = 3.17;
        eps_pp_bot = 1e-4;
        
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

        !Calculate up/down going amps in each region
        r_hl=(Klz(1)-Kz0)/(Klz(1)+Kz0)
        r_vl=(Klz(1)-eps_reff(1)*Kz0)/(Klz(1)+eps_reff(1)*Kz0)

        !Recurrence Matrix
        !First layer
        Allocate(mat(2,2))
        mat(1,1)=exp((0,-1)*Klz(1)*d(1));mat(2,1)=r_hl*exp((0,1)*Klz(1)*d(1)
        mat(1,2)=r_hl*exp((0,-1)*Klz(1)*d(1);mat(2,2)=exp((0,1)*Klz(1)*d(1))
        V_hl=1.0/2*(1+Kz0/Klz(1))*mat
        mat(2,1)=r_vl*exp((0,1)*Klz(1)*d(1)
        mat(1,2)=r_vl*exp((0,-1)*Klz(1)*d(1)
        V_vl=1./2.*K0/Kl(1)*(1+eps_reff(1)*Kz0/Klz(1))*mat
        deallocate(mat)

        allocate(mat(2,1))
        mat(1,1)=r_h;mat(2,1)=1.0
        A_B=matmul(V_hl,mat)
        mat(1,1)=r_v
        C_D=matmul(V_vl,mat)
        deallocate(mat)

        A(1)=A_B(1)*exp((0,1)*Klz(1)*d(1))
        B(1)=A_B(2)*exp((0,-1)*Klz(1)*d(1))
        C(1)=C_D(1)*exp((0,1)*Klz(1)*d(1))
        D(1)=C_D(2)*exp((0,-1)*Klz(1)*d(1))

        ! The other layers

        Do k=1,Nl-2
           r_hl=r_hl=(Klz(k+1)-Klz(k))/(Klz(k+1)+Klz(k))
           r_vl=(eps_reff(k)*Klz(k+1)-eps_reff(k+1)*Klz(k))/(eps_reff(k)&
           *Klz(k+1)+eps_reff(k+1)*Klz(k));
           
           allocate(mat(2,2))
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
           
           A(k+1)=A_B(1)*exp((0,1)*Klz(k+1)*d(k+1))
           B(k+1)=A_B(2)*exp((0,-1)*Klz(k+1)*d(k+1))
           C(k+1)=C_D(1)*exp((0,1)*Klz(k+1)*d(k+1))      
           D(k+1)=C_D(2)*exp((0,-1)*Klz(k+1)*d(k+1)) 
         End Do
         deallocate(mat)
         
         T_h=(B(Nl-1)*exp((0,1)*Klz(Nl-1)*d(Nl-1))-A(Nl-1)*&
         exp((0,-1)*Klz(Nl-1)*d(Nl-1)))*Klz(Nl-1)/Kz_bot&
         *exp((0,-1)*Kz_bot*d(Nl-1))
         T_v=(D(Nl-1)*exp((0,1)*Klz(Nl-1)*d(Nl-1))-C(Nl-1)*&
         exp((0,-1)*Klz(Nl-1)*d(Nl-1)))*Klz(Nl-1)/Kz_bot&
         *exp((0,-1)*Kz_bot*d(Nl-1))*sqrt(eps_bot/eps_reff(Nl-1))

         !Add up Tb's
         Tb_h(j,i)=K0/cos(thet_p(i))*sum(Real(Aimag(eps_reff))/2*&
         temp(2:ubound(Tpz))*(A*Conjg(A)/Klz_pp*(exp(2*Klz_pp*d)-exp(2*Klz_pp.*d1))-B.*conj(B)./Klz_pp.*(exp(-2*Klz_pp.*d)-exp(-2*Klz_pp.*d1))
  End Do
End Do

End Function CoherentModel
