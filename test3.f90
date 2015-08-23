!Main Program to run the coherent model.
!Version 1.0 of the program is to test the performance of Coherent Model
!with the same input cluster of MEMLS.

Program test3

Use VariDefine
Implicit None


!1.Define variables

REAL,Pointer,Dimension(:)::H,M,Ts,temperature
REAL,Pointer,Dimension(:)::z,temp
REAL,Pointer,Dimension(:,:)::density
Integer,Parameter::fre=13,angle=3
REAL,Dimension(angle,fre)::TbH,TbV,TbHm,TbVm
Integer::LayerNum
Integer::i,j,k,q,d,r,con
Character(len=10)::fname

REAL::start,finish

Real,Parameter::lc=0.4396 !correlation length
Integer,Parameter,Dimension(3)::std=(/20,40,60/)!density variation standard
REAL,Parameter,Dimension(3)::G=(/0.03,0.06,0.09/)!Geothermal heatflux

Integer,Parameter::PointNum=1 !number of point calculated along the line
Integer,Parameter::N=2!number of the realziations coherent model runs

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

open(40,File='cminput.csv',status='new')
Do d=1,LayerNum
write(40,'(4F9.4)')z(d),temperature(d),density(1,d),density(2,d)
End Do
close(40)

print*,'Ts=',Ts(i),' H=',H(i)
print*,'M=',M(i), ' G=',G(i)
print*,'Layer number is',LayerNum

CALL CPU_TIME(start)
DO r=1,N
Allocate(temp(LayerNum))!the input of CoherentTb requires
temp=density(r,:)       !rank 1 array while denisty ranks 2

If (mod(r,50) .EQ. 0) Then
print*,'Running realization #',r,'/',N
End If

CALL CoherentTb(z,temp,temperature,LayerNum,TbH,TbV,fre,angle)
TbHm=TbHm+TbH
TbVm=TbVm+TbV
END DO
CALL CPU_TIME(finish)
print '("Time = ",f9.3," seconds.")',finish-start
TbHm=TbHm/N;
TbVM=TbVm/N;
con=con+1
!write(fname,'(I4)')con!Set Output name
!CALL WriteOutput(fname,Tbm,fre*2,angle)
END DO
END DO
Ts(i)=Ts(i)-6
END DO
Deallocate(z,density,temperature,temp)
END DO

Do i=1,fre
print*,TbHm(:,i),TbVm(:,i)
end do
End Program

