//  ***  Sahil Brar (UCID: 30021440)  ***
// CPSC 355 (L01) Assignment 5

// Assignment 5: Translate all functions except main() from the C code provided into ARMv8 assembly language. Put them all into a separeate
//               assembly source code file called a5.asm. These functions will be called from the main() function given, which will be in its
//               own source code file called a5Main.c. Also move the global variables int0 a5.asm. Your assemvly functions will call the library
//               routines printf() and getChar(). Be sure to handle the global variables and format strings in the appropriate way. Input will
//               come from standard input; the program is terminated by typing control-d. Run the program to show that it is working as expected,
//               capturing its output using the script UNIX command, and name that output file script.txt. Use a variety of input expressions
//               to show that your program is caclulating correctly.

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    fp .req x29                                                         // Register equates to rename x29 to fp
                    lr .req x30                                                         // Register equates to rename x30 to lr

                    define(i_r, w21)                                                    // Define register for i
                    define(c_r, w22)                                                    // Define register for c

                    MAXVAL = 100                                                        // Constant value    
                    BUFSIZE = 100                                                       // Constant value
                    MAXOP = 20                                                          // Constant value
                    NUMBER = '0'                                                        // Constant value
                    TOOBIG = '9'                                                        // Constant value

//---data-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    .data                                                               // decalare data section
                    .global new_sp                                                      // globalize variable for both files
                    .global val                                                         // globalize variable for both files
                    .global bufp                                                        // globalize variable for both files
                    .global buf                                                         // globalize variable for both files
new_sp:             .word 0                                                             // initialize new_sp
bufp:               .word 0                                                             // initialize bufp
val:                .skip MAXVAL*4                                                      // initialize array val
buf:                .skip BUFSIZE*4                                                     // initialize array buf

//---text-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    .text                                                               // declare text section
fmt_error1:         .string "error: stack full\n"                                       // error message format
fmt_error2:         .string "error: stack empty\n"                                      // error message format
fmt_ungetch:        .string "ungetch: too many characters\n"                            // error message format

//---int push(int f)---------------------------------------------------------------------------------------------------------------------------------------------------------
                    .global push                                                        // globalize push subroutine
                    .balign 4                                                           // align by 4 bits
push:               stp fp, lr, [sp, -16]!                                              
                    mov fp, sp  

                    mov w26, w0                                                         // mov f into w26

                    adrp x9, new_sp                                                     
                    add x9, x9, :lo12:new_sp
                    ldr w10, [x9]                                                       // w10 = sp

                    // if (new_sp < MAXVAL)
                    cmp w10, MAXVAL                                                     // compare sp and MAXVAL
                    b.ge else                                                           // if sp >= MAXVAL, jump to else

                    adrp x28, val       
                    add x28, x28, :lo12:val                                             // calculate val[] base address
                    str w26, [x28, w10, SXTW 2]                                         // store f into val[sp]

                    add w10, w10, 1                                                     // sp++
                    str w10, [x9]                                                       // store value of sp

                    b exit_if                                                           // jump to subroutine end, return val[sp]

                    // else
else:               adrp x0, fmt_error1                         
                    add x0, x0, :lo12:fmt_error1                                        // prepare print statement argument for error
                    bl printf                                                           // call print function

exit_if:            ldp fp, lr, [sp], 16
                    ret                                                                 // return

//---void clear----------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    .global clear                                                       // make subroutine clear globally visible
                    .balign 4
clear:              stp fp, lr, [sp, -16]!
                    mov fp, sp

                    adrp x9, new_sp                                                     // setting up sp
                    add x9, x9, :lo12:new_sp
                    ldr w10, [x9]                                                       // w10 = sp
                    mov w10, 0                                                          // sp = 0
                    str w10, [x9]                                                       // store value of sp
                 
                    ldp fp, lr, [sp], 16
                    ret                                                                 // return   

//---int pop()---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    .global pop                                                         // make subroutine pop globally visible
                    .balign 4
pop:                stp fp, lr, [sp, -16]!
                    mov fp, sp

                    adrp x9, new_sp                                                     // calling sp address
                    add x9, x9, :lo12:new_sp
                    ldr w10, [x9]                                                       // w10 = sp

                    // if (new_sp > 0)
                    cmp w10, 0                                                          // compare sp and 0
                    b.le elsepop                                                        // if sp <= 0 jump to elsepop

                    sub w10, w10, 1                                                     // --sp
                    adrp x28, val
                    add x28, x28, :lo12:val                                             // calculate base address for val[]
                    ldr w0, [x28, w10, SXTW 2]                                          // load val[--sp] and
                    str w10, [x9]                                                       // store new value of sp and

                    b endif                                                             // jump to end of subroutine, return val[--sp]
                    
                    // else
elsepop:            adrp x0, fmt_error2                                                 // setting up error message
                    add x0, x0, :lo12:fmt_error2                                        
                    bl printf                                                           // call print function for error message
                    bl clear                                                            // branch and link to clear() subroutine

endif:              ldp fp, lr, [sp], 16                
                    ret                                                                 // return

//---int getop(char *s, int lim)--------------------------------------------------------------------------------------------------------------------------------------------------------
                    s_size = 8                                                          // size of array s
                    s_m = 16                                                            // location of array s
                    alloc = -(16 + 8) & -16                                             // memory allocation for getop
                    dealloc = -alloc                                                    // memory allocation for dealloc
                    .global getop                                                       // make getop globally visible
                    .balign 4
getop:              stp fp, lr, [sp, alloc]!
                    mov fp, sp
                    
                    add x14, fp, s_m                                                    // move base address if s into x14
                    mov x26, x0                                                         // move array *s into x26
                    mov w25, w1                                                         // move int lim into w25
                    str x26, [x14]                                                      // store the address of *s into x26

truu:               bl getch                                                            // branch link getch
                    mov c_r, w0                                                         // c = getcha()
                    
                    // while ((c = getch()) == ' ' || c == '\t' || c == '\n')
                    cmp c_r, ' '                                                        // compare c and ' '
                    b.eq truu                                                           // if c == ' ' jump to truu

                    cmp c_r, '\t'                                                       // compare c and '\t'
                    b.eq truu                                                           // if c == '\t' jump to truu

                    cmp c_r, '\n'                                                       // compare c and '\n'
                    b.eq truu                                                           // if c == '\n' jump to truu

                    // if (c < '0' || c > '9')
                    cmp c_r, '0'                                                        // compare c and '0'
                    b.lt truif                                                          // if c < '0' jump to truif

                    cmp c_r, '9'                                                        // compare c and '9'
                    b.gt truif                                                          // if c > '9' jump to truif

                    b next                                                              // branch to next

truif:              mov w0, c_r                                                         // move c into w0 to be returned
                    b endtop                                                            // branch to endtop and return c

next:               add x14, fp, s_m                                                    // loading base address of s
                    ldr x26, [x14]                                                      // load x26 with base address of s
                    str c_r, [x26]                                                      // s[0] = c

                    // for (i = 1; (c = getchar()) >= '0' && c <= '9'; i++)
                    mov i_r, 1                                                          // i = 1
                    b test                                                              // branch to test

                    
loop:               // if (i < lim)
                    cmp i_r, w25                                                        // compare i and lim
                    b.ge exitloopif                                                     // if i >= lim jump to exitloopif
                    add x14, fp, s_m                                                    // loading base address of s
                    ldr x26, [x14]                                                      // load base address of s into x26
                    str c_r, [x26, i_r, SXTW 2]                                         // s[i] = c

exitloopif:         add i_r, i_r, 1                                                     // i++

test:               bl getchar                                                          // call getchar function
                    mov c_r, w0                                                         // c = getchar()
                    cmp c_r, '0'                                                        // compare c and '0'
                    b.lt dip                                                            // if c < '0' jump to dip

                    cmp c_r, '9'                                                        // compare c and '9'
                    b.le loop                                                           // if c <= '9' jump to loop

