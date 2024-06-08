; =============================================================================
; Simple MegaROM Writer
; -----------------------------------------------------------------------------
; Copyright (C)2024 HRA! (t.hara)
; =============================================================================

bdos		:= 0x0005
rdslt		:= 0x000C
calslt		:= 0x001C
enaslt		:= 0x0024
chgcpu		:= 0x0180
getcpu		:= 0x0183
ramad1		:= 0xF342
ramad2		:= 0xF343
jiffy		:= 0xFC9E
exptbl		:= 0xFCC1

; BDOS function call
_TERM0		:= 0x00
_CONIN		:= 0x01
_CONOUT		:= 0x02
_AUXIN		:= 0x03
_AUXOUT		:= 0x04
_LSTOUT		:= 0x05
_DIRIO		:= 0x06
_DIRIN		:= 0x07
_INNOE		:= 0x08
_STROUT		:= 0x09
_BUFIN		:= 0x0A
_CONST		:= 0x0B
_CPMVER		:= 0x0C
_DSKRST		:= 0x0D
_SELDSK		:= 0x0E
_FOPEN		:= 0x0F
_FCLOSE		:= 0x10
_SFIRST		:= 0x11
_SNEXT		:= 0x12
_FDEL		:= 0x13
_RDSEQ		:= 0x14
_WRSEQ		:= 0x15
_FMAKE		:= 0x16
_FREN		:= 0x17
_LOGIN		:= 0x18
_CURDRV		:= 0x19
_SETDTA		:= 0x1A
_ALLOC		:= 0x1B
_RDRND		:= 0x21
_WRRND		:= 0x22
_FSIZE		:= 0x23
_SETRND		:= 0x24
_WRBLK		:= 0x26
_RDBLK		:= 0x27
_WRSER		:= 0x28
_GDATE		:= 0x2A
_SDATE		:= 0x2B
_GTIME		:= 0x2C
_STIME		:= 0x2D
_VERIFY		:= 0x2E
_RDABS		:= 0x2F
_WRABS		:= 0x30
_DPARM		:= 0x31
_FFIRST		:= 0x40
_FNEXT		:= 0x41
_FNEW		:= 0x42

			org		0x100

; =============================================================================
;	Entry point
; =============================================================================
			scope	main
main::
			; �N���v�����v�g��\������ --------------------------------------------
			ld		c, _STROUT
			ld		de, start_prompt
			call	bdos

			; turboR�`�F�b�N ------------------------------------------------------
			ld		a, [exptbl]
			ld		hl, 0x002d
			call	rdslt
			ld		[romver], a
			cp		a, 3
			jr		c, skip_getcpu
			; -- turboR �Ȃ� CPU �� Z80 �ɐ؂�ւ��� ------------------------------
			ld		ix, getcpu
			call	calslt
			ld		[cpumode], a			; ���݂� CPU ���[�h��ۑ����Ă���
			ld		ix, chgcpu
			ld		a, 0x80					; Z80���[�h
			call	calslt
		skip_getcpu:
			; �t�@�C�����J�� ------------------------------------------------------
			call	get_file_name
			jp		z, usage

			ld		hl, file_name
			ld		de, fcb
			call	sub_fopen

			; �X���b�g���`�F�b�N���� ----------------------------------------------
			call	check_slot				; page1, page2 �̃X���b�g���؂�ւ��
			ld		a, [megarom_slot]
			inc		a
			jp		z, not_found_exit

			; �����������Ƃ�\������ --------------------------------------------
			ld		c, _STROUT
			ld		de, found_megarom
			call	bdos
			ld		a, [megarom_slot]
			call	put_slot_num

			; �S���������� --------------------------------------------------------
			ld		c, _STROUT
			ld		de, erase_all_message
			call	bdos
			call	erase_all
			ld		c, _STROUT
			ld		de, ok_message
			call	bdos

			; �������� ------------------------------------------------------------
			call	write_images

			; �t�@�C������� ----------------------------------------------------
			ld		hl, fcb
			call	sub_fclose

			; �I������ ------------------------------------------------------------
