//  ***********************************
//  simple scrolling text assembly 
//  the text can be bigger than $ff 
//  uisng kick assembler
//  ***********************************


//   Setting Labels and Constants  
            .const Screen   = $0400+480   //middle of screen 40*12
            .const BCKG     = $d020
            .const BRDER    = $d021
            .const CHROUT   = $ffd2          // Kernal routine to print a charater

        * = $C000 "sys 49152"  //  sys 49152

Main:
 //     Clear the screen and set colours 
        lda     #147            //  Clear Screen Screen Code (the ascii value)
        jsr     CHROUT          //   See the above for the explanation 

        lda     #0
        sta     BCKG
        sta     BRDER

StartScroll:
        lda     #<ScrollText
        sta     $fb
        lda     #>ScrollText
        sta     $fc

//  ********* Fill In chars
FillChar:
        lda     #5
        sta     Frames

        ldy     #$00
        lda     ($fb),y
        beq     StartScroll
        sta     Screen+39
        
        clc
        lda     $fb
        adc     #$01
        sta     $fb
        lda     $fc
        adc     #$00
        sta     $fc

//              Create a delay
//              Screen Refresh delays are better
//         ldx     #$40
//              delayx
//         ldy     #$ff
//              delayy
//         dey
//         bne     delayy
//         dex
//         bne     delayx

//          Wait for Scan line 250 in order to avoid Flicker 
//          Phase explains its not the best solution this way
//          Better use interrupts
ScanLine:
        lda     $d012
        cmp     #$fa            // HEX 250
        bne     ScanLine

//              Check to see if we are still on raster line 250
SameScanLine:
        lda     $d012
        cmp     #$fa
        beq     SameScanLine

//              This is the delay and using Screen Refresh Frames
//              Phase explains that PAL system uses 50 frames per second
//              So if we use the number 5 it would mean that every 10 frames it scrolls 
        dec     Frames
        bne     ScanLine

//              Scrolls by one character the whole line
        ldx     #$00
ScrollLine:
        lda     Screen+1,x
        sta     Screen,x
        inx
        cpx     #$27
        bne     ScrollLine
//      Loopy
        jmp     FillChar

exit:
        rts

//  ***********************************
//  text date that will scroll below
//  ***********************************

ScrollText:
        .text    "hello and welcome. this is hopefully the start of "
        .text    " me learning to get characters on screen and  "
        .text    "display text easily enough to read. "
        .text    " shout out to phaze 101 as i pinched his code "
        .text    "to help me understand it more. "
        .text    "                             "
        .byte    0

Frames:
        .byte    0