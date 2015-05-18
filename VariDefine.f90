! Define common variables
! Yuna Duan, May 7th

Module VariDefine

Implicit None

! The UWBRAD sensor parameters
! 13 frequencys and 3 incidence angle
Real,Parameter,Dimension(13)::frequency=(/0.54,0.66,0.78,0.9,1.02,1.14,&
1.26,1.38,1.5,1.62,1.74,1.86,1.98/)*1e9
Real,Parameter,Dimension(3)::theta=(/0.0,40.0,50.0/)

! Computation constant
REAL,Parameter::PI=3.14159

!Variables for CoherentTb.f90
REAL,Pointer,Dimension(:)::d,d1,klz_p,klz_pp,fv,eps_p_reff,thet,alpha,beta,&
eps_pp_ice,eps_pp_reff
COMPLEX,Pointer,Dimension(:)::eps_eff,eps_reff,kl,klz,AA,BB,CC,DD

REAL,Pointer,Dimension(:)::temp,density,z
End Module 
