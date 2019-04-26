.device ATmega32
.include "m32def.inc"
.cseg
.def temp		= r16
.def counter	= r18
.def plus		= r25
.def rejestr	= r19
.def pomocniczy = r23
;---------------wektory przerwań---------------
.org 0
RJMP start

.org $002
RJMP przerwanie_int0

.org $004
RJMP przerwanie_int1

.org $006
RJMP przerwanie_int2

.org $014                    
RJMP przerwanie_komparatora

;----------------------------------------------
start:
;-----------stos programowy-------------------
ldi temp, high(RAMEND)
out SPH, temp
ldi temp, low(RAMEND)
out SPL, temp
;--------------timer tryb CTC-----------------
ldi temp, (1<<CS00) | (1<<CS02) | (1<<WGM01)   
out TCCR0, temp
ldi temp, 1<<OCF0
out TIFR, temp
ldi temp, 1<<OCIE0
out TIMSK, temp
ldi rejestr, 60		;ustawienie wartosci 
out OCR0, rejestr	;do ktorej ma zliczac 
;-----konfiguracja przerwan zewnetrznych------
ldi temp, (1<<INT0) | (1<<INT1) | (1<<INT2)
out GICR, temp
ldi temp, (1<<ISC01) | (1<<ISC11)
out MCUCR, temp
ldi temp, (1<<INTF0) | (1<<INTF1) | (1<<INTF2)
out GIFR, temp
ldi temp, (0<<ISC2)
out MCUCSR, temp
;------------konfiguracja portow--------------
ldi r17, 0xFF
out DDRA, r17
out PORTB, r17
out PORTC, r17
out PORTD, r17
ldi r17, 0x00
out DDRB, r17
out DDRC, r17
out DDRD, r17
;----------rejestry pomocnicze----------------
ldi plus, 2
clr pomocniczy
clr counter
sei
; --------petla nieskonczona------------------
main:
rjmp main  
; -----obsługa przerwania komparatora---------
przerwanie_komparatora:
push temp
in temp, SREG
push temp

cpi pomocniczy, 1
breq krokowe_lewo
cpi pomocniczy, 2
breq krokowe_prawo
cpi pomocniczy, 3
breq polkrokowe
cpi pomocniczy, 4
breq odwrot_polkrokowego
clr pomocniczy
;===========================================
krokowe_lewo:
inc counter
cpi counter, 30
brlo dioda1_pomoc
cpi counter, 60
brlo dioda2_pomoc
cpi counter, 90
brlo dioda3_pomoc
cpi counter, 120
brlo dioda4_pomoc
brlo koniec_przerwania_pomoc
clr counter
rjmp koniec_przerwania
;===========================================
krokowe_prawo:
inc counter
cpi counter, 30
brlo dioda4_pomoc
cpi counter, 60
brlo dioda3_pomoc
cpi counter, 90
brlo dioda2
cpi counter, 120
brlo dioda1
brlo koniec_przerwania_pomoc
clr counter
rjmp koniec_przerwania
;===========================================
polkrokowe:
inc counter
cpi counter, 30
brlo dioda1
cpi counter, 60
brlo dioda12
cpi counter, 90
brlo dioda2
cpi counter, 120
brlo dioda23
cpi counter, 150
brlo dioda3
cpi counter, 180
brlo dioda34
cpi counter, 210
brlo dioda4
cpi counter, 240
brlo dioda41
brlo koniec_przerwania_pomoc
clr counter
rjmp koniec_przerwania
;======podskoki=======================
dioda1_pomoc:
brlo dioda1
dioda2_pomoc:
brlo dioda2
dioda3_pomoc:
brlo dioda3
dioda4_pomoc:
brlo dioda4
koniec_przerwania_pomoc:
brlo koniec_przerwania
;======================================
odwrot_polkrokowego:
inc counter
cpi counter, 30
brlo dioda41
cpi counter, 60
brlo dioda4
cpi counter, 90
brlo dioda34
cpi counter, 120
brlo dioda3
cpi counter, 150
brlo dioda23
cpi counter, 180
brlo dioda2
cpi counter, 210
brlo dioda12
cpi counter, 240
brlo dioda1
brlo koniec_przerwania
clr counter
rjmp koniec_przerwania
;--------sekwencja diod na wyjsciu------------
dioda1:
cbi PORTA, 4
sbi PORTA, 5
sbi PORTA, 6
sbi PORTA, 7
rjmp koniec_przerwania
dioda12:
cbi PORTA, 4
cbi PORTA, 5
sbi PORTA, 6
sbi PORTA, 7
rjmp koniec_przerwania
dioda2:
sbi PORTA, 4
cbi PORTA, 5
sbi PORTA, 6
sbi PORTA, 7
rjmp koniec_przerwania
dioda23:
sbi PORTA, 4
cbi PORTA, 5
cbi PORTA, 6
sbi PORTA, 7
rjmp koniec_przerwania
dioda3:
sbi PORTA, 4
sbi PORTA, 5
cbi PORTA, 6
sbi PORTA, 7
rjmp koniec_przerwania
dioda34:
sbi PORTA, 4
sbi PORTA, 5
cbi PORTA, 6
cbi PORTA, 7
rjmp koniec_przerwania
dioda4:
sbi PORTA, 4
sbi PORTA, 5
sbi PORTA, 6
cbi PORTA, 7
rjmp koniec_przerwania
dioda41:
cbi PORTA, 4
sbi PORTA, 5
sbi PORTA, 6
cbi PORTA, 7
rjmp koniec_przerwania
;--------------------------------------------
koniec_przerwania:
pop r16
out SREG, r16
pop r16
reti
;------obsługa przerwania zewnętrznego 0------
przerwanie_int0:
push temp
in temp, SREG
push temp
add rejestr, plus
out OCR0, rejestr
pop temp
out SREG, temp
pop temp
reti
;------obsługa przerwania zewnętrznego 1------
przerwanie_int1:
push temp
in temp, SREG
push temp
sub rejestr, plus
out OCR0, rejestr
pop temp
out SREG, temp
pop temp
reti
;------obsługa przerwania zewnętrznego 2------
przerwanie_int2:
push temp
in temp, SREG
push temp
inc pomocniczy
pop temp
out SREG, temp
pop temp
reti
.exit