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

		org		0x4000
		db		"AB"		; ID
		dw		init		; INIT
		dw		0			; STATEMENT
		dw		0			; DEVICE
		dw		0			; TEXT
		dw		0			; Reserved
		dw		0			; Reserved
		dw		0			; Reserved

init:
		; SCREEN1 �ɕς���
		ld		a, 1
		call	chgmod
		; COLOR 15, 4, 7
		ld		hl, forclr
		ld		a, 15
		ld		[hl], a
		inc		hl
		ld		a, 4
		ld		[hl], a
		inc		hl
		ld		a, 7
		ld		[hl], a
		call	chgclr
		; �^�C�g���\��
		ld		a, 0
		out		[0x99], a
		ld		a, 0x40 + 0x18
		out		[0x99], a
		ld		hl, message1
		call	puts
		; ���C�Z���X�����\��
		ld		a, 32
		out		[0x99], a
		ld		a, 0x40 + 0x18
		out		[0x99], a
		ld		hl, message2
		call	puts
		; ROM �̃X���b�g�𒲂ׂ�
		di
		in		a, [0xA8]			; ���݂��̃v���O���������� page1 �̃X���b�g�𒲂ׂ�
		rrca
		rrca
		and		a, 3
		ld		[romslt], a
		add		a, 0xC1
		ld		h, 0xFC
		ld		l, a
		ld		a, [hl]				; EXTTBL ������
		and		a, 0x80
		jr		z, no_extslt
		inc		hl
		inc		hl
		inc		hl
		inc		hl
		ld		a, [hl]				; �g���X���b�g�I�����W�X�^
		and		a, 0x0C
		ld		b, a
		ld		a, [romslt]
		or		a, b
		or		a, 0x80
		ld		[romslt], a
no_extslt:
		ld		a, [romslt]
		; PAGE1 ���J�[�g���b�W�̃X���b�g�ɂ���
		ld		h, 0x80
		call	enaslt
		; PSG ��������
		ld		a, 0
		ld		e, 0
		call	wrtpsg
		ld		a, 1
		ld		e, 0
		call	wrtpsg
		ld		a, 7
		ld		e, 0b10111111
		call	wrtpsg
		; PCM�Đ�
main_loop:
		di
		ld		hl, bank0_pcm
		ld		bc, 16384 - 6144
		call	pcm_play

		ld		a, 1
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 2
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 3
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 4
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 5
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 6
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 7
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 8
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 9
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 10
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 11
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 12
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 13
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 14
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 15
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 16
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 17
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 18
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 19
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 20
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 21
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 22
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 23
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 24
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 25
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 26
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 27
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 28
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 29
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 30
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

		ld		a, 31
		ld		[0x7000], a
		ld		hl, 0x8000
		ld		bc, 16384
		call	pcm_play

wait_key:
		xor		a, a
		call	gttrig
		or		a, a
		jr		z, wait_key
		jp		main_loop

puts:
		ld		a, [hl]
		or		a, a
		ret		z
		out		[0x98], a
		nop
		nop
		inc		hl
		jr		puts

pcm_play:
		ld		a, 8
		out		[0xA0], a
pcm_play_loop:
		; ���� 4bit
		ld		a, [hl]				; 7+1
		and		a, 15				; 7+1
		and		a, 15				; 7+1		�������킹
		and		a, 15				; 7+1		�������킹
		and		a, 15				; 7+1		�������킹
		out		[0xA1], a			; 11+1

		; ��� 4bit
		nop							; 4+1
		nop							; 4+1
		ld		a, [hl]				; 7+1		�������킹
		ld		a, [hl]				; 7+1		�������킹
		ld		a, [hl]				; 7+1
		rrca						; 4+1
		rrca						; 4+1
		rrca						; 4+1
		rrca						; 4+1
		dec		bc					; 6+1
		and		a, 15				; 7+1
		out		[0xA1], a			; 11+1

		inc		hl					; 6+1
		ld		a, c				; 4+1
		or		a, b				; 4+1
		jr		nz, pcm_play_loop	; 12+1
		ret

message1:
		db		"MegaROM Check", 0
message2:
		db		"VOICEVOX: Ⱥ¶�ި", 0
		align	0x4000 + 6144

bank0_pcm::
		binary_link "voise.bin"
