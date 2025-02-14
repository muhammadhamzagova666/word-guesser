;***********************************************************************
; Filename   : Word Guesser.txt
; Project    : Word Guesser – Interactive Assembly Language Game
; Type       : Educational Assembly Language Semester Project
; Author     : Team Members
;            :   Muhammad Talha (21K-3349)
;            :   Muhammad Hamza (21K-4579)
;            :   Muhammad Taha  (21K-3316)
; Instructor : Sir Nadeem Ghouri
; Purpose    : Display groups of alphabets, allow user to select groups 
;            : and rearrange letters to form a guessed word.
; Comments   : Descriptive comments are provided to explain why each
;            : block of code is executed.
;***********************************************************************

INCLUDE Irvine32.inc

.data
; Define the alphabets string (includes filler characters for spacing)
alphabets BYTE "ABCDEFGHIJKLMNOPQRSTUVWXYZ*****************", 0

; Group arrays to store the user-selected indices for different word lengths.
gr3 BYTE 3 DUP(0)       ; For 3-letter words.
gr4 BYTE 4 DUP(0)       ; For 4-letter words.
gr5 BYTE 5 DUP(0)       ; For 5-letter words.
gr6 BYTE 6 DUP(0)       ; For 6-letter words.
gr7 BYTE 7 DUP(0)       ; For 7-letter words.
gr8 BYTE 8 DUP(0)       ; For 8-letter words.

; Arrays for storing the rearranged letters based on the selected groups.
arr3 BYTE 9 DUP(0)      ; 3-letter arrangement (using extra space for spacing).
arr4 BYTE 16 DUP(0)     ; 4-letter arrangement.
arr5 BYTE 25 DUP(0)     ; 5-letter arrangement.
arr6 BYTE 36 DUP(0)     ; 6-letter arrangement.
arr7 BYTE 49 DUP(0)     ; 7-letter arrangement.
arr8 BYTE 64 DUP(0)     ; 8-letter arrangement.

tcx DWORD ?             ; Temporary variable for intermediate calculations.

;**********************************************************
; Prompt and Message String Literals
; All messages are crafted to be clear and user-friendly.
;**********************************************************
prompt0 BYTE "WORD GUESSER", 0
prompt1 BYTE "Computer Organization & Assembly Language Semester Project", 0
prompt2 BYTE "Instructor: Sir Nadeem Ghouri", 0
prompt3 BYTE "Members: ", 0
prompt4 BYTE "   Muhammad Talha   (21K-3349)", 0
prompt5 BYTE "   Muhammad Hamza   (21K-4579)", 0
prompt6 BYTE "   Muhammad Taha    (21K-3316)", 0
prompt7 BYTE "Exiting the game. Thank you for playing!", 0
prompt8 BYTE "Developers: ", 0
strLetter BYTE "Enter The Number Of Letters (3 - 8; Enter 0 to Exit): ", 0 
Askgroup BYTE "Enter Group Number: ", 0 
guess1 BYTE "The Guessed Word: ", 0 
inv BYTE "Invalid Input!", 0
space BYTE "  ", 0

;******************************************************************
; General-purpose Counters and Temporary Storage Variables
;******************************************************************
counter BYTE 0      ; Counter for spacing in group display.
count BYTE 1        ; Counter for grouping letters.
count1 BYTE 1       ; Secondary counter for display formatting.
alpha BYTE 8 DUP(0) ; Final output word storage (size accommodates up to 8 letters).

check BYTE ?        ; Flag variable (reserved for future use).
letters BYTE ?      ; Stores the number of letters chosen by the user.
rowSize DWORD ?     ; Reserved for layout configuration.
locAalphabet DWORD ?; Reserved for future alphabet position calculations.

.code

;******************************************************************
; Procedure: MAIN
; Purpose  : Handles program startup, user input, and dispatches
;            to appropriate letter processing subroutines.
;******************************************************************
MAIN PROC
    ; Set text color for improved visual clarity.
    mov eax, 2 + 0 * 4
    call setTextColor

    ; Display project title and introductory details.
    mov edx, OFFSET prompt0
    call WRITESTRING
    call crlf
    call crlf

    mov edx, OFFSET prompt1
    call WRITESTRING
    call crlf

    mov edx, OFFSET prompt2
    call WRITESTRING
    call crlf
    call crlf

    mov edx, OFFSET prompt3
    call WRITESTRING
    call crlf

    mov edx, OFFSET prompt4
    call WRITESTRING
    call crlf

    mov edx, OFFSET prompt5
    call WRITESTRING
    call crlf

    mov edx, OFFSET prompt6
    call WRITESTRING
    call crlf

    ; Wait for the user to acknowledge before moving forward.
    call crlf
    call waitmsg

    ; Initialize exit code.
    mov eax, 0

