Program maintest

Use VariDefine
Implicit None

Integer :: i
Open(10,File='dat/T.dat',Status='old')
Open(20,File='dat/z.dat',Status='old')
Open(30,File='dat/rho.dat',Status='old')

allocate(temp(8827),density(8827),z(8827))
Do i=1,8827
   Read(10,*)temp(i)
   Read(20,*)z(i)
   Read(30,*)density(i)
End Do

Close(10);Close(20);Close(30)
Call CoherentTb
deallocate(temp,density,z)
End Program maintest
