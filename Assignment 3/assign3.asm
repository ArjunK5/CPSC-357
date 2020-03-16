//  ***  Sahil Brar (UCID: 30021440)  ***
// CPSC 355 (L01) Assignment 3

// Assignment 3: Create an ARMv8 assembly language program that implements the algorithm provided (on assignment document). Create space on
//               the stack to store all local variables. Use m4 macors or assembler equates for all stack variable offsets. Optimize code so
//               it uses as few instructions as possible. Be sure that you always read or write memory when using or assigning to the local
//               variables. ALSO run the program in gdb, first displaying contents of the array before sorting, and then once after it is 
//               sorted (use x command to examine memory). Capture gdb using script UNIX command (script.txt).

//---PRINT STATEMENTS-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\\
unsort_p:       .string "Unsorted Array: \n"                                                // Prints unsorted array statement

sorted_p:       .string "\nSorted Array: \n"                                                // Prints the sorted array statement

values_p:       .string "v[%d] = %d\n"                                                      // Prints array values

//---Initialization----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\\
                fp .req x29                                                                 // Register equates to rename x29 to fp
                lr .req x30                                                                 // Register equates to rename x30 to lr

                size = 100                                                                  // Array has 100 values
                v_size = size * 4                                                           // Array v size gets 100 * 4 = 400 bytes
                gap_size = 4                                                                // gap is 4 bytes
                i_size = 4                                                                  // int variable i is 4 bytes
                j_size = 4                                                                  // int variable j is 4 bytes
                temp_size = 4                                                               // int variable temp is 4 bytes
                gapVal = size/2                                                             // int variable for gap = size/2 for outer loop initalization

                alloc = -(16 + v_size + gap_size + i_size + j_size + temp_size) & -16       // Variable for allocation of memory
                dealloc = -alloc                                                            // Variable for deallocation of memory

                gap_s = 16                                                                  // 
                i_s = 20                                                                    //
                j_s = 24                                                                    //    
                temp_s = 28                                                                 //
                jgap_s = 32                                                                 //
                v_s = 36                                                                    //
                
                .balign 4                                                                   // Aligns instruction bits by 4
                .global main                                                                // Make main visible to the linker. When compiling with gc, a "main" function must be visible.

main:           stp fp, lr, [sp, alloc]!                                                    // Store X29 and X30 at the address pointed to by SP.
                mov fp, sp                                                                  // Copy SP to X29

                define(v_base_r, x28)                                                       // Define register for base address of the array v
                define(i_r, w19)                                                            // Define register for variable i (index of unsorted array v)
                define(gap_r, w20)                                                          // Define regsiter for the gap variable
                define(j_r, w21)                                                            // Define register for the variable j (index of sorted array v)
                define(temp_r, w22)                                                         // Define register for the temp variable
                define(vi_r, w23)                                                           // Define register for value stored at v[i]
                define(vj_r, w24)                                                           // Define register for value stored at v[j]
                define(vj1_r, w25)                                                          // Define register for value stored at v[j + gap]

                add v_base_r, fp, v_s                                                       // Calculate base address for array v

                mov i_r, 0                                                                  // initialize i to 0
                str i_r, [fp, i_s]                                                          // Store i_r value into stack memory address
                b rand_test                                                                 // Jump to rand_test to start loop condition test

//---Initialize array to random positive integers mod 512--------------------------------------------------------------------------------------------------------------------------------------------------------------
loop_rand:      ldr i_r, [fp, i_s]                                                          // Load value stored in stack memory for i
                bl rand                                                                     // Run the random command
                and vi_r, w0, 0x1FF                                                         // Put 0x1FF into vi_r
                str vi_r, [v_base_r, i_r, SXTW 2]                                           // Store rand() and 0x1FF at v[i] into stack

                add i_r, i_r, 1                                                             // i++
                str i_r, [fp, i_s]                                                          // store new index value of i into stack

rand_test:      cmp i_r, size                                                               // compare i and size
                b.lt loop_rand                                                              // if i < size jump to loop_rand to run first loop

//---Display the unsorted array-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                adrp x0, unsort_p                                                           // setting first argm of printf
                add x0, x0, :lo12:unsort_p                                                  // add low 12 bits to x0
                bl printf                                                                   // calls printf function
                
                mov i_r, 0                                                                  // re-initialize i to 0
                str i_r, [fp, i_s]                                                          // store new i value into stack memory
                b print_test                                                                // jump to print loop test condition