rep1:
    ; Clear screen and prompt for the number of letters.
    call clrscr
    mov edx, OFFSET strLetter
    call WRITESTRING
    call READDEC
    
    ; Store the user input into variable 'letters'.
    mov letters, al 
    cmp al, 0
    je ex         ; Exit if user inputs 0.
    cmp al, 2
    jbe repeat1   ; Prompt again if input is less than 3.

    ; Dispatch to the subroutine based on number of letters.
    cmp letters, 3
    je three
    cmp letters, 4
    je four
    cmp letters, 5
    je five
    cmp letters, 6
    je six1
    cmp letters, 7
    je seven
    cmp letters, 8
    je eight

repeat1:
    ; Inform user of invalid input and pause briefly before retry.
    mov edx, OFFSET inv
    call WRITESTRING
    call crlf
    push eax
    mov eax, 1000
    call delay
    pop eax
    call clrscr
    jmp rep1

;******************************************************************
; Subroutine Dispatch for Different Word Lengths
;******************************************************************
three:
    call letter3
    jmp ex

four:
    call letter4
    jmp ex

five:
    call letter5
    jmp ex

six1:
    call letter6
    jmp ex

seven:
    call letter7
    jmp ex

eight:
    call letter8

;******************************************************************
; Exit Section: Final messages and cleanup before program termination.
;******************************************************************
ex:
    call crlf
    mov edx, OFFSET prompt7
    call WRITESTRING
    call crlf
    mov eax, 3000
    call delay
    call clrscr

    mov edx, OFFSET prompt0
    call WRITESTRING
    call crlf
    call crlf
    mov edx, OFFSET prompt8
    call WRITESTRING
    call crlf
    mov edx, OFFSET prompt4
    call WRITESTRING
    call crlf
    mov edx, OFFSET prompt5
    call WRITESTRING
    call crlf
    mov edx, OFFSET prompt6
    call WRITESTRING
    call crlf

    exit
MAIN ENDP

;******************************************************************
; Procedure: letter3
; Purpose  : Process input and generate the output for a 3-letter word.
;            Includes displaying groups, prompting for group selection,
;            and rearranging letters based on the user’s input.
;******************************************************************
letter3 PROC
    xor ebx, ebx
    mov ecx, 26

    ; Display groups of three letters (for visual aid).
group1:
    mov al, [alphabets + ebx]
    call WRITECHAR
    cmp count, 3
    jne next
    ; After printing 3 letters, insert space for separation.
    jmp space1

space1:
    mov edx, OFFSET space
    call WRITESTRING
    inc counter      ; Increase counter for spaces printed.
    mov count, 0
next:
    inc count
    inc ebx
    loop group1
    call crlf

    ; Prompt for group selection from the displayed groups.
    mov esi, 0
    mov ecx, 3
    mov edx, OFFSET Askgroup
    call WRITESTRING
    call crlf

input:
    call READINT
    sub al, 1           ; Adjust from 1-based to 0-based indexing.
    cmp al, 0
    jb repeat3
    cmp al, 8
    ja repeat3
    jmp movInArr3

repeat3:
    inc ecx             ; Allow multiple attempts.
    mov edx, OFFSET inv
    call WRITESTRING
    call crlf
    loop input

movInArr3:
    mov [gr3+esi], al  ; Save validated selection.
    inc esi
    loop input

    ; Rearrangement of letters according to user-selected group.
    mov edi, 0
    mov ecx, 3

matrix:
    ; Multiply group selection by 3 to calculate starting offset.
    mov eax, 3
    movzx ebx, [gr3 + edi]
    mul ebx           ; eax now holds index offset.
    push ecx          ; Save loop counter.
    mov ecx, 3
    mov edx, edi

store:
    ; Transfer letter from alphabets to the arranged array.
    movzx ebx, [alphabets+eax]
    mov [arr3+edx], bl
    add edx, 3        ; Ensure letters remain spaced by 3 positions.
    inc eax
    loop store

    inc edi           ; Process next group selection.
    mov eax, 0
    pop ecx
    loop matrix

    ; Display the rearranged letters.
    mov esi, 0
    mov ecx, 9

group2:
    movzx eax, [arr3+esi]
    call WRITECHAR
    cmp count1, 3
    je space2
    jmp next1

space2:
    mov edx, OFFSET space
    call WRITESTRING
    mov count1, 0
next1:
    inc esi
    inc count1
    loop group2
    call crlf

    ; Ask user for a final adjustment of their group selection.
    mov ecx, 3
    mov esi, 0
    mov edx, OFFSET Askgroup
    call WRITESTRING
    call crlf

input1:
    call READDEC
    sub al, 1
    cmp al, 2
    ja tryagain3

    mov [gr3+esi], al
    inc esi
    loop input1
    call crlf
    jmp s

tryagain3:
    inc ecx
    mov edx, OFFSET inv
    call WRITESTRING
    call crlf
    loop input1

s:
    ; Output the final guessed word.
    mov edx, OFFSET guess1
    call WRITESTRING

    mov esi, 0
    mov ebx, 0
    mov ecx, 3
    mov eax, 3

guess:
    movzx edx, [gr3+esi]
    mul edx          ; Use multiplication to calculate letter location.
    mov ebx, eax
    movzx eax, [arr3+ebx+esi]
    mov [alpha+esi], al
    call WRITECHAR
    mov eax, 3
    inc esi
    loop guess

    ret
letter3 ENDP

;******************************************************************
; Procedure: letter4
; Purpose  : Process input and generate the output for a 4-letter word.
;            Follows analogous logic to letter3 but with groups of four.
;******************************************************************
letter4 PROC
    xor ebx, ebx
    mov ecx, 26

    ; Display groups of four letters.
group3:
    mov al, [alphabets+ebx]
    call WRITECHAR
    cmp count, 4
    jne next2
    jmp space3

space3:
    mov edx, OFFSET space
    call WRITESTRING
    inc counter      ; Count spacing groups.
    mov count, 0
next2:
    inc count
    inc ebx
    loop group3
    call crlf

    ; Prompt user for group selection.
    mov esi, 0
    mov ecx, 4
    mov edx, OFFSET Askgroup
    call WRITESTRING
    call crlf

input2:
    call READINT
    sub al, 1           ; Adjust to 0-based index.
    cmp al, 0
    jb repeat4
    cmp al, 7
    ja repeat4
    jmp movInArr4

repeat4:
    inc ecx
    mov edx, OFFSET inv
    call WRITESTRING
    call crlf
    loop input2

movInArr4:
    mov [gr4+esi], al  ; Save validated group selection.
    inc esi
    loop input2

    ; Rearrange letters based on group selection.
    mov edi, 0
    mov ecx, 4

matrix1:
    mov eax, 4
    movzx ebx, [gr4+edi]
    mul ebx           ; Multiply base value (4) with selection.
    push ecx
    mov ecx, 4
    mov edx, edi

store1:
    movzx ebx, [alphabets+eax]
    mov [arr4+edx], bl
    add edx, 4       ; Maintain fixed spacing.
    inc eax
    loop store1

    inc edi         ; Next group.
    mov eax, 0
    pop ecx
    loop matrix1

    ; Display the rearranged 4-letter groups.
    mov esi, 0
    mov ecx, 16

group4:
    movzx eax, [arr4+esi]
    call WRITECHAR
    cmp count1, 4
    je space4
    jmp next3

space4:
    mov edx, OFFSET space
    call WRITESTRING
    mov count1, 0
next3:
    inc esi
    inc count1
    loop group4
    call crlf

    ; Final group selection for 4-letter word.
    mov ecx, 4
    mov esi, 0
    mov edx, OFFSET Askgroup
    call WRITESTRING
    call crlf

input3:
    call READDEC
    sub al, 1
    cmp al, 3
    ja tryagain4

    mov [gr4+esi], al
    inc esi
    loop input3
    call crlf
    jmp r

tryagain4:
    inc ecx
    mov edx, OFFSET inv
    call WRITESTRING
    call crlf
    loop input3

r:
    ; Output the final guessed 4-letter word.
    mov edx, OFFSET guess1
    call WRITESTRING

    mov esi, 0
    mov ebx, 0
    mov ecx, 4
    mov eax, 4

guess2:
    movzx edx, [gr4+esi]
    mul edx
    mov ebx, eax
    movzx eax, [arr4+ebx+esi]
    mov [alpha+esi], al
    call WRITECHAR
    mov eax, 4
    inc esi
    loop guess2

    ret
letter4 ENDP

;******************************************************************
; Procedure: letter5
; Purpose  : Process input and generate output for a 5-letter word.
;            The logic is similar to letter3 and letter4 but with 5-letter groups.
;******************************************************************
letter5 PROC
    xor ebx, ebx
    mov ecx, 26

    ; Display groups of five letters.
group5:
    mov al, [alphabets+ebx]
    call WRITECHAR
    cmp count, 5
    jne next4
    jmp space5

space5:
    mov edx, OFFSET space
    call WRITESTRING
    inc counter      ; Track the number of group separations.
    mov count, 0
next4:
    inc count
    inc ebx
    loop group5
    call crlf

    ; Prompt the user for selecting groups.
    mov esi, 0
    mov ecx, 5
    mov edx, OFFSET Askgroup
    call WRITESTRING
    call crlf

input4:
    call READINT
    sub al, 1           ; Adjust input.
    cmp al, 0
    jb repeat5
    cmp al, 5
    ja repeat5
    jmp movInArr5

repeat5:
    inc ecx
    mov edx, OFFSET inv
    call WRITESTRING
    call crlf
    loop input4

movInArr5:
    mov [gr5+esi], al  ; Save user selection.
    inc esi
    loop input4

    ; Rearrangement logic for 5-letter groups.
    mov edi, 0
    mov ecx, 5

matrix2:
    mov eax, 5
    movzx ebx, [gr5+edi]
    mul ebx           ; Calculate starting offset.
    push ecx
    mov ecx, 5
    mov edx, edi

store2:
    movzx ebx, [alphabets+eax]
    mov [arr5+edx], bl
    add edx, 5        ; Increase offset by 5.
    inc eax
    loop store2

    inc edi
    mov eax, 0
    pop ecx
    loop matrix2

    ; Display the rearranged data.
    mov esi, 0
    mov ecx, 25

group6:
    movzx eax, [arr5+esi]
    call WRITECHAR
    cmp count1, 5
    je space6
    jmp next5

space6:
    mov edx, OFFSET space
    call WRITESTRING
    mov count1, 0
next5:
    inc esi
    inc count1
    loop group6
    call crlf

    ; Prompt final selection for the 5-letter word.
    mov ecx, 5
    mov esi, 0
    mov edx, OFFSET Askgroup
    call WRITESTRING
    call crlf

input5:
    call READDEC
    sub al, 1
    cmp al, 4
    ja tryagain5

    mov [gr5+esi], al
    inc esi
    loop input5
    call crlf
    jmp q

tryagain5:
    inc ecx
    mov edx, OFFSET inv
    call WRITESTRING
    call crlf
    loop input5

q:
    ; Output the final guessed 5-letter word.
    mov edx, OFFSET guess1
    call WRITESTRING

    mov esi, 0
    mov ebx, 0
    mov ecx, 5
    mov eax, 5

guess4:
    movzx edx, [gr5+esi]
    mul edx
    mov ebx, eax
    movzx eax, [arr5+ebx+esi]
    mov [alpha+esi], al
    call WRITECHAR
    mov eax, 5
    inc esi
    loop guess4

    ret
letter5 ENDP

;******************************************************************
; Procedure: letter6
; Purpose  : Process input and generate output for a 6-letter word.
;            Uses similar techniques with groups of six letters.
;******************************************************************
letter6 PROC
    xor ebx, ebx
    mov ecx, 26

    ; Display groups of six letters.
group7:
    mov al, [alphabets+ebx]
    call WRITECHAR
    cmp count, 6
    jne next6
    jmp space7

space7:
    mov edx, OFFSET space
    call WRITESTRING
    inc counter      ; Update spacing counter.
    mov count, 0
next6:
    inc count
    inc ebx
    loop group7
    call crlf

    ; Prompt user to select from 6-letter groups.
    mov esi, 0
    mov ecx, 6
    mov edx, OFFSET Askgroup
    call WRITESTRING
    call crlf

input6:
    call READINT
    sub al, 1
    cmp al, 0
    jb repeat6
    cmp al, 4
    ja repeat6
    jmp movInArr6

repeat6:
    inc ecx
    mov edx, OFFSET inv
    call WRITESTRING
    call crlf
    loop input6

movInArr6:
    mov [gr6+esi], al  ; Save user's group index.
    inc esi
    loop input6

    ; Rearrangement for 6-letter words.
    mov edi, 0
    mov ecx, 6

matrix3:
    mov eax, 6
    movzx ebx, [gr6+edi]
    mul ebx           ; Determine starting index.
    push ecx
    mov ecx, 6
    mov edx, edi

store3:
    movzx ebx, [alphabets+eax]
    mov [arr6+edx], bl
    add edx, 6        ; Maintain constant spacing.
    inc eax
    loop store3

    inc edi
    mov eax, 0
    pop ecx
    loop matrix3

    ; Display rearranged letters.
    mov esi, 0
    mov ecx, 36

group8:
    movzx eax, [arr6+esi]
    call WRITECHAR
    cmp count1, 6
    je space8
    jmp next7

space8:
    mov edx, OFFSET space
    call WRITESTRING
    mov count1, 0
next7:
    inc esi
    inc count1
    loop group8
    call crlf

    ; Final user selection for letter arrangement.
    mov ecx, 6
    mov esi, 0
    mov edx, OFFSET Askgroup
    call WRITESTRING
    call crlf

input7:
    call READDEC
    sub al, 1
    cmp al, 5
    ja tryagain6

    mov [gr6+esi], al
    inc esi
    loop input7
    call crlf
    jmp y

tryagain6:
    inc ecx
    mov edx, OFFSET inv
    call WRITESTRING
    call crlf
    loop input7

y:
    ; Output the final guessed 6-letter word.
    mov edx, OFFSET guess1
    call WRITESTRING

    mov esi, 0
    mov ebx, 0
    mov ecx, 6
    mov eax, 6

guess5:
    movzx edx, [gr6+esi]
    mul edx
    mov ebx, eax
    movzx eax, [arr6+ebx+esi]
    mov [alpha+esi], al
    call WRITECHAR
    mov eax, 6
    inc esi
    loop guess5

    ret
letter6 ENDP

;******************************************************************
; Procedure: letter7
; Purpose  : Process input and generate output for a 7-letter word.
;            Uses groups of seven letters.
;******************************************************************
letter7 PROC
    xor ebx, ebx
    mov ecx, 26

    ; Display letter groups of seven.
group9:
    mov al, [alphabets+ebx]
    call WRITECHAR
    cmp count, 7
    jne next8
    jmp space9

space9:
    mov edx, OFFSET space
    call WRITESTRING
    inc counter      ; Count spacing events.
    mov count, 0
next8:
    inc count
    inc ebx
    loop group9
    call crlf

    ; Prompt user for a group selection.
    mov esi, 0
    mov ecx, 7
    mov edx, OFFSET Askgroup
    call WRITESTRING
    call crlf

input8:
    call READINT
    sub al, 1
    cmp al, 0
    jb repeat7
    cmp al, 3
    ja repeat7
    jmp movInArr7

repeat7:
    inc ecx
    mov edx, OFFSET inv
    call WRITESTRING
    call crlf
    loop input8

movInArr7:
    mov [gr7+esi], al  ; Save validated group selection.
    inc esi
    loop input8

    ; Rearrange letters for the 7-letter word.
    mov edi, 0
    mov ecx, 7

matrix4:
    mov eax, 7
    movzx ebx, [gr7+edi]
    mul ebx           ; Calculate offset.
    push ecx
    mov ecx, 7
    mov edx, edi

store4:
    movzx ebx, [alphabets+eax]
    mov [arr7+edx], bl
    add edx, 7        ; Maintain spacing.
    inc eax
    loop store4

    inc edi         ; Next selection.
    mov eax, 0
    pop ecx
    loop matrix4

    ; Display rearranged groups.
    mov esi, 0
    mov ecx, 49

