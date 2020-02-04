//  ****  Sahil Brar (UCID: 30021440)  **** 
// CPSC 355 (L01) Assignment 1b

// Program to find minimum of y = 2x^4 - 145x^2 - 44x - 14 in the range -10 <= x <= 10, by stepping through the range one by one
// in a loop and testing. Using only long integers for x, and not factoring the expression. Use the printf() function to display
// to the screen the values of x, y, and the current minimum on each iteration of the loop.

// Version 1(b): Optimize the 1a program by putting the loop test athe the bottom of the loop (still a pre-test loop), and
//               make use of the madd instruction. Also add macros to the program to make it more readable (use m4). Use
//               macros for heavily used macros.

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\\
display:    .string "For x = %d, y = %d. \n Current minimum value of y = %d. \n"        // Format output
            .balign 4                                                                   // This aigns instructions by 4 bits

            .global main                                                                // Make main visible to the linker. When compiling with gc, a "main" function must be visible.
    
main:       stp x29, x30, [sp, -16]!                                                    // Store X29 and X30 at the address pointed to by SP. [SP, -16]! decreases SP by 16 *BEFORE* this operation is done.
            mov x29, sp                                                                 // Copy SP to X29

            define(x_r, x19)                                                            // Assign macro for x19 (holds x value)
            mov x_r, -10                                                                // Reserve a register for x and give it immediate value of -10 (smallest value in range).

            define(y_r, x20)                                                            // Assign macro for x20 (holds y value)
            mov y_r, 0                                                                  // Reserve a register for y and give it immediate value of 0.

            define(min_r, x21)                                                          // Assign macro for x21 (holds minimum value of y)
            mov min_r, 0                                                                // Reserve a register for minimum of y and give it immediate value of 0 to begin with.

            define(count_r, x22)                                                        // Assign macro for x22 (holds # of times loop is run)
            mov count_r, 0                                                              // Reserve a register for the loop count.

            define(a_r, x23)                                                            // Assign macro for x23 holding first number in equation (2)
            define(b_r, x24)                                                            // Assign macro for x24 holding second number in equation (145)
            define(c_r, x25)                                                            // Assign macro for x25 holding third number in equation (44)

test:       mov y_r, 0                                                                  // Have y=0 for each time loop is re-run.

            mov a_r, 2                                                                  // Store value of 2 from equation (2x^4) into register
            mul a_r, a_r, x_r                                                           // a_r = 2x
            mul a_r, a_r, x_r                                                           // a_r = 2x^2
            mul a_r, a_r, x_r                                                           // a_r = 2x^3
            madd y_r, a_r, x_r, y_r                                                     // y_r = 0 + 2x^4

            mov b_r, -145                                                               // Store immediate of -145 from equation (145x^2) into register
            mul b_r, b_r, x_r                                                           // b_r = -145x
            madd y_r, b_r, x_r, y_r                                                     // y_r = y_r + -145x^2

            mov c_r, -44                                                                // Store immediate of -44 from equation (44x) into register
            madd y_r, c_r, x_r, y_r                                                     // y_r = y_r + -44x     

            add y_r, y_r, -14                                                           // Subtract constant from y with constant value from equation (14).

            cmp count_r, 0                                                              // Compare # of loops run with 0
            b.eq newYmin                                                                // If # of loops run = 0, then set y with the current y minimum by calling newYmin

            cmp y_r, min_r                                                              // Compares current y with the minimum y value
            b.lt newYmin                                                                // if current y < minimum y, then set current y as the new y minimum value

loop:       adrp x0, display                                                            // setting first argm of printf
            add x0, x0, :lo12:display                                                   // add low 12 bits to x0
            mov x1, x_r                                                                 // place value of x in x1 for printf
            mov x2, y_r                                                                 // place value of y in x2 for prinf
            mov x3, min_r                                                               // place value of y minimum in x3 for printf

            bl printf                                                                   // calls printf function
            add x_r, x_r, 1                                                             // adds immediate value 1 to the range being tested (-10 to 10)
            add count_r, count_r, 1                                                     // adds immediate value 1 to the loop counter
            b check                                                                     // Returns to test loop to test next value in range

newYmin:    mov min_r, y_r                                                              // Stores the new y minimum value when called upon
            b loop                                                                      // sends to loop to be displayed on screen and values to be incremented by 1 (above)

check:      cmp x_r, 10                                                                 // Compare x to maximum range value. *THIS IS PRE TEST LOOP*
            b.le test                                                                   // If x <= 10, skip to end

end:        mov x0, 0                                                                   // Store the value 0 in register x0. By convention, funtions use x0 to return values makes main return 0

            ldp x29, x30, [sp], 16                                                      // Load x29 & x30 from the address pointed to by SP. [sp], 16 increases sp by 16 *AFTER* this operation is done

            ret                                                                         // "Returns" from thi function. Sets the program counter to the value stored in a register. If no register is given, defaults to x30 (AKA LR)
