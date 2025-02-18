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


    la t1, sat_data_v1                     # Loading the data_one address
    la t2, sat_data_v2                    # Loading the data_two address

    # Set up vector length (8 elements, 8-bit each)
    li t0, 8
    vsetvli t0, t0, e8, m1, ta, ma  # SEW = 8 bits, 8 elements per vector

    # Load vectors from memory (byte-wise)
    vle8.v v2, (t2)     # Load v2 with 8-bit elements from data_v2
    vle8.v v1, (t1)     # Load v1 with 8-bit elements from data_v1

    # Perform saturating vector addition
    vsadd.vv v3, v2, v1  # v3 = v2 + v1 (saturating)

    # Perform saturating vector subtraction
    vssub.vv v4, v2, v1  # v4 = v2 - v1 (saturating)

    # vector single width saturating add and subtract
    # Saturating adds of unsigned integers.
    vsaddu.vv v3, v2, v1                 # Vector-vector

    # Saturating adds of signed integers.
    vsadd.vv v3, v1, v2                # Vector-vector

    # Saturating subtract of unsigned integers.
    vssubu.vv v3, v1, v2              # Vector-vector

    # Saturating subtract of signed integers.
    vssub.vv v3, v1, v2                 # Vector-vector



    # Load data into vector registers
    la t1, avg_data_v1       # Load address of data_one into t1
    vle8.v v1, (t1)          # Load vector data_one into v1 (8-bit elements)
    
    la t2, avg_data_v2       # Load address of data_two into t2
    vle8.v v2, (t2)          # Load vector data_two into v2 (8-bit elements)



    # Perform Averaging Add for Signed Integers
    vaadd.vv v3, v1, v2      # Signed Averaging Add (v3 = (v1 + v2) >> 1)
    
    # Perform Averaging Add for Unsigned Integers
    vaaddu.vv v4, v1, v2     # Unsigned Averaging Add (v4 = (v1 + v2) >> 1)

    # Perform Averaging Subtract for Signed Integers
    vasub.vv v5, v1, v2      # Signed Averaging Subtract (v5 = (v1 - v2) >> 1)
    
    # Perform Averaging Subtract for Unsigned Integers
    vasubu.vv v6, v1, v2     # Unsigned Averaging Subtract (v6 = (v1 - v2) >> 1)


    # Load vector registers with test data (covering corner cases)
    la t0, data_fractional_mul_vs2
    vle8.v v2, (t0)  # Load vector vs2
    la t1, data_fractional_mul_vs1
    vle8.v v1, (t1)  # Load vector vs1

    # Perform Vector Signed Fractional Multiplication
    vsmul.vv v3, v2, v1  # vd[i] = clip(roundoff_signed(vs2[i] * vs1[i], SEW-1))





    vle32.v v0, (t0)                    
    vle32.v v1, (t1)
    vle32.v v2, (t2)
        
    # vadd.vv v4, v1, v2, v0.t            # Masked Vector addition with vector

    # single width integer add
    vle32.v v0, (t0)                    
    vle16.v v1, (t1)
    vle16.v v2, (t2)

    # vector single width saturating add and subtract
    # Saturating adds of unsigned integers.
    vsaddu.vv v3, v2, v1                 # Vector-vector

    # Saturating adds of signed integers.
    vsadd.vv v3, v1, v2                # Vector-vector

    # Saturating subtract of unsigned integers.
    vssubu.vv v3, v1, v2              # Vector-vector

    # Saturating subtract of signed integers.
    vssub.vv v3, v1, v2                 # Vector-vector


    la t0, data_mask                     # Loading the data_mask address
    la t1, data_three                     # Loading the data_one address
    la t2, data_four                     # Loading the data_two address

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




    # vector single width saturating add and subtract
    # Saturating adds of unsigned integers.
    vsaddu.vv v3, v2, v1                 # Vector-vector

    # Saturating adds of signed integers.
    vsadd.vv v3, v1, v2                # Vector-vector

    # Saturating subtract of unsigned integers.
    vssubu.vv v3, v1, v2              # Vector-vector

    # Saturating subtract of signed integers.
    vssub.vv v3, v1, v2                 # Vector-vector

    

    j write_tohost   

.align 2    
write_tohost:
    li gp, 1
    sw gp, tohost, t5
    j write_tohost
    
.data

sat_data_v2:  .byte 120, -120, 250, 10   # First input vector
sat_data_v1:  .byte  10, -10,  10, 20    # Second input vector

avg_data_v1:
    .byte 50, -30, 100, 20, 75, -50, 25, -10  # 8-bit signed values for vector 1

avg_data_v2:
    .byte 60, -40, 120, 30, 85, -45, 35, -15  # 8-bit signed values for vector 2

data_fractional_mul_vs2:
    .byte 0x7F   # +127 (Max Positive)
    .byte 0x80   # -128 (Max Negative)
    .byte 0x01   # +1
    .byte 0xFF   # -1
    .byte 0x40   # +64
    .byte 0xC0   # -64
    .byte 0x02   # +2
    .byte 0xFE   # -2

data_fractional_mul_vs1:
    .byte 0x7F   # +127 (Max Positive)
    .byte 0x80   # -128 (Max Negative)
    .byte 0x02   # +2
    .byte 0xFE   # -2
    .byte 0x40   # +64
    .byte 0xC0   # -64
    .byte 0x01   # +1
    .byte 0xFF   # -1

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


data_mask:
.word 0b10010001


RVTEST_DATA_BEGIN