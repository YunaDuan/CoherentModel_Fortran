%function [Tb_V,Tb_H,Tb] = coherent_model(Input_param)
% Calculation of the Brightness Temperature with the coherent model
load('Input_param3.mat')
z = Input_param.depth ;
density = Input_param.density_profile ;
Tpz = Input_param.Temp_profile ;
freq=Input_param.frequency;
thet=Input_param.theta;


d = z(2:end);
d1 = [0 d(1:end-1)];
Nl = length(z)-1;

%thet = 0;             % Observation Angle in deg
thet_p = thet*pi/180; % Observation Angle in rad

fv = density./917 ; %density is in kg.m^-3
b = 1/3;
eps_h = 0.9974;
eps_s =3.215 ; 


if(density<=400)
    eps_p_reff = 1 + 1.4667.*fv + 1.435.*fv.^3 ;
else
   eps_p_reff = ((1-fv).*eps_h^b + fv.*eps_s^b).^(1/b) ;
   
end

Theta = 300./Tpz -1;
alpha = (0.00504 +0.0062.*Theta).*exp(-22.1.*Theta);

for f=1:length(freq)
    for t=1:length(thet)

K0 = 2*pi/(3e8)*freq(f); % Electromagnetic wavenumber

Kx= K0*sin(thet_p(t)) ; % horizontal component of the wavenumber in each ice layer
Kz0 =sqrt(K0^2-Kx^2);
%disp([num2str(k0) num2str(kx) ])

%Imaginary Ice Permittivity from Matzler in the DMRT-ML paper

beta = 0.0207./Tpz.*(exp(335./Tpz)./(exp(335./Tpz)-1).^2) +1.16e-11.*(freq(f).*1e-9).^2+exp(-9.963+0.0372.*(Tpz-273.16));

eps_pp_ice = alpha./(freq(f).*1e-9) + beta.*(freq(f).*1e-9);

eps_pp_reff = eps_pp_ice.*(0.52.*density./(1e3) + 0.62.*(density./(1e3)).^2);

eps_eff = eps_p_reff +1i.*eps_pp_reff;
eps_reff = eps_eff(2:end);

% Electromagnetic wavenumber in each layer:
Kl = sqrt(eps_reff).*K0;
Klz = sqrt(Kl.^2 - Kx^2);
Klz_p = real(Klz);
Klz_pp = imag(Klz);

%At the Bottom
T_bot = Tpz(end);
eps_p_bot = 3.17;
eps_pp_bot = 1e-4;

 %eps_p_bot = 3.17;
 
 % Try to add water at the base, but to do so, the  eps_pp_bot should be
 % very large. And this version of the coherent model does not with large eps_pp_bot 
%  T_bot = 273;
%  eps_pp_bot = 1e-4;
%  eps_p_bot = 80;

% eps_p_bot = eps_p_reff(end);
% eps_pp_bot = eps_pp_reff(end);
eps_bot = eps_p_bot + 1i.*eps_pp_bot;

K_bot = sqrt(eps_bot).*K0;
Kz_bot = sqrt(K_bot^2 - Kx^2);
Kz_pp_bot = imag(Kz_bot);

% Bottom Reflection coefficients 
r_h=(Klz(Nl)-Kz_bot)/(Klz(Nl)+Kz_bot); 
r_v=(eps_bot*Klz(Nl)-eps_reff(Nl)*Kz_bot)/(eps_bot*Klz(Nl)+eps_reff(Nl)*Kz_bot);

% Find surface reflection coeff

for l=Nl-1:-1:1 % reflection coefficients on the bottom already calculated
    
    r_hl=(Klz(l)-Klz(l+1))/(Klz(l)+Klz(l+1));
    r_vl=(eps_reff(l+1)*Klz(l)-eps_reff(l)*Klz(l+1))/(eps_reff(l+1)*Klz(l)+eps_reff(l)*Klz(l+1));
    
    %Matrix coefficients
    r_h=(r_h*exp(1i*2*Klz(l+1)*(d(l+1)-d(l)))+r_hl)/(r_h*exp(1i*2*Klz(l+1)*(d(l+1)-d(l)))*r_hl+1);
    r_v=(r_v*exp(1i*2*Klz(l+1)*(d(l+1)-d(l)))+r_vl)/(r_v*exp(1i*2*Klz(l+1)*(d(l+1)-d(l)))*r_vl+1);
    
end

r_hl=(Kz0-Klz(1))/(Kz0+Klz(1));
r_vl=(eps_reff(1)*Kz0-Klz(1))/(eps_reff(1)*Kz0+Klz(1));

r_h=(r_h*exp(1i*2*Klz(1)*d(1))+r_hl)/(r_h*exp(1i*2*Klz(1)*d(1))*r_hl+1);
r_v=(r_v*exp(1i*2*Klz(1)*d(1))+r_vl)/(r_v*exp(1i*2*Klz(1)*d(1))*r_vl+1);

% Calculate up/down going amps in each region

r_hl=(Klz(1)-Kz0)/(Klz(1)+Kz0);
r_vl=(Klz(1)-eps_reff(1)*Kz0)/(Klz(1)+eps_reff(1)*Kz0);

% Recurrence Matrix
%First Layer
V_hl=1./2.*(1+Kz0/Klz(1))*[exp(-1i*Klz(1)*d(1)) r_hl*exp(-1i*Klz(1)*d(1));
    r_hl*exp(1i*Klz(1)*d(1)) exp(1i*Klz(1)*d(1))];

V_vl=1./2.*K0/Kl(1)*(1+eps_reff(1)*Kz0/Klz(1))*[exp(-1i*Klz(1)*d(1)) r_vl*exp(-1i*Klz(1)*d(1));
    r_vl*exp(1i*Klz(1)*d(1)) exp(1i*Klz(1)*d(1))];

