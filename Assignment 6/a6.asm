//  ***  Sahil Brar (UCID: 30021440)  ***
// CPSC 355 (L01) Assignment 6

// Assignment 6: Write an ARMv8 assembly language program to compute the function arctan(x) using the series expansion from the assignment file.
//               Use double precision floating-point numbers. The program will read a series of input values from a file whose name is specified
//               in command line. The input values will be in binary format; each number will be double precision (thus each is 8 bytes long).
//               Read from the file using system I/O. Process the input values one at a time using a loop, calculate arctan(x), and then use 
//               printf() to print out the input value and its corresponding output values in table form to the screen. Print out all values
//               with a precision of 10 decimal digits to the right of the decimal point. Run the program using the input.bin file and capture
//               its execution using a script command.

//---data---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    .data
                    .balign 8                                                           // Align by 8 bits
STOP_LIMIT:         .double 0r1.0e-13                                                   // ending series comparison value
temp_m:             .double 0r0.0                                                       // Initialize temp variable
divnum_m:           .double 0r100.0                                                     // Dividing by 100 value
zero_m:             .double 0r0.0                                                       // Define variable for 0

//---text----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    .text
                    .balign 4
//---Print statments----------------------------------------------------------------------------------------------------------------------------------------------------------------------
fmt_abort:          .string "Can't open file for writing.   Aborting.\n"
fmt_error:          .string "Error writing file.    Aborting.\n"
fmt_opening:        .string "\nOpening file: %s\n"
fmt_notopen:        .string "Error: Incorrect number of arguments. Usage: ./a6 <filename.bin>\n"
fmt_end:            .string "-----------------------------------\nEnd of file reached.\n\n"
fmt_head:           .string "\n     x:          |     arctan(x):   \n-----------------------------------\n"
fmt_x:              .string " %.10f   "                                                 // Prints negative x values so all values line up in output
fmt_x2:             .string "  %.10f    "                                               // Prints positive x values so all values line up in output
fmt_arctan:         .string "   %.10f\n"                                                // Prints arctan(x) value

//---Constants, Variables and defining of registers---------------------------------------------------------------------------------------------------------------------------------------------------------
                    LOWER_LIMIT = -95
                    UPPER_LIMIT = +95
                    INCREMENT = 5

                    buf_size = 8                                                        // Buffer for reading 8 byte floats
                    buf_s = 16                                                          // Buffer offset in memory
                        
                    alloc = -(16 + buf_size) & -16                                      // Allocation of memory calculation for main
                    dealloc = -alloc                                                    // Deallocation of memory calucation for main

                    fp .req x29                                                         // Register equates to rename x29 to fp
                    lr .req x30                                                         // Register equates to rename x30 to lr

                    define(value_r, w19)                                                // Define register for value
                    define(fd_r, w20)                                                   // Define register for fd
                    define(argc_r, w21)                                                 // Define register for argc
                    define(argv_r, x22)                                                 // Define register for argv
                    define(buf_base_r, x23)                                             // Define register for buf base address
                    define(nread_r, x24)                                                // Define register for variable read

//---arctan(x)-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    .global main
                    .balign 4
arctan:             stp fp, lr, [sp, -16]!                                              // Memory allocation for subroutine
                    mov fp, sp

                    fmov d9, d0                                                         // Move input from d0 into temorary register d9 (x)

                    adrp x10, STOP_LIMIT                                                // Get address of the series ending condtional number
                    add x10, x10, :lo12:STOP_LIMIT
                    ldr d10, [x10]                                                      // Move stop limit into d10

                    adrp x10, zero_m                                                    // Get address of variable holding 0
                    add x0, x10, :lo12:zero_m
                    ldr d15, [x10]                                                      // Move 0 into d15 (arctan(x) sum)
                    ldr d14, [x10]                                                      // Move 0 into d15

                    mov w11, 1                                                          // initialize # of times run to 1 (incremented later)

                    fmov d12, 1.0                                                       // n=d12 (initialized to 1, increments by 2 later)

arc_loop:           cmp w11, 1                                                          // Compare counter to 1
                    b.gt arc_next1                                                      // If greater than 1 then skip over initial step

                    fmov d13, d9                                                        // Otherwise d13 = x
                    fmov d2, d13                                                        // d2 = d13 (x before divided by n)
                    b arc_contd

arc_next1:          fmov d13, d2                                                        // reload value of x^n before it was divided by n                              
                    fmul d13, d13, d9                                                   // mul current term by x
                    fmul d13, d13, d9                                                   // mul current term by x (x^n)
                    fneg d13, d13                                                       // negate x (flips for adidition/subtraction in formula)
                    fmov d2, d13                                                        // save value x^n before it is divided by n
                    fdiv d13, d13, d12                                                  // current x^n/ n

arc_contd:          fadd d15, d15, d13                                                  // arctan(x) holding total
                    add w11, w11, 1                                                     // Increment w11 by 1
                    fmov d1, 2.0                                                        // Move 2.0 into d1
                    fadd d12, d12, d1                                                   // increment n by 2

                    fcmp d13, d14                                                       // Compare x^n/n with 0 to see if it is positive or negative
                    b.gt arc_check                                                      // If positve, branch to arc_check

                    fneg d13, d13                                                       // Otherwise is negative, negate it to turn positive
                    fcmp d13, d10                                                       // Compare x^n/n with 1.0e-13
                    fneg d13, d13                                                       // Negate the value back to get its original sign
                    b.gt arc_loop                                                       // If x^n/n > 1.0e-13 branch back to loop to continue series
                    b arc_exit                                                          // Otherwise end series and break to arc_exit