exit_cmd:
			; page1, page2 �� RAM �֖߂�
			call	change_to_ram
			; turboR �Ȃ猳��CPU���[�h�ɖ߂�
			ld		a, [romver]
			cp		a, 3
			jr		c, skip_chgcpu
			ld		a, [cpumode]
			or		a, 0x80
			ld		ix, chgcpu
			call	calslt
skip_chgcpu:
			; DOS�֖߂�
			ei
			ld		c, _TERM0
			jp		bdos

			; SimpleMegaROM ��������Ȃ������ꍇ --------------------------------
not_found_exit:
			ld		c, _STROUT
			ld		de, not_found_message
			call	bdos
			jr		exit_cmd

			; �t�@�C�������������� ------------------------------------------------
err_bad_file_name::
			ld		c, _STROUT
			ld		de, bad_file_name_message
			call	bdos
			jr		exit_cmd

			; �g������\�� --------------------------------------------------------
usage:
			ld		c, _STROUT
			ld		de, usage_message
			call	bdos
			jr		exit_cmd
			endscope

; =============================================================================
;	page1, page2 �� RAM �֐؂�ւ���
; =============================================================================
			scope	change_to_ram
change_to_ram::
			ld		a, [ramad1]
			ld		h, 0x40
			call	enaslt

			ld		a, [ramad2]
			ld		h, 0x80
			call	enaslt
			ret
			endscope

; =============================================================================
;	page1, page2 �� ROM �֐؂�ւ���
; =============================================================================
			scope	change_to_rom
change_to_rom::
			ld		a, [megarom_slot]
			ld		h, 0x40
			call	enaslt

			ld		a, [megarom_slot]
			ld		h, 0x80
			call	enaslt
			ret
			endscope

; =============================================================================
;	��������
; =============================================================================
			scope	write_images
write_images::
			xor		a, a
			ld		[bank_id], a
			; ROM�ɐ؂�ւ���
			call	change_to_rom
	_loop:
			; �t�@�C���� 8KB �ǂݍ���
			ld		hl, fcb
			ld		de, 0x2000				; page0�㔼 �ɓǂݍ���
			ld		bc, 0x2000
			call	sub_fread
			ld		a, h
			or		a, l
			ret		z						; �ǂݍ��߂Ȃ��Ȃ����炨���܂�
			ld		bc, 0x9FFF
			call	_write_8k
			; �t�@�C���� 8KB �ǂݍ���
			ld		hl, fcb
			ld		de, 0x2000				; page0�㔼 �ɓǂݍ���
			ld		bc, 0x2000
			call	sub_fread
			ld		a, h
			or		a, l
			ret		z						; �ǂݍ��߂Ȃ��Ȃ����炨���܂�
			ld		bc, 0xBFFF
			call	_write_8k
			; ���̃o���N��
			ld		a, [bank_id]
			inc		a
			ld		[bank_id], a
			; �i���\��
			rrca
			rrca
			rrca
			rrca
			and		a, 0x0F
			add		a, '0'
			ld		e, a
			ld		c, _CONOUT
			call	bdos
			ld		a, [bank_id]
			and		a, 0x0F
			add		a, '0'
			cp		a, '9' + 1
			jr		c, _skip
			add		a, 'A' - ('9' + 1)
		_skip:
			ld		e, a
			ld		c, _CONOUT
			call	bdos
			ld		e, 0x0D
			ld		c, _CONOUT
			call	bdos
			; �܂������H
			ld		a, [bank_id]
			cp		a, 32
			jp		nz, _loop
			; RAM�֐؂�ւ���
			call	change_to_ram
			; ���s
			ld		c, _STROUT
			ld		de, crlf_message
			call	bdos
			ret

	_write_8k:
			ld		hl, 0x7000				; Bank Register
			ld		de, 0x3FFF
	_loop_8k:
			; -- �������݃R�}���h : 0x5555 : Bank#1, 0x1555 �� 0xAA
			ld		a, 0xAA
			ld		[hl], 0x01
			ld		[ 0x8000 + 0x1555 ], a
			; -- �������݃R�}���h : 0x2AAA : Bank#0, 0x2AAA �� 0x55
			ld		a, 0x55
			ld		[hl], 0x00
			ld		[ 0x8000 + 0x2AAA ], a
			; -- �������݃R�}���h : 0x5555 : Bank#1, 0x1555 �� 0xA0
			ld		a, 0xA0
			ld		[hl], 0x01
			ld		[ 0x8000 + 0x1555 ], a
			; -- ��������
			ld		a, [bank_id]			; �������ރo���N
			ld		[hl], a
			ld		a, [de]					; �������ޒl
			ld		[bc], a					; ��������
			; -- �҂�(Tbp = 20usec�ȏ�)
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			dec		de
			dec		bc
			bit		5, d
			jp		nz, _loop_8k
			ret
			endscope

