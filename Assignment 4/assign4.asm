//  ***  Sahil Brar (UCID: 30021440)  ***
// CPSC 355 (L01) Assignment 4

// Assignment 4: Create an aRMv8 assembly language program that implements the provided C code. Implement all the subroutines as unoptimized
//               closed subroutines, using stack variables to store all local variables. Note that the function newPyramid() must have a local
//               variable (called p) which is returned by value to main, where it is assigned to the local variables khafre and cheops.
//               (Copy the C code to assembly even if it seems inefficient)
//               Also run the program in gdb, displaying the values of khafre and cheops after they have been set by function calls. Capture
//               the gdb session and make an output script.txt file.

//---PRINT STATEMENTS-----------------------------------------------------------------------------------------------------------------------------------------------------------------
print_Pyramid:      .string "\tCenter = (%d, %d)\n\tBase width = %d   Base length = %d\n\tHeight = %d\n\tVolume = %d\n\n"
print_initial:      .string "\nInitial pyramid values: \n"
print_new:          .string "\nNew pyramid values: \n"
print_khafre:       .string "Pyramid Khafre\n"
print_cheops:       .string "Pyramid Cheops\n"

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    fp .req x29                                                         // Register equates to rename x29 to fp
                    lr .req x30                                                         // Register equates to rename x30 to lr

                    define(result_r, w19)                                               // Define register w19 as result_r
                    define(factor_r, w27)                                               // Define register w27 as factor_r
                    define(p_r, x19)                                                    // Define register x19 as p_r
                    define(khafre_r, x20)                                               // Define register x20 as khafre_r
                    define(cheops_r, x21)                                               // Define register x21 as cheops_r

                    x_offset = 0                                                        // Offset for x
                    y_offset = 4                                                        // Offset for y
                    center_offset = 0                                                   // Offset for nested struct center (coord)

                    width_offset = 0                                                    // Offset for width
                    length_offset = 4                                                   // Offset for length
                    base_offset = 8                                                     // Offset for nested struct base (size)
                        
                    height_offset = 16                                                  // Offset for height
                    volume_offset = 20                                                  // Offset for volume

                    result_offset = 16                                                  // Offset for result

                    khafre_size = 32                                                    // Size of pyramid Khafre
                    cheops_size = 32                                                    // Size of pyramid Cheops
                    khafre_s = 16                                                       // Shift in memory from fp
                    cheops_s = 40                                                       // Shift in memory from fp and Khafre
                   
                    p_size = 32                                                         // Size of pyramid p

                    result_size = 4                                                     // Size of result in bytes
                    factor_size = 4                                                     // Size of factor
                    
                    alloc = -(16 + cheops_size + khafre_size) & -16                     // Allocation for memory for main          
                    dealloc = -alloc                                                    // Deallocation for memory for main

                    .balign 4                                                           // Aligns instruction bits by 4
                    .global main                                                        // Make main visible to the linker. When compiling with gc, a "main" function must be visible.
//---int main()----------------------------------------------------------------------------------------------------------------------------------------------------
main:               stp fp, lr, [sp, alloc]!                                            // Store X29 and X30 at the address pointed to by SP.
                    mov fp, sp                                                          // Copy SP to X29

                    add khafre_r, fp, khafre_s                                          // Calculate base address for Khafre            
                    mov x8, khafre_r                                                    // move Khafre_r into x8 for calucations in subroutine or struct
                    mov w1, 10                                                          // move initial value for width of 10 into w1 for subroutine
                    mov w2, 10                                                          // move initial value for length of 10 into w2 for subroutine
                    mov w3, 9                                                           // move initial value for height of 9 into w3 for subroubtine
                    bl newPyramid                                                       // Branch to newPyramid

                    add cheops_r, fp, cheops_s                                          // calculate base address for Cheops
                    mov x8, cheops_r                                                    // move cheops_r into x8 for calucaltions in subroutine    
                    mov w1, 15                                                          // move initial value for width of 15 into w1 for subroutine
                    mov w2, 15                                                          // move initial value for length of 15 into w2 for subroutine
                    mov w3, 18                                                          // move initial value for height of 18 into w3 for subroutine
                    bl newPyramid                                                       // branch to newPyramid

                    adrp x0, print_initial                                              // setting first argm of printf
                    add x0, x0, :lo12:print_initial                                     // add low 12 bits to x0
                    bl printf                                                           // calls printf function

                    adrp x0, print_khafre                                               // setting first argm of printf
                    add x0, x0, :lo12:print_khafre                                      // add low 12 bits to x0
                    bl printf                                                           // calls printf function
                    mov x8, khafre_r                                                    // move Khafre_r into x8 for calucations in subroutine or struct
                    bl printPyramid                                                     // branch to printPyramid
                    
                    adrp x0, print_cheops                                               // setting first argm of printf
                    add x0, x0, :lo12:print_cheops                                      // add low 12 bits to x0
                    bl printf                                                           // calls printf function
                    mov x8, cheops_r                                                    // move cheops_r into x8 for calucaltions in subroutine 
                    bl printPyramid                                                     // branch to printPyramid

                    bl equalSize                                                        // branch to equalSize

                    ldr result_r, [fp, result_offset]                                   // load result from equalSize into result_r
                    cmp result_r, 1                                                     // compare result_r and 1
                    b.eq false                                                          // if equals 1, branch to false

                    mov x8, cheops_r                                                    // move cheops_r into x8 for calucaltions in subroutine 
                    mov w1, 9                                                           // move factor value of 9 into w1 for expand subroutine
                    bl expand                                                           // branch to expand
        
                    mov x8, cheops_r                                                    // move cheops_r into x8 for calucaltions in subroutine 
                    mov w1, 27                                                          // move 27 into w1 for reloation subroutine
                    mov w2, -10                                                         // move -10 into w2 for relocation subroutine
                    bl relocate                                                         // branch to relocate

                    mov x8, khafre_r                                                    // move Khafre_r into x8 for calucations in subroutine or struct
                    mov w1, -23                                                         // move -23 into w1 for relocation subroutine
                    mov w2, 17                                                          // move 117 into w2 for relocation subroutine
                    bl relocate                                                         // branch to relocate

false:              adrp x0, print_new                                                  // setting first argm of printf
                    add x0, x0, :lo12:print_new                                         // add low 12 bits to x0
                    bl printf                                                           // calls printf function

                    adrp x0, print_khafre                                               // setting first argm of printf
                    add x0, x0, :lo12:print_khafre                                      // add low 12 bits to x0
                    bl printf                                                           // calls printf function
                    mov x8, khafre_r                                                    // move Khafre_r into x8 for calucations in subroutine or struct
                    bl printPyramid                                                     // branch to printPyramid
                    
                    adrp x0, print_cheops                                               // setting first argm of printf
                    add x0, x0, :lo12:print_cheops                                      // add low 12 bits to x0
                    bl printf                                                           // calls printf function
                    mov x8, cheops_r                                                    // move cheops_r into x8 for calucaltions in subroutine 
                    bl printPyramid                                                     // branch to printPyramid

//---end of code (deallocation of memory)----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
end:                mov x0, 0                                                           // Store the value 0 in register x0. By convention, funtions use x0 to return values makes main return 0

                    ldp fp, lr, [sp], dealloc                                           // Load x29 & x30 from the address pointed to by SP

                    ret                                                                 // "Returns" from this function. Sets the program counter to the value stored in a register. 
                                                                                        //  If no register is given, defaults to x30 (AKA LR)

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//---struct pyramid newPyramid-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    newPyramid_alloc = -(16 + p_size) & -16                             // Calculate memory allocation for newPyramid
                    newPyramid_dealloc = -newPyramid_alloc                              // Calculate memory deallocation for newPyramid            

newPyramid:         stp fp, lr, [sp, newPyramid_alloc]!                                 // Store X29 and X30 at the address pointed to by SP.
                    mov fp, sp                                                          // Copy SP to X29   

                    mov p_r, x8                                                         // move pyramid into local variable p_r

                    str wzr, [p_r, center_offset + x_offset]                            // p.center.x = 0

                    str wzr, [p_r, center_offset + y_offset]                            // p.center.y = 0
                    
                    mov w28, w1                                                         // mov w1 (width) into w28 for volume calculation
                    str w1, [p_r, base_offset + width_offset]                           // p.base.width = width

                    mul w28, w28, w2                                                    // p.volume = width * length
                    str w2, [p_r, base_offset + length_offset]                          // p.base.length = length

                    mul w28, w28, w3                                                    // p.volume = width * length * height
                    str w3, [p_r, height_offset]                                        // p.height = height 

                    mov w22, 3                                                          // move 3 into w22     
                    udiv w28, w28, w22                                                  // p.volume = (width * length * height) / 3
                    str w28, [p_r, volume_offset]                                       // p.volume stored
        
                    ldp fp, lr, [sp], newPyramid_dealloc                                // Load x29 & x30 from the address pointed to by SP
                    ret                                                                 // "Returns" from this function. Sets the program counter to the value stored in a register. 

//---printPyramid----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    print_alloc = -(16 + p_size) & -16                                  // Calculate memory allocation for printPyramid             
                    print_dealloc = -print_alloc                                        // Calculate memory deallocation for printPyramid

printPyramid:       stp fp, lr, [sp, print_alloc]!                                      // Store X29 and X30 at the address pointed to by SP.
                    mov fp, sp                                                          // Copy SP to X29

                    adrp x0, print_Pyramid                                              // setting first argm of printf
                    add x0, x0, :lo12:print_Pyramid                                     // add low 12 bits to x0
                    ldr w1, [x8, x_offset + center_offset]                              // w1 = p.center.x
                    ldr w2, [x8, y_offset + center_offset]                              // w2 = p.center.y
                    ldr w3, [x8, width_offset + base_offset]                            // w3 = p.base.width
                    ldr w4, [x8, length_offset + base_offset]                           // w4 = p.base.length
                    ldr w5, [x8, height_offset]                                         // w5 = p.height
                    ldr w6, [x8, volume_offset]                                         // w6 = p.volume
                    bl printf                                                           // calls printf function         

                    mov x0, 0                                                           // Store the value 0 in register x0
                    ldp fp, lr, [sp], print_dealloc                                     // Load x29 & x30 from the address pointed to by SP              
                    ret                                                                 // "Returns" from this function. Sets the program counter to the value stored in a register. 