group10:
    movzx eax, [arr7+esi]
    call WRITECHAR
    cmp count1, 7
    je space10
    jmp next9

space10:
    mov edx, OFFSET space
    call WRITESTRING
    mov count1, 0
next9:
    inc esi
    inc count1
    loop group10
    call crlf

    ; Final group selection.
    mov ecx, 7
    mov esi, 0
    mov edx, OFFSET Askgroup
    call WRITESTRING
    call crlf

input9:
    call READDEC
    sub al, 1
    cmp al, 6
    ja tryagain7

    mov [gr7+esi], al
    inc esi
    loop input9
    call crlf
    jmp x

tryagain7:
    inc ecx
    mov edx, OFFSET inv
    call WRITESTRING
    call crlf
    loop input9

x:
    ; Output final guessed 7-letter word.
    mov edx, OFFSET guess1
    call WRITESTRING

    mov esi, 0
    mov ebx, 0
    mov ecx, 7
    mov eax, 7

guess6:
    movzx edx, [gr7+esi]
    mul edx
    mov ebx, eax
    movzx eax, [arr7+ebx+esi]
    mov [alpha+esi], al
    call WRITECHAR
    mov eax, 7
    inc esi
    loop guess6
    ret
letter7 ENDP

;******************************************************************
; Procedure: letter8
; Purpose  : Process input and generate output for an 8-letter word.
;            Uses groups of eight letters.
;******************************************************************
letter8 PROC
    xor ebx, ebx
    mov ecx, 26

    ; Display groups of eight letters.
group11:
    mov al, [alphabets+ebx]
    call WRITECHAR
    cmp count, 8
    jne next10
    jmp space11

space11:
    mov edx, OFFSET space
    call WRITESTRING
    inc counter      ; Update the space counter.
    mov count, 0
next10:
    inc count
    inc ebx
    loop group11
    call crlf

    ; Prompt the user for group selection.
    mov esi, 0
    mov ecx, 8
    mov edx, OFFSET Askgroup
    call WRITESTRING
    call crlf

input10:
    call READINT
    sub al, 1
    cmp al, 0
    jb repeat8
    cmp al, 3
    ja repeat8
    jmp movInArr8

repeat8:
    inc ecx
    mov edx, OFFSET inv
    call WRITESTRING
    call crlf
    loop input10

movInArr8:
    mov [gr8+esi], al  ; Save the validated group index.
    inc esi
    loop input10

    ; Rearrangement logic for 8-letter words.
    mov edi, 0
    mov ecx, 8

matrix5:
    mov eax, 8
    movzx ebx, [gr8+edi]
    mul ebx           ; Determine starting offset.
    push ecx
    mov ecx, 8
    mov edx, edi

store5:
    movzx ebx, [alphabets+eax]
    mov [arr8+edx], bl
    add edx, 8        ; Maintain fixed spacing.
    inc eax
    loop store5

    inc edi
    mov eax, 0
    pop ecx
    loop matrix5

    ; Display rearranged letters for 8-letter groups.
    mov esi, 0
    mov ecx, 64

group12:
    movzx eax, [arr8+esi]
    call WRITECHAR
    cmp count1, 8
    je space12
    jmp next11

space12:
    mov edx, OFFSET space
    call WRITESTRING
    mov count1, 0
next11:
    inc esi
    inc count1
    loop group12
    call crlf

    ; Final prompt for user selection.
    mov ecx, 8
    mov esi, 0
    mov edx, OFFSET Askgroup
    call WRITESTRING
    call crlf

input11:
    call READDEC
    sub al, 1
    cmp al, 7
    ja tryagain8

    mov [gr8+esi], al
    inc esi
    loop input11
    call crlf
    jmp z

tryagain8:
    inc ecx
    mov edx, OFFSET inv
    call WRITESTRING
    call crlf
    loop input11

z:
    ; Output the final guessed 8-letter word.
    mov edx, OFFSET guess1
    call WRITESTRING

    mov esi, 0
    mov ebx, 0
    mov ecx, 8
    mov eax, 8

guess7:
    movzx edx, [gr8+esi]
    mul edx
    mov ebx, eax
    movzx eax, [arr8+ebx+esi]
    mov [alpha+esi], al
    call WRITECHAR
    mov eax, 8
    inc esi
    loop guess7

    ret
letter8 ENDP

END main