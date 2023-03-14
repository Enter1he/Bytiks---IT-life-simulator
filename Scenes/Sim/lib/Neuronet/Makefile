all: Neuronet.dll

clean:
	del Neuronet.dll && del Neuronet.o && del neuronet.mod

Neuronet.dll: Neuronet.f90 lua.f90 dyn_Array.f90
	gfortran -shared -O2 -o Neuronet.dll Neuronet.f90 lua.f90 dyn_Array.f90 lua.o -I. -L. -llua54

