
.286 
.model small
.stack 100h
.data
.code


FILL:
	fill_color EQU ss:[bp+4]
	edge_color EQU ss:[bp+6]
	x EQU ss:[bp+8]
	y EQU ss:[bp+10]

	push bp
	mov bp, sp



	mov sp, bp
	pop bp
	ret 8

absolute:
	x EQU ss:[bp+4]
	push bp
	mov bp, sp

	mov ax, x
	mov bx, 0
	sub ax, bx
	jl negative

	positive:
	mov ax, x
	mov sp, bp
	pop bp
	ret 2
	negative:
	mov ax, x
	neg ax
	mov sp, bp
	pop bp
	ret 2



;; finds the min value between 2 and returns it in ax
min:
	x EQU ss:[bp+4]
	y EQU ss:[bp+6]

	push bp
	mov bp, sp

	mov ax, x
	mov bx, y

	cmp ax, bx
	jge min_isY

	min_isX:
	mov ax, x
	mov sp, bp
	pop bp
	ret 4

	min_isY:
	mov ax, y
	mov sp, bp
	pop bp
	ret 4


callh:
mov ax, x2
mov bx, y1
mov cx, x1
mov dx, color
push ax
push bx
push cx
push dx
call  drawLine_h
mov sp, bp
pop bp
ret 10

; check if we have a special case of a horizontal or vertical line
drawLine:
color EQU ss:[bp+4]
x1 EQU ss:[bp+6]
y1 EQU ss:[bp+8]
x2 EQU ss:[bp+10]
y2 EQU ss:[bp+12]

push bp
mov bp, sp

deltaX equ ss:[bp - 2]
deltaY equ ss:[bp - 4]
slope equ ss:[bp - 6]
y0 equ ss:[bp-8]
y equ ss:[bp-10]
x equ ss:[bp-12]
minXY equ ss:[bp-14]
upX equ ss:[bp-16]
upY equ ss:[bp-18]
absX equ ss:[bp-20]
absY equ ss:[bp-22]
sub sp, 22


mov bx, x2
mov ax, y2
mov cx, x1
mov dx, y1
sub bx, cx	                ; BX = X2 -X1

mov deltaX, bx
jnz no_callv
callv:
mov ax, y2
mov bx, y1
mov cx, x1
mov dx, color
push ax
push bx
push cx
push dx
call drawLine_v
mov sp, bp
pop bp
ret 10
no_callv:

sub ax, dx
; sub dx, ax                  ; AX = Y2 -Y1
mov deltaY, ax
jz callh

jmp myLoop

myLoop:
mov bx, deltaX

push bx
call absolute
mov absX, ax

mov bx, deltaY

push bx
call absolute
mov absY, ax

mov ax, absX
mov bx, absY
push ax
push bx
call min
mov minXY, ax

mov dx, 0
mov ax, deltaX
cwd
mov bx, minXY
idiv bx
mov upX, ax

mov dx, 0
mov ax, deltaY
cwd
mov bx, minXY
idiv bx
mov upY, ax

mov cx, minXY
mov ax, x1
mov bx, y1

mov x, ax
mov y, bx

loopstart:

   push bx
   push ax
   push color
   call drawPixel

	mov ax, x
	mov bx, upX
	add ax, bx
	mov x, ax

	mov ax, y
	mov bx, upY

	add ax, bx
	mov y, ax

	mov ax, x
	mov bx, y

   dec cx          
   jnz loopstart
   exit:
	mov sp, bp
	pop bp
	ret 10



; draw a single pixel specific to Mode 13h (320x200 with 1 byte per color)
drawPixel:
	color EQU ss:[bp+4]
	x1 EQU ss:[bp+6]
	y1 EQU ss:[bp+8]

	push	bp
	mov	bp, sp

	push	bx
	push	cx
	push	dx
	push	es

	; set ES as segment of graphics frame buffer
	mov	ax, 0A000h
	mov	es, ax


	; BX = ( y1 * 320 ) + x1
	mov	bx, x1
	mov	cx, 320
	xor	dx, dx
	mov	ax, y1
	imul	cx
	add	bx, ax

	; DX = color
	mov	dx, color

	; plot the pixel in the graphics frame buffer
	mov	BYTE PTR es:[bx], dl

	pop	es
	pop	dx
	pop	cx
	pop	bx

	pop	bp

	ret	6
	

; draw a horizontal line
drawLine_h:
	color EQU ss:[bp+4]
	x1 EQU ss:[bp+6]
	y1 EQU ss:[bp+8]
	X2 EQU ss:[bp+10]

	push bp
	mov bp, sp

	push    bx
	push    cx

	; BX keeps track of the X coordinate
	mov	bx, x1

	; CX = number of pixels to draw
	mov	cx, x2
	sub	cx, bx
	inc	cx
	dlh_loop:
		push	y1
		push	bx
		push	color
		call	drawPixel
		add	bx, 1
		loopw	dlh_loop
	dlh_end:

	pop     cx
	pop     bx

	pop bp

	ret 8

; draw a vertical line
drawLine_v:
	color EQU ss:[bp+4]
	x1 EQU ss:[bp+6]
	y1 EQU ss:[bp+8]
	y2 EQU ss:[bp+10]

	push bp
	mov bp, sp

	push    bx
	push    cx

	; BX keeps track of the Y coordinate
	mov	bx, y1

	; CX = number of pixels to draw
	mov	cx, y2
	sub	cx, bx
	inc	cx
	dlv_loop:
		push	bx
		push	x1
		push	color
		call	drawPixel
		add	bx, 1
		loopw	dlv_loop
	dlv_end:

	pop     cx
	pop     bx

	pop bp

	ret 8

start:
	; initialize data segment
	mov ax, @data
	mov ds, ax

	; set video mode - 320x200 256-color mode
	mov ax, 4F02h
	mov bx, 13h
	int 10h

	; This draws a triangle as request as part of part 1 of the Lab6
	; Uses the drawline function
	; This uses the exact same functions and algorithm as in my Lab5.
	; Everything works the same as in Lab5.
	; Basically this just draws 3 different lines that form a triangle.

	; Draws a pink line horizontally
	push WORD PTR 110
	push WORD PTR 260
	push WORD PTR 110
	push WORD PTR 60
	push 0005h
	call drawLine
			
	; Draws a dark blue diagonal (going upwards) line 
	push WORD PTR 10
	push WORD PTR 160
	push WORD PTR 110
	push WORD PTR 60
	push 0001h
	call drawLine

	; Draws a blue-purple ish diagonal (going downwards) line.
	push WORD PTR 110
	push WORD PTR 260
	push WORD PTR 10
	push WORD PTR 160
	push 0009h
	call drawLine

	; prompt for a key
	mov ah, 0
	int 16h

	; switch back to text mode
	mov ax, 4f02h
	mov bx, 3
	int 10h

	mov ax, 4C00h
	int 21h

END start
