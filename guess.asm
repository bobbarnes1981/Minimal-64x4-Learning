            #org 0x2000                             ; origin for program

            ; TODO: use numbers 0-99?

; Start

            JPS _Print "Guess the number 0-9", 0    ; print game name
            JAS cr                                  ;

; generate a random number

getnum:     JPS _Random                             ; generate pseudo random number in 'A' register
            STB rndnum                              ; store register 'A' in rndnum
            CPI 10                                  ; compare A-10
            BCS getnum                              ; branch on carry set (retry rnd)
            MIB 0x00, guscnt                        ; reset guess counter

; get the guess from the user

getguess:   INB guscnt                              ; increment guess counter
            JPS _Print "Guess: ", 0                 ;
            LDB guscnt                              ; load guess count to 'A'
            JAS PrintDec                            ; print guess count
            JAS cr                                  ;
reguess:    MIV _ReadBuffer, _ReadPtr               ; reset read pointer
            JPS _ReadLine                           ; read a line
            LDB _ReadBuffer                         ; load first byte to 'A'
            STB gusnum                              ; store register 'A' in gusnum

; validate the user input

            CIB 48, gusnum                          ; compare 48 ('0') to guess char
            BMI reguess                             ;
            CIB 58, gusnum                          ; compare 57 (':') to guess char
            BPL reguess                             ;

; check the guess

            LDB gusnum                              ;
            SUI 48                                  ; convert text to numeric
            CPB rndnum                              ; compare guess to random number
            BEQ correct                             ; guess is equal to random
            BPL hi                                  ; guess is higher than random
            BMI lo                                  ; guess is lower than random, we can remove this branch and fall through

lo:         JPS _Print "Too lo", 0                  ;
            JAS cr                                  ;
            JPA getguess                            ;

hi:         JPS _Print "Too hi", 0                  ;
            JAS cr                                  ;
            JPA getguess                            ;

correct:    JPS _Print "Correct", 0                 ;

; try again?

            JPS _Print "Try again? y/n", 0          ;
            MIV _ReadBuffer, _ReadPtr               ; reset read pointer
            JPS _ReadLine                           ; read a line
            LDB _ReadBuffer                         ; load first byte to 'A'
            CPI 'y'                                 ;
            BEQ getnum                              ;
            JAS _Prompt                             ;

; subroutine for carriage return, there must be a better way

cr:         LDI 0x0a                                ; carriage return
            JAS _PrintChar                          ;
            RTS                                     ;

            ; TODO: subroutine to convert input buffer to number

; subroutine to print decimal value in 'A'

PrintDec:   STZ 0                                   ; store number in 0
            MIB 0x00, divtencount                   ; reset tens counter
divnotdone: CIZ 10, 0                               ; compare number to ten
            BMI printtens                           ; done if less than ten
            SIZ 10, 0                               ; otherwise subtract 10
            INB divtencount                         ; increment tens counter
            JPA divnotdone                          ; keep going until counted all tens
printtens:  LDB divtencount                         ; load the tens counter
            CPI 0                                   ; is tens counter zero?
            BEQ printunits                          ; ignore if zero
            ADI 48                                  ; convert number to ascii
            JAS _PrintChar                          ; print tens
printunits: LDZ 0                                   ; load left over units from number in 0
            ADI 48                                  ; convert number to ascii
            JAS _PrintChar                          ; print units
            RTS                                     ; return

; storage

#org 0x1000 rndnum:                                 ; storage for random number
#org 0x1001 gusnum:                                 ; storage for guess number
#org 0x1002 guscnt:                                 ; storage for guess count

            ; TODO: use zero page?

#org 0x1004 divtencount:

; OS API

#org 0x00c9 _ReadPtr:
#org 0xf003 _Prompt:
#org 0xf042 _PrintChar:
#org 0xf048 _PrintPtr:
#org 0xf045 _Print:
#org 0xf009 _Random:
#org 0xf018 _ReadLine:
#org 0x00cd _ReadBuffer:
