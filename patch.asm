; https://github.com/ArcadeTV/msu-md-fatalfury

; I/O
HW_version		EQU	$A10001					; hardware version in low nibble
											; bit 6 is PAL (50Hz) if set, NTSC (60Hz) if clear
											; region flags in bits 7 and 6:
											;         USA NTSC = $80
											;         Asia PAL = $C0
											;         Japan NTSC = $00
											;         Europe PAL = $C0
											
; MSU-MD vars
MCD_STAT		EQU $A12020					; 0-ready, 1-init, 2-cmd busy
MCD_CMD			EQU $A12010
MCD_ARG 		EQU $A12011
MCD_CMD_CK 		EQU $A1201F


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		org $4
		dc.l 	ENTRY_POINT						; custom entry point for redirecting
		
		org 	$100
		dc.b 	'SEGA MEGASD     '
		
		org 	$1A4							; ROM_END
		dc.l 	$001FFFFF						; Overwrite with 16 MBIT size
				
		org 	$39C							; original entry point, after reset-checks ($200 present in the header)
Game

		org 	$4F4 							; Check CRC bypass
		;rts
		
		org 	$1604C0
		jsr 	pause_track						; Pause on
		
		org 	$1604FE							; Pause off
		jsr 	resume_track
		
		org 	$160628							; hijack this
		jsr 	CustomPlaySound
		rts
		
		org 	$160A60
		jsr 	fade_track
		nop
		
		org 	$160B86
		;jsr 	pause_track_sas					; StopAllSounds
		

		org		$17F6C0
MSUDRV
		incbin	"msu-drv.bin"


		org 	$17FE10
ENTRY_POINT
		tst.w 	$00A10008  					; Test mystery reset (expansion port reset?)
		bne Main          					; Branch if Not Equal (to zero) - to Main
		tst.w 	$00A1000C  					; Test reset button
		bne Main          					; Branch if Not Equal (to zero) - to Main
Main
		move.b 	$00A10001,d0      			; Move Megadrive hardware version to d0
		andi.b 	#$0F,d0           			; The version is stored in last four bits, so mask it with 0F
		beq 	Skip                  		; If version is equal to 0, skip TMSS signature
		move.l 	#'SEGA',$00A14000 			; Move the string "SEGA" to 0xA14000
Skip
		btst 	#$6,(HW_version).l 			; Check for PAL or NTSC, 0=60Hz, 1=50Hz
		bne 	jump_lockout				; branch if != 0
		jsr 	audio_init
		jmp 	Game
jump_lockout
		jmp 	lockout



audio_init
		jsr 	MSUDRV
		nop
		nop
		nop
		
		tst.b 	d0							; if 1: no CD Hardware found
		bne		audio_init_fail				; Return without setting CD enabled

		move.w 	#($1500|255),MCD_CMD		; Set CD Volume to MAX
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
audio_init_fail
		jmp 	lockout


		align 	2
CustomPlaySound
ready
		tst.b 	MCD_STAT
		bne.s 	ready 						; Wait for Driver ready to receive cmd
		jsr 	find_track
		rts 								; Return to regular game code



find_track
		cmp.b	#$81,d7						; Geese
		beq		play_track_24
		cmp.b	#$82,d7						; M.Max
		beq		play_track_8
		cmp.b	#$83,d7						; Raiden
		beq		play_track_11
		cmp.b	#$84,d7						; B.Kane
		beq		play_track_1
		cmp.b	#$85,d7						; TFRue
		beq		play_track_12
		cmp.b	#$86,d7						; Duck
		beq		play_track_7
		cmp.b	#$87,d7						; Intro
		beq		play_track_4
		cmp.b	#$88,d7						; Map
		beq		play_track_3
		cmp.b	#$89,d7						; vs
		beq		play_track_6
		cmp.b	#$8A,d7						; Result
		beq		play_track_17
		cmp.b	#$8B,d7						; Geese Cutscene
		beq		play_track_18
		cmp.b	#$8C,d7						; Geese preparing
		beq		play_track_27
		cmp.b	#$8D,d7						; Continue
		beq		play_track_14
		cmp.b	#$8E,d7						; Kidnapping
		beq		play_track_26
		cmp.b	#$8F,d7						; 2P
		beq		play_track_13
		cmp.b	#$90,d7						; Hiscore
		beq		play_track_16
		cmp.b	#$91,d7						; Game Over
		beq		play_track_15
		cmp.b	#$92,d7						; Richard Meyer
		beq		play_track_2
		cmp.b	#$93,d7						; Ending
		beq		play_track_31
		rts


