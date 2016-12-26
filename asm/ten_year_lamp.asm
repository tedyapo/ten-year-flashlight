;;;
;;; ten_year_lamp.asm :
;;;    PIC12LF1571 code for (2x) LiFeS2 AA-powered LED glow marker
;;;
;;;  20161106 TCY
    
    LIST        P=12LF1571
 #include    <p12lf1571.inc>
  
  ERRORLEVEL -302
  ERRORLEVEL -305  
  ERRORLEVEL -207
  
;;;
;;; OSCTUNE_VAL: set to fine-tune current draw for compensating for
;;;              component tolerances
;  OSCTUNE_VAL  equ   0          
   OSCTUNE_VAL  equ   b'00100000'
;  OSCTUNE_VAL  equ   b'00011111'

;;;
;;; number of LED pulses per WDT timeout loop
;;; 
  N_PULSES    equ   6
  
LED_PULSE   macro
  variable  i
  i = 0
  while i < N_PULSES - 1
  movwf     LATA              ;start inductor ramp-up
  clrf      LATA              ;end inductor ramp-up
  nop                         ; 2 nops here - tuned for minimum current
  nop
  i += 1
  endw
  movwf     LATA              ;start inductor ramp-up
  clrf      LATA              ;end inductor ramp-up
  endm

;;; 
;;; I/O pin configuration
;;; 
  GATE_DRIVE_A  equ   4
  GATE_DRIVE_B  equ   5  

  __CONFIG  _CONFIG1, _FOSC_INTOSC & _WDTE_ON & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOREN_OFF & _CLKOUTEN_OFF
  __CONFIG _CONFIG2, _WRT_OFF & _PLLEN_OFF & _STVREN_OFF & _BORV_HI & _LPBOREN_OFF & _LVP_ON

;;;
;;; variables in Common RAM (accessable from all banks)
;;; 
  CBLOCK 0x70
    reset_counter
  ENDC  
  
  ORG     0
RESET_VEC:  
  nop
  nop
  nop
  nop
INTERRUPT_VEC:
  BANKSEL   OSCCON
  movlw     b'00111011'      ; 500 kHz MF osc
  movwf     OSCCON
  
  BANKSEL   OSCTUNE
  movlw     OSCTUNE_VAL
  movwf     OSCTUNE

  movlw     .255
  movwf     reset_counter

  BANKSEL   ANSELA
  movlw     b'00000000'     ; all digital I/O
  movwf     ANSELA

  BANKSEL   LATA
  clrf      LATA
  
  BANKSEL   TRISA
  clrf      TRISA           ; set all lines as outputs

  BANKSEL   WDTCON
  movlw     b'00001001'     ; WDT 16ms timeout    
  movwf     WDTCON        

  BANKSEL   LATA
  movlw     (1 << GATE_DRIVE_A) | (1 << GATE_DRIVE_B)
    
MAIN_LOOP:
  LED_PULSE
  sleep
  decfsz    reset_counter 
  goto      MAIN_LOOP
  reset

  ;; fill remainder of program memory with reset instructions
  fill      (reset), 0x0400-$
  END
