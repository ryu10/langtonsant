; langant.s
;   Langton's Ant for the Apple II
;
.segment "CODE"
; Apple ROM Routines
HGR = $F3E2
HCOLOR = $F6F0
HPLOT = $F457
HLINE = $F53A
COUT = $FDED
PRBYTE = $FDDA
PRINTCR = $FD8E
WAIT = $fca8
; constants
BITMAP_SIZE = $1b00
; MAX_ANTS = 3
; X_MAX = 280
; Y_MAX = 160
;
; zpg locs
; BC = $1D ; zpg loc $1D, $1E
BC = $EC ; zpg loc $EC, $ED
DE = $CE ; zpg loc $CE, $CF
FG = $EE ; zpg loc $EE, $EF
;
; structs
.struct Ant              ; 8 bytes
        ax .word
        ay .byte
        aori .byte
        updcolor .byte
        fill .byte 3
.endstruct
; offsets
ax_off = 0
ay_off = 2
aori_off = 3
updcol_off = 4
;
; program start
ENTRY:  
;       org $6000
        jsr HGR
        ldx #3    ; color = white
        jsr HCOLOR
; init
        jsr INITANTS
;
MAINLOOP:
        jsr UPDANTS
        jsr UPDSCREEN
        jmp MAINLOOP
        rts
;
UPDANTS:
        lda #MAX_ANTS
        sta CNTR
        lda #<ANTS
        sta FG    ; zpg [FG+1, FG] = ANT0 Base address
        lda #>ANTS
        sta FG+1
UA0:    
        ; move forward
        ldy #aori_off ; current orientation
        lda (FG),y
        cmp #0 ; up?
        bne UA_RT
        ; move up
        ldy #ay_off
        lda (FG),y
        tax
        dex
        cpx #$FF
        bne UA_UP1 ; -1?
        ldx #Y_MAX-1 ; wrap
UA_UP1: txa
        sta (FG),y
        jmp UA_ORI ; done move up
UA_RT:  cmp #1 ; right?
        bne UA_DN
        ; move right
        ldy #ax_off
        lda (FG),y
        sta DE
        iny
        lda (FG),y
        sta DE+1
        lda DE
        clc          ; inc ant x 
        adc #1
        sta DE
        lda DE+1
        adc #0
        sta DE+1
        cmp #>X_MAX
        bne UA_RT1
        lda DE
        cmp #<X_MAX
        bne UA_RT1
        ; reached X_MAX, wrap
        lda #0
        sta DE
        sta DE+1
UA_RT1: ldy #ax_off ; save ant x
        lda DE
        sta (FG),y
        iny
        lda DE+1
        sta (FG),y
        jmp UA_ORI  ; done move right
UA_DN:  cmp #2 ; down?
        bne UA_LF
        ; move down
        ldy #ay_off
        lda (FG),y
        tax
        inx
        cpx #Y_MAX
        bne UA_DN1
        ldx #0  ; wrap
UA_DN1: txa 
        sta (FG),y
        jmp UA_ORI ; done move down
UA_LF:  ; move left
        ldy #ax_off
        lda (FG),y
        sta DE
        iny
        lda (FG),y
        sta DE+1
        lda DE
        sec
        sbc #1
        sta DE
        lda DE+1
        sbc #0
        sta DE+1
        cmp #$FF
        bne UA_LF1
        lda DE
        cmp #$FF
        bne UA_LF1
        lda #<(X_MAX-1)  ; -1, wrap
        sta DE
        lda #>(X_MAX-1)
        sta DE+1
UA_LF1: ldy #ax_off
        lda DE
        sta (FG),y
        iny
        lda DE+1
        sta (FG),y  ; done move left
UA_ORI: ; get current location
        ldy #ax_off    ; load <ax -> x
        lda (FG),y
        tax
        iny            ; load >ax -> BWORK
        lda (FG),y
        sta BWORK
        ldy #ay_off    ; load ay -> a
        lda (FG),y
        ldy BWORK      ; >ax -> y
        jsr COOR2OFF   ; offset -> [BC+1, BC], bitloc -> Acc
        ; get current bit
        tax            ; generate mask
        lda #1
UA1:    cpx #0         ; shift mask
        beq UA2
        asl
        dex
        jmp UA1
UA2:    sta BWORK      ; save mask to BWORK
        clc            ; calc bitmap adrs -> BC
        lda #<BITMAP
        adc BC
        sta BC
        lda #>BITMAP
        adc BC+1
        sta BC+1
        ldy #0
        lda (BC),y     ; load current byte from bitmap
        and BWORK ; bit test (black or white)
        beq UA_BLACK
UA_WHITE:      
        ; invert to blk
        ldy #updcol_off
        lda #0 
        sta (FG),y
        ; white - turn right
        ldy #aori_off
        lda (FG),y
        clc
        adc #1
        cmp #4 ; left to up?
        bne UA3 
        lda #0 ; up
UA3:    sta (FG),y
        jmp UA5   ; UA_WHITE done
UA_BLACK:  
        ; invert to white
        ldy #updcol_off
        lda #3
        sta (FG),y
        ; black - turn left
        ldy #aori_off
        lda (FG),y
        sec
        sbc #1
        bpl UA4 ; up to left?
        lda #3 ; left
UA4:    sta (FG),y  ; UA_BLACK done
UA5:    ; repeat for # of ants
        clc
        lda FG
        adc #.sizeof(Ant)
        sta FG
        lda FG+1
        adc #0
        sta FG+1
        dec CNTR
        beq UA6
        jmp UA0
UA6:    rts
;
UPDSCREEN:
        lda #MAX_ANTS
        sta CNTR
        lda #<ANTS
        sta FG    ; zpg FG = ANT Base address
        lda #>ANTS
        sta FG+1
US0:    ldy #updcol_off ; load col -> COLOR
        lda (FG),y
        sta COLOR
        ldy #ax_off    ; load <ax -> x
        lda (FG),y
        tax
        iny            ; load >ax -> BWORK
        lda (FG),y
        sta BWORK
        ldy #ay_off    ; load ay -> a
        lda (FG),y
        ldy BWORK      ; >ax -> y
        jsr PLOTMAP
        clc
        lda FG
        adc #.sizeof(Ant)
        sta FG
        lda FG+1
        adc #0
        sta FG+1
        dec CNTR
        bne US0
        rts
; plot at ([y, x], Acc) in BITMAP and hgr vram
PLOTMAP:
        stx DE      ; save x, y, a
        sty DE+1
        pha
        ; plot in bitmap  
        jsr COOR2OFF
        ; get current byte in BITMAP
        tax
        lda BC
        clc
        adc #<BITMAP
        sta BC
        lda BC+1
        adc #>BITMAP
        sta BC+1
        ldy #0
        lda (BC),y
        sta BWORK
        clc
        lda #$01 ; mask init
@L0:    cpx #0
        beq @L1
        asl
        dex
        jmp @L0
@L1:    ldx COLOR
        bne @L2 
        eor #$FF ; bit black, invert mask
        and BWORK
        jmp @L3
@L2:    ora BWORK ; bit white
@L3:    sta (BC), y ; store result
        ; HPLOT
        lda COLOR
        jsr HCOLOR
        pla
        ldx DE
        ldy DE+1
        jsr HPLOT
        rts
; ([y, x] , a) -> offset, 
; offset >>3 -> BC, offset & 0x07 -> Acc
COOR2OFF:
        pha     ; set Acc->BC
        lda #0
        sta BC+1
        pla
        sta BC
        ; BC * 280 -> [BC+1, BC]
        ; 280 = $0118 = 0000 0001 0001 1000
        clc
        jsr ROLBC
        jsr ROLBC
        jsr ROLBC
        jsr ROLBC
        jsr ADDABC
        jsr ROLBC
        jsr ADDABC
        jsr ROLBC
        jsr ROLBC
        jsr ROLBC
        ; BC + [y, x] -> BC
        clc
        txa
        adc BC
        sta BC
        tya
        adc BC+1
        sta BC+1
        lda BC
        and #$07
        jsr LSRBC
        jsr LSRBC
        jsr LSRBC
        rts
ROLBC:  ; shift left [BC+1, BC]
        rol BC
        rol BC+1
        rts
LSRBC:
        lsr BC+1
        ror BC
        rts
ADDABC:  ; [BC+1, BC] + Acc -> [BC+1, BC] 
        pha
        clc
        adc BC
        sta BC
        lda #0
        adc BC+1
        sta BC+1
        pla
        rts
; initants
        .include "initant.inc"
;
.segment "DATA"
BITMAP: 
        .res BITMAP_SIZE, 0
;
COLOR:
        .res 1
BWORK:
        .res 1
CNTR:
        .res 1
ANTS:
        .tag Ant  ; ant #0
        .tag Ant  ; ant #1
        .tag Ant  ; ant #2
        .tag Ant  ; ant #3
