// sprite movements

#import "constants.asm"
#import "macro.asm"

BasicUpstart2(enter)

.label LouDirection = $02a7
.label Lou_right = 170   // Using the sprite sheet from char pad remember how many animations
// you have going right as well as any overlays.
.label Lou_left = 174    // For your overlay, remember its 0,1,2 and three (0 is 1st sprite)
// so if you have 6 animations your first right anim sprite is 0-5 and the left anim would be 6-11

.label FrameCounter = $02a8 // our free byte for animation counting
.label Sprite_FrameCounter = $02a9

enter:
// ** Clearing screen

    jsr CLEAR
    Screen_Update( GREY,DARK_GRAY)
// ************************************************************** 

// OVERLAY SPRITE  - SINGLE COLOUR
    lda #SPRITERAM+8      // Load the sprite pointer Ours is 170
    sta SPRITE0         // Just off the screen ram 2040
 
    lda #SPRITERAM          // Load the sprite pointer Ours is 170
    sta SPRITE0 +1           // Just off the screen ram 2040

    lda #3              // additional sprite %0000 0011              
    sta SPENA           // Enable the sprite
//    sta YXPAND
    lda #2                  // %0000 0010
    sta SPMC

    lda #80             // Position of sprite o screen
    sta SP0X            // for x
    sta SP0X+2              // for x
    lda #100
    sta SP0Y            // for y
    sta SP0Y+2              // for y

    lda #0             // SPR Col 1
    sta SP0COL

// SET UP THE COLOUR    
    lda #5                  // SPR Col 1
    sta SP0COL+1
    lda #09
    sta SPMC0
    lda #13
    sta SPMC1

// Framecounter initialise
    lda #0              // set to 0
    sta FrameCounter

// ************************************************************** 

GameLoop:
    lda #240        // Scanline -A
    cmp RASTER
    bne GameLoop

    inc FrameCounter
    lda FrameCounter
    cmp #64        // 64 based on 4 frames  ******
    bne KeyboardTest
    lda #0
    sta FrameCounter

KeyboardTest:
    lda 197
    cmp #scanCode_A
    bne TestForAKey
    lda #255
    sta LouDirection
    jmp UpdateLou

TestForAKey:
    cmp #scanCode_D
    bne GameLoop
    lda #1
    sta LouDirection
    jmp UpdateLou


UpdateLou:
    jsr Calculate_Sprite_Frames
    lda LouDirection
    bmi Going_left         // only need to test one direction
    
    // ** Move bytes for Right
    lda #Lou_right
    clc
    adc Sprite_FrameCounter
    sta SPRITE0 + 1
    lda #Lou_right+8           // counting 8 frames forward for our outline
    clc
    adc Sprite_FrameCounter
    sta SPRITE0

    inc SP0X
    inc SP0X + 2
    jmp GameLoop

Going_left:
    // ** Move bytes for Left
    lda #Lou_left
    clc
    adc Sprite_FrameCounter
    sta SPRITE0 + 1
    lda #Lou_left + 8           // counting 8 frames forward for our outline
    clc
    adc Sprite_FrameCounter
    sta SPRITE0

    dec SP0X
    dec SP0X + 2
    jmp GameLoop

// --------------------------------------
Calculate_Sprite_Frames:
    inc FrameCounter
    lda FrameCounter
    and #%00111111 // 63
    sta FrameCounter
    lsr 
    lsr
    lsr
    lsr

    sta Sprite_FrameCounter
    rts

// STORING SPRITES HERE

* = $2a80 "Sprite Data"
.import binary "sprites\HULK_Walk - Sprites.bin"

