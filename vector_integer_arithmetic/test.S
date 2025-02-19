#define RVTEST_DATA_BEGIN                                               \
        .pushsection .tohost,"aw",@progbits;                            \
        .align 6; .global tohost; tohost: .dword 0; .size tohost, 8;    \
        .align 6; .global fromhost; fromhost: .dword 0; .size fromhost, 8;\
        .popsection;                                                    \
        .align 4; .global begin_signature; begin_signature:
#define RVTEST_CODE_BEGIN                                               \
        .section .text.init;                                            \
        .align  6;                                                      \
        .global _start;                         \
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



    li a0, 8                           # AVL
    li a2, 0xffffffff
    vsetvli a1, a0, e32, m1, ta, ma     # SEW = 32 bits, LMUL = 1, AVL = 8

    # Vector Integer Add-with-Carry / Subtract-with-Borrow Instructions
    la t1, data_one_adc                     # Loading the data_one address
    la t2, data_two_adc                     # Loading the data_two address

    vle32.v v1, (t1)
    vle32.v v2, (t2)

    vmadc.vvm v4, v2, v1, v0                # carry calculations    
    vadc.vvm v3, v2, v1, v0                  # Vector-Vector additon with carry
    vadd.vv v3, v2, v1
    vmmv.m v0, v4                           # Move carry to v0 




    # vector merge instruction
    la t0, data_mask                     # Loading the data_mask address
    la t1, data_one                     # Loading the data_one address
    la t2, data_two                     # Loading the data_two address
    li a0, 8                           # AVL
    vsetvli a1, a0, e32, m1, ta, ma     # SEW = 32 bits, LMUL = 1, AVL = 8
    # Loading data to vectors
    vle32.v v0, (t0)                    
    vle32.v v1, (t1)
    vle32.v v2, (t2)
    li a2, 0xa2a2a2a2    
    vmerge.vvm v3, v2, v1, v0                  # Vector-Vector merge 
    vmerge.vxm v4, v2, a2, v0                  # Vector-Scalar Merge
    vmerge.vim v5, v2, 15, v0
 
    vmv.v.v v3, v2 # vd[i] = vs1[i]
    vmv.v.x v3, a2 # vd[i] = x[rs1]






    la t0, data_mask                     # Loading the data_mask address
    la t1, data_one                     # Loading the data_one address
    la t2, data_two                     # Loading the data_two address
    li a0, 8                        # AVL
    vsetvli a1, a0, e32, m1, ta, ma     # SEW = 32 bits, LMUL = 1, AVL = 8
    # Loading data to vectors
    vle32.v v0, (t0)                    
    vle32.v v1, (t1)
    vle32.v v2, (t2)      
    vadd.vv v4, v1, v2, v0.t            # Masked Vector addition with vector
    # single width integer add
    vle32.v v0, (t0)                    
    vle16.v v1, (t1)
    vle16.v v2, (t2)
    # integer add , subtract and reverse subtract
    vadd.vv v3, v2, v1
    vsub.vv v3, v2, v1
    # vrsub.vv v3, v2, v1           - Not supported instruction, unrewcognied opcode
    li t0, 5
    # vrsub.vx v3, v2, t0 , vm     - illegal operands, why?
    vrsub.vx v3, v2, t0
    # A vector of integer values can be negated using a reverse-subtract instruction with a scalar operand of x0. An assembly 
    # pseudoinstruction vneg.v vd,vs = vrsub.vx vd,vs,x0 is provided.
    vrsub.vx v3,v2, x0



    li a0, 8                           # AVL
    vsetvli a1, a0, e32, m1, ta, ma     # SEW = 32 bits, LMUL = 1, AVL = 8
    # Loading data to vectors                 
    vle32.v v1, (t1)
    vle32.v v2, (t2)      
    vzext.vf2 v3, v1
    vsext.vf4 v4, v1
    # vzext.vf8 v3, v1   - illegal instruction error






    la t1, data_three                     # Loading the data_one address
    la t2, data_four                     # Loading the data_two address
    li a0, 8                           # AVL
    vsetvli a1, a0, e32, m1, ta, ma     # SEW = 32 bits, LMUL = 1, AVL = 8
    vle32.v v1, (t1)
    vle32.v v2, (t2)
    vle32.v v3, (t2)
    # integer multiple add, overwrite addend
    vmacc.vv v3, v2, v1                 # vd[i] = vs1[i] * vs2[i] + vd[i]

    # integer multiply sub, overwrite minued
    vnmsac.vv v3, v2, v1                # vd[i] = - (vs1[i] * vs2[i]) + vd[i]

    # integer multiply add, overwrite multiplicand
    vmadd.vv v3, v2, v1                 # vd[i] = (vs1[i] * vd[i]) + vs2[i]

    # integer multiply sub, overwrite multiplicand
    vnmsub.vv v3, v2, v1

    # Shift Operations, only log2(SEW) bits are used to shift the amount, to match with the element width
    # vsll.vv v3, v2, v1, vm           # illegal operands if vm is used
    vsll.vv v3, v1, v2
    # vnsrl.wi v3, v2, 1                 # Vector-Vector additon with narrowing
    # vnsrl.wv v4, v1, v2




    la t1, data_three                     # Loading the data_one address
    la t2, data_four                     # Loading the data_two address

    li t0, 8
    # Configuring vector for widening instructions
    vsetvli t0, t0, e16, mf2, ta, ma  # SEW=32, LMUL=1
    vle32.v v1, (t1)
    vle32.v v2, (t2)


    vle32.v v2, (t2)
    # vadd.vi v1, v0, 1
    
    
    vnsrl.wi v3, v2, 1                 # Vector-Vector additon with narrowing
    vnsrl.wv v4, v2, v1


    # If the SEW is e32, i am getting error on the vwadd instruction. why?
    # vector widening integer add subtract
    vwaddu.vv v3, v2, v1  # vector-vector
    vwaddu.vx v3, v2, t0  # vector-scalar
    vwsubu.vv v3, v2, v1  # vector-vector
    vwsubu.vx v3, v2, t0  # vector-scalar

    # Widening signed integer add/subtract, 2*SEW = SEW +/- SEW
    vwadd.vv v3, v2, v1   # vector-vector
    vwadd.vx v3, v2, t0   # vector-scalar
    vwsub.vv v3, v2, v1   # vector-vector
    vwsub.vx v3, v2, t0   # vector-scalar

    # Widening unsigned integer add/subtract, 2*SEW = 2*SEW +/- SEW
    vwaddu.wv v3, v2, v1  # vector-vector
    vwaddu.wx v3, v2, t0  # vector-scalar
    vwsubu.wv v3, v2, v1  # vector-vector
    vwsubu.wx v3, v2, t0  # vector-scalar

    # Widening signed integer add/subtract, 2*SEW = 2*SEW +/- SEW
    vwadd.wv v3, v2, v1   # vector-vector
    vwadd.wx v3, v2, t0   # vector-scalar
    vwsub.wv v3, v2, v1   # vector-vector
    vwsub.wx v3, v2, t0   # vector-scalar

    

    j write_tohost   

