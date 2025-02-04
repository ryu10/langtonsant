; plot1.s
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
; Constants
XMAX = 240 ; HGR
YMAX = 192 ; HGR
;
ENTRY:  
; plot triangle
;       org $6000
        jsr HGR
        ldx #3    ; color = white
        jsr HCOLOR
; plot first pt
        ldy #0
        ldx #$64
        lda #$32
        jsr HPLOT
; plot to second pt
        ldx #0
        lda #$96
        ldy #$64
        jsr HLINE
; plot to third pt
        ldx #0
        lda #$32
        ldy #$64
        jsr HLINE
; plot to first pt
        ldx #0
        lda #$64
        ldy #$32
        jsr HLINE
        rts
;
;.segment "DATA"
;ITR:    .byte 0
;W1ST:    .byte 0
