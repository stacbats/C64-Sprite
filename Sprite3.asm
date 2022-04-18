:BasicUpstart2(main)

.label screen_memory = $0400
.label border_color = $d020
.label background_color = $d021

.label irq_handler_vector = $0314
.label irq_handler_address = $ea31

.const COORDINATES_COUNT = 256


.const VIC2 = $d000  // 53248
.namespace sprites {
  .label positions = VIC2
  .label enable_bits = VIC2 + 21
  .label colors = VIC2 + 39
  .label pointers = screen_memory + 1024 - 1//8
}
main:
  lda #DARK_GRAY
  sta background_color
  sta border_color
  lda #1
  sta VIC2+28   // Multi colour
  lda BLUE
  sta $d025
  lda YELLOW
  sta $d026


  :clear_screen()
  
  lda #%00000001
  sta sprites.enable_bits


  sei

  ldx #<animate_sprites
  ldy #>animate_sprites
  stx irq_handler_vector
  sty irq_handler_vector + 1

  cli 

loop:

    jmp loop

animate_sprites:
  .for (var i = 0; i < 8; i++) {
    ldx current_coords + i
    lda x_coordinates, X
    sta sprites.positions + 2*i + 0
    lda y_coordinates, X
    sta sprites.positions + 2*i + 1
    inx
    cpx #COORDINATES_COUNT
    bne end
    ldx #0 
  end:
    txa
    sta current_coords + i
  }
  jmp irq_handler_address


current_coords:
  .fill 8, 10*[7-i] 

x_coordinates:
  .fill COORDINATES_COUNT, position(i, COORDINATES_COUNT).getX()

y_coordinates:
  .fill COORDINATES_COUNT, position(i, COORDINATES_COUNT).getY()

.function position(index, total_count) {
  .var top_left = Vector(23, 50, 0)
  .var screen_size = Vector(320, 200, 0)
  .var sprite_size = Vector(24, 21, 0)
  .var center = top_left + screen_size/2 - sprite_size/2
  .var start = Vector(0, -40, 0)
  .var rotation = RotationMatrix(0, 0, toRadians(index*360/total_count))
  .return center + rotation*start
}
.pc = 64*255 "sprite bitmap"
.import binary "Tornado - Sprites.bin"

.macro clear_screen() {
  ldx #250
  lda #' '
loopx:
  .for (var i = 0; i < 4; i++) {
    sta screen_memory + 250*i - 1, X
  }
  dex
  bne loopx
}
