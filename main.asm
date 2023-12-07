title proyecto final
.286
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
endm EscribirMarcoMacro
.model small
.stack 256
.data
columna dw 3
renglon dw 3
anchoMarco dw 70
altoMarco dw 10
cantidadCaracteres dw 1
lineaAscii dw 205
verticalAscii dw 186
esquinaSuperiorIzquierdaAscii dw 201
esquinaSuperiorDerechaAscii dw 187
esquinaInferiorIzquierdaAscii dw 200
esquinaInferiorDerechaAscii dw 188
cambioAtributo db 0
azulAtributo dw 23; 0|001|0111
rojoAtributo dw 64; 0|100|0000
verdeAtributo dw 39; 0|010|0111
blancoAtributo dw 7; 0|000|0111
estadoActualAtributo dw 7; 0|000|0111
.code
main proc
  mov ax,@data        ; Carga la dirección del segmento de datos en el registro AX
  mov ds,ax           ; Mueve el valor de AX al registro de segmento de datos (DS)
  call clrscr         ; Llama a la función clrscr para limpiar la pantalla
  EscribirMarcoMacro columna, renglon, anchoMarco, altoMarco ; Llama a la macro EscribirMarcoMacro con los parámetros especificados
  relog:
    in al,60h         ; Lee el valor del teclado en el registro AL
    cmp al, 'o'       ; Compara el valor leído con el carácter 'o'
    je casoO          ; Salta a la etiqueta casoO si son iguales
    cmp al, 's'       ; Compara el valor leído con el carácter 's'
    je casoS          ; Salta a la etiqueta casoS si son iguales
    cmp al, 41h       ; Compara el valor leído con el carácter 'b'
    je casoB          ; Salta a la etiqueta casoB si son iguales
    cmp al, 'v'       ; Compara el valor leído con el carácter 'v'
    je casoV          ; Salta a la etiqueta casoV si son iguales
    cmp al, 'r'       ; Compara el valor leído con el carácter 'r'
    je casoR          ; Salta a la etiqueta casoR si son iguales
    jmp fin           ; Salta a la etiqueta fin si no se cumple ninguna de las comparaciones anteriores
    casoO:
      mov ax,blancoAtributo          ; Mueve el valor de blancoAtributo al registro AX
      mov estadoActualAtributo,ax    ; Mueve el valor de AX al estadoActualAtributo
      mov cambioAtributo, 1          ; Mueve el valor 1 a cambioAtributo
      jmp fin                        ; Salta a la etiqueta fin
    casoS:
      jmp fin                        ; Salta a la etiqueta fin
    casoB:
      mov ax,azulAtributo            ; Mueve el valor de azulAtributo al registro AX
      mov estadoActualAtributo,ax    ; Mueve el valor de AX al estadoActualAtributo
      mov cambioAtributo, 1          ; Mueve el valor 1 a cambioAtributo
      jmp fin                        ; Salta a la etiqueta fin
    casoV:
      mov ax,verdeAtributo           ; Mueve el valor de verdeAtributo al registro AX
      mov estadoActualAtributo,ax    ; Mueve el valor de AX al estadoActualAtributo
      mov cambioAtributo, 1          ; Mueve el valor 1 a cambioAtributo
      jmp fin                        ; Salta a la etiqueta fin
    casoR:
      mov ax,rojoAtributo            ; Mueve el valor de rojoAtributo al registro AX
      mov estadoActualAtributo,ax    ; Mueve el valor de AX al estadoActualAtributo
      mov cambioAtributo, 1          ; Mueve el valor 1 a cambioAtributo
      jmp fin                        ; Salta a la etiqueta fin
    fin:
    cmp cambioAtributo, 1            ; Compara el valor de cambioAtributo con 1
    je pintarMarco                   ; Salta a la etiqueta pintarMarco si son iguales
    jmp finPintarMarco               ; Salta a la etiqueta finPintarMarco si no son iguales

    pintarMarco:
      EscribirMarcoMacro columna, renglon, anchoMarco, altoMarco ; Llama a la macro EscribirMarcoMacro con los parámetros especificados
      mov cambioAtributo, 0          ; Mueve el valor 0 a cambioAtributo
    finPintarMarco:
    in al,60h                       ; Lee el valor del teclado en el registro AL
    dec al                          ; Decrementa el valor de AL en 1
  jnz relog                         ; Salta a la etiqueta relog si el resultado de la comparación anterior no es cero
  mov ah,4ch                        ; Mueve el valor 4Ch al registro AH (función de terminación del programa)
  mov al,00h                        ; Mueve el valor 00h al registro AL (código de salida del programa)
  int 21h                           ; Llama a la interrupción 21h para terminar el programa
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