.global main
.global data
.global edgem
.global transm
.global name
.global parsefd
.data
    x: .quad 0
    pi: .double 3.141592658979
    half: .double .5
    name: .asciz "./image.ppm"
    parsefile: .asciz "./script"
.bss
    data: .zero 786432#512*512*3
    transm: .quad 0
    edgem: .quad 0
    parsefd: .quad 0
.text
main:
    mov $10, %rdi
    mov $4, %rsi
    call makematrix
    mov %rax, edgem(%rip)

    mov $4, %rdi
    mov $4, %rsi
    call makematrix
    mov %rax, transm(%rip)
    mov %rax, %rdi
    call identitymatrix

    mov $2, %rax
    lea parsefile(%rip), %rdi
    xor %rsi, %rsi
    syscall
    mov %rax, parsefd(%rip)

    call parse

    mov $3, %rax
    mov parsefd(%rip), %rdi
    syscall

    mov edgem(%rip), %rdi
    call freematrix

    mov transm(%rip), %rdi
    call freematrix
    ret
