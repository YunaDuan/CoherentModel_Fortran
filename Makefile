# Compiler Syntax Notes
# "$^" refers to the output variable name
# "$@" refers to the filenames of all prereqs, separated by spaces
# "-fcheck=all" does run-time checks on array bounds, etc.

F90=gfortran
CFLAGS=
LFLAGS=
RunCoherentModel : *.f90
	$(F90) $(CFLAGS) -o $@ $^
clean:
	rm -f *.o *.mod
