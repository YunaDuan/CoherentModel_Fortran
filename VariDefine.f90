! Define common variables
! Yuna Duan, May 7th

Module VariDefine

Implicit None

!1.The UWBRAD sensor parameters
! frequencys [Hz] and 3 incidence angle

REAL,Parameter::GreenlandfGhz(12)=(/0.54,0.66,0.804,0.9,1.164,1.26,1.38,&
1.5,1.62,1.74,1.86,1.98/)*1e9
Real,Parameter,Dimension(3)::theta=(/0.0,40.0,50.0/)
Real,Parameter,Dimension(13)::frequency=(/0.54,0.66,0.78,0.9,1.02,1.14,&
1.26,1.38,1.5,1.62,1.74,1.86,1.98/)*1e9

! Computation constant
REAL,Parameter::PI=3.14159

End Module 
