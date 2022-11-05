.global _start
input_image: .word 1057442138,  2410420899, 519339369,  2908788659, 1532551093, 4249151175, 4148718620, 788746931,  3777110853, 2023451652
.word 3000595192,   1424215634, 3130581119, 3415585405, 2359913843, 1600975764, 1368061213, 2330908780, 3460755284, 464067332
.word 2358850436,   1191202723, 2461113486, 3373356749, 3070515869, 4219460496, 1464115644, 3200205016, 1316921258, 143509283
.word 3846979011,   2393794600, 618297079,  2016233561, 3509496510, 1966263545, 568123240,  4091698540, 2472059715, 2420085477
.word 395970857,    2217766702, 44993357,   694287440,  2233438483, 1231031852, 2612978931, 1464238350, 3373257252, 2418760426
.word 4005861356,   288491815, 3533591053,  754133199,  3745088714, 2711399263, 2291899825, 2117953337, 1710526325, 1989628126
.word 465096977,    3100163617, 195551247,  3884399959, 422483884,  2154571543, 3380017320, 380355875,  4161422042, 654077379
.word 2168260534,   3266157063, 3870711524, 2809320128, 3980588369, 2342816349, 1283915395, 122534782,  4270863000, 2232709752
.word 1946888581,   1956399250, 3892336886, 1456853217, 3602595147, 1756931089, 858680934,  2326906362, 2258756188, 1125912976
.word 1883735002,   1851212965, 3925218056, 2270198189, 3481512846, 1685364533, 1411965810, 3850049461, 3023321890, 2815055881

output_image: .space 24 
.space 24
.space 24
.space 24
.space 24
.space 24

arr: .space 100       // size 25 array to hold the elements in every window

_start:
ldr a1, =input_image  // a1 points to array 
ldr a2, =arr          // a2 points to the array
ldr a3, =output_image // a3 points to the output image
mov a4, a1            // a4 copies the original address 
mov v7, #3            // v7 used to store the offset of the ldrb and strb 

median_filter:
mov v2, #0                    // v2 stores the k which records the downward sliding of window
mov v3, #0                    // v3 stores the l which records the rightward sliding of window 
mov v4, #0                    // v4 stores i which is row of the window
mov v5, #0                    // v5 stores j which is column of the window
push {a1-a3,v1-v5,lr}         // push the original values
b fourth_for            
                           
first_for:              // increment of downward movement
cmp v2, #5
bge end_value           // when k reaches 6, which means the process of one value is done
mov v4, #0              // restore the value for i 
mov v5, #0              // restore the value for j
mov v3, #0              // restore the value for l
add a3,a3,#4
add v2,v2,#1            // k=k+1;
mov a1,a4              // a1 points to the first element
add a1,a1,v3,lsl #2    // update address: r0 = r0 + 4l + 40k
add a1,a1,v2,lsl #5   
add a1,a1,v2,lsl #3

b fourth_for      // starts from the inner loop from the new k value

second_for:           // increment of right movement
push {lr}             // start sorting the 25-element array
bl sort              
pop  {lr}
ldr a2, [sp,#4]      // we need to restore the address of arr and reload element into it.

cmp v3, #5
bge first_for          
mov a1, a4           // when moving the window, we first need to restore the base address
mov v4, #0           // also need to restore value for i
mov v5, #0           // restore value for j

add a3,a3,#4         // after storing the median value into the array, we update the base address of the output array
add v3,v3,#1         // l=l+1

add a1,a1,v3,lsl #2  // update address: r0 = r0 + 4l + 40k
add a1,a1,v2,lsl #5   
add a1,a1,v2,lsl #3

b fourth_for          // with new base address, we start again from the inner loop

third_for:
cmp v4, #4
bge second_for
add v4,v4,#1
mov v5, #0             // when we start a new fourth for loop, we should restore value for j
mov a1, a4             // we need to restore the current base address which is r0 = r0 + 4l + 40k
add a1,a1,v3,lsl #2
add a1,a1,v2,lsl #5
add a1,a1,v2,lsl #3
b fourth_for    

fourth_for:
cmp v5, #5                
bge third_for
mov a1, a4                // restore the base address
add a1,a1,v3,lsl #2
add a1,a1,v2,lsl #5
add a1,a1,v2,lsl #3

add a1,a1,v5,lsl #2       // address is r0+40i+4j within the window 
add a1,a1,v4,lsl #5
add a1,a1,v4,lsl #3

ldrb v1, [a1,v7]              // v1 stores the R value of the element


str v1,[a2]               // extract element and store it in arr
add a2,a2,#4              // a2 points to next 
add v5,v5,#1
b fourth_for          // continue the inner loop

end_value:
subs v7,v7,#1
blt end_all
ldr a1,[sp,#0]
ldr a2,[sp,#4]
ldr a3,[sp,#8]
mov v2, #0                    
mov v3, #0                    
mov v4, #0                    
mov v5, #0                    
b fourth_for

end_all: 
pop {a1-a3,v1-v5,lr}
b end

sort:
push {a1-a4,v1-v5}
sub a2,a2,#100       // a2 now points to the first element
mov v1, #25          // v1 now stores the size of this array
mov v2, #1           // v2 now stores the i of the sorting loop
for:
cmp v2,v1 
BGE end_sort
ldr v3,[a2,#4]!      // v3 stores the arr[i]
mov a1, v2           // a1 stores j
mov v4, a2           // v4 stores the address of the j points to 
while:
cmp a1,#0            // compare j with 0
ble insert
ldr v5,[v4,#-4]      // v5 stores  arr[j-1]
cmp v5, v3          // compare arr[j-1] and arr[i]
ble insert
str v5,[v4]
sub a1,a1,#1        // j=j-1
sub v4,v4,#4        // v4 points to the previous one
B while
insert:
str v3, [v4]        // arr[j] == value 
add v2, v2, #1      // i= i+1
B for
end_sort:
sub a2,a2,#48            //  a2 now points to the median of the sorted array
ldr a4,[a2]              // a4 now is the median
strb a4,[a3,v7]          // insert median to the out_put image. for red one just store it to the most significant byte
pop {a1-a4,v1-v5}        // pop all the previously pushed registers
bx lr   

end:
b end
	