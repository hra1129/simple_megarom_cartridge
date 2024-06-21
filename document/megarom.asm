; -----------------------------------------------------------------------------
;	MegaROM Test Program
; =============================================================================
;	2024/06/17 t.hara (HRA!)
; -----------------------------------------------------------------------------

enaslt	:= 0x0024
gttrig	:= 0x00D8
chgmod	:= 0x005F
chgclr	:= 0x0062
wrtpsg	:= 0x0093
forclr	:= 0xF3E9
bakclr	:= 0xF3EA
bdrclr	:= 0xF3EB
romslt	:= 0xE000

        org     0x4000
        db      "AB"        ; ID
        dw      init        ; INIT
        dw      0           ; STATEMENT
        dw      0           ; DEVICE
        dw      0           ; TEXT
        dw      0           ; Reserved
        dw      0           ; Reserved
        dw      0           ; Reserved

init:
        ; ROM のスロットを調べる
        di
        in      a, [0xA8]           ; 現在このプログラムがある page1 のスロットを調べる
        rrca
        rrca
        and     a, 3
        ld      [romslt], a
        add     a, 0xC1
        ld      h, 0xFC
        ld      l, a
        ld      a, [hl]             ; EXTTBL を見る
        and     a, 0x80
        jr      z, no_extslt
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        ld      a, [hl]             ; 拡張スロット選択レジスタ
        and     a, 0x0C
        ld      b, a
        ld      a, [romslt]
        or      a, b
        or      a, 0x80
        ld      [romslt], a
no_extslt:
        ld      a, [romslt]
        ; PAGE1 をカートリッジのスロットにする
        ld      h, 0x80
        call    enaslt