print_val:      ldr i_r, [fp, i_s]                                                          // loads value stored in i from stack
                ldr vi_r, [v_base_r, i_r, SXTW 2]                                           // loads value in v[i]
                
                adrp x0, values_p                                                           // setting first argm of printf
                add x0, x0, :lo12:values_p                                                  // add low 12 bits to x0
                mov w1, i_r                                                                 // place value of i into x1 for printf
                mov w2, vi_r                                                                // place value of v[i] in x2 for prinf
                bl printf                                                                   // calls printf function
                
                add i_r, i_r, 1                                                             // i++
                str i_r, [fp, i_s]                                                          // store new value of i into stack

print_test:     cmp i_r, size                                                               // compare i and size
                b.lt print_val                                                              // if i < size jump to print_val to print values

//~~~Outer loop of sort~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                str gap_r, [fp, gap_s]                                                      // Store value of gap
                mov gap_r, gapVal                                                           // gap = size / 2
                b outloop_test                                                              // branch to outloop_test (below) is test condition for the out-most for loop

outer_loop:     mov i_r, gap_r                                                              // i = gap
                b nest_test                                                                 // branch to nest_test (below) is test condition for first nested loop

nest_loop:      sub j_r, i_r, gap_r                                                         // j = i - gap
                b in_nest_test                                                              // branch to in_nest_test (below) is test condition for inner nested loop

in_nest_loop:   ldr vj_r, [v_base_r, j_r, SXTW 2]                                           // load v[j]

                add temp_r, j_r, gap_r                                                      // temp = j + gap
                ldr vj1_r, [v_base_r, temp_r, SXTW 2]                                       // load v[j + gap]

                cmp vj1_r, vj_r                                                             // compare v[j + gap] and v[j]
                b.lt skip                                                                   // if v[j + gap] < v[j] THEN do not do loop instructions and branch to skip
                                                                                            // ELSE:
                mov temp_r, vj_r                                                            // temp = v[j]
                mov vj_r, vj1_r                                                             // v[j] = v[j + gap]
                mov vj1_r, temp_r                                                           // v[j + gap] = temp

                str vj_r, [v_base_r, j_r, SXTW 2]                                           // Store v[j]

                mov temp_r, 0                                                               // temp = 0
                add temp_r, j_r, gap_r                                                      // temp = j + gap
                str vj1_r, [v_base_r, temp_r, SXTW 2]                                       // store v[j + gap]

                sub j_r, j_r, gap_r                                                         // j = j - gap

in_nest_test:   cmp j_r, 0                                                                  // compare j and 0
                b.ge in_nest_loop                                                           // IF j >= 0 then branch to in_nest_loop (above)

skip:           add i_r, i_r, 1                                                             // i = i + 1

nest_test:      cmp i_r, size                                                               // compare i and size
                b.lt nest_loop                                                              // IF i < size then branch to nest_loop (above)
                
                mov w26, 2                                                                  // register w26 = 2
                udiv gap_r, gap_r, w26                                                      // gap = gap/2

outloop_test:   cmp gap_r, 0                                                                // Compare gap and 0
                b.gt outer_loop                                                             // IF gap > 0 then branch to outer_loop (above)

//---Display the sorted array-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                adrp x0, sorted_p                                                           // setting first argm of printf
                add x0, x0, :lo12:sorted_p                                                  // add low 12 bits to x0
                bl printf                                                                   // calls printf function
                
                mov i_r, 0                                                                  // re-initialize i to 0
                str i_r, [fp, i_s]                                                          // store new i value into stack memory
                b sortp_test                                                                // jump to print sorted loop test condition (below)

print_sort:     ldr i_r, [fp, i_s]                                                          // loads value stored in i from stack
                ldr vj_r, [v_base_r, i_r, SXTW 2]                                           // loads value in v[j]
                
                adrp x0, values_p                                                           // setting first argm of printf
                add x0, x0, :lo12:values_p                                                  // add low 12 bits to x0
                mov w1, i_r                                                                 // place value of i into w1 for printf
                mov w2, vj_r                                                                // place value of v[j] in w2 for prinf
                bl printf                                                                   // calls printf function
                
                add i_r, i_r, 1                                                             // i++
                str i_r, [fp, i_s]                                                          // store new value of i into stack

sortp_test:     cmp i_r, size                                                               // compare i and size
                b.lt print_sort                                                             // if i < size jump to print_val to print values

//---end of code (deallocation of memory)----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
end:            mov x0, 0                                                                   // Store the value 0 in register x0. By convention, funtions use x0 to return values makes main return 0

                ldp fp, lr, [sp], dealloc                                                   // Load x29 & x30 from the address pointed to by SP. [sp], 16 increases sp by 16 *AFTER* this operation is done

                ret                                                                         // "Returns" from this function. Sets the program counter to the value stored in a register. 
                                                                                            //  If no register is given, defaults to x30 (AKA LR)
