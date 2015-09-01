!Generate Observation 

Program GenerateObs

Use VariDefine
Implicit None

!1.Define variables

REAL,Allocatable,Dimension(:)::H,M,Ts,temperature,G
REAL,Allocatable,Dimension(:)::z,temp
REAL,Allocatable,Dimension(:,:)::density
Integer,Parameter::fre=13,angle=3
REAL,Dimension(angle,fre)::TbH,TbV,TbHm,TbVm
Integer::LayerNum
Integer::i,r,j
Character(len=10)::fname

REAL::start,finish

Real,Parameter::lc=0.4396 !correlation length
Integer,Parameter::std=30!density variation standard

Integer,Parameter::PointNum=47 !number of point calculated along the line
Integer,Parameter::N=500!number of the realziations coherent model runs

Allocate(H(PointNum),M(PointNum),Ts(PointNum),G(PointNum))

!2.Get Model Input
!2.1 Get ground information
!Read ground info from ./dat folder
open(10,File='dat/Ts.dat',Status='old')!Surface Temperature,RACMO
open(20,File='dat/H.dat',Status='old')!!Icesheet thickness,OIB
open(30,File='dat/M.dat',Status='old')!accumulation rate,RACMO
open(40,File='dat/G.dat',status='old')!geothermal heatflux [w/m2]

DO i=1,PointNum
Read(10,*)Ts(i)
Read(20,*)H(i)
Read(30,*)M(i)
Read(40,*)G(i)
END DO

close(10);close(20);close(30);close(40)

!3.Calculate Tb for different setting of parameters
DO i=19,19

print*,'Running point',i,'/',PointNum !time step

!3.1 get grid of layers
CALL GetLayerNumber(H(i),LayerNum)
Allocate(z(LayerNum))
CALL GetGrid(H(i),LayerNum,z)
Allocate(temperature(LayerNum),density(N,LayerNum))

!3.2 calculate temperature profile
CALL TempProfile(Ts(i),G(i),H(i),M(i),(H(i)-z),temperature,LayerNum)
CALL DensityRealization(z,std,lc,LayerNum,N,density)
TbHm=0.0 !tracking the mean of N density realization
TbVm=0.0
CALL CPU_TIME(start)
DO r=1,N
Allocate(temp(LayerNum))!the input of CoherentTb requires
temp=density(r,:)       !rank 1 array while denisty ranks 2

If (mod(r,50) .EQ. 0) Then
print*,'Running realization #',r,'/',N
End If

!write(fname,'(I4)')r
!fname='Obs1/'//trim(adjustl(fname))//'.dat'
!open(70,File=fname,status='new')

CALL CoherentTb(z,temp,temperature,LayerNum,TbH,TbV,fre,angle)
TbHm=TbHm+TbH
TbVm=TbVm+TbV

!Do j=1,fre
!        write(70,"(3f9.3)")TbH(1,j),TbH(2,j),TbH(3,j)
!End do

!Do j=1,fre
!        write(70,"(3f9.3)")TbV(1,j),TbV(2,j),TbV(3,j)
!End do

DEALLOCATE(temp)
END DO

CALL CPU_TIME(finish)
print '("Time = ",f9.3," seconds.")',finish-start
TbHm=TbHm/N;
TbVM=TbVm/N;

Deallocate(z,density,temperature)

write(fname,'(I4)')i!Set Output name
fname='Obs/'//trim(adjustl(fname))//'.dat'
open(50,File=fname,status='new')!geothermal heatflux [w/m2]

DO j=1,fre
write(50,"(3f9.3)")TbHm(1,j),TbHm(2,j),TbHm(3,j)
END DO

Do j=1,fre
write(50,"(3f9.3)")TbVm(1,j),TbVm(2,j),TbVm(3,j)
END DO

close(50)

END DO

End Program
