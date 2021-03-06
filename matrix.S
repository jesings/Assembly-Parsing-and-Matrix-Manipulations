.global makematrix
.global resizematrix
.global copymatrix
.global freematrix
.global identitymatrix
.global multiplymatrix
.global printmatrix
.global matrixstart
.global scalarmult
.global one
.data
matrixstart:
    .quad 0
format:
    .asciz "%f "
newl:
    .asciz "\n"
indices:
    .quad 0,4,8,12
zero:
    .double 0.0
one:
    .double 1.0
scalar:
    .double 1.0
//param order rdi, rsi, rdx, rcx, r8, r9
//return value in rax
.text
makematrix://makes a matrix with %rdi columns and %rsi rows, and returns its reference in %rax
    //columns put on the stack
    push %rdi//number of columns
    push %rsi
    movq $32, %rdi
    call malloc@PLT
    pop %rsi
    pop %rdi
    mov %rax, matrixstart(%rip)
    //allocate space for the matrix
    push %rdi
    push %rsi
    imul %rsi, %rdi
    shl $3, %rdi//length of array in bytes
    call malloc@PLT
    pop %rsi
    pop %rdi
    //populates fields of the matrix pseudo-struct properly
    movq matrixstart(%rip), %rcx
    movq %rax, (%rcx)
    movq %rdi, 8(%rcx)
    movq %rsi, 16(%rcx)
    movq $0, 24(%rcx)
    //sets return value
    movq matrixstart(%rip), %rax
    ret

resizematrix://adds %rsi columns to matrix %rdi, no return val
    movq %rdi, matrixstart(%rip)
    movq 8(%rdi), %rdx
    addq %rsi, %rdx
    movq %rdx, 8(%rdi)
    movq %rdx, %rsi
    shlq $5, %rsi
    movq (%rdi), %rdi
    call realloc@PLT
    movq matrixstart(%rip), %rdi
    movq %rax, (%rdi)
    ret

copymatrix://makes a deepcopy of matrix %rdi, returns the pointer to that new matrix
    mov %rdi, matrixstart(%rip)
    push %rdi
    mov 8(%rdi), %rdi
    mov $4, %rsi
    call makematrix
    pop %rbx
    push %rax
    //new matrix made, copy fields of pseudo-struct, find array addresses, and memcpy
    movq (%rax), %rdi
    movq (%rbx), %rsi
    movq 8(%rbx), %rdx
    imul 16(%rbx), %rdx
    shl $3, %rdx
    push %rdi
    call memcpy@PLT
    pop %rdi
    pop %rax
    mov 24(%rdi), %rdx
    mov %rdx, 24(%rax)
    ret

freematrix://frees the memory of matrix %rdi, no return value
    mov %rdi, matrixstart(%rip)
    movq (%rdi), %rdi
    call free@PLT//array freed
    movq matrixstart(%rip), %rdi
    call free@PLT//pseudo-struct freed
    ret

printmatrix://prints matrix %rdi, no return value
    mov %rdi, matrixstart(%rip)
    push %r14
    push %r13
    push %rbx
    sub $8, %rsp //align to the 16 byte boundary, there's a better way to do this
    mov $0, %r13
    poloop:
    mov matrixstart(%rip), %rcx
    cmp 16(%rcx), %r13
    je peloop
    mov $0, %r14
    piloop:
    mov %r14, %rax
    mov %r13, %rbx
    shl $2, %rax
    add %rax, %rbx
    mov matrixstart(%rip), %rcx
    movq (%rcx), %rdx
    movsd (%rdx,%rbx,8), %xmm0 //found double to print, set arguments to print it
    lea format(%rip), %rdi
    mov $1, %rax
    call printf@PLT
    inc %r14
    mov matrixstart(%rip), %rcx
    //loop stuff
    cmp 24(%rcx),%r14
    jl piloop
    inc %r13
    lea newl(%rip), %rdi
    mov $0, %rax
    call printf@PLT
    jmp poloop
    peloop:
    add $8, %rsp
    pop %rbx
    pop %r13
    pop %r14
    ret

identitymatrix://turns square matrix %rdi into an identity matrix, no return value
    mov %rdi, matrixstart(%rip)
    mov 8(%rdi), %rdx
    mov %rdx,24(%rdi)
    push %r14
    push %r13
    push %rbx
    mov $0, %r13
    ioloop:
    cmp $4, %r13
    je ieloop
    mov $0, %r14
    iiloop:
    mov matrixstart(%rip), %rcx
    cmp %r13, %r14
    //make the 0 or 1 proper for the identity
    jne mzero
    movsd one(%rip), %xmm0
    jmp moned
    mzero:
    movsd zero(%rip), %xmm0
    moned:
    mov %r14, %rax
    mov %r13, %rbx
    shl $2, %rax
    add %rax, %rbx
    movq (%rcx), %rdx
    movsd %xmm0, (%rdx, %rbx, 8)
    inc %r14
    //put the 0 or 1 in the right memory location
    cmp 8(%rcx),%r14
    jl iiloop
    inc %r13
    jmp ioloop
    ieloop:
    pop %rbx
    pop %r13
    pop %r14
    ret

multiplymatrix: //multiplies matrix1 rdi, matrix2 rsi, stores resulting matrix in rsi, no return value
    pushq %r13
    pushq %r14
    pushq %rbp
    movq %rsp, %rbp

    pushq %rdi
    pushq %rsi
    mov 8(%rsi), %rax
    imul 16(%rsi), %rax
    shl $3, %rax
    mov %rax, %rdi
    call malloc@PLT
    mov %rax, %r8
    popq %rsi
    popq %rdi//okay this makes a new array

    mov $0, %r13 //we take the rows of the first matrix, and the columns of the second
    loop_layer_0:
    mov $0, %r14
    loop_layer_1:
    //put r14th row of matrix 1 in ymm1
    mov %r13, %rax
    shl $3, %rax
    mov (%rdi),%rdx
    add %rdx, %rax
    lea indices(%rip), %rcx
    vmovupd (%rcx), %ymm4
    vpcmpeqq %ymm3, %ymm3, %ymm3
    vgatherqpd %ymm3, (%rax,%ymm4,8), %ymm1
    //put r13th column of matrix 2 in ymm2
    mov %r14, %rax
    shl $5, %rax
    mov (%rsi),%rdx
    add %rdx, %rax
    vmovupd (%rax), %ymm2
    //properly accumulate data
    vmulpd %ymm1, %ymm2, %ymm2
    vhaddpd %ymm2, %ymm2, %ymm0
    vpermq $0b11011000, %ymm0, %ymm0
    vhaddpd %ymm0, %ymm0, %ymm0
    //move the accumulator into the proper memory location of the array pointed to by %r8
    mov %r14, %rax
    mov %r13, %rcx
    shl $2, %rax
    add %rax, %rcx
    shl $3, %rcx
    add %r8, %rcx
    movsd %xmm0,(%rcx)
    //loop stuff
    inc %r14
    cmp 24(%rsi),%r14
    jl loop_layer_1
    inc %r13
    cmp 8(%rdi),%r13
    jl loop_layer_0

    push %rdi
    push %rsi
    push %r8
    mov (%rsi), %rdi
    call free@PLT
    pop %r8
    pop %rsi
    pop %rdi
    mov %r8, (%rsi)//frees the old array in matrix 2, and insert the array pointed to by %r8

    mov %rbp, %rsp
    popq %rbp
    popq %r14
    popq %r13
    vzeroupper
    ret
scalarmult:
    movsd %xmm0, scalar(%rip)
    mov $0, %rcx
    smloop:
    mov %rcx, %rax
    shl $5, %rax
    mov (%rdi), %rsi
    vmovupd (%rsi,%rax), %ymm0
    vbroadcastsd scalar(%rip), %ymm1
    vmulpd %ymm0, %ymm1, %ymm0
    vmovupd %ymm0, (%rsi,%rax)
    inc %rcx
    cmp 24(%rdi), %rcx
    jl smloop
    vzeroupper
    ret
