title Proyecto Final de EyPC
.286
RetardoMacro macro tiempo
  pusha
  push tiempo
  call generarRetardoFacil
  popa
endm
ImprimirCadenaMacro macro variable
  pusha
  mov dx,offset variable
  mov ah, 09h
  int 21h
  popa
endm

ValorDelTiempoEnRegistros macro
  mov ah,2ch
  int 21h
endm
UbicaCursorMacro macro columna,renglon
  pusha
  push columna
  push renglon
  call ubicaCursor
  popa
endm
EscribeCaracterMacro macro caracter, atributo,cantidadCaracteres
  pusha
  push cantidadCaracteres
  push atributo
  push caracter
  call escribeCaracter
  popa
endm
EscribirMarcoMacro macro columna,renglon,anchoMarco,altoMarco
  pusha
  push columna
  push renglon
  push anchoMarco
  push altoMarco
  call escribirMarco
  popa
endm
ImprimirTextoMacro macro col, ren, numero
  pusha
  UbicaCursorMacro col, ren
  mov ah, 09h
  lea dx,mensaje
  int 21h
  mov ah, 02h
  mov dl, numero + 48
  int 21h
  popa
endm
ImprimirRelogMacro macro
  pusha
  call imprimirRelog
  popa
endm
.model small
.stack 256
.data
; Variables de estado
estadoActualAtributo dw 7; 0|000|0111
;------------------------------------
; Variables de Marco
columna dw 3
renglon dw 3
anchoMarco dw 72
altoMarco dw 11
esquinaSuperiorIzquierdaAscii dw 201
cantidadCaracteres dw 1
lineaAscii dw 205
verticalAscii dw 186
esquinaSuperiorDerechaAscii dw 187
esquinaInferiorIzquierdaAscii dw 200
esquinaInferiorDerechaAscii dw 188
;------------------------------------
; Variables de colores
azulAtributo dw 23; 0|001|0111
rojoAtributo dw 64; 0|100|0000
verdeAtributo dw 39; 0|010|0111
blancoAtributo dw 7; 0|000|0111
;------------------------------------
; Variables para hacer logs
mensaje db 'AQUI TOY ','$'
; Variables Relog
cadenaTiempo db 'HH:MM:SS:CS','$'
diez db 10
;------------------------------------
; Variables de Animacion
retardo dw 10
;------------------------------------
; Constantes
logitudTiempoNumeros equ 4 
plantillaParaHacerCast equ 3030h


.code
main proc
  mov ax,@data
  mov ds,ax
  RetardoMacro retardo
  jmp noAnimacion
  animacion:
    in al,60h
    cmp al,1fh
    je noAnimacion
    in al,60h
    cmp al,1
    je terminar2
    jmp seguirAnimacion
    terminar2:
      call clrscr
      mov ah,4ch
      mov al,00h
      int 21h
    seguirAnimacion:
      ImprimirTextoMacro 3,3,1
      ;Logica de la animacion
  jmp animacion
  noAnimacion:
    call clrscr
    EscribirMarcoMacro columna, renglon, anchoMarco, altoMarco
  estadoMarco:
    ImprimirRelogMacro
    in al,60h
    cmp al,1Eh
    je animacion
    ;-------------------
    in al,60h
    cmp al,30h
    je colorMarcoAzul
    ;-------------------
    in al,60h
    cmp al,2fh
    je colorMarcoVerde
    ;-------------------
    in al,60h
    cmp al,13h
    je colorMarcoRojo
    ;-------------------
    in al,60h
    cmp al,18h
    je colorMarcoBlanco
    ;-------------------
    in al,60h
    cmp al,1
    je terminarPrograma
    jmp estadoMarco
    colorMarcoAzul:
      ;No es necesario renderizar si el estado no cambia
      mov ax,azulAtributo
      cmp estadoActualAtributo, ax
      je estadoMarco
      mov estadoActualAtributo,ax
      jmp resolverEstado
    colorMarcoVerde:
      mov ax,verdeAtributo
      cmp estadoActualAtributo, ax
      je estadoMarco
      ; ImprimirTextoMacro 3,3,2
      mov estadoActualAtributo, ax
      jmp resolverEstado
    colorMarcoRojo:
      mov ax,rojoAtributo
      cmp estadoActualAtributo, ax
      je estadoMarco  
      ; ImprimirTextoMacro 3,3,3
      mov estadoActualAtributo, ax
      jmp resolverEstado
    colorMarcoBlanco:
      mov ax,blancoAtributo
      cmp estadoActualAtributo, ax
      je estadoMarco
      mov estadoActualAtributo, ax
      jmp resolverEstado
  resolverEstado:
    EscribirMarcoMacro columna, renglon, anchoMarco, altoMarco
    xor ax,ax
    jmp estadoMarco
  terminarPrograma:
  call clrscr
  mov ah,4ch
  mov al,00h
  int 21h
endp main

; Procedimiento para ubicar el cursor en una posición específica de la pantalla.
; Entradas:
;   - [bp+4]: Columna (dl) donde se desea ubicar el cursor.
;   - [bp+2]: Fila (dh) donde se desea ubicar el cursor.
; Salidas:
;   - Ninguna.
ubicaCursor proc
  mov bp, sp
  mov ah, 02h
  mov bh, 0
  mov dl, [bp+4]
  mov dh, [bp+2]
  int 10h
  ret 4
