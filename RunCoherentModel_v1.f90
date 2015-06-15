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
REAL,Pointer,Dimension(:)::H,M,Ts
REAL,Pointer,Dimension(:)::z,temp
REAL,Pointer,Dimension(:,:)density
REAL,Pointer,Dimension(:,:,:)temperature
Integer::Nly,i,j,k,m,n,q
Real::Tsm,Mm
Integer,Parameter::PointNum=47
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
Tsm=sum(Ts)/PointNum;!mean Ts for density model
Mm=sum(M)/PointNmu!mean accumulation rate for density model

Ts=Ts-3 !Temperature offset
!3.Calculate Tb for different setting of parameters
DO i=1,PointNum
  print*,'Running point',i,'/',PointNum !time step
  !3.1 get grid of layers
  CALL Getgrid(H(i),z)
  Nly=size(GetGrid,1)
  Allocate(temperature(Nly),temperature(Nl,3,3),temp(Nl),density(Nly))
  
  !3.2 calculate temperature profile 
  DO j=1,3 !geothermal heatflux
    DO k=1,3 !surface temperature
      Ts(i)=Ts(i)+(k-1)*3 !make dTs varies from -3 to 0 and 3
      CALL TempProfile(Ts(i),G(j),H(i),(H(i)-Getgrid),M(i),temp)
      temperature(:,k,j)=tempe
    END DO
    Ts(i)=Ts(i)-6 
  END DO
  
  !3.3 density profile
  !    According to Ken's presentation, the variation of density is small
  !    due to the change of input. So a single density profile is used which
  !    ignores all the possible change due with different inputs.

      CALL HLDensity(z,Tsm,Mm,temp)

      DO m=1,3 !different standard deviation
        
        CALL CoherentTb
        CALL WriteOutput
      END DO
Deallocate(temperature,temp,densite,z)
END DO
End Program RunCoherentModel_v1
















