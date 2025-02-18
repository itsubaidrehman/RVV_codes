
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

        la t0, A
        la t1, B
        la t2, C
    

        li t3, 16                           # set no of elements in a vector to be 16
        vsetvli t4, t3, e8, mf4, ta, ma     # this configures Effective Element width to be 32 bits, LMUL to be 1/4, that means we are using only 1/4 of 512 bit registers 
                                            # that means each element is of 32 bits and LMUL is 1 mapping to a single vector register

        vle8.v v1, (t0)                    # load vector A of 32 bit elements each in vector register v1
        vle8.v v2, (t1)                    # load vector B of 32 bit elements each in vector register v2

        vadd.vv v3, v2, v1                  # vadd.vv specifies both the source operands are vector registers

        vse32.v v3, (t2)

        j write_tohost   

.align 2    
write_tohost:
    li gp, 1
    sw gp, tohost, t5
    j write_tohost
    
.data
A:  .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10  # First Vector
B:  .word 16, 15, 14, 13, 12, 11, 10, 9, 8, 7 # Second Vector
C:  .space 64  # Allocate space for result (16 * 4 bytes)


RVTEST_DATA_BEGIN