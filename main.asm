;╔═══════════════════════════════════════════════════════════════════════════════════════════════════╗
;║ Autor: Aguilar Martinez Erick Yair                                                                ║
;║ Fecha: 2023-12-07                                                                                 ║
;║ Descripción: Proyecto final de la materia Estructura y Programación de Computadoras.              ║
;║ Versión del compilador/ensamblador:                                                               ║
;║ 	Turbo Assembler Version 4.1 Copyright (c) 1988, 1996 Borland International                       ║
;║ Modificaciones subsecuentes:                                                                      ║
;║ 	{-<fecha>:<descripccion>}                                                                        ║
;║ 	-2023-12-07:creacion                                                                             ║
;║                                                                                                   ║
;║ Comandos para ensamblado y enlazado:                                                              ║
;║   OPCINON 1: Ensamblado y enlazado paso a paso                                                    ║
;║   Ensamblado: tasm <ruta_archivo>/main.asm                                                        ║
;║   Enlazado: tlink <ruta_archivo>/main.obj                                                         ║
;║   Depuracion: td <ruta_archivo>/main.exe                                                          ║
;║   Ejecucion: <ruta_archivo>/main.exe                                                              ║
;║   OPCION 2: Uso de .bat                                                                           ║
;║   Ejecutar el archivo run.bat                                                                     ║
;║                                                                                                   ║
;╚═══════════════════════════════════════════════════════════════════════════════════════════════════╝
title Proyecto Final de EyPC
; La directiva `.286` en el código de ensamblador indica al 
; ensamblador que sólo se deben utilizar las instrucciones y
; los registros que están disponibles en el procesador Intel 80286
; y sus versiones anteriores. Esto significa que no se pueden
; utilizar las características específicas de los procesadores más recientes.
; Esta directiva es útil cuando se escribe código que debe
; ser compatible con una gama específica de procesadores.
.286
; Macro para generar un retardo
; Entrada: tiempo - el tiempo de retardo
; Salida: ninguna
RetardoMacro macro tiempo
  pusha
  push tiempo
  call generarRetardoFacil
  popa
endm
; ImprimirCadenaMacro macro
; Macro que imprime una cadena de caracteres en la consola.
; 
; Entradas:
;   - variable: dirección de memoria de la cadena a imprimir.
; 
; Salidas:
;   - Ninguna.
; 
; Efectos secundarios:
;   - Modifica los registros DX y AH.
;
ImprimirCadenaMacro macro variable
  pusha
  mov dx,offset variable
  mov ah, 09h
  int 21h
  popa
endm
; AdaptarCadenaMacro macro espacios
;   Descripción: Macro que adapta la cadena 
;   de relog para insertar espacios.
;   Entradas:
;     - espacios: cantidad de espacios que se desean insertar
;   Salidas: Ninguna.
;   Efectos secundarios: Modifica la variable global cadenaAdaptada.
AdaptarCadenaMacro macro espacios
  pusha
  push espacios
  call adapatarCadena
  popa
endm
; Macro que obtiene el valor del tiempo en los registros
; Entradas: Ninguna
; Salidas: El valor del tiempo en los registros dx y dx
ValorDelTiempoEnRegistros macro
  mov ah,2ch
  int 21h
endm
; Macro para establecer la posición del cursor en la pantalla
; Entrada: columna - número de columna (0-79)
;          renglon - número de fila (0-24)
UbicaCursorMacro macro columna,renglon
  pusha
  push columna
  push renglon
  call ubicaCursor
  popa
endm
; Macro que escribe un caracter en la pantalla con un atributo y una cantidad de caracteres especificada.
; 
; Parámetros:
; - caracter: El caracter a escribir en la pantalla.
; - atributo: El atributo del caracter a escribir.
; - cantidadCaracteres: La cantidad de caracteres a escribir.
; NOTA: EL CURSOR YA DEBE ESTAR POSICIONADO.
EscribeCaracterMacro macro caracter, atributo, cantidadCaracteres
  pusha
  push cantidadCaracteres
  push atributo
  push caracter
  call escribeCaracter
  popa
endm
; Macro para escribir un marco en la pantalla
; Parámetros:
;   - columna: posición de la columna donde se iniciará el marco
;   - renglon: posición del renglón donde se iniciará el marco
;   - anchoMarco: ancho del marco
;   - altoMarco: alto del marco
EscribirMarcoMacro macro columna,renglon,anchoMarco,altoMarco
  pusha
  push columna
  push renglon
  push anchoMarco
  push altoMarco
  call escribirMarco
  popa
endm
; Macro para imprimir el reloj
; Esta macro guarda los registros en la pila, llama a la función imprimirRelog y luego los restaura.
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
columna dw 4
renglon dw 4
anchoMarco dw 61
altoMarco dw 20
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
; Variables para hacer logs - Solo para pruebas
mensaje db 'AQUI TOY ','$'
; Variables Relog
cadenaTiempo db 'HH:MM:SS:CS','$'
diez db 10
;------------------------------------
; Variables de Animacion
paso dw 3
maximoEspaciado dw 11
caracterRelleno db ' '
caracterDosPuntos db ':'
cadenaAdaptada db 80 dup('#'),'$'
debeAnimar db 1
;------------------------------------
; Constantes
logitudTiempoNumeros equ 4 
plantillaParaHacerCast equ 3030h
maximaLongitudCadenaAdaptadaTiempo equ 80 

.code
main proc
  mov ax,@data
  mov ds,ax
  jmp noAnimacion
  saltarAnimacion:
    call generarAnimacion
  relogDesplegado:
    xor ax,ax
    mov ax,maximoEspaciado
    push ax
    call adapatarCadena
    UbicaCursorMacro 2,12
    ImprimirCadenaMacro cadenaAdaptada
    ; Caracter s
    in al,60h
    cmp al,1fh
    je noAnimacion
    ;-------------------
    ; ESC
    in al,60h
    cmp al,1
    je terminar2
    ;-------------------
    jmp relogDesplegado
    terminar2:
      call clrscr
      mov ah,4ch
      mov al,00h
      int 21h
  noAnimacion:
    call clrscr
    EscribirMarcoMacro columna, renglon, anchoMarco, altoMarco
  estadoMarco:
    ImprimirRelogMacro;Imprime y acutaliza el relog
    in al,60h
    cmp al,1Eh
    je saltarAnimacion
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

; Procedimiento: generarRetardoFacil
; Descripción: Genera un retardo utilizando dos ciclos anidados.
; Parámetros:
;   - [bp+2]: Contador externo (cx)
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

; Procedimiento obtenerTiempo
; Descripción: Este procedimiento obtiene el tiempo en formato de cadena de caracteres y lo guarda en la variable cadenaTiempo.
; Parámetros: Ninguno
; Retorno: Ninguno
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
; Procedimiento para imprimir el reloj en pantalla
; Entradas: Ninguna
; Salidas: Ninguna
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

; Procedimiento: adapatarCadena
; Descripción: Este procedimiento se encarga de adaptar una la cadena del relog,
; insertando espacios y caracteres de relleno según los parámetros especificados.
; Parámetros:
;   - [bp+2]: Cantidad de espacios que se desean insertar.
; Retorno:
;   - Ninguno
; Efectos secundarios:
;   - Modifica la variable global cadenaAdaptada.
adapatarCadena proc
  mov bp,sp
  call obtenerTiempo
  mov bx,[bp+2];cantidad de espacios
  mov si,offset cadenaTiempo
  mov di,offset cadenaAdaptada
  push di
  mov cx,maximaLongitudCadenaAdaptadaTiempo
  mov al,caracterRelleno
  limpiarCadena:
    mov [di],al
    inc di
  loop limpiarCadena
  pop di
  mov cx,3
  insertarEspacios:
    ;Escribir numeros
    push bx
    mov al,[si]
    mov [di],al
    inc si
    inc di
    mov al,[si]
    mov [di],al
    add si,2
    inc di
    cmp bx,0
    je noHayEspacios
    ;Escribir espacios
    push bx
    mov al,caracterRelleno
    escribirEspacios:
      mov [di],al
      inc di
      dec bx
    jnz escribirEspacios
    ;Escribir dos puntos
    mov al,caracterDosPuntos
    mov [di],al
    inc di
    ;-------------------
    pop bx
    mov al,caracterRelleno
    escribirEspacios2:
      mov [di],al
      inc di
      dec bx
    jnz escribirEspacios2
    jmp continuarCiclo
    noHayEspacios:
    mov al,caracterDosPuntos
    mov [di],al
    inc di
    continuarCiclo:
    pop bx
  loop insertarEspacios
  mov al,[si]
    mov [di],al
    inc si
    inc di
    mov al,[si]
    mov [di],al
  ret 2
adapatarCadena endp

; Genera una animación en la pantalla para la expansioón de la cadena del relog.
; El número máximo de espaciado entre fotogramas se encuentra en la variable maximoEspaciado.
; La variable bx se utiliza como contador para los fotogramas espacios a insertar.
; La macro UbicaCursorMacro se encarga de posicionar el cursor en la pantalla.
; La macro AdaptarCadenaMacro adapta la cadena en función del valor de bx.
; La macro ImprimirCadenaMacro imprime la cadena adaptada en la pantalla.
; La macro RetardoMacro introduce un retardo entre fotogramas.
; El ultimo fotograma no se limpia de la pantalla.
generarAnimacion proc
  mov cx,maximoEspaciado
  mov bx,0
  fotograma:
    cmp cx,1
    je ultimoFotograma
      call clrscr
    ultimoFotograma:
    UbicaCursorMacro 2,12
    AdaptarCadenaMacro bx
    ImprimirCadenaMacro cadenaAdaptada
    inc bx
    RetardoMacro paso
  loop fotograma
  ret
generarAnimacion endp
end main