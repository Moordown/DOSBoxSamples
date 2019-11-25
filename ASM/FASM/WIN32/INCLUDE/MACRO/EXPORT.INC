
; macroinstruction for making export section

macro export dllname,[label,string]	; strings must be sorted
 { common
    local module,addresses,names,ordinal,count
    count = 0
   forward
    count = count+1
   common
    dd 0,0,0,rva module,1
    dd count,count,rva addresses,rva names,rva ordinal
    addresses:
   forward
    dd rva label
   common
    names:
   forward
    local name
    dd rva name
   common
    ordinal: count = 0
   forward
    dw count
    count = count+1
   common
    module db dllname,0
   forward
    name db string,0 }
