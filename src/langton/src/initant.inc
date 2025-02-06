; initant.inc
;   include file to initialize the statuses of the ants
;   uncomment one of the following 
;
; *****************************
; #1 three ants at an triangle
; *****************************
MAX_ANTS = 3
X_MAX = 280
Y_MAX = 160
;
INITANTS:  ; initialize the statuses of ants
        ; ant0 at (100, 50), ori=2 (dn)
        lda #100 
        sta ANTS +ax_off
        lda #0
        sta ANTS +ax_off+1
        lda #50
        sta ANTS +ay_off
        lda #2
        sta ANTS +aori_off
        lda #0 ; black
        sta ANTS + updcol_off
        ; ant1 at (50, 100), ori=1 (right)
        lda #50   
        sta ANTS+.sizeof(Ant) +ax_off
        lda #0
        sta ANTS+.sizeof(Ant) +ax_off+1
        lda #100
        sta ANTS+.sizeof(Ant) +ay_off
        lda #1
        sta ANTS+.sizeof(Ant) +aori_off
        lda #0 ; black
        sta ANTS+.sizeof(Ant) +updcol_off
        ; ant2 at (150, 100), ori=3 (left)
        lda #150   
        sta ANTS+.sizeof(Ant)*2 +ax_off
        lda #0
        sta ANTS+.sizeof(Ant)*2 +ax_off+1
        lda #100
        sta ANTS+.sizeof(Ant)*2 +ay_off
        lda #3
        sta ANTS+.sizeof(Ant)*2 +aori_off
        lda #0 ; black
        sta ANTS+.sizeof(Ant)*2 +updcol_off
        rts
;
;
; *******************************
; #2 two ants pointing each other
; *******************************
; MAX_ANTS = 2
; ;
; INITANTS:  ; initialize the statuses of ants
;         ; ant0 at (88, 25), ori=1 (right)
;         lda #84
;         sta ANTS +ax_off
;         lda #0
;         sta ANTS +ax_off+1
;         lda #25
;         sta ANTS +ay_off
;         lda #1
;         sta ANTS +aori_off
;         lda #0 ; black
;         sta ANTS + updcol_off
;         ; ant1 at (50, 103), ori=3 (left)
;         lda #50   
;         sta ANTS+.sizeof(Ant) +ax_off
;         lda #0
;         sta ANTS+.sizeof(Ant) +ax_off+1
;         lda #100
;         sta ANTS+.sizeof(Ant) +ay_off
;         lda #3
;         sta ANTS+.sizeof(Ant) +aori_off
;         lda #0 ; black
;         sta ANTS+.sizeof(Ant) +updcol_off
;         rts
;
; ******************************
; #2 two ants erasing each other
; ******************************
; MAX_ANTS = 2
; X_MAX = 240
; Y_MAX = 160
; ;
; INITANTS:  ; initialize the statuses of ants
;         ; ant0 at (88, 25), ori=1 (right)
;         lda #84
;         sta ANTS +ax_off
;         lda #0
;         sta ANTS +ax_off+1
;         lda #30
;         sta ANTS +ay_off
;         lda #1
;         sta ANTS +aori_off
;         lda #0 ; black
;         sta ANTS + updcol_off
;         ; ant1 at (52, 103), ori=3 (left)
;         lda #49
;         sta ANTS+.sizeof(Ant) +ax_off
;         lda #0
;         sta ANTS+.sizeof(Ant) +ax_off+1
;         lda #108
;         sta ANTS+.sizeof(Ant) +ay_off
;         lda #3
;         sta ANTS+.sizeof(Ant) +aori_off
;         lda #0 ; black
;         sta ANTS+.sizeof(Ant) +updcol_off
;         rts
;