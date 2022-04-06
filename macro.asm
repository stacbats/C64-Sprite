// *********************************************************
// Our Macro's

.const CLEAR    = $e544         // Kernal routine to clear screen
.const SCREEN   = $d021         // Screen Colour Poke 53281
.const BORDER   = $d020         // Border Colour Poke 53280
.const INKS     = $0286         // change colour for text

.macro Screen_Update(color1,color2) {
    lda #color1
    sta BORDER
    lda #color2
    sta SCREEN
}

.macro Cursor_Color(ink) {
    lda #ink
    sta INKS
}