# Compiler Syntax Notes
# "$^" refers to the output variable name
# "$@" refers to the filenames of all prereqs, separated by spaces
# "-fcheck=all" does run-time checks on array bounds, etc.

# The compiler
FC=gfortran
# flags
CFLAGS= -g -fbounds-check
# List of executables to be built
PROGRAMS = maintest 
all: $(PROGRAMS)

#the rules
maintest:CoherentTb.o
CoherentTb.o:Varidefine.o
CoherentTb:Varidefine.o

#General rule for building prog from prog.o
%: %.o
	$(FC) $(CFLAGS) -o $@ 
#General rules for building prog.o from prog.f90
%.o: %.f90
	$(FC) $(CFLAGS) -c $<
# Utility targets
clean:
	rm -f *.o *.mod
