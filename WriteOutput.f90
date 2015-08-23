!Subroutine to write an array in a .txt file
!*******************************************************************
!Input: 1.The name of the outputfile - fname
!         The name has the type of string
!       2.The arrary for export - results(m,n)
!       3.The dimensions of the array - m,n


Subroutine WriteOutput(fname,results,m,n)

Implicit None

Character(len=10),Intent(in)::fname
Integer,Intent(in)::m,n
REAL,Intent(in)::results(m,n)

Integer::i
Character(LEN=30)::output !Output directory
Character(LEN=6)::Fruns !File name

!Set the output directory
output='Runs'//trim(adjustl(fname))//'.dat'
open(unit=20,file=output,status='new',access='sequential',form='formatted')

!Do i=1,m
        Write(unit=20,'(F6.4)')results
!End Do

Close(20)

End Subroutine
