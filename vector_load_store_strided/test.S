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

    la t1, data_one                     # Loading the data_one address
    li a0, 8                           # AVL

    vsetvli a1, a0, e32, m1, ta, ma     # SEW = 32 bits, LMUL = 1, AVL = 8

    # Loading data to vectors
    vle32.v v1, (t1)                    # Unit Stride Vector load
    vle16.v v1, (t1)                    # Unit Stride Vector load
    # vle64.v v1, (t1)                    # Unit Stride Vector load - this will raise illegal instruction exception?
    # vle64.v v2, (t1)
    vle32.v v1, (t1)                    # Unit Stride Vector load

    li a2, 0
    vlse32.v v2, (t1), a2               # Stride = 0

    li a2, 8
    vlse32.v v3, (t1), a2               # Stride = 2

    li a2, 16
    vlse32.v v4, (t1), a2               # Stride = 4

    la t1, data_mask
    li a2, -4
    vlse32.v v5, (t1), a2               # Stride = -1

    # Vector Indexed Load Store
    la t2, load_index
    vle32.v v6, (t2)
    la t1, data_one

    vluxei32.v v7, (t1), v6             # Vector indexed-unordered load instruction
    vloxei32.v v7, (t1), v6

    vlseg4e32.v v8, (t1)                # Unit Stride Segment Load with nf=4, emul=1, eew = 32

    # Load base address of data_array and index_array
    la x10, data_array     # x10 = base address of data_array (0x1000)
    la x11, index_array    # x11 = base address of index_array (0x1000)

    # Set up vector configuration: e32 (32-bit elements), m1 (single width), max vector length (vl=4)
    li a0, 4               # Set VLMAX (max vector length) to 4
    vsetvli a1, a0, e32, m1, ta, ma  # Set vector length to at most 4, with 32-bit element size

    # Load vector indices from memory (vs2 holds memory addresses)
    # vle32.v v2, (x11)  # Load 4 addresses from index_array into vs2

    
    # First, we deliberately cause a fault on element 0 by pointing it to invalid memory
    la x10, invalid_data     # Load invalid address for element 0 (0xDEADBEEF)
    vle32ff.v v1, (x10) # Perform the unit-stride fault-only-first load (trap on element 0)
    
    # After this load, if element 0 causes a trap, the vector length should be reduced to 0 (no further loads).
    # Print the contents of v1 to show the outcome.

    
    # Now simulate a fault on a later element (e.g., element 3) while the first elements are valid
    la x10, data_array      # Load valid data array address for elements
    vle32ff.v v2, (x10)  # Perform the unit-stride fault-only-first load (fault on element 3)
    
    # If element 3 raises an exception, the vector length should be reduced to 3.
    # We still expect elements 0, 1, and 2 to be loaded successfully, but element 3 will be skipped.
    # Print the contents of v2 to show the outcome.

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
.word 0x00001000
.word 0x01000010
.word 0x10000000
.word 0x90078601
.word 0xcafebeef
.word 0xdeadbeef
.word 0xabcdef12
.word 0x345345ab
.word 0xabcdabcd
.word 0x67899876
.word 0x11221122
.word 0xceabfeed
.word 0xa123a456
.word 0x1abc2def
.word 0x50501122
.word 0x91101122
.word 0x12180001
.word 0xffffffff
.word 0x00001000
.word 0x01000010
.word 0x10000000
.word 0x90078601
.word 0xcafebeef
.word 0x345345ab
.word 0xabcdabcd
.word 0x67899876
.word 0x11221122
.word 0xceabfeed
.word 0xa123a456

data_mask:
.word 0b10010001

load_index:
.word 4
.word 8
.word 4
.word 12
.word 36
.word 56
.word 28
.word 20

data_array:
    .word 0x00000001, 0x00000002, 0x00000003, 0xDEADBEEF, 0x00000004, 0x00000005  # Simulated memory values

# Invalid address (simulating fault on certain element)
invalid_data:
    .word 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF, 0xDEADBEEF

# Index array (points to base addresses of the valid data array)
index_array:
    .word 0x1000, 0x1004, 0x1008, 0x100C, 0x1010



RVTEST_DATA_BEGIN