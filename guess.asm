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
            MIZ 0x00, guesscount                    ; reset guess counter

; get the guess from the user

getguess:   INZ guesscount                          ; increment guess counter
            JPS _Print "Guess: ", 0                 ;
            LDZ guesscount                          ; load guess count to 'A'
            JAS PrintDec                            ; print guess count
            JAS cr                                  ;
reguess:    MIV _ReadBuffer, _ReadPtr               ; reset read pointer
            JPS _ReadLine                           ; read a line
            LDB _ReadBuffer                         ; load first byte to 'A'
            STZ guessnum                            ; store register 'A' in guessnum

; validate the user input

            CIZ 48, guessnum                        ; compare 48 ('0') to guess char
            BMI reguess                             ;
            CIZ 58, guessnum                        ; compare 57 (':') to guess char
            BPL reguess                             ;

; check the guess

            LDZ guessnum                            ;
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
            JAS cr                                  ;

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

PrintDec:   STZ divnumber                           ; store number
            MIZ 0x00, divtencount                   ; reset tens counter
            MIZ 0x00, divhuncount                   ; reset hundreds counter
divsubhun:  CIZ 100, divnumber                      ; compare number to 100
            BMI divsubten                           ; done if less than 100
            SIZ 100, divnumber                      ; otherwise subtract 100
            INZ divhuncount                         ; increment 100 counter
            JPA divsubhun                           ; keep going until counted all hundreds
divsubten:  CIZ 10, divnumber                       ; compare number to 10
            BMI printhuns                           ; done if less than 10
            SIZ 10, divnumber                       ; otherwise subtract 10
            INZ divtencount                         ; increment 10 counter
            JPA divsubten                           ; keep going until counted all tens
printhuns:  CIZ 0, divhuncount                      ; is 100 counter zero? (also loads to 'A')
            BEQ printtens                           ; ignore if zero
            ADI 48                                  ; convert number to ascii
            JAS _PrintChar                          ; print hundreds
            LDZ divtencount                         ; load tens
            JPA printtensf                          ; not zero so force print tens
printtens:  CIZ 0, divtencount                      ; is 10 counter zero? (also loads to 'A')
            BEQ printunits                          ; ignore if zero
printtensf: ADI 48                                  ; convert number to ascii
            JAS _PrintChar                          ; print tens
printunits: LDZ divnumber                           ; load left over units from number
            ADI 48                                  ; convert number to ascii
            JAS _PrintChar                          ; print units
            RTS                                     ; return

#mute

; storage

#org 0x0000

rndnum:         0xff
guessnum:       0xff
guesscount:     0xff

divnumber:      0xff
divtencount:    0xff
divhuncount:    0xff

; OS API

#org 0x00c9 _ReadPtr:
#org 0xf003 _Prompt:
#org 0xf042 _PrintChar:
#org 0xf048 _PrintPtr:
#org 0xf045 _Print:
#org 0xf009 _Random:
#org 0xf018 _ReadLine:
#org 0x00cd _ReadBuffer:
