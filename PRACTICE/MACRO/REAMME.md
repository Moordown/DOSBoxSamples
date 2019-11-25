# макрокоманды на этапе сборки

NAME macro ARGS
    ...
ENDM
ARGS = A1, A2, A3
ARGS = A1=0, A2, A3=10

# константы уровня сборки

## Все что внутри скобок, ассемблер не интерпретирует
x equ <123 450>

buffed db x

z = 1 + 2
z = z + 1

# foreach
NAME macro ARGS
    IRPQ x, <ARGS>
        ...
    ENDM
ENDM

# метки для прыжка внутри макроса
local label 

# file function

3Dh, 3Eh

07с0 - запуск кода биосом