A_B=V_hl*[r_h;1];
C_D=V_vl*[r_v;1];

A(1)=A_B(1)*exp(1i*Klz(1)*d(1));
B(1)=A_B(2)*exp(-1i*Klz(1)*d(1));
C(1)=C_D(1)*exp(1i*Klz(1)*d(1));
D(1)=C_D(2)*exp(-1i*Klz(1)*d(1));

%The other layers
for l=1:Nl-1
    r_hl=(Klz(l+1)-Klz(l))/(Klz(l+1)+Klz(l));
    r_vl=(eps_reff(l)*Klz(l+1)-eps_reff(l+1)*Klz(l))/(eps_reff(l)*Klz(l+1)+eps_reff(l+1)*Klz(l));
    
    V_hl=1./2.*(1+Klz(l)/Klz(l+1))*[exp(-1i*Klz(l+1)*(d(l+1)-d(l))) r_hl*exp(-1i*Klz(l+1)*(d(l+1)-d(l)));
        r_hl*exp(1i*Klz(l+1)*(d(l+1)-d(l))) exp(1i*Klz(l+1)*(d(l+1)-d(l)))];
    
    V_vl=1./2.*Kl(l)/Kl(l+1)*(1+eps_reff(l+1)./eps_reff(l)*Klz(l)/Klz(l+1))*[exp(-1i*Klz(l+1)*(d(l+1)-d(l))) r_vl*exp(-1i*Klz(l+1)*(d(l+1)-d(l)));
        r_vl*exp(1i*Klz(l+1)*(d(l+1)-d(l))) exp(1i*Klz(l+1)*(d(l+1)-d(l)))];
    
    A_B=V_hl*A_B;
    C_D=V_vl*C_D;
    
    A(l+1)=A_B(1)*exp(1i*Klz(l+1)*d(l+1));
    B(l+1)=A_B(2)*exp(-1i*Klz(l+1)*d(l+1));
    C(l+1)=C_D(1)*exp(1i*Klz(l+1)*d(l+1));
    D(l+1)=C_D(2)*exp(-1i*Klz(l+1)*d(l+1));
end

T_h=(B(Nl)*exp(1i*Klz(Nl)*d(Nl))-A(Nl)*exp(-1i*Klz(Nl)*d(Nl)))*Klz(Nl)/Kz_bot*exp(-1i*Kz_bot*d(Nl));
T_v=(D(Nl)*exp(1i*Klz(Nl)*d(Nl))-C(Nl)*exp(-1i*Klz(Nl)*d(Nl)))*Klz(Nl)/Kz_bot*exp(-1i*Kz_bot*d(Nl))*sqrt(eps_bot/eps_reff(Nl));

% Add up Tb's

Tb_h(t,f)=K0/cos(thet_p(t))*sum(imag(eps_reff)/2.*Tpz(2:end).*(A.*conj(A)./Klz_pp.*(exp(2*Klz_pp.*d)-exp(2*Klz_pp.*d1)) ...
    -B.*conj(B)./Klz_pp.*(exp(-2*Klz_pp.*d)-exp(-2*Klz_pp.*d1)) ...
    +1i*A.*conj(B)./Klz_p.*(exp(-1i*2*Klz_p.*d)-exp(-1i*2*Klz_p.*d1)) ...
    -1i*B.*conj(A)./Klz_p.*(exp(1i*2*Klz_p.*d)-exp(1i*2*Klz_p.*d1)))) ...
    +K0/cos(thet_p(t))*imag(eps_bot)/2*T_bot/Kz_pp_bot*T_h*conj(T_h)*exp(-2*Kz_pp_bot*d(Nl));

 Tb_v(t,f)=K0/cos(thet_p(t))*sum(imag(eps_reff)/2.*Tpz(2:end).*(Klz.*conj(Klz)+Kx^2)./Kl./conj(Kl)...
     .*(C.*conj(C)./Klz_pp.*(exp(2*Klz_pp.*d)-exp(2*Klz_pp.*d1))-D.*conj(D)./Klz_pp.*(exp(-2*Klz_pp.*d)-exp(-2*Klz_pp.*d1)) ...
     +(Klz.*conj(Klz)-Kx^2)./(Klz.*conj(Klz)+Kx^2).*C.*conj(D)/1i./Klz_p.*(exp(-1i*2*Klz_p.*d)-exp(-1i*2*Klz_p.*d1)) ...
     -(Klz.*conj(Klz)-Kx^2)./(Klz.*conj(Klz)+Kx^2).*D.*conj(C)/1i./Klz_p.*(exp(1i*2*Klz_p.*d)-exp(1i*2*Klz_p.*d1)))) ...
     +K0/cos(thet_p(t))*imag(eps_bot)/2*T_bot*(Kz_bot*conj(Kz_bot)+Kx^2)/Kz_pp_bot/K_bot/conj(K_bot)*T_v*conj(T_v)*exp(-2*Kz_pp_bot*d(Nl)); 
    
 p1=imag(eps_reff)/2.*Tpz(2:end).*(Klz.*conj(Klz)+Kx^2)./Kl./conj(Kl);
 p2=C.*conj(C)./Klz_pp.*(exp(2*Klz_pp.*d)-exp(2*Klz_pp.*d1));
 
    
    
    end
end
Tb_h0=1-abs(r_h)^2;
Tb_v0=1-abs(r_v)^2;

Tb_V = real(Tb_v);
Tb_H = real(Tb_h);

Tb = (Tb_V+Tb_H)./2;
return