arc_check:          fcmp d13, d10                                                       // Compare x^n/n with 1.e-13
                    b.gt arc_loop                                                       // If x^n/n > 1.0e-13 branch back to loop to continue series

arc_exit:           fmov d0, d15                                                        // Move arct(x) series calculation into d0 to return
                    ldp fp, lr, [sp], 16                                            
                    ret                                                                 // Return

//---main()----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    .global main
                    .balign 4                       
main:               stp fp, lr, [sp, alloc]!                                            // Allocate memory for main()
                    mov fp, sp

                    mov argc_r, w0                                                      
                    mov argv_r, x1
                    cmp argc_r, 2                                                       // Compare number of arguments
                    b.eq contd                                                          // If equal branch to contd
                    
                    adrp x0, fmt_notopen                                                // Otherwise print cannot open file                                    
                    add x0, x0, :lo12:fmt_notopen
                    bl printf
                    b end                                                               // Then branch to end program

contd:              adrp x0, fmt_opening                                                // Print which file is being opened
                    add x0, x0, :lo12:fmt_opening
                    ldr x1, [argv_r, 8]                                                 // Load what file from command line into x1
                    bl printf

                    mov x0, -100                                                        // Reading input from file begins, first arg (cwd)
                    ldr x1, [argv_r, 8]                                                 // 2nd arg (pathname)
                    mov w2, 0                                                           // 3rd arg (read only)
                    mov w3, 0                                                           // 4th arg (not used)
                    mov x8, 56                                                          // Openat I/O request
                    svc 0                                                               // Call system function
                    mov fd_r, w0                                                        // Record file descriptor

                    // Error check openat
                    cmp fd_r, 0                                                         // error check: branch over
                    b.ge openok                                                         // If file opened successfully, branch to openok

                    // Otherwise cant openat, then abort
                    adrp x0, fmt_abort                                                  // Printing abort statement
                    add x0, x0, :lo12:fmt_abort
                    bl printf
                    mov x0, -1                                                          // return -1
                    b end                                                               // Branch to end

openok:             add buf_base_r, fp, buf_s                                           // Calculate base address of buf

                    adrp x0, fmt_head                                                   // Printing header
                    add x0, x0, :lo12:fmt_head
                    bl printf

                    // For loop
                    mov value_r, LOWER_LIMIT                                            // Value = LOWER_LIMIT
                    b test                                                              // Branch to test

loop:               mov w0, fd_r                                                        // 1st arg (fd)
                    mov x1, buf_base_r                                                  // 2nd arg (buf)
                    mov w2, buf_size                                                    // 3rd arg (n)
                    mov x8, 63                                                          // Read I/O request
                    svc 0                                                               // Call system function
                    mov nread_r, x0                                                     // Record the # of bytes read

                    cmp nread_r, buf_size                                               // Compare # of bytes read and 8
                    b.ne exit                                                           // if nread != 8 exit loop

                    ldr d0, [buf_base_r]                                                // Load x into d0

                    adrp x10, zero_m                                                    // Get address of variable holding 0.0
                    add x0, x10, :lo12:zero_m
                    ldr d14, [x10]                                                      // Load d14 with 0.0

                    fcmp d0, d14                                                        // Compare x and 0.0 (Checking if positive for negative for printing lined up columns)
                    b.ge print_space                                                    // If x >= 0 branch to print_space

                    adrp x0, fmt_x                                                      // Otherwise print x as normally (negative)
                    add x0, x0, :lo12:fmt_x
                    bl printf
                    b temp_div                                                          // Branch to temp_div

print_space:        adrp x0, fmt_x2                                                     // Since positive add additional space to print statement
                    add x0, x0, :lo12:fmt_x2    
                    bl printf

temp_div:           adrp x10, temp_m                                                    // Get address of variable temp
                    add x10, x10, :lo12:temp_m
                    ldr d0, [x10]                                                       // Load temp into d0

                    scvtf d1, value_r                                                   // Convert value into a signed floating point number and put into d1
                    
                    adrp x10, divnum_m                                                  // Get address of 100 (dividing number)
                    add x10, x10, :lo12:divnum_m
                    ldr d2, [x10]                                                       // Load 100 into d2

                    fdiv d0, d1, d2                                                     // temp = value/100

                    bl arctan                                                           // Branch to arctan to calculate arctan

                    adrp x0, fmt_arctan                                                 // Setup print for arctan(x)
                    add x0, x0, :lo12:fmt_arctan
                    bl printf

                    add value_r, value_r, INCREMENT                                     // value += INCREMENT

test:               cmp value_r, UPPER_LIMIT                                            // Compare value and UPPER_LIMIT
                    b.le loop                                                           // If value <= UPPERLIMIT branch to loop

exit:               adrp x0, fmt_end                                                    // Setup print statement for file has ended
                    add x0, x0, :lo12:fmt_end
                    bl printf

                    mov w0, fd_r                                                        // 1st arg (fd)
                    mov x8, 57                                                          // Close I/O request
                    svc 0                                                               // Call system function

end:                ldp fp, lr, [sp], dealloc                                           // Deallocate memory for main
                    ret