//---void equalSize---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    equal_alloc = -(16 + alloc + result_size) & -16                     // Calculate memory allocation for equalSize subroutine
                    equal_dealloc = -equal_alloc                                        // Calcuate memory deallocation for equalSize subroutine

equalSize:          stp fp, lr, [sp, alloc]!                                            // Store X29 and X30 at the address pointed to by SP.
                    mov fp, sp                                                          // Copy SP to X29  

                    mov result_r, 0                                                     // result = FALSE       

                    ldr w23, [khafre_r, width_offset + base_offset]                     // p1.base.width               
                    ldr w24, [cheops_r, width_offset + base_offset]                     // p2.base.width           
                    cmp w23, w24                                                        // compare both widths (if #1)
                    b.ne skip                                                           // if not equal, then skip
                    
                    ldr w23, [khafre_r, length_offset + base_offset]                    // p1.base.length        
                    ldr w24, [cheops_r, length_offset + base_offset]                    // p2.base.length         
                    cmp w23, w24                                                        // compare both lengths (if #2)
                    b.ne skip                                                           // if not equal, then skip
                                                                   
                    ldr w23, [khafre_r, height_offset]                                  // p1.height   
                    ldr w24, [cheops_r, height_offset]                                  // p2.height
                    cmp w23, w24                                                        // compare both heights (if #3)
                    b.ne skip                                                           // if not equal, then skip

                    mov result_r, 1                                                     // result = TRUE

skip:               str result_r, [fp, result_offset]                                   // Store result into memory
                    
                    ldp fp, lr, [sp], dealloc                                           // Load x29 & x30 from the address pointed to by SP
                    ret                                                                 // "Returns" from this function. Sets the program counter to the value stored in a register. 

//---void expand-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    expand_alloc = -(16 + p_size + factor_size) & -16                   // Calculate memory allocation for expand subroutine               
                    expand_dealloc = -expand_alloc                                      // Calcualte memory deallocation for expand subroutine     

expand:             stp fp, lr, [sp, newPyramid_alloc]!                                 // Store X29 and X30 at the address pointed to by SP.
                    mov fp, sp                                                          // Copy SP to X29
                    
                    ldr w10, [x8, base_offset + width_offset]                           // p.base.width         
                    mul w10, w10, w1                                                    // p.base.width * factor
                    mov w28, w10                                                        // p.volume = width
                    str w10, [x8, base_offset + width_offset]                           // store new width     

                    ldr w10, [x8, base_offset + length_offset]                          // p.base.length            
                    mul w10, w10, w1                                                    // p.base.length * factor
                    mul w28, w28, w10                                                   // p.volume = width * length     
                    str w10, [x8, base_offset + length_offset]                          // store new length           

                    ldr w10, [x8, height_offset]                                        // p.height   
                    mul w10, w10, w1                                                    // p.height * factor 
                    mul w28, w28, w10                                                   // p.volume = width * length * height
                    str w10, [x8, height_offset]                                        // store new height

                    mov w22, 3                                                          // move 3 into w22
                    udiv w28, w28, w22                                                  // p.volume = (width * length * height) / 3
                    str w28, [x8, volume_offset]                                        // store new volume             
                    
                    ldp fp, lr, [sp], newPyramid_dealloc                                // Load x29 & x30 from the address pointed to by SP
                    ret                                                                 // "Returns" from this function. Sets the program counter to the value stored in a register. 

//---void relocate----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    relocate_alloc = -(16 + alloc) & -16                                // Calculate memory allocation for relocate subroutine         
                    relocate_dealloc = -relocate_alloc                                  // Calculate memory deallocation for relocate subroutine

relocate:           stp fp, lr, [sp, relocate_alloc]!                                   // Store X29 and X30 at the address pointed to by SP.  
                    mov fp, sp                                                          // Copy SP to X29

                    ldr w23, [x8, x_offset + center_offset]                             // p.center.x                 
                    add w23, w23, w1                                                    // p.center.x + deltaX     
                    str w23, [x8, x_offset + center_offset]                             // store new x        
    
                    ldr w23, [x8, y_offset + center_offset]                             // p.center.y
                    add w23, w23, w2                                                    // p.center.y + deltaY
                    str w23, [x8, y_offset + center_offset]                             // store new y

                    ldp fp, lr, [sp], relocate_dealloc                                  // Load x29 & x30 from the address pointed to by SP
                    ret                                                                 // "Returns" from this function. Sets the program counter to the value stored in a register. 
