# Compiler
FC = ifort
# Compiler flags
ifeq ($(FC),gfortran)
        CFLAGS = -O0 -pg -g -fopenmp -fbacktrace -fbounds-check
else
        CFLAGS = -O2 -traceback -debug -qopenmp -xHost -ipo -pg -g -fp-model source -i8 -I${MKLROOT}/include/intel64/ilp64 -mkl=parallel
endif

# Directories
OBJDIR = $(PWD)/obj
SRCDIR = $(PWD)/src_age_structure
NRDIR  = $(PWD)/NRdir




# Libraries - 
LIBS = ${MKLROOT}/lib/intel64/libmkl_lapack95_ilp64.a -liomp5 -lpthread -lm -ldl

# Files and folders
TARGET = seir_pred                      
_OBJ = nrtype.o nrutil.o nr_bsstep.o global_data_ageclass.o rkck.o rkqs.o SEIR_sub_ageclass.o SEIR_main_ageclass.o 
	
OBJ = $(patsubst %,$(OBJDIR)/%,$(_OBJ))

ifeq ($(FC),gfortran)
# GFORTRAN
# -J points to the output directory for the auto-generated .mod files
#$(OBJDIR)/%.o: $(SRCDIR)/%.f90 $(OBJ)
$(OBJDIR)/%.o: $(SRCDIR)/%.f90
	$(FC) -c -o $@ $< $(CFLAGS) -J$(OBJDIR)
#$(OBJDIR)/%.o: $(NRDIR)/%.f90 $(OBJS)
$(OBJDIR)/%.o: $(NRDIR)/%.f90
	$(FC) -c -o $@ $< $(CFLAGS) -J$(OBJDIR)
else
#IFORT
# -module points to the output directory for the auto-generated .mod files
$(OBJDIR)/%.o: $(SRCDIR)/%.f90
	$(FC) -c $(CFLAGS) $< -o $@ -module $(OBJDIR)
$(OBJDIR)/%.o: $(NRDIR)/%.f90
	$(FC) -c $(CFLAGS) $< -o $@ -module $(OBJDIR)
endif

$(TARGET): $(OBJ)
#	$(FC) -o $@ $^ $(CFLAGS) $(LIBS) -I$(FFTDIR) -I$(OBJDIR)
	$(FC) -o $@ $^ $(CFLAGS) -I$(OBJDIR)

.PHONY: clean

clean:
	rm -f $(OBJDIR)/*.o
	rm -f $(OBJDIR)/*.mod
	
all:
	echo $(NRDIR)
