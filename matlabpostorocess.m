% Read the brightnesstemperature calculated by fortran.
% Weigh the brightness temperature of different angle by antenna pattern
% and visiualize the result

% 1. read the brightness temperature
clear
close all
pointnum=47;fre=13;angle=3;
Tbh=zeros(angle,fre,pointnum);
Tbv=zeros(angle,fre,pointnum);

for i=1:pointnum
    fname=num2str(i);
    fdir=['./Obs/' fname '.dat'];
    Tbh(:,:,i)=csvread(fdir,0,0,[0,0,12,2])';
    Tbv(:,:,i)=csvread(fdir,13,0)';
end

% 2.average the Tb on antenna pattern
% 2.1 read the antenna pattern file
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

for i=1:47
            UWBRADh(i,:)=sum(squeeze(Tbh(:,:,i)).*Glin)./sum(Glin);
            UWBRADv(i,:)=sum(squeeze(Tbv(:,:,i)).*Glin)./sum(Glin);
end

UWBRADc=(UWBRADv+UWBRADh)./2;

% 3.Plot the Tb vs frequency along the flight line
figure,
for i=1:pointnum
    plot(fGHz,UWBRADc(i,:));hold on
end
title('Brightness temperature along the flight line')
xlabel('frequency [Ghz]')
ylabel('Tb [k]')

UWBRADh=UWBRADh';
UWBRADv=UWBRADv';
UWBRADc=UWBRADc';
% 4.Add random noise to the observation and plot
sigTb=0.5; %observational uncertainty
v=randn(size(UWBRADc)).*sigTb;
TbObs=UWBRADc+v;

figure,
pcolor(1:pointnum,fGHz,TbObs)
set(gca,'FontSize',14)
xlabel('Distance along flight line')
ylabel('Frequency, GHz')
colorbar

% 5.Calculate the standard deviation of the Observation and compare with 
%   MEMLS results
MEMLSTb=load('dat/TbObs.mat');
difTbObs=TbObs-MEMLSTb.TbObs;

figure,
pcolor(1:pointnum,fGHz,difTbObs)
set(gca,'FontSize',14)
xlabel('Distance along flight line')
ylabel('Frequency, GHz')
colorbar

figure,
plot(fGHz,UWBRADc(:,1),'linewidth',2)
xlabel('frequency [Ghz]')
ylabel('Tb [k]')