.align 2    
write_tohost:
    li gp, 1
    sw gp, tohost, t5
    j write_tohost
    
.data
data_one:              
.word 0xfebaceef
.word 0xdeabdeef
.word 0xcafebeef
.word 0xffffffff
.word 0xaaaaaaaa
.word 0xabcabcab
.word 0xdeadfeab

data_two:              
.word 0xcafebeef
.word 0xdeadbeef
.word 0xabcdef12
.word 0x345345ab
.word 0xabcdabcd
.word 0x67899876
.word 0x11221122
.word 0xceabfeed

data_three:
.word 0x1
.word 0x7
.word 0x1
.word 0x2
.word 0x6
.word 0x3
.word 0x1
.word 0x8

data_four:
.word 0x1003
.word 0x7
.word 0x1
.word 0x2
.word 0x6
.word 0x3
.word 0x1
.word 0x8

data_one_adc:
    .word 0x00000001, 0x7FFFFFFF, 0xFFFFFFFF, 0x00000002  # Small, max positive, max unsigned, small
    .word 0x00000000, 0x80000000, 0xFFFFFFFE, 0x00000003  # Zero, min negative, -2, small

data_two_adc:
    .word 0x00000001, 0x7FFFFFFF, 0x00000001, 0xFFFFFFFF  # Small, max positive, small, max unsigned
    .word 0x00000000, 0x80000000, 0x00000002, 0xFFFFFFFD  # Zero, min negative, +2, -3

data_mask:
.word 0b10010001


RVTEST_DATA_BEGIN