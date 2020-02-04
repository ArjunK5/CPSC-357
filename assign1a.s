//  ****  Sahil Brar (UCID: 30021440)  ****
// CPSC 355 (L01) Assignment 1a

// Program to find minimum of y = 2x^4 - 145x^2 - 44x - 14 in the range -10 <= x <= 10, by stepping through the range one by one
// in a loop and testing. Using only long integers for x, and not factoring the expression. Use the printf() function to display
// to the screen the values of x, y, and the current minimum on each iteration of the loop.

// Version 1(a): Write a program without macros, and use only the mul, add, and mov instructions to do calculations. Use a pre-test loop,
//               where the test is at the top of the loop.

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\\
display:    .string "For x = %d, y = %d. \n Current minimum value of y = %d. \n"        // Format output
            .balign 4                                                                   // This aigns instructions by 4 bits

            .global main                                                                // Make main visible to the linker. When compiling with gc, a "main" function must be visible.
    
main:       stp x29, x30, [sp, -16]!                                                    // Store X29 and X30 at the address pointed to by SP. [SP, -16]! decreases SP by 16 *BEFORE* this operation is done.
            mov x29, sp                                                                 // Copy SP to X29

            mov x19, -10                                                                // Reserve a register for x and give it immediate value of -10 (smallest value in range).
            mov x20, 0                                                                  // Reserve a register for y and give it immediate value of 0.
            mov x21, 0                                                                  // Reserve a register for minimum of y and give it immediate value of 0 to begin with.
            mov x22, 0                                                                  // Reserve a register for the loop count.

test:       cmp x19, 10                                                                 // Compare x to maximum range value. *THIS IS PRE TEST LOOP*
            b.gt end                                                                    // If x>10, skip to end

            mov x20, 0                                                                  // Have y=0 for each time loop is rerun.

            mov x23, 2                                                                  // Store value of 2 from equation (2x^4) into register
            mul x23, x23, x19                                                           // x23 = 2x
            mul x23, x23, x19                                                           // x23 = 2x^2
            mul x23, x23, x19                                                           // x23 = 2x^3
            mul x23, x23, x19                                                           // x23 = 2x^4

            mov x24, -145                                                               // Store immediate of -145 from equation (145x^2) into register
            mul x24, x24, x19                                                           // x24 = -145x
            mul x24, x24, x19                                                           // x24 = -145x^2

            mov x25, -44                                                                // Store immediate of -44 from equation (44x) into register
            mul x25, x25, x19                                                           // x25 = -44x     

            add x20, x20, x23                                                           // Add calculated value of 2x^4 to y from assigned register
            add x20, x20, x24                                                           // Subtract calculated value of 145x^2 from y (from register)
            add x20, x20, x25                                                           // Subtract calculated value of 44x from y (from register)
            add x20, x20, -14                                                           // Subtract constant from y with constant value from equation (14).

            cmp x22, 0                                                                  // Compare # of loops run with 0
            b.eq newYmin                                                                // If # of loops run = 0, then set y with the current y minimum by calling newYmin

            cmp x20, x21                                                                // Compares current y with the minimum y value
            b.lt newYmin                                                                // if current y < minimum y, then set current y as the new y minimum value

loop:       adrp x0, display                                                            // setting first argm of printf
            add x0, x0, :lo12:display                                                   // add low 12 bits to x0
            mov x1, x19                                                                 // place value of x in x1 for printf
            mov x2, x20                                                                 // place value of y in x2 for prinf
            mov x3, x21                                                                 // place value of y minimum in x3 for printf

            bl printf                                                                   // calls printf function
            add x19, x19, 1                                                             // adds immediate value 1 to the range being tested (-10 to 10)
            add x22, x22, 1                                                             // adds immediate value 1 to the loop counter
            b test                                                                      // Returns to test loop to test next value in range

newYmin:    mov x21, x20                                                                // Stores the new y minimum value when called upon
            b loop                                                                      // sends to loop to be displayed on screen and values to be incremented by 1 (above)

end:        mov x0, 0                                                                   // Store the value 0 in register x0. By convention, funtions use x0 to return values makes main return 0

            ldp x29, x30, [sp], 16                                                      // Load x29 & x30 from the address pointed to by SP. [sp], 16 increases sp by 16 *AFTER* this operation is done

            ret                                                                         // "Returns" from thi function. Sets the program counter to the value stored in a register. If no register is given, defaults to x30 (AKA LR)
