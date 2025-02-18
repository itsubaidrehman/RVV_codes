
#define RVTEST_DATA_BEGIN                                               \
        .pushsection .tohost,"aw",@progbits ;                           \
        .align 6; .global tohost; tohost: .dword 0; .size tohost, 8;    \
        .align 6; .global fromhost; fromhost: .dword 0; .size fromhost, 8;\
        .popsection;                                                    \
        .align 4; .global begin_signature; begin_signature:					
#define RVTEST_CODE_BEGIN                                               
        .section .text.init;                                            
        .align  6;                                                      
        .global _start;

_start:                                 \
        j main;                             \
trap_vector:                                                            \
    csrr t5, mcause ;                       \
    nop;                                \
    nop;                                \
    nop;                                \
    nop;                                \
    nop;                                \
    j write_tohost

RVTEST_CODE_BEGIN
main:

    # Enabling the vector operations by setting mstatus bit
    li t1, 1024
    csrrs x0, mstatus, t1

    li t1, 0x6000
    csrrs x0, mstatus, t1

    # Load n into a0
    # la a0, n
    # lw a0, 0(a0)                 # Load n into a0

    # Load a (floating point scalar) into fa0
    la a3, a                    # Load address of a
    flw fa0, 0(a3)               # Load a into fa0

    # Load addresses of x and y
    la a1, x                     # Load base address of x into a1
    la a2, y                     # Load base address of y into a2

    # Call SAXPY function
    call saxpy

    # Exit program (return 0)
    j write_tohost 

saxpy:
    li a0, 33
    vsetvli a4, a0, e32, m1, ta, ma  # Set vector length for 32-bit floats
loop:
    vle32.v v0, (a1)                 # Load x vector
    vle32.v v8, (a2)                  # Load y vector
    
    vfmacc.vf v8, fa0, v0             # Compute: y = a * x + y
    vse32.v v8, (a2)                  # Store y back to memory
    
    slli a5, a4, 2                    # Compute byte offset
    add a1, a1, a5                    # Advance x pointer
    add a2, a2, a5                    # Advance y pointer

    sub a0, a0, a4                   # Decrement n by VL

    bgt a0, x0, loop                     # Repeat if n > 0

    ret                                # Return from function

          

.align 2    
write_tohost:
    li gp, 1
    sw gp, tohost, t5
    j write_tohost
    
.data

a:      .float 2.0                   # Scalar multiplier a = 2.0
x:      .float 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0  # x array
y:      .float 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0  # y array


RVTEST_DATA_BEGIN