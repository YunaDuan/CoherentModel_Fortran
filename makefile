
# Syntax Notes
#  "$^" refers to the output variable name
#  "$@" refers to the filenames of all prerequisites, separated by spaces
#  "-fcheck=all" does run-time checks on array bounds, args, etc.

#F90=gfortran-mp-4.6
FC = gfortran
#Flags for debugging
FCFLAGS =-g -Wall -Wextra -fcheck=all
FCFLAGS = -O2
#flags forall (e.g. look for system .mod files, required in gfortran)
FCFLAGS = -I/usr/include
#libraries needed for linking
LDFLAGS=./lib/libopenblas.a
# List of executables to be built within the package
PROGRAMS = RunCoherentModel_v1
# "make" builds all
all: $(PROGRAMS)

#the rules for programs
RunCoherentModel_v1:GetLayerNumber.o
RunCoherentModel_v1:GetGrid.o
RunCoherentModel_v1:TempProfile.o
RunCoherentModel_v1:DensityRealization.o
RunCoherentModel_v1:CoherentTb.o
#RunCoherentModel_v1:WriteOutput.o
RunCoherentModel_v1:rand_normal.o
RunCoherentModel_v1:VariDefine.o
RunCoherentModel_v1.o:VariDefine.o

%: %.o
	$(FC) $(FCFLAGS) -o $@ $^ $(LDFLAGS)
%.o: %.f90
		$(FC) $(FCFLAGS) -c $<

%.o: %.F90
		$(FC) $(FCFLAGS) -c $<
.PHONY: clean veryclean
clean:
	rm -f *.o *.mod
veryclean:
	rm -f *~ $(PROGRAMS)
