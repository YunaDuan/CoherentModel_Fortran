! Program to get input for running coherent model
! Include Ice sheet thickness, basal heat flux, accumulation rate and 
! surface temperature

Subroutine GetCMInput

Implicit None
Real :: H(47)
Integer :: i

! Ice sheet thickness
Open(10,File='dat/H.dat',Status='Unknown')
Read(10,*) ! shake off the explaination row
Do i=1,47
  Read(10,*)H(i)
End Do
Close(10)

End Subroutine GetCMInput
