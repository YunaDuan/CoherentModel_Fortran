Subroutine WriteOutput(p)

Use VariDefine
Implicit None
Character(LEN=30)::output
Character(LEN=4)::Fruns
Integer::p

write(Fpoint,'(I4)')p
output='Runs'//trim(adjustl(Fruns))//'.dat'
open(unit=20,file=output,status='new',access='sequential',form=formatted)

Write(unit=20,)
Close(20)
End Subroutine
