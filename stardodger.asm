incbin 'template.p'

; rem RAND USR 16514

DFILE:    equ 16396

PAUSE: equ $0f35 
PRINT: equ $0010 
KEYBOARD: equ $02bb 

SCREEN_WIDTH: equ 32
PLAY_AREA_HEIGHT: equ 18
DELAY: equ 512

  ; go to the relevant place in the file
  seek $79
  org 16514

  ; start of 40 bytes of machine code data
  start: equ $

  ; reset score
  ld bc, 0
  ld (score), bc

  ; put the player on the screen
  ld hl, (DFILE)
  ld bc, 1 + (SCREEN_WIDTH + 1) * 5 + 4
  add hl, bc
  ld (player), hl

  ; etablish the playing area by printing lines
  ; of spaces onto the screen.
  ld bc, PLAY_AREA_HEIGHT * SCREEN_WIDTH

clearLoop:
  ld a, $80  ; empty space
  push bc
  call PRINT
  pop bc
  dec bc

  ; check if decremented to zero
  ld a, 0
  cp c
  jp nz, clearLoop
  cp b
  jp nz, clearLoop

scroll:
  ; pause a bit
  ld bc, DELAY ; number of frames to pause
  call pause

  ; choose next star position
  ld hl, (randvar)
  inc hl
  ld (randvar), hl
  ld a, (hl)
  and 15

  ld (starpos), a

  ld a, 0
  ld hl, (DFILE) ; HL will be the source for the copy
  inc hl ; skip past the first NEWLINE
  inc hl ; source pointer for copy is 1 character to the right

  ld de, (DFILE) ; DE will be the destination for the copy
  inc de ; will start 1 character to the left of HL
  ld a, PLAY_AREA_HEIGHT

scrollLoop:
  ld bc, SCREEN_WIDTH - 1 ; length for copy
  ldir ; copy the line

  ; add the next character to the end
  push af ; save the value of a
  push bc
  ld b, a ; save the current line

  ld a, (starpos)
  cp b
  jp nz, notStar
  ld a, $97
  jp doneStar

notStar:
  ld a, $80

doneStar:
  ld (de), a
  pop bc
  pop af

  ; move to the next line
  inc bc ; move to next character
  inc bc ; skip over NEWLINE
  add hl, bc
  ld d, h
  ld e, l
  dec de

  dec a
  jp nz, scrollLoop

  ; check the keyboard and put the code into A
  call KEYBOARD
  ; A is 253, 253 HL
  ld a, 253
  cp h
  jp z, goUp

  ; Z is 254, 251 HL
  ld a, 251
  cp h
  jp z, goDown

  ; no key pressed
  ld bc, 0
  jp movePlayer

goUp:
  ; to go up, subtract the number of characters on a line, including the
  ; NEWLINE. Add (2^16 - amount), which is the same as subtracting the amount
  ld bc, 65536 - (SCREEN_WIDTH + 1)
  jp movePlayer

goDown:
  ; to go down, add the number of characters on a line, including the
  ; NEWLINE
  ld bc, SCREEN_WIDTH + 1

movePlayer:
  ld hl, (player)
  add hl, bc
  ld (player), hl

noKeyboard:
  ; move player
  ld hl, (player)

  ; check if player has hit a star
  ld a, (hl)
  cp $80
  jp nz, die

  ; now draw the player
  ld (hl), $92

  ; increase score
  ld hl, (score)
  inc hl
  ld (score), hl

repeat:
  jp scroll

die:
  ld bc, (score)
  ret

pause:
  dec bc
  ld a, 0
  cp b
  jr nz, pause
  cp c
  jr nz, pause
  ret

randvar:
  db 0, 0  ; random number generation offset
starpos:
  db 3  ; position of next star
player:
  db 0, 0  ; position of player on screen (address within screen memory)
score:
  db 0, 0

end: equ $
program_length: equ end - start
