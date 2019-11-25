
macro ccall proc,[arg]
 { common local size
   size = 0
   reverse
   push arg
   size = size+4
   common
   call proc
   add esp,size }