play_track_1								
		move.w	#($1100|1),MCD_CMD			; send cmd: play track #1, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_2								
		move.w	#($1100|2),MCD_CMD			; send cmd: play track #2, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_3								
		move.w	#($1100|3),MCD_CMD			; send cmd: play track #3, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_4								
		move.w	#($1100|4),MCD_CMD			; send cmd: play track #4, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_5								
		move.w	#($1100|5),MCD_CMD			; send cmd: play track #5, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_6								
		move.w	#($1100|6),MCD_CMD			; send cmd: play track #6, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_7								
		move.w	#($1100|7),MCD_CMD			; send cmd: play track #7, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_8							
		move.w	#($1100|8),MCD_CMD			; send cmd: play track #8, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_9								
		move.w	#($1100|9),MCD_CMD			; send cmd: play track #9, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_10							
		move.w	#($1100|10),MCD_CMD			; send cmd: play track #10, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_11								
		move.w	#($1100|11),MCD_CMD			; send cmd: play track #11, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_12							
		move.w	#($1100|12),MCD_CMD			; send cmd: play track #12, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_13								
		move.w	#($1100|13),MCD_CMD			; send cmd: play track #13, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_14
		move.w	#($1100|14),MCD_CMD			; send cmd: play track #14, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_15
		move.w	#($1100|15),MCD_CMD			; send cmd: play track #15, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_16
		move.w	#($1100|16),MCD_CMD			; send cmd: play track #16, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_17
		move.w	#($1100|17),MCD_CMD			; send cmd: play track #17, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_18
		move.w	#($1100|18),MCD_CMD			; send cmd: play track #18, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_19
		move.w	#($1100|19),MCD_CMD			; send cmd: play track #19, no loop
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_24
		move.w	#($1100|24),MCD_CMD			; send cmd
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_26
		move.w	#($1100|26),MCD_CMD			; send cmd
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_27
		move.w	#($1100|27),MCD_CMD			; send cmd
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
play_track_31
		move.w	#($1100|31),MCD_CMD			; send cmd
		addq.b	#1,MCD_CMD_CK				; Increment command clock
		jsr	MUTE_THIS						; Mute Chipsound
		rts
		
MUTE_THIS									; Mute Chipsound
		move.l   #$0000009F,d7
		rts
		
pause_track
		move.w 	#($1300|0),MCD_CMD 			; send cmd: pause track
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		moveq   #0,d1
		jsr     $160CFE
		rts
pause_track_sas
		move.w 	#($1300|0),MCD_CMD 			; send cmd: pause track
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		moveq   #0,d1
		jsr     $160CFE
		moveq   #$2B,d0
		move.b  #$80,d1
		rts
		
resume_track
		move.w 	#($1400|0),MCD_CMD 			; send cmd: pause track
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		moveq   #6,d4
		jsr     $160CFE
		rts
fade_track
		move.w 	#($1300|70),MCD_CMD 		; send cmd: pause track
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		jsr 	$160952
		jsr 	$1609F6
		rts
fade_track_slow
		move.w 	#($1300|300),MCD_CMD 		; send cmd: pause track
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts



		align	2							; insert GFX and code for lockout screen
lockout
	incbin	"msuLockout.bin"		
