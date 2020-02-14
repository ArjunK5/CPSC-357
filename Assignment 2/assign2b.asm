//  ***  Sahil Brar (UCID: 30021440)  ***
// CPSC 355 (L01) Assignment 2b

// Assignment 2: Bit reversal using shift and bitwise logical operations.Create an ARMv8 assembly language program that implements the C code 
//               provided. 

// Version b: Use 32-bit registers for variables delcared using int. Use m4 macros to name the registers to make your code more readable. 
//            Optimize the code so it uses as few instructions as possible. Also print out the original and reversed values both in hexidecimal
//            and in binary, just before the program exits.            

//            *** For version B, x is initialized with 0x7F807F80 ***
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

values: .string "Values: Original = 0x%08X     Reversed = 0x%08X\n"                     // Prints the original and reversed values in hexadecimal
            .balign 4                                                                   // This aigns instructions by 4 bits

            .global main                                                                // Make main visible to the linker. When compiling with gc, a "main" function must be visible.

main:       stp x29, x30, [sp, -16]!                                                    // Store X29 and X30 at the address pointed to by SP. [SP, -16]! decreases SP by 16 *BEFORE* this operation is done.
            mov x29, sp                                                                 // Copy SP to X29

            define(x_r, w19)                                                            // assign macro for w19 (holding unsigned integer x)
            define(y_r, w20)                                                            // assign macro for w20 (holding unsigned integer y)
            define(t1_r, w21)                                                           // assign macro for w21 (holding unsigned integer t1)
            define(t2_r, w22)                                                           // assign macro for w22 (holding unsigned integer t2)
            define(t3_r, w23)                                                           // assign macro for w23 (holding unsigned integer t3)
            define(t4_r, w24)                                                           // assign macro for w24 (holding unsigned integer t4)

            mov x_r, 0x7F807F80                                                         // Initialize x with 0x7F807F80

step1:      and t1_r, x_r, 0x55555555                                                   // t1 = x & 0x55555555
            lsl t1_r, t1_r, 1                                                           // t1 = t1 << 1

            lsr t2_r, x_r, 1                                                            // t2 = t2 >> 1
            and t2_r, t2_r, 0x55555555                                                  // t2 = t2 & 0x55555555

            orr y_r, t1_r, t2_r                                                         // y = t1 | t2

step2:      and t1_r, y_r, 0x33333333                                                   // t1 = y & 0x33333333
            lsl t1_r, t1_r, 2                                                           // t1 = t1 << 2

            lsr t2_r, y_r, 2                                                            // t2 = y >> 2
            and t2_r, t2_r, 0x33333333                                                  // t2 = t2 & 0x33333333

            orr y_r, t1_r, t2_r                                                         // y = t1 | t2

step3:      and t1_r, y_r, 0x0F0F0F0F                                                   // t1 = y & 0x0F0F0F0F
            lsl t1_r, t1_r, 4                                                           // t1 = t1 << 4

            lsr t2_r, y_r, 4                                                            // t2 = y >> 4
            and t2_r, t2_r, 0x0F0F0F0F                                                  // t2 = t2 & 0x0F0F0F0F

            orr y_r, t1_r, t2_r                                                         // y = t1 | t2

step4:      lsl t1_r, y_r, 24                                                           // t1 = y << 24

            and t2_r, y_r, 0xFF00                                                       // t2 = y & 0xFF00
            lsl t2_r, t2_r, 8                                                           // t2 = t2 << 8

            lsr t3_r, y_r, 8                                                            // t3 = y >> 8
            and t3_r, t3_r, 0xFF00                                                      // t3 = t3 & 0xFF00

            lsr t4_r, y_r, 24                                                           // t4 = y >> 24

            orr y_r, t1_r, t2_r                                                         // y = t1 | t2
            orr y_r, y_r, t3_r                                                          // y = y | t3
            orr y_r, y_r, t4_r                                                          // y = y | t4

print:      adrp x0, values                                                             // setting first argm of printf
            add x0, x0, :lo12:values                                                    // add low 12 bits to x0
            mov w1, x_r                                                                 // place value of x_r in x1 for printf
            mov w2, y_r                                                                 // place value of y_y in x2 for prinf
            bl printf                                                                   // calls printf function

end:        mov x0, 0                                                                   // Store the value 0 in register x0. By convention, funtions use x0 to return values makes main return 0

            ldp x29, x30, [sp], 16                                                      // Load x29 & x30 from the address pointed to by SP. [sp], 16 increases sp by 16 *AFTER* this operation is done

            ret                                                                         // "Returns" from thi function. Sets the program counter to the value stored in a register. If no register is given, defaults to x30 (AKA LR)
