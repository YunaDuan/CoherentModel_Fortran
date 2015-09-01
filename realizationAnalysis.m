%%  analysis the 500 realizations
% 1. read the brightness temperature
clear
close all

N=500;fre=13;angle=3;
Tbh=zeros(angle,fre,N);
Tbv=zeros(angle,fre,N);

for i=1:N
    fname=num2str(i);
    fdir=['./Realizations/R500/' fname '.dat'];
    Tbh(:,:,i)=csvread(fdir,0,0,[0,0,12,2])';
    Tbv(:,:,i)=csvread(fdir,13,0)';
end

fname='ConicalSpiral_40Turns_NoseConeGeometry.csv';
fdir=['./dat/' fname];
AntennaPattern=csvread(fdir,1,1,[1,1,181,16]);    
SensorTheta=180:-2:-180;
SensorfGHz=linspace(0.5,2,16);

fGHz=[0.54,0.66,0.78,0.9,1.02,1.14,1.26,1.38,1.5,1.62,1.74,1.86,1.98];
tetad=[0 40 50];

% 2.2 average the Tb 
for f=1:length(fGHz)
    [~,fclose]=min(fGHz(f)-SensorfGHz);    
    for q=1:length(tetad),
        j=find(SensorTheta==tetad(q));
        GdB(q,f)=AntennaPattern(j,fclose);
    end
    
end
Glin=10.^(GdB./10);

for i=1:N
            UWBRADh(i,:)=sum(squeeze(Tbh(:,:,i)).*Glin)./sum(Glin);
            UWBRADv(i,:)=sum(squeeze(Tbv(:,:,i)).*Glin)./sum(Glin);
end
UWBRADc=(UWBRADh+UWBRADv)/2;

%3. Error Analysis
Stdh=std(UWBRADh);
Stdv=std(UWBRADv);
Stdc=std(UWBRADc);

% get the std of the mean Tb
stdhm=Stdh./sqrt(500);
stdvm=Stdv./sqrt(500);
stdcm=Stdc./sqrt(500);

figure,
plot(fGHz,Stdh,fGHz,Stdv,fGHz,Stdc,'linewidth',2);
set(gca,'fontsize',14)
xlabel('frequency Ghz');ylabel('std of Tb K')
legend('H','V','C')
title('Std of 500 realizations')

figure,
plot(fGHz,stdhm,fGHz,stdvm,fGHz,stdcm,'linewidth',2);
set(gca,'fontsize',14)
xlabel('frequency Ghz');ylabel('std of Tb K')
legend('H','V','C')
title('Accuacy of 500 realizations')

% suppose the std of the mean is 0.1 K
% std_m=std/sqrt(n);
nh=(Stdh./0.1).^2;
nv=(Stdv./0.1).^2;
nc=(Stdc./0.1).^2;

figure,
plot(fGHz,nh,fGHz,nv,fGHz,nc,'linewidth',2);
set(gca,'fontsize',14)
xlabel('frequency Ghz');ylabel('realizations')
legend('H','V','C')
title('Realizations Needed for 0.1K accuracy')
