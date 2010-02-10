INSTALL_DIR=/usr/local/lib/
RM= /bin/rm -vf
CC=gcc

proj_gauss_mixtures_objects= src/bovy_isfin.o src/bovy_randvec.o \
	src/calc_splitnmerge.o src/logsum.o src/minmax.o\
	src/normalize_row.o src/proj_EM.o src/proj_EM_step.o \
	src/proj_gauss_mixtures.o src/splitnmergegauss.o src/bovy_det.o

proj_gauss_main_objects= src/main.o src/parse_option.o src/read_data.o \
		src/read_IC.o src/read_till_sep.o src/write_model.o \
		src/cleanup.o

#
# The next targets are the main make targets: all, 
# extremedeconvolution (the executable), and 
# extremedeconvolution.so (the sharable object library)
#
all: build/extremedeconvolution build/extremedeconvolution.so

build:
	mkdir build

build/extremedeconvolution: $(proj_gauss_mixtures_objects) $(proj_gauss_main_objects) build
	$(CC) -o $@ -lm -lgsl -lgslcblas $(proj_gauss_mixtures_objects)\
	 $(proj_gauss_main_objects)

build/extremedeconvolution.so: $(proj_gauss_mixtures_objects) \
			src/proj_gauss_mixtures_IDL.o build
	$(CC) -shared -o $@ -lm -lgsl -lgslcblas\
	 $(proj_gauss_mixtures_objects)\
	 src/proj_gauss_mixtures_IDL.o

%.o: %.c
	$(CC) -fpic -Wall -c $< -o $@ -I src/

#
# INSTALL THE IDL WRAPPER
#
install: build/extremedeconvolution.so
	cp $< $(INSTALL_DIR)libextremedeconvolution.so

idlwrapper:
	echo 'result = CALL_EXTERNAL("$(INSTALL_DIR)libextremedeconvolution.so", $$' > tmp
	cat pro/projected_gauss_mixtures_c.pro_1 tmp pro/projected_gauss_mixtures_c.pro_2 > pro/projected_gauss_mixtures_c.pro
	$(RM) tmp


#
# TEST THE INSTALLATION
#
test:
	(cd examples && echo 'fit_TF' | idl)
	(cd examples && ((diff TF.tex TF.out && echo 'Ouput of test agrees with given solution') \
	|| echo -e 'Output of test does not agree with given solution\nManually diff the TF.tex and TF.out (given solution) file'))


.PHONY: clean spotless

clean:
	$(RM) $(proj_gauss_mixtures_objects)
	$(RM) $(proj_gauss_main_objects)
	$(RM) src/proj_gauss_mixtures_IDL.o

spotless: clean
	$(RM) src/*.~
	$(RM) pro/projected_gauss_mixtures.pro
	$(RM) build/extremedeconvolution
	$(RM) build/extremedeconvolution.so
	rmdir build