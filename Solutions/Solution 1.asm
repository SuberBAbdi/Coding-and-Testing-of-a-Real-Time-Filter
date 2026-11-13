;*******************************************************************************
; File:        main.asm
; Processor:   PIC16F877A
; Assembler:   MPASM
; Description: Basic template with reset/interrupt vectors and port setup
;*******************************************************************************

    LIST        P=16F877A           ; Define processor
    #INCLUDE    <p16f877a.inc>      ; Include processor-specific definitions

;-------------------------------------------------------------------------------
; Configuration Bits (4 MHz HS/XT Crystal, WDT Off, LVP Off)
;-------------------------------------------------------------------------------
    __CONFIG    _FOSC_HS & _WDTE_OFF & _PWRTE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF

;-------------------------------------------------------------------------------
; Variable Definitions (Shared/Unbanked RAM: 0x70 - 0x7F, Bank 0: 0x20 - 0x6F)
;-------------------------------------------------------------------------------
    CBLOCK      0x20
        TEMP_VAR                    ; General purpose variable in Bank 0
        DELAY_CNT1
        DELAY_CNT2
    ENDC

    CBLOCK      0x70                ; Context saving variables (accessible in all banks)
        W_TEMP
        STATUS_TEMP
        PCLATH_TEMP
    ENDC

;-------------------------------------------------------------------------------
; Reset Vector
;-------------------------------------------------------------------------------
    ORG         0x0000
    GOTO        INIT                ; Jump to initialization routine

;-------------------------------------------------------------------------------
; Interrupt Service Routine (ISR)
;-------------------------------------------------------------------------------
    ORG         0x0004
ISR:
    ; Save Context
    MOVWF       W_TEMP              ; Save W register
    SWAPF       STATUS, W           ; Swap STATUS nibbles into W (affects no flags)
    MOVWF       STATUS_TEMP         ; Save STATUS register
    MOVF        PCLATH, W           ; Read PCLATH
    MOVWF       PCLATH_TEMP         ; Save PCLATH
    CLRF        PCLATH              ; Select Page 0

    ; --- Insert Interrupt Handling Code Here ---

    ; Restore Context
    MOVF        PCLATH_TEMP, W
    MOVWF       PCLATH              ; Restore PCLATH
    SWAPF       STATUS_TEMP, W
    MOVWF       STATUS              ; Restore STATUS
    SWAPF       W_TEMP, F
    SWAPF       W_TEMP, W           ; Restore W register
    RETFIE                          ; Return from interrupt

;-------------------------------------------------------------------------------
; Microcontroller Initialization
;-------------------------------------------------------------------------------
INIT:
    BANKSEL     ADCON1              ; Switch to Bank 1
    MOVLW       0x06                ; Configure all PORTA & PORTE pins as digital I/O
    MOVWF       ADCON1

    MOVLW       0x00                ; Set all PORTB pins as outputs (0 = output, 1 = input)
    MOVWF       TRISB
    MOVLW       0xFF                ; Set all PORTD pins as inputs
    MOVWF       TRISD

    BANKSEL     PORTB               ; Switch back to Bank 0
    CLRF        PORTB               ; Clear all outputs on PORTB

;-------------------------------------------------------------------------------
; Main Program Loop
;-------------------------------------------------------------------------------
MAIN_LOOP:
    ; --- Insert Main Application Code Here ---
    BSF         PORTB, 0            ; Set RB0 high
    NOP
    BCF         PORTB, 0            ; Set RB0 low
    GOTO        MAIN_LOOP           ; Repeat forever

    END                             ; End of program