dip:                // if (i < lim)
                    cmp i_r, w25                                                        // compare i and lim                        
                    b.ge topelse                                                        // if i >= lim jump to topelse

                    mov w0, c_r                                                         // move c into w0 as param
                    bl ungetch                                                          // branch and link to ungetch

                    mov w11, '\0'                                                       // move '\0' into w11
                    add x14, fp, s_m                                                    // load address of s into x14
                    ldr x26, [x14]                                                      // load address of s into x26
                    str w11, [x26, i_r, SXTW 2]                                         // s[i] = '\0'
                    mov w0, NUMBER                                                      // move NUMBER into w0 as param
                    b endtop                                                            // jump to endtop and return NUMBER

topelse:            // else
                    // while (c != '\n' && c != EOF)
                    cmp c_r, '\n'                                                       // compare c and '\n'
                    b.eq dip2                                                           // if c == '\n' then jump to dip2

                    cmp c_r, -1                                                         // compare c and EOF
                    b.eq dip2                                                           // if c == EOF jump to dip2

                    bl getchar                                                          // call getchar()
                    mov c_r, w0                                                         // c = getchar()
                    b topelse                                                           // jump to topelse

dip2:               mov w11, '\0'                                                       // move '\0' into w11
                    add x14, fp, s_m                                                    // calculate base address of s and store in x14
                    ldr x26, [x14]                                                      // load x26 with base address of s
                    str w11, [x26, w25, SXTW 2]                                         // s[lim-1] = '\0'
                    sub w25, w25, 1                                                     // lim-1
                    mov w0, TOOBIG                                                      // move TOOBIG into w0 to be returned

endtop:             ldp fp, lr, [sp], dealloc
                    ret                                                                 // return

//---int getch()-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    .global getch                                                       // make getch visible globally
                    .balign 4
getch:              stp fp, lr, [sp, -16]!
                    mov fp, sp

                    adrp x9, bufp                                                       // setup bufp
                    add x9, x9, :lo12:bufp                                              // calculate bufp base address
                    ldr w10, [x9]                                                       // load w10 with bufp

                    cmp w10, 0                                                          // compare bufp and 0
                    b.le getelse                                                        // if bufp <= 0 jump to getelse

                    sub w10, w10, 1                                                     // --bufp
                    adrp x27, buf                                               
                    add x27, x27, :lo12:buf                                             // calculate base address of buf[]
                    ldr w0, [x27, w10, SXTW 2]                                          // buf[--bufp]
                    str w10, [x9]                                                       // store new value of bufp

                    b endget                                                            // return buf[--bufp]

getelse:            bl getchar                                                          // else call getchar()

endget:             ldp fp, lr, [sp], 16
                    ret                                                                 // return

//---void ungetch(int c)--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    .global ungetch                                                     // make ungetch visible globally
                    .balign 4
ungetch:            stp fp, lr, [sp, -16]!
                    mov fp, sp

                    mov w26, w0                                                         // move c into w26

                    adrp x9, bufp
                    add x9, x9, :lo12:bufp                                              // calculate base address of bufp
                    ldr w10, [x9]                                                       // store bufp into w10
                    
                    // if (bufp > BUFSIZE)
                    cmp w10, BUFSIZE                                                    // compare bufp and BUFSIZE
                    b.le unelse                                                         // if bufp <= BUFSIZE jump to unelse

                    adrp x0, fmt_ungetch                                                
                    add x0, x0, :lo12:fmt_ungetch                                       // prepare error message
                    bl printf                                                           // call print function

                    b unif                                                              // exit subroutine

unelse:             // else
                    adrp x27, buf                                                       
                    add x27, x27, :lo12:buf                                             // calculate base address of buf[]
                    str w26, [x27, w10, SXTW 2]                                         // buf[bufp++] = c

                    add w10, w10, 1                                                     // bufp++
                    str w10, [x9]                                                       // store new value of bufp

unif:               ldp fp, lr, [sp], 16
                    ret                                                                 // return
