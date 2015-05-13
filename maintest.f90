Program testsubs

Use VariDefine

Implicit None
Real :: T(8827),rho(8827),z(8827)
Integer :: i

Open(10,File='dat/T.dat',Status='Unknown')
Open(20,File='dat/z.dat',Status='Unknown')
Open(30,File='dat/rho.dat',Status='Unknown')

Do i=1,8827
   Read(10,*)T(i)
   Read(20,*)z(i)
   Read(30,*)rho(i)
End Do

Close(10);Close(20);Close(30)

Call CoherentTb(z,T,rho)

End Program testsubs