ubicaCursor endp
; Procedimiento que escribe un caracter en la pantalla.
; Parámetros:
;   - [bp+2]: Caracter a escribir (valor ASCII).
;   - [bp+4]: Atributo del caracter.
;   - [bp+6]: Numero de veces que se va a escribir el caracter.
; Retorna:
;   - Nada.
escribeCaracter proc
  mov bp, sp
  mov bh,0
  mov cx,[bp+6]
  mov ah, 09h
  mov al, [bp+2]
  mov bl, [bp+4]
  int 10h
  ret 6
escribeCaracter endp
; Procedimiento que genera un retardo fácil.
; Entradas: El valor del contador externo en [bp+2].
; Salidas: Ninguna.
generarRetardoFacil proc
  mov bp, sp
  mov cx, [bp+2] ; contador externo
  mov dx, cx ; contador interno
  ciclo1:
    ciclo2:
      dec dx
    jnz ciclo2
    dec cx
  jnz ciclo1
  ret 2
endp

; Procedimiento que escribe un marco en la pantalla de texto en modo gráfico.
; El marco consiste en una serie de caracteres ASCII que forman un borde alrededor de un área rectangular.
; Los parámetros esperados son:
;   - [bp+2]: cantidad de filas del marco
;   - [bp+4]: cantidad de columnas del marco
;   - [bp+6]: fila inicial del marco
;   - [bp+8]: columna inicial del marco
;   - estadoActualAtributo: atributo de los caracteres a escribir

escribirMarco proc
  mov bp,sp
  UbicaCursorMacro [bp+8],[bp+6]
  mov [cantidadCaracteres],1
  EscribeCaracterMacro esquinaSuperiorIzquierdaAscii, estadoActualAtributo, cantidadCaracteres
  mov ax,[bp+4]
  dec ax
  mov [cantidadCaracteres],ax
  mov ax,[bp+8]
  inc ax
  UbicaCursorMacro ax,[bp+6]
  EscribeCaracterMacro lineaAscii, estadoActualAtributo, cantidadCaracteres
  mov ax,[cantidadCaracteres]
  add ax,[bp+8]
  UbicaCursorMacro ax,[bp+6]
  mov [cantidadCaracteres],1
  EscribeCaracterMacro esquinaSuperiorDerechaAscii, estadoActualAtributo, cantidadCaracteres
  mov cx,[bp+2]
  dec cx
  mov bx,[bp+8]
  mov ax,[bp+8]
  bordeVertical:
    inc bx
    UbicaCursorMacro ax,bx
    EscribeCaracterMacro verticalAscii, estadoActualAtributo, cantidadCaracteres
    add ax,[bp+4]
    dec ax
    UbicaCursorMacro ax,bx
    EscribeCaracterMacro verticalAscii, estadoActualAtributo, cantidadCaracteres
    inc ax
    sub ax,[bp+4]
  loop bordeVertical
  UbicaCursorMacro [bp+8],bx
  mov [cantidadCaracteres],1
  EscribeCaracterMacro esquinaInferiorIzquierdaAscii, estadoActualAtributo, cantidadCaracteres
  mov ax,[bp+4]
  dec ax
  mov [cantidadCaracteres],ax
  mov ax,[bp+8]
  inc ax
  UbicaCursorMacro ax,bx
  EscribeCaracterMacro lineaAscii, estadoActualAtributo, cantidadCaracteres
  mov ax,[cantidadCaracteres]
  add ax,[bp+8]
  UbicaCursorMacro ax,bx
  mov [cantidadCaracteres],1
  EscribeCaracterMacro esquinaInferiorDerechaAscii, estadoActualAtributo, cantidadCaracteres
  ret 8
escribirMarco endp

obtenerTiempo proc
  ValorDelTiempoEnRegistros
  mov di,offset cadenaTiempo
  xor ax,ax
  mov al,ch
  div diez
  xor ax,plantillaParaHacerCast
  mov [di],ax
  xor ax,ax
  mov al,cl
  div diez
  xor ax,plantillaParaHacerCast
  mov [di+3],ax
  xor ax,ax
  mov al,dh
  div diez
  xor ax,plantillaParaHacerCast
  mov [di+6],ax
  xor ax,ax
  mov al,dl
  div diez
  xor ax,plantillaParaHacerCast
  mov [di+9],ax
  ret 
obtenerTiempo endp 
imprimirRelog proc
  mov dl,2
  xor ax,ax
  mov ax,[altoMarco]
  div dl
  xor ah,ah
  add ax,renglon
  mov cx,ax
  xor ax,ax
  mov ax,[anchoMarco]
  div dl
  xor ah,ah
  sub al,6
  add ax,columna
  UbicaCursorMacro ax,cx
  call obtenerTiempo
  ImprimirCadenaMacro cadenaTiempo 
  ret
imprimirRelog endp
; Procedimiento para limpiar la pantalla.
; Llama a la interrupción de BIOS 10h con AH=0Fh para obtener el modo de video actual,
; y luego llama nuevamente a la interrupción con AH=0 para limpiar la pantalla.
clrscr proc
  mov ah,0fh
  int 10h
  mov ah,0
  int 10h
  ret
clrscr endp



end main