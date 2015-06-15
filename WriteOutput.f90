Subroutine WriteOutput(p)

Use VariDefine
Implicit None
Character(LEN=30)::output
Character(LEN=4)::Fpoint
Integer::p

write(Fpoint,'(I4)')p
output='Runs'//trim(adjustl(Fpoint))//'.dat'
open(unit=20,file=output,status='new',access='sequential',form=formatted)


End Subroutine
