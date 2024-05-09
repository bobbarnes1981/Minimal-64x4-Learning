        #org 0x2000                         ; origin for program

        JPS _Print "Hello, World!", 0       ; use os api to print null terminated string
        
loop:   NOP                                 ; do nothing
        JPA loop                            ; jump to loop
    
#org 0xf045 _Print:                         ; point _Print to correct memory address