; =============================================================================
;	�R�}���h���C����������t�@�C�������擾����
;	input:
;		none
;	output:
;		Zf=1: �R�}���h���C������������
;		Zf=0: ����I��
; =============================================================================
			scope	get_file_name
get_file_name::
			ld		hl, 0x0080
			ld		b, [hl]
	_skip_white:
			inc		hl
			ld		a, [hl]
			cp		a, ' '
			jr		nz, _first_char
			djnz	_skip_white
			ret								; �R�}���h���C������������
	_first_char:
			ld		de, file_name + 1
			ld		c, 1
	_copy_string:
			ld		a, [hl]
			ld		[de], a
			inc		c
			inc		hl
			inc		de
			djnz	_copy_string
			ld		a, c
			ld		[file_name], a
			or		a, a
			ret
			endscope

; =============================================================================
;	SimpleMegaROM ����������
;	input:
;		none
;	output:
;		[megarom_slot] .... �������X���b�g�B������Ȃ��ꍇ�́A0xFF
; =============================================================================
			scope	check_slot
check_slot::
			; �u������Ȃ��v���}�[�N���Ă���
			ld		a, 0xFF
			ld		[megarom_slot], a
			; SLOT#0 ���猟��
			xor		a, a
	_primary_slot_loop:
			; �g���X���b�g�̃t���O�� MSB �ɃR�s�[
			ld		b, a
			add		a, exptbl & 255
			ld		l, a
			ld		h, exptbl >> 8
			ld		a, [hl]
			and		a, 0x80
			or		a, b
	_expanded_slot_loop:
			; page1, page2 �̃X���b�g��؂�ւ���
			push	af
			ld		h, 0x40
			call	enaslt
			pop		af

			push	af
			ld		h, 0x80
			call	enaslt

			; page1 �� ROM �ł��邱�Ƃ��m�F����
			ld		hl, 0x4000
			ld		a, [hl]
			cpl
			ld		[hl], a
			cp		a, [hl]
			cpl
			ld		[hl], a
			jp		z, _no_match				; ROM����Ȃ��������
			; page2 �� ROM �ł��邱�Ƃ��m�F����
			ld		hl, 0x8000
			ld		a, [hl]
			cpl
			ld		[hl], a
			cp		a, [hl]
			cpl
			ld		[hl], a
			jp		z, _no_match				; ROM����Ȃ��������
			; page1, page2 �Ƃ��� ROM �������̂ŁAID�`�F�b�N
			ld		hl, 0x7000					; �o���N���W�X�^�̃A�h���X
			ld		bc, 0x0001					; B=0, C=1
			; -- 0x5555 => BANK#1 1555 �� 0xAA ����
			ld		[hl], c
			ld		a, 0xAA
			ld		[0x8000 + 0x1555], a
			; -- 0x2AAA => BANK#0 2AAA �� 0x55 ����
			ld		[hl], b
			ld		a, 0x55
			ld		[0x8000 + 0x2AAA], a
			; -- 0x5555 => BANK#1 1555 �� 0x90 ����
			ld		[hl], c
			ld		a, 0x90
			ld		[0x8000 + 0x1555], a
			; -- 0x0000, 0x0001 => BANK#0 0000, BANK#0 0001 ��ǂ�
			ld		[hl], b
			ld		a, [0x8000 + 0x0000]
			cp		a, 0xBF						; �Œ�l
			jp		nz, _no_match
			ld		a, [0x8000 + 0x0001]
			cp		a, 0xB7						; SST39SF040
			jp		nz, _no_match
			pop		af
			ld		[megarom_slot], a			; ���������ꍇ
			ret
	_no_match:
			pop		af
			bit		7, a
			jr		z, _is_primary_slot
	_is_expanded_slot:
			add		a, 4
			bit		4, a
			jp		z, _expanded_slot_loop
			and		a, 0x03
	_is_primary_slot:
			inc		a
			bit		2, a
			jp		z, _primary_slot_loop
			ret									; ������Ȃ������ꍇ
			endscope

; =============================================================================
;	ROM ��S�ď�������
;	input:
;		none
;	output:
;		none
; =============================================================================
			scope	erase_all
erase_all::
			ld		hl, 0x7000					; �o���N���W�X�^�̃A�h���X
			ld		bc, 0x0001					; B=0, C=1
			; -- 0x5555 => BANK#1 1555 �� 0xAA ����
			ld		[hl], c
			ld		a, 0xAA
			ld		[0x8000 + 0x1555], a
			; -- 0x2AAA => BANK#0 2AAA �� 0x55 ����
			ld		[hl], b
			ld		a, 0x55
			ld		[0x8000 + 0x2AAA], a
			; -- 0x5555 => BANK#1 1555 �� 0x90 ����
			ld		[hl], c
			ld		a, 0x80
			ld		[0x8000 + 0x1555], a
			; -- 0x5555 => BANK#1 1555 �� 0x90 ����
			ld		[hl], c
			ld		a, 0xAA
			ld		[0x8000 + 0x1555], a
			; -- 0x2AAA => BANK#0 2AAA �� 0x55 ����
			ld		[hl], b
			ld		a, 0x55
			ld		[0x8000 + 0x2AAA], a
			; -- 0x5555 => BANK#1 1555 �� 0x90 ����
			ld		[hl], c
			ld		a, 0x10
			ld		[0x8000 + 0x1555], a
			; -- Wait Tsce (Max 100msec)
			ei
			ld		b, 16				; 8�ŏ\���Ȃ͂������A�����]�v�ɑ҂�
			ld		hl, jiffy
	_wait_loop1:
			ld		a, [hl]
	_wait_loop2:
			cp		a, [hl]
			jr		z, _wait_loop2
			djnz	_wait_loop1
			ret
			endscope

; =============================================================================
;	put slot num
;	input:
;		A .... �X���b�g�ԍ� (ENASLT�`��)
; =============================================================================
			scope	put_slot_num
put_slot_num::
			push	af
			; primary slot ��\��
			and		a, 0x03
			add		a, '0'
			ld		c, _CONOUT
			ld		e, a
			call	bdos
			; �g������Ă��邩�H
			pop		af
			and		a, 0x80
			jr		z, _put_crlf			; �g������Ă��Ȃ���Ή��s��
			; �g���X���b�g��\������
			push	af
			ld		c, _CONOUT
			ld		e, '-'
			call	bdos
			pop		af
			rrca
			rrca
			and		a, 0x03
			add		a, '0'
			ld		c, _CONOUT
			ld		e, a
			call	bdos
	_put_crlf:
			ld		c, _STROUT
			ld		de, crlf_message
			call	bdos
			ret
			endscope

; =============================================================================
;	�V����FCB�𐶐�����
;	input:
;		HL ... �t�@�C����
;		DE ... FCB�p�̃������̃A�h���X (37bytes)
;	output:
;		none
;	break:
;		all
;	comment:
;		���C���h�J�[�h '*' �́A'?' �ɓW�J����
; =============================================================================
			scope	sub_setup_fcb
sub_setup_fcb::
			; ���g���N���A����
			push	hl
			push	de
			ld		l, e
			ld		h, d
			inc		de
			ld		bc, 36
			ld		[hl], 0
			ldir
			; �J�����g�h���C�u�擾
			ld		c, _CURDRV
			call	bdos
			inc		a
			pop		de
			pop		hl
			ld		[de], a
			; �h���C�u���̑��݃`�F�b�N
			ld		a, [hl]
			inc		hl
			ld		c, a				; C = ����
			cp		a, 3
			jr		c, copy_file_name
			inc		hl
			ld		a, [hl]				; 2nd char
			dec		hl
			cp		a, ':'
			jr		nz, copy_file_name
			ld		a, [hl]				; 1st char
			or		a, a
			jp		m, copy_file_name
			and		a, 0b1101_1111
			cp		a, 'H'+1
			jr		nc, copy_file_name
			sub		a, 'A'
			jr		c, copy_file_name
			inc		a
			ld		[de], a				; Driver Number 1:A, 2:B, ... 8:H
			inc		hl
			inc		hl
			dec		c
			dec		c
			; �t�@�C����(Max 8����) �̃R�s�[
		copy_file_name:
			inc		de					; DE: �t�@�C����
			ld		b, 8				; B: �t�@�C�����̍ő�T�C�Y
			inc		c					; ���܍��킹
		copy_file_name_loop:
			dec		c
			jr		z, fill_name_padding	; �t�@�C�����̃R�s�[�͏I�����
			ld		a, [hl]
			cp		a, '.'
			jr		z, copy_ext_name_skip_dot
			cp		a, '*'
			jr		z, copy_ext_name_skip_wildcard
			call	check_error_char
			jp		c, err_bad_file_name
			ld		[de], a
			inc		hl
			inc		de
			djnz	copy_file_name_loop
			; �s�b�^��8�����̖��O���w�肳��Ă���ꍇ�� . �����邩�`�F�b�N
			ld		a, [hl]
			cp		a, '.'
			jr		nz, copy_ext_name
			inc		hl
			jr		copy_ext_name
			; �t�@�C�����̎c������C���h�J�[�h�Ŗ��߂�
		copy_ext_name_skip_wildcard:
			ld		a, '?'
			inc		hl
			jr		copy_ext_name_skip_dot_loop
			; �t�@�C�����̎c��̌��Ԃ��X�L�b�v
		fill_name_padding:
			dec		hl					; '.' ��ǂݔ�΂������̂��܍��킹
			inc		c					; '.' ��ǂݔ�΂������̂��܍��킹
		copy_ext_name_skip_dot:
			ld		a, ' '
		copy_ext_name_skip_dot_loop:
			ld		[de], a				; ���Ԃ� ' ' �Ŗ��߂�
			inc		de					; �g���q�̈ʒu�܂ňړ�
			djnz	copy_ext_name_skip_dot_loop
			inc		hl					; '.' ��ǂݔ�΂�
			dec		c					; '.' ��ǂݔ�΂�
			; �g���q(Max 3����) �̃R�s�[
		copy_ext_name:
			ld		b, 3
			inc		c
			dec		c
			jr		z, fill_ext_padding
		copy_ext_name_loop:
			ld		a, [hl]
			cp		a, '*'
			jr		z, copy_ext_name_padding_wildcard
			call	check_error_char
			jp		c, err_bad_file_name
			ld		[de], a
			inc		hl
			inc		de
			dec		c
			jr		z, copy_ext_name_padding
			djnz	copy_ext_name_loop
			jr		copy_name_finish
			; * �� ? �ɒu��
		copy_ext_name_padding_wildcard:
			ld		a, '?'
			jr		copy_ext_name_padding_loop
			; �g���q�� 3���������Ȃ�p�f�B���O
		copy_ext_name_padding:
			dec		b
			jr		z, copy_name_finish
		fill_ext_padding:
			ld		a, ' '
		copy_ext_name_padding_loop:
			ld		[de], a
			inc		de
			djnz	copy_ext_name_padding_loop
			; �t�@�C�����ȊO�̃t�B�[���h������������
		copy_name_finish:
			ret

	check_error_char:
			push	hl
			push	bc
			ld		hl, error_char
			ld		b, a
	check_error_char_loop:
			ld		a, [hl]
			or		a, a
			jr		z, check_error_exit		; �s���ȋL���ɂ͈�v���Ȃ�����
			cp		a, b
			scf
			jr		z, check_error_exit		; �s���ȋL���Ɉ�v����
			inc		hl
			jr		check_error_char_loop
	check_error_exit:
			ld		a, b
			pop		bc
			pop		hl
			ret		c						; �G���[�Ȃ甲����
	toupper:
			cp		a, 'a'
			jr		c, toupper_exit
			cp		a, 'z'+1
			jr		nc, toupper_exit
			and		a, 0b1101_1111			; a �� A ... z �� Z
	toupper_exit:
			or		a, a					; Cf = 0
			ret
	error_char:
			db		":\"\\^|<>,./ ", 0
			endscope

; =============================================================================
;	�t�@�C�����J��
;	input:
;		HL ... �t�@�C����
;		DE ... FCB�p�̃������̃A�h���X (37bytes)
;	output:
;		A .... 00h: ����, FFh: ���s
;	break:
;		all
;	comment:
;		���ɑ��݂���t�@�C�����J��
; =============================================================================
			scope	sub_fopen
sub_fopen::
			push	de
			call	sub_setup_fcb
			pop		de
			push	de
			ld		c, _FOPEN
			call	bdos
			pop		hl
			ld		de, 14
			add		hl, de
			push	af
			ld		a, 1
			ld		[hl], a
			dec		a
			inc		hl
			ld		[hl], a
			ld		de, 33-15
			add		hl, de
			ld		[hl], a
			inc		hl
			ld		[hl], a
			inc		hl
			ld		[hl], a
			inc		hl
			ld		[hl], a
			pop		af
			ret
			endscope

; =============================================================================
;	�t�@�C�������
;	input:
;		HL ... �J����FCB
;	output:
;		A .... 00h: ����, FFh: ���s
;	break:
;		all
;	comment:
;		none
; =============================================================================
			scope	sub_fclose
sub_fclose::
			ld		c, _FCLOSE
			ex		de, hl
			jp		bdos
			endscope

; =============================================================================
;	�t�@�C����ǂ�
;	input:
;		HL ... �J����FCB
;		DE ... �ǂݏo�����ʂ��i�[����A�h���X
;		BC ... �ǂݏo���T�C�Y
;	output:
;		A .... 00h: ����, 01h: ���s�܂���EOF
;		HL ... ���ۂɓǂ񂾃o�C�g��
;	break:
;		all
;	comment:
;		none
; =============================================================================
			scope	sub_fread
sub_fread::
			push	bc					; �T�C�Y
			push	hl					; FCB
			; �]����A�h���X�̎w��
			ld		c, _SETDTA
			call	bdos
			; �ǂݏo��
			pop		de					; FCB
			pop		hl					; �T�C�Y = ���R�[�h�� (1���R�[�h 1byte�ݒ�)
			ld		c, _RDBLK
			jp		bdos
			endscope

; =============================================================================
start_prompt::
			db		"SimpleMegaROM Writer v1.0", 0x0D, 0x0A
			db		"Copyright(C)2024 HRA!", 0x0D, 0x0A, "$"
not_found_message::
			db		"SimpleMegaROM is not found.", 0x0D, 0x0A, "$"
found_megarom::
			db		"Detect SimpleMegaROM", 0x0D, 0x0A
			db		"  SLOT#$"
crlf_message::
			db		0x0D, 0x0A, "$"
erase_all_message::
			db		"Erase ROM data .... $"
ok_message::
			db		"OK", 0x0D, 0x0A, "$"
megarom_slot::
			db		0
usage_message::
			db		"Usage> SMEGAWT <file name.rom>", 0x0D, 0x0A
			db		"Writes the specified file to SimpleMegaROM.", 0x0D, 0x0A, "$"
file_name::
			db		0		; length
			ds		255
bad_file_name_message::
			db		"Bad file name.", 0x0D, 0x0A, "$"
bank_id::
			db		0
romver::
			db		0
cpumode::
			db		0
fcb::
			ds		37
