# Syntax Notes
#  "$^" refers to the output variable name
#  "$@" refers to the filenames of all prerequisites, separated by spaces
#  "-fcheck=all" does run-time checks on array bounds, args, etc.

#The compiler
FC = gfortran
#Flags for debugging
FCFLAGS =-g -Wall -Wextra -fcheck=all
FCFLAGS = -O2
#flags forall (e.g. look for system .mod files, required in gfortran)
FCFLAGS = -I/usr/include
#libraries needed for linking
LDFLAGS = 
# List of executables to be built within the package
PROGRAMS = test1
# "make" builds all
all: $(PROGRAMS)

#the rules for programs
test1:tempProfile.o
test1:GetGrid.o
test1:GetLayerNumber.o
test1:DensityRealization.o
test1:VariDefine.o
test1.o:VariDefine.o
test1:mvnrnd.o
test1:cholesky.o
test1:rand_normal.o

#general rules
%: %.o
	$(FC) $(FCFLAGS) -o $@ $^ $(LDFLAGS)
%.o: %.f90
		$(FC) $(FCFLAGS) -c $<

%.o: %.F90
		$(FC) $(FCFLAGS) -c $<

# Utility targets
.PHONY: clean veryclean
clean:
	rm -f *.o *.mod
veryclean:
	rm -f *~ $(PROGRAMS)
