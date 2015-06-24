!Main Program to run the coherent model.
!Version 1.0 of the program is to test the performance of Coherent Model
!with the same input cluster of MEMLS.
!The temperature profile is calculated from function tempProfile while the
!density profile came from existing matlab data.

Program RunCoherentModel_v1

Use VariDefine
Implicit None

!1.Define variables
REAL,Dimension(3)::G
REAL,Pointer,Dimension(:)::H,M,Ts,temperature
REAL,Pointer,Dimension(:)::z,temp
REAL,Pointer,Dimension(:,:)density
REAL,Dimension(3,13)::TbH,TbV,TbHm,TbVm 
Integer::Nly,i,j,k,m,q,r

Integer,Parameter::PointNum=47,N=500
Real,Parameter::lc=0.4396
Integer,Parameter,Dimension(3)::std=(/20,40,60/)

Allocate(H(PointNum),M(PointNum),Ts(PointNum))

!2.Get Model Input
!2.1 Set flight line ground info variation
G=(/0.03,0.06,0.09/)!geothermal heat flux,[w/m2]

open(10,File='dat/Ts.dat',Status='old')!Surface Temperature
open(20,File='dat/H.dat',Status='old')!!Icesheet thickness
open(30,File='dat/M.dat',Status='old')!accumulation rate

DO i=1,PointNum
   Read(10,*)Ts(i)
   Read(20,*)H(i)
   Read(30,*)M(i)
END DO

close(10);close(20);close(30)

Ts=Ts-3 !Temperature offset
!3.Calculate Tb for different setting of parameters
DO i=1,PointNum
  TbHm=0.0
  TbVm=0.0      
  print*,'Running point',i,'/',PointNum !time step
  !3.1 get grid of layers
  CALL Getgrid(H(i),z)
  Nly=size(z,1)
  Allocate(temperature(Nly),density(N,Nly))
  !3.2 calculate temperature profile 
  DO j=1,3 !geothermal heatflux
    DO k=1,3 !surface temperature
      Ts(i)=Ts(i)+(k-1)*3 !make dTs varies from -3 to 0 and 3
      CALL TempProfile(Ts(i),G(j),H(i),(H(i)-z),M(i),temperature)
      Di m=1,3
        CALL DensityRealization(z,std(m),lc,N,1,density)
        DO q=1,N
          CALL CoherentTb(z,density(q,:),temperature,TbH,TbV)
          TbHm=TbHm+TbH
          TbVm=TbVm+TbV
        END DO        
      END DO
    END DO
    Ts(i)=Ts(i)-6 
  END DO
  TbHm=TbHm/N;
  TbVM=TbVm/N;
  CALL WriteOutput
  Deallocate(z,density,temperature)  
END DO
End Program RunCoherentModel_v1
















