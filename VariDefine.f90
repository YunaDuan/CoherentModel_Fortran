! Define common variables
! Yuna Duan, May 7th

Module VariDefine

Implicit None

! The UWBRAD sensor parameters
! 13 frequencys and 3 incidence angle
Real :: frequency(13)
Real :: theta(3)
frequency=(/0.54,0.66,0.78,0.9,1.02,1.14,1.26,1.38,1.5,1.62,1.74&
,1.86,1.98/)
theta=(/0,40,50/)
frequency=frequency*1.0e9

!variables
Type BrightnessTemperature
        Real ::H
        Real ::V
        REAL ::C
End Type

! Computation constant
Parameter( PI=3.14159)
        
