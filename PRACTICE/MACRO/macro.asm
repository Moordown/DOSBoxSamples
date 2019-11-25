pushes macro args
    irq arg, <args>
        push arg
    endm
endm

pops macro args
    irq arg, <args>
        pop arg
    endm
endm