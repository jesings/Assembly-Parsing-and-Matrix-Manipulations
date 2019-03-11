.global rotatez
.global rotatey
.global rotatex
.global dilate
.global transform
.global deg2rad
.extern sin
.extern cos
.data
pi:
    .double 3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679
.bss
matrixstart:
    .quad 0
.text
dilate://takes 3 params, x,y,z dilation in %xmm0-2, takes matrix in %rdi
    push %r12
    mov %rdi, matrixstart(%rip)
    mov $4, %rdi
    mov $4, %rsi
    sub $8, %rsp
    call makematrix
    mov %rax, %r12
    add $8, %rsp
    mov %r12, %rdi
    movsd %xmm0,(%rsp)
    call identitymatrix
    movsd (%rsp),%xmm0
    mov (%r12), %rdi
    movsd %xmm0, (%rdi)
    movsd %xmm1, 40(%rdi)
    movsd %xmm2, 80(%rdi)
    mov %r12, %rdi
    mov matrixstart(%rip), %rsi
    call multiplymatrix
    pop %r12
    ret

transform://takes 3 params, x,y,z offset in %xmm0-2, takes matrix in %rdi
    push %r12
    mov %rdi, matrixstart(%rip)
    mov $4, %rdi
    mov $4, %rsi
    sub $8, %rsp
    call makematrix
    mov %rax, %r12
    add $8, %rsp
    mov %r12, %rdi
    movsd %xmm0,(%rsp)
    call identitymatrix
    movsd (%rsp),%xmm0
    mov (%r12), %rdi
    movsd %xmm0, 96(%rdi)
    movsd %xmm1, 104(%rdi)
    movsd %xmm2, 112(%rdi)
    mov %r12, %rdi
    mov matrixstart(%rip), %rsi
    call multiplymatrix
    pop %r12
    ret
rotatez://takes 1 param
    mov %rdi, matrixstart(%rip)
    push %r12
    sub $24, %rsp
    movsd %xmm0, 8(%rsp)
    call sin@PLT
    movsd %xmm0, 16(%rsp)
    movsd 8(%rsp), %xmm0
    call cos@PLT
    movsd %xmm0, 24(%rsp)
    mov $4, %rdi
    mov $4, %rsi
    call makematrix
    mov %rax, %r12
    mov %rax, %rdi
    call identitymatrix
    mov (%r12), %rdi
    movsd 24(%rsp), %xmm0
    movsd %xmm0, (%rdi)
    movsd 16(%rsp), %xmm0
    movsd %xmm0, 8(%rdi)
    movsd 16(%rsp), %xmm1
    xorpd %xmm0, %xmm0
    subsd %xmm1, %xmm0
    movsd %xmm0, 32(%rdi)
    movsd 24(%rsp), %xmm0
    movsd %xmm0, 40(%rdi)
    mov %r12, %rdi
    mov matrixstart(%rip), %rsi
    call multiplymatrix
    mov %r12, %rdi
    call freematrix
    add $24, %rsp
    pop %r12
    ret
rotatex://takes 1 param
    mov %rdi, matrixstart(%rip)
    push %r12
    sub $24, %rsp
    movsd %xmm0, 8(%rsp)
    call sin@PLT
    movsd %xmm0, 16(%rsp)
    movsd 8(%rsp), %xmm0
    call cos@PLT
    movsd %xmm0, 24(%rsp)
    mov $4, %rdi
    mov $4, %rsi
    call makematrix
    mov %rax, %r12
    mov %rax, %rdi
    call identitymatrix
    mov (%r12), %rdi
    movsd 24(%rsp), %xmm0
    movsd %xmm0, 40(%rdi)
    movsd 16(%rsp), %xmm0
    movsd %xmm0, 48(%rdi)
    movsd 16(%rsp), %xmm1
    xorpd %xmm0, %xmm0
    subsd %xmm1, %xmm0
    movsd %xmm0, 72(%rdi)
    movsd 24(%rsp), %xmm0
    movsd %xmm0, 80(%rdi)
    mov %r12, %rdi
    mov matrixstart(%rip), %rsi
    call multiplymatrix
    mov %r12, %rdi
    call freematrix
    add $24, %rsp
    pop %r12
    ret
rotatey://takes 1 param
    mov %rdi, matrixstart(%rip)
    push %r12
    sub $24, %rsp
    movsd %xmm0, 8(%rsp)
    call sin@PLT
    movsd %xmm0, 16(%rsp)
    movsd 8(%rsp), %xmm0
    call cos@PLT
    movsd %xmm0, 24(%rsp)
    mov $4, %rdi
    mov $4, %rsi
    call makematrix
    mov %rax, %r12
    mov %rax, %rdi
    call identitymatrix
    mov (%r12), %rdi
    movsd 24(%rsp), %xmm0
    movsd %xmm0, (%rdi)
    movsd 16(%rsp), %xmm0
    movsd %xmm0, 64(%rdi)
    movsd 16(%rsp), %xmm1
    xorpd %xmm0, %xmm0
    subsd %xmm1, %xmm0
    movsd %xmm0, 16(%rdi)
    movsd 24(%rsp), %xmm0
    movsd %xmm0, 80(%rdi)
    mov %r12, %rdi
    mov matrixstart(%rip), %rsi
    call multiplymatrix
    mov %r12, %rdi
    call freematrix
    add $24, %rsp
    pop %r12
    ret
deg2rad:
    movsd pi(%rip), %xmm1
    mulsd %xmm1, %xmm0
    mov   $180, %rax
    cvtsi2sd %rax, %xmm1
    divsd %xmm1, %xmm0
    ret
