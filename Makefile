NVCC = nvcc
LDLIBS =
TARGET = gpu-des
DEBUG =
CCFLAGS = -Wextra -Wall -Wunused-parameter -O2
CUDA_COMPILER_OPTIONS = $(addprefix --compiler-options ,${CCFLAGS}) --std=c++11 -dc -O2 --compiler-bindir /usr/bin/gcc-13 -Xptxas
ALL_CCFLAGS =
ALL_LDFLAGS =
GENCODE_FLAGS = --gpu-architecture=compute_86
INCLUDES = -I/usr/local/cuda/samples/common/inc -I/usr/local/cuda/include -I/usr/include
CC = gcc-13
CXX = g++-13  # Fixed CXX variable definition

.PHONY: all clean debug

all: ${TARGET}

debug: DEBUG += -G
debug: ${TARGET}

OBJECTS = main.o des_cpu.o des_gpu.o des_kernels.o

des_gpu.o: des_gpu.cu des_gpu.cuh des_kernels.cuh common.h
	${NVCC} ${INCLUDES} ${DEBUG} ${GENCODE_FLAGS} ${CUDA_COMPILER_OPTIONS} -c $< -o $@

des_kernels.o: des_kernels.cu des_kernels.cuh
	${NVCC} ${INCLUDES} ${DEBUG} ${GENCODE_FLAGS} ${CUDA_COMPILER_OPTIONS} -c $< -o $@

des_cpu.o: des_cpu.cpp des_cpu.h bit_utils.h common.h
	${CXX} ${INCLUDES} ${DEBUG} ${CCFLAGS} -c $< -o $@  # Changed to use g++ for CPU files

# Rule for main.o
main.o: main.cpp des_cpu.h des_gpu.cuh common.h
	${NVCC} ${INCLUDES} ${GENCODE_FLAGS} ${CUDA_COMPILER_OPTIONS} -c $< -o $@

${TARGET}: ${OBJECTS}
	${NVCC} ${GENCODE_FLAGS} $^ -o $@ ${LDLIBS}  # Added LDLIBS to link libraries

# Clean rule
clean:
	rm -Iv ${TARGET} *.o
