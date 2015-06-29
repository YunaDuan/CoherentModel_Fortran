# Syntax Notes
#  "$^" refers to the output variable name
#  "$@" refers to the filenames of all prerequisites, separated by spaces
#  "-fcheck=all" does run-time checks on array bounds, args, etc.

#F90=gfortran-mp-4.6
FC = gfortran
FCFLAGS=-g -Wall -Wextra -fcheck=all
FCFLAGS += -I/usr/include
PROGRAMS = test1
all: $(PROGRAMS)

test1:tempProfile.o
tempProfile:VariDefine.o
tempProfile.o:VariDefine.o

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
