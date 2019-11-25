procedure bigchars
parameter startx,starty,instring

set blink off

if startx > 20
	return
endif

curenty = starty
curlet = 1

if "MONO" $ upper(sys(2006))
	colorvar = "n/n"
else
	colorvar = "n/b"
endif

do while curlet <= len(instring) and curenty < 89
	do case
		case substr(instring,curlet,1) = " "
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 3,curenty + 5 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 6
		case substr(instring,curlet,1) = "t" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 5 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 6
			@ 0,0 say " ÛÛ"
			@ 0,3 say "Ü" color (colorvar)
			
			@ 1,0 say "ßÛÛ"
			@ 1,3 say "ß" color w+/n
			@ 1,4 say "Ü" color (colorvar)
			
			@ 2,1 say "ÛÛ " color w+/n

			@ 3,0 say " ßÛ"
			@ 3,3 say "Ü" color w+/n
			
			@ 4,0 say "   ßß" color (colorvar)
		case substr(instring,curlet,1) = "s" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 5 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 1,0 say "ÜÛ"
			@ 1,2 say "ß" color w+/n
			@ 1,3 say "ÛÜ"
			
			@ 2,0 say " ß"
			@ 2,2 say "ßÛÜ" color w+/n
			@ 2,5 say "ß" color (colorvar)

			@ 3,0 say "ßÛÜÛ"
			@ 3,4 say "ß " color w+/n
			
			@ 4,0 say "  ßßß" color (colorvar)
		case substr(instring,curlet,1) = "e" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 5 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 1,0 say "ÜÛ"
			@ 1,2 say "ßÛ" color w+/n
			@ 1,4 say "Ü"

			@ 2,0 say "ÛÛßßß " color w+/n
			
			@ 3,0 say "ßÛ"
			@ 3,2 say "ÜÛß" color w+/n
			@ 3,5 say "Ü" color (colorvar)
			
			@ 4,0 say "  ßßß" color (colorvar)
		case substr(instring,curlet,1) = "r" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 5 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 6
			@ 1,0 say "ÛÜÛ"
			@ 1,3 say "ß" color w+/n
			@ 1,4 say "Ü" color (colorvar)
			
			@ 2,0 say "ÛÛ " color w+/n
			@ 2,3 say "ß" color (colorvar)
			
			@ 3,0 say "ÛÛ " color w+/n
			
			@ 4,0 say " ßß" color (colorvar)
		case substr(instring,curlet,1) = "o" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 5 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 1,0 say "ÜÛ"
			@ 1,2 say "ßÛ" color w+/n
			@ 1,4 say "Ü"

			@ 2,0 say "ÛÛ ÛÛ " color w+/n
			
			@ 3,0 say "ßÛ"
			@ 3,2 say "ÜÛß " color w+/n
			
			@ 4,0 say "  ßßß" color (colorvar)
		case substr(instring,curlet,1) = "a" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 8
			@ 1,0 say "Üß"
			@ 1,2 say "ßÛ" color w+/n
			@ 1,4 say "Ü"

			@ 2,0 say "ÜÛ"
			@ 2,2 say "ßÛÛ " color w+/n
			
			@ 3,0 say "ßÛ"
			@ 3,2 say "ÜÛÛÜ" color w+/n
			
			@ 4,0 say "  ßß ßß" color (colorvar)
		case substr(instring,curlet,1) = "i" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 3 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 4
			@ 0,0 say "ß"
			@ 0,1 say "ß" color w+/n
			@ 0,2 say "Ü" color (colorvar)
			
			@ 1,0 say "ÛÛ"
			@ 1,2 say "Ü" color (colorvar)
			
			@ 2,0 say "ÛÛ " color w+/n

			@ 3,0 say "ÛÛ " color w+/n
			
			@ 4,0 say " ßß" color (colorvar)
		case substr(instring,curlet,1) = "n" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 5 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 1,0 say "ÛÜ"
			@ 1,2 say "ßÛ" color w+/n
			@ 1,4 say "Ü"

			@ 2,0 say "ÛÛ ÛÛ " color w+/n
			
			@ 3,0 say "ÛÛ ÛÛ " color w+/n

			@ 4,0 say " ßß ßß" color (colorvar)
		case substr(instring,curlet,1) = "m" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 8 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 10
			@ 1,0 say "ÛÜ"
			@ 1,2 say "ßÛ" color w+/n
			@ 1,4 say "Ü"
			@ 1,5 say "ßÛ" color w+/n
			@ 1,7 say "Ü"

			@ 2,0 say "ÛÛ ÛÛ ÛÛ " color w+/n
			
			@ 3,0 say "ÛÛ ÛÛ ÛÛ " color w+/n

			@ 4,0 say " ßß ßß ßß" color (colorvar)
		case substr(instring,curlet,1) = "f" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 0,0 say " ÜÛ"
			@ 0,3 say "ßß" color w+/n
			@ 0,5 say "Ü" color (colorvar)
			
			@ 1,0 say "ßÛÛ"
			@ 1,3 say "ß" color w+/n
			@ 1,4 say "Ü" color (colorvar)
			
			@ 2,1 say "ÛÛ " color w+/n

			@ 3,1 say "ÛÛ " color w+/n
			
			@ 4,0 say "  ßß" color (colorvar)
		case substr(instring,curlet,1) = "l" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 3 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 4
			@ 0,0 say "ÛÛ"
			@ 0,2 say "Ü" color (colorvar)
			
			@ 1,0 say "ÛÛ " color w+/n
			
			@ 2,0 say "ÛÛ " color w+/n

			@ 3,0 say "ÛÛ " color w+/n
			
			@ 4,0 say " ßß" color (colorvar)
		case substr(instring,curlet,1) = "k" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 7 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 8
			@ 0,0 say "ÛÛ"
			@ 0,2 say "Ü" color (colorvar)
			
			@ 1,0 say "ÛÛÜÛß" color w+/n
			@ 1,5 say "Ü" color (colorvar)
			
			@ 2,0 say "ÛÛÛÜ" color w+/n
			@ 2,4 say "ß" color (colorvar)

			@ 3,0 say "ÛÛ " color w+/n
			@ 3,3 say "ßÛÜ"
			
			@ 4,0 say " ßß  ßß" color (colorvar)
		case substr(instring,curlet,1) = "u" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 1,0 say "ÛÛ"
			@ 1,2 say "Ü" color (colorvar)
			@ 1,3 say "ÛÛ"
			@ 1,5 say "Ü" color (colorvar)

			@ 2,0 say "ÛÛ ÛÛ " color w+/n
			
			@ 3,0 say "ßÛ"
			@ 3,2 say "Ü" color w+/n
			@ 3,3 say "ß"
			@ 3,4 say "Û " color w+/n
			
			@ 4,0 say "  ßß ß" color (colorvar)
		case substr(instring,curlet,1) = "b" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 0,0 say "ÛÛ"
			@ 0,2 say "Ü" color (colorvar)

			@ 1,0 say "ÛÛßÛ" color w+/n
			@ 1,4 say "Ü"
			
			@ 2,0 say "ÛÛ " color w+/n
			@ 2,3 say " Û"
			@ 2,5 say "Û" color (colorvar)
				
			@ 3,0 say "ÛÛÜÛß " color w+/n

			@ 4,0 say " ßßßß" color (colorvar)
		case substr(instring,curlet,1) = "c" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 5 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 6
			@ 1,0 say "ÜÛ"
			@ 1,2 say "ßÛ" color w+/n
			@ 1,4 say "Ü" color (colorvar)
			
			@ 2,0 say "ÛÛ " color w+/n
			@ 2,3 say " ß" color (colorvar)
			
			@ 3,0 say "ßÛ"
			@ 3,2 say "ÜÛ" color w+/n
			@ 3,4 say "Ü" color (colorvar)

			@ 4,0 say "  ßßß" color (colorvar)
		case substr(instring,curlet,1) = "d" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 5 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 0,0 say "   ÛÛ"
			@ 0,5 say "Ü" color (colorvar)
			
			@ 1,0 say "ÜÛ"
			@ 1,2 say "ßÛÛ " color w+/n
			
			@ 2,0 say "Û " color w+/n
			@ 2,2 say "ß" color (colorvar)
			@ 2,3 say "ÛÛ " color w+/n
			
			@ 3,0 say "ßÛÜÛÛ"
			@ 3,5 say "Û" color (colorvar)

			@ 4,0 say "  ßßßß" color (colorvar)
		case substr(instring,curlet,1) = "q" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 5 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 1,0 say "ÜÛ"
			@ 1,2 say "ß" color w+/n
			@ 1,3 say "ÜÛ"
			@ 1,5 say "Ü" color (colorvar)
			
			@ 2,0 say "Û " color w+/n
			@ 2,2 say "ß" color (colorvar)
			@ 2,3 say "ÛÛ " color w+/n
			
			@ 3,0 say "ßÛÜÛÛ"
			@ 3,5 say "Û" color (colorvar)

			@ 4,0 say "  ß" color (colorvar)
			@ 4,3 say "ÛÛ " color w+/n

			@ 5,0 say "    ßß" color (colorvar)
			
		case substr(instring,curlet,1) = "g"  
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 1,0 say "ÜÛ"
			@ 1,2 say "ß" color w+/n
			@ 1,3 say "ÜÛ"
			@ 1,5 say "Ü" color (colorvar)

			@ 2,0 say "Û " color w+/n
			@ 2,2 say "ß" color (colorvar)
			@ 2,3 say "ÛÛ " color w+/n
			
			@ 3,0 say "ßÛÜÛÛ"
			@ 3,5 say "Û" color (colorvar)
			
			@ 4,0 say " Ü"
			@ 4,2 say "Ü" color w+/n
			@ 4,3 say "Û"
			@ 4,4 say "ß " color w+/n
			
			@ 5,0 say "  ßßß" color (colorvar)
		case substr(instring,curlet,1) = "h" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 5 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 0,0 say "ÛÛ" color w+/n
			@ 0,2 say "Ü" color (colorvar)

			@ 1,0 say "ÛÛßÛ" color w+/n
			@ 1,4 say "Ü"
			
			@ 2,0 say "ÛÛ ÛÛ " color w+/n
			
			@ 3,0 say "ÛÛ ÛÛ " color w+/n

			@ 4,0 say " ßß ßß" color (colorvar)
		case substr(instring,curlet,1) = "j" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 3 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 5
			@ 0,0 say " ß"
			@ 0,2 say "ß" color w+/n
			@ 0,3 say "Ü" color (colorvar)
			
			@ 1,0 say " ÛÛ"
			@ 1,3 say "Ü" color (colorvar)
			
			@ 2,1 say "ÛÛ " color w+/n

			@ 3,1 say "ÛÛ " color w+/n
			
			@ 4,0 say "ß"
			@ 4,1 say "ß " color w+/n
			@ 4,3 say "ß" color (colorvar)
		case substr(instring,curlet,1) = "p" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 1,0 say "ÛÜßÛÜ"

			@ 2,0 say "ÛÛ " color w+/n
			@ 2,3 say " Û"
			@ 2,5 say "Û" color (colorvar)
			
			@ 3,0 say "ÛÛÜÛß " color w+/n
			
			@ 4,0 say "ÛÛ " color w+/n
			@ 4,3 say "ßß" color (colorvar)
			
			@ 5,0 say " ßß" color (colorvar)
		case substr(instring,curlet,1) = "w" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 8 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 9
			@ 1,0 say "ÛÛ"
			@ 1,2 say "Ü" color (colorvar)
			@ 1,3 say "Û"
			@ 1,4 say "Ü" color (colorvar)
			@ 1,5 say "ÛÛ"
			@ 1,7 say "Ü" color (colorvar)

			@ 2,0 say "ßÛ"
			@ 2,2 say "ÜÛÜÛß " color w+/n
			
			@ 3,1 say "ÛÛ ÛÛ " color w+/n
			
			@ 4,0 say "  ßß ßß" color (colorvar)
		case substr(instring,curlet,1) = "x" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 7 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 8
			@ 1,0 say "ßÛÜÜÛ"
			@ 1,5 say "ß" color w+/n
			@ 1,6 say "Ü" color (colorvar)
			
			@ 2,0 say " ÜÛÛ"
			@ 2,4 say "Ü" color w+/n
			@ 2,5 say "ß" color (colorvar)
			
			@ 3,0 say "ÛÛ " color w+/n
			@ 3,3 say "ß" color (colorvar)
			@ 3,4 say "ÛÛ" color w+/n
			@ 3,6 say "Ü" color (colorvar)
			
			@ 4,0 say " ßß  ßß" color (colorvar)
		case substr(instring,curlet,1) = "y" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 1,0 say "ÛÛ"
			@ 1,2 say "Ü" color (colorvar)
			@ 1,3 say "ÛÛ"
			@ 1,5 say "Ü" color (colorvar)

			@ 2,0 say "ÛÛ ÛÛ " color w+/n
			
			@ 3,0 say " ßÛÛ"
			@ 3,4 say "ß " color w+/n
			
			@ 4,0 say " ÜÛ"
			@ 4,3 say "ß " color w+/n

			@ 5,0 say "  ßß" color (colorvar)
		case substr(instring,curlet,1) = "v" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 1,0 say "ÛÛ"
			@ 1,2 say "Ü" color (colorvar)
			@ 1,3 say "ÛÛ"
			@ 1,5 say "Ü" color (colorvar)

			@ 2,0 say "ß"
			@ 2,1 say "Û Ûß " color w+/n
			
			@ 3,0 say " ßÛ"
			@ 3,3 say "ß " color w+/n

			@ 4,0 say "   ß" color (colorvar)
		case substr(instring,curlet,1) = "/" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 4 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 6
			@ 0,0 say "   Û"
			@ 0,4 say "Ü" color (colorvar)

			@ 1,0 say "  Û"
			@ 1,3 say "Üß" color (colorvar)
			
			@ 2,0 say " Û"
			@ 2,2 say "Üß" color (colorvar)
			
			@ 3,0 say "Û"
			@ 3,1 say "Üß" color (colorvar)

			@ 4,0 say " ß" color (colorvar)
		case substr(instring,curlet,1) = "z" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 1,0 say "ß"
			@ 1,1 say "ßßÛÛ" color w+/n
			@ 1,5 say "Ü" color (colorvar)
		
			@ 2,0 say " ÜÛ"
			@ 2,3 say "ß " color w+/n
			@ 2,5 say "ß" color (colorvar)
			
			@ 3,0 say "ÛÛÜÜ" color w+/n
			@ 3,4 say "Ü"
			
			@ 4,0 say " ßßßßß" color (colorvar)
		case substr(instring,curlet,1) = "|"
			startx = startx + 6
			curenty = starty
		case substr(instring,curlet,1) = "A" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 7 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 9
			@ 0,2 say "ÛÛÛ" color w+/n
			@ 0,5 say "Ü" color (colorvar)

			@ 1,1 say "ÛÛ ÛÛ" color w+/n
			@ 1,6 say "Ü" color (colorvar)

			@ 2,0 say "Ü"
			@ 2,1 say "ÛÛÜÛÛÜ" color w+/n

			@ 3,0 say "ÛÛ " color w+/n
			@ 3,3 say "ßß" color (colorvar)
			@ 3,5 say "ÛÛ " color w+/n
			
			@ 4,0 say " ßß   ßß" color (colorvar)
		case substr(instring,curlet,1) = "B" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 8
			@ 0,0 say "ÛÛßß" color w+/n
			@ 0,4 say "ÛÜ"

			@ 1,0 say "ÛÛÜ" color w+/n
			@ 1,3 say "ÜÛ"
			@ 1,5 say "ß " color w+/n
			
			@ 2,0 say "ÛÛ " color w+/n
			@ 2,3 say "ß"  color (colorvar)
			@ 2,4 say "ÛÛ" color w+/n
			@ 2,6 say "Ü"  color (colorvar)

			@ 3,0 say "ÛÛÜ" color w+/n
			@ 3,3 say "ÜÛ"
			@ 3,5 say "ß " color w+/n
			
			@ 4,0 say " ßßßßß" color (colorvar)
		case substr(instring,curlet,1) = "C" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 8 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 9
			@ 0,0 say " ÜÛ"
			@ 0,3 say "ßßÛ" color w+/n
			@ 0,6 say "Ü"
			
			@ 1,0 say "ÛÛ " color w+/n
			@ 1,3 say "ß" color (colorvar)
			@ 1,4 say "  ß"
			@ 1,7 say "Û" color (colorvar)

			@ 2,0 say "ÛÛ " color w+/n
			@ 2,3 say "   Ü "
			
			@ 3,0 say " ßÛÜÜÛ"
			@ 3,6 say "ß " color w+/n
			
			@ 4,0 say "   ßßßß" color (colorvar)
		case substr(instring,curlet,1) = "D" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 8
			@ 0,0 say "ÛÛßÛ" color w+/n
			@ 0,4 say "Ü"
			
			@ 1,0 say "ÛÛ " color w+/n
			@ 1,3 say " ÛÛ"
			@ 1,6 say "Ü" color (colorvar)

			@ 2,0 say "ÛÛ " color w+/n
			@ 2,3 say " ÛÛ"
			@ 2,6 say "Û" color (colorvar)
			
			@ 3,0 say "ÛÛÜÛß " color w+/n
			@ 3,6 say "ß" color (colorvar)
			
			@ 4,0 say " ßßßß" color (colorvar)
		case substr(instring,curlet,1) = "E" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 0,0 say "ÛÛßßß" color w+/n
			@ 0,5 say "Ü" color (colorvar)

			@ 1,0 say "ÛÛÜ" color w+/n
			@ 1,3 say "ÜÜ"
			
			@ 2,0 say "ÛÛ " color w+/n
			@ 2,3 say "ßßß" color (colorvar)
			
			@ 3,0 say "ÛÛÜ" color w+/n
			@ 3,3 say "ÜÜ"
			
			@ 4,0 say " ßßßßß" color (colorvar)
		case substr(instring,curlet,1) = "F" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 0,0 say "ÛÛßßß" color w+/n
			@ 0,5 say "Ü" color (colorvar)

			@ 1,0 say "ÛÛÜ" color w+/n
			@ 1,3 say "Ü"
			
			@ 2,0 say "ÛÛ " color w+/n
			@ 2,3 say "ßß" color (colorvar)
			
			@ 3,0 say "ÛÛ " color w+/n
			
			@ 4,0 say " ßß" color (colorvar)
		case substr(instring,curlet,1) = "G" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 8 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 9
			@ 0,0 say " ÜÛ"
			@ 0,3 say "ßßÛ" color w+/n
			@ 0,6 say "Ü"
			
			@ 1,0 say "ÛÛ " color w+/n
			@ 1,3 say "ß" color (colorvar)
			@ 1,4 say "  ß"
			@ 1,7 say "Û" color (colorvar)

			@ 2,0 say "ÛÛ " color w+/n
			@ 2,3 say " ßÛÛ"
			@ 2,7 say "Ü" color (colorvar)
			
			@ 3,0 say " ßÛÜÜÛ"
			@ 3,6 say "ß " color w+/n
			
			@ 4,0 say "   ßßßß" color (colorvar)
		case substr(instring,curlet,1) = "H" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 7 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 8
			@ 0,0 say "ÛÛ"
			@ 0,2 say "Ü " color (colorvar)
			@ 0,4 say "ÛÛ"
			@ 0,6 say "Ü " color (colorvar)

			@ 1,0 say "ÛÛÜ" color w+/n
			@ 1,3 say "ÜÛÛ"
			@ 1,6 say "Û" color (colorvar)
			
			@ 2,0 say "ÛÛ " color w+/n
			@ 2,3 say "ß" color (colorvar)
			@ 2,4 say "ÛÛ " color w+/n
			
			@ 3,0 say "ÛÛ " color w+/n
			@ 3,3 say " "
			@ 3,4 say "ÛÛ " color w+/n
			
			@ 4,0 say " ßß  ßß" color (colorvar)
		case substr(instring,curlet,1) = "I" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 3 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 4
			@ 0,0 say "ÛÛ"
			@ 0,2 say "Ü" color (colorvar)
			
			@ 1,0 say "ÛÛ " color w+/n
			
			@ 2,0 say "ÛÛ " color w+/n

			@ 3,0 say "ÛÛ " color w+/n
			
			@ 4,0 say " ßß" color (colorvar)
		case substr(instring,curlet,1) = "J" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 0,0 say "   ÛÛ"
			@ 0,5 say "Ü" color (colorvar)
			
			@ 1,3 say "ÛÛ " color w+/n
			
			@ 2,3 say "ÛÛ " color w+/n
			
			@ 3,0 say "ßÛÜÛ"
			@ 3,4 say "ß " color w+/n
			
			@ 4,0 say "  ßßß" color (colorvar)
		case substr(instring,curlet,1) = "K" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 7 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 9
			@ 0,0 say "ÛÛ"
			@ 0,2 say "Ü" color (colorvar)
			@ 0,3 say "ÜÛ"
			@ 0,5 say "ß" color w+/n
			@ 0,6 say "Ü" color (colorvar)

			@ 1,0 say "ÛÛÛß " color w+/n
			@ 1,5 say "ß" color (colorvar)
			
			@ 2,0 say "ÛÛßÛ" color w+/n
			@ 2,4 say "Ü"
			
			@ 3,0 say "ÛÛ " color w+/n
			@ 3,3 say " ßÛÜ"
			
			@ 4,0 say " ßß   ßß" color (colorvar)
		case substr(instring,curlet,1) = "L" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 7
			@ 0,0 say "ÛÛ"
			@ 0,2 say "Ü" color (colorvar)
			
			@ 1,0 say "ÛÛ " color w+/n
			
			@ 2,0 say "ÛÛ " color w+/n
			
			@ 3,0 say "ÛÛÜ" color w+/n
			@ 3,3 say "ÜÜ"
			
			@ 4,0 say " ßßßßß" color (colorvar)
		case substr(instring,curlet,1) = "M" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 10 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 11
			@ 0,0 say "ÛÛÜ   ÜÛÛ"
			@ 0,9 say "Ü" color (colorvar)

			@ 1,0 say "ÛÛÛÜ" color w+/n
			@ 1,4 say " ÜÛÛÛ"
			@ 1,9 say "Û" color (colorvar)

			
			@ 2,0 say "ÛÛ ÛÜÛ ÛÛ " color w+/n

			@ 3,0 say "ÛÛ " color w+/n
			@ 3,3 say " Û"
			@ 3,5 say "Ûß" color (colorvar)
			@ 3,7 say "ÛÛ " color w+/n

			@ 4,0 say " ßß  ß  ßß" color (colorvar)
		case substr(instring,curlet,1) = "N" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 8 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 9
			@ 0,0 say "ÛÛÜ  ÛÛ"
			@ 0,7  say "Ü" color (colorvar)

			@ 1,0 say "ÛÛßÜ" color w+/n
			@ 1,4 say " ÛÛ"
			@ 1,7 say "Û" color (colorvar)
			
			@ 2,0 say "ÛÛ " color w+/n
			@ 2,3 say "ß"
			@ 2,4 say "ÜÛÛ " color w+/n
			
			@ 3,0 say "ÛÛ " color w+/n
			@ 3,3 say " ßÛÛ"
			@ 3,7 say " " color w+/n
			
			@ 4,0 say " ßß   ßß" color (colorvar)
			
		case substr(instring,curlet,1) = "O" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 7,curenty + 7 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 9
			@ 0,0 say " ÜÛ"
			@ 0,3 say "ß" color w+/n
			@ 0,4 say "ÛÜ"
			
			@ 1,0 say "ÛÛ " color w+/n
			@ 1,3 say "ß " color (colorvar)
			@ 1,5 say "ÛÛ"
			@ 1,7 say "Ü" color (colorvar)
			
			@ 2,0 say "ÛÛ " color w+/n
			@ 2,3 say "  ÛÛ"
			@ 2,7 say "Û" color (colorvar)

			@ 3,0 say " ßÛÜÛ"
			@ 3,5 say "ß " color w+/n
			@ 3,7 say "ß" color (colorvar)
						
			@ 4,0 say "   ßßß" color (colorvar)
		case substr(instring,curlet,1) = "P" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 8
			@ 0,0 say "ÛÛß" color w+/n
			@ 0,3 say "ßÛÜ"

			@ 1,0 say "ÛÛ " color w+/n
			@ 1,3 say " ÛÛ"
			@ 1,6 say "Û" color (colorvar)
			
			@ 2,0 say "ÛÛßßß " color w+/n
			@ 2,6 say "ß" color (colorvar)
			
			@ 3,0 say "ÛÛ " color w+/n
			
			@ 4,0 say " ßß" color (colorvar)
		case substr(instring,curlet,1) = "Q" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 8 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 9
			@ 0,0 say " ÜÛ"
			@ 0,3 say "ß" color w+/n
			@ 0,4 say "ÛÜ"
			
			@ 1,0 say "ÛÛ " color w+/n
			@ 1,3 say "ß " color (colorvar)
			@ 1,5 say "ÛÛ"
			@ 1,7 say "Ü" color (colorvar)
			
			@ 2,0 say "ÛÛ " color w+/n
			@ 2,3 say "Ü ÛÛ"
			@ 2,7 say "Û" color (colorvar)

			@ 3,0 say " ßÛÜÛÜ"
			@ 3,6 say "ßß" color (colorvar)
			
			@ 4,0 say "   ßßß" color (colorvar)
			@ 4,6 say "ß"
			@ 4,7 say "Ü" color (colorvar)
		case substr(instring,curlet,1) = "R" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 7 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 8
			@ 0,0 say "ÛÛß" color w+/n
			@ 0,3 say "ßÛÜ"

			@ 1,0 say "ÛÛ " color w+/n
			@ 1,3 say " ÛÛ"
			@ 1,6 say "Û" color (colorvar)
			
			@ 2,0 say "ÛÛßßÛÜ" color w+/n
			@ 2,6 say "ß" color (colorvar)
			
			@ 3,0 say "ÛÛ " color w+/n
			@ 3,3 say " ÛÛ"
			@ 3,6 say "Û" color (colorvar)
			
			@ 4,0 say " ßß  ßß" color (colorvar)
		case substr(instring,curlet,1) = "S" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 7 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 8
			@ 0,0 say "ÜÛ"
			@ 0,2 say "ßßÛ" color w+/n
			@ 0,5 say "Ü"

			@ 1,0 say "ßÛÛÜÜ"
			@ 1,5 say "ßß" color (colorvar)
			
			@ 2,0 say "Ü  ßÛÛ"
			@ 2,6 say "Û" color (colorvar)
			
			@ 3,0 say "ßÛÜÜÛ"
			@ 3,5 say "ß " color w+/n
			
			@ 4,0 say "  ßßßß" color (colorvar)
		case substr(instring,curlet,1) = "T" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 7 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 8
			@ 0,0 say "ß"
			@ 0,1 say "ßÛÛßß" color w+/n
			@ 0,6 say "Ü" color (colorvar)

			@ 1,2 say "ÛÛ " color w+/n
			
			@ 2,2 say "ÛÛ " color w+/n
			
			@ 3,2 say "ÛÛ " color w+/n
			
			@ 4,0 say "   ßß" color (colorvar)
		case substr(instring,curlet,1) = "U" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 8
			@ 0,0 say "ÛÛ"
			@ 0,2 say "Ü " color (colorvar)
			@ 0,4 say "ÛÛ"
			@ 0,6 say "Ü " color (colorvar)

			@ 1,0 say "ÛÛ " color w+/n
			@ 1,3 say " ÛÛ"
			@ 1,6 say "Û" color (colorvar)
			
			@ 2,0 say "ÛÛ " color w+/n
			@ 2,3 say " "
			@ 2,4 say "ÛÛ " color w+/n
			
			@ 3,0 say "ßÛ"
			@ 3,2 say "Ü" color w+/n
			@ 3,3 say "Ü"
			@ 3,4 say "Ûß " color w+/n
			
			@ 4,0 say "  ßßßß" color (colorvar)
		case substr(instring,curlet,1) = "V" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 7 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 9
			@ 0,0 say "ÛÛ"
			@ 0,2 say "Ü" color (colorvar)
			@ 0,3 say "  ÛÛ"
			@ 0,7 say "Ü" color (colorvar)

			@ 1,0 say " ÛÛ"
			@ 1,3 say "Ü" color (colorvar)
			@ 1,4 say "ÛÛ " color w+/n
			@ 1,7 say "ß" color (colorvar)
			
			@ 2,0 say " ßÛ"
			@ 2,3 say "ÜÛß " color w+/n
			
			@ 3,0 say "  ßÛ"
			@ 3,4 say "ß " color w+/n

			@ 4,0 say "    ß" color (colorvar)
		case substr(instring,curlet,1) = "W" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 10 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 12
			@ 0,0 say "ÛÛ"
			@ 0,2 say "Ü " color (colorvar)
			@ 0,4 say "ÛÛ"
			@ 0,6 say "Ü " color (colorvar)
			@ 0,8 say "ÛÛ"
			@ 0,10 say "Ü" color (colorvar)

			@ 1,0 say "ßÛ"
			@ 1,2 say "Ü" color w+/n
			@ 1,3 say " ÛÛ"
			@ 1,6 say "Û" color (colorvar)
			@ 1,7 say "ÜÛ"
			@ 1,9 say "ß " color w+/n
			
			@ 2,1 say "ÛÛÜÛÛÜÛÛ " color w+/n
			
			@ 3,2 say "ÛÛ " color w+/n
			@ 3,6 say "ÛÛ " color w+/n
			@ 3,9 say "ß" color (colorvar)

			@ 4,0 say "   ßß  ßß" color (colorvar)
		case substr(instring,curlet,1) = "X" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 8 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 9
			@ 0,0 say "ÛÛ"
			@ 0,2 say "Ü" color (colorvar)
			@ 0,3 say "  ÛÛ"
			@ 0,7 say "Ü" color (colorvar)

			@ 1,0 say " ßÛÜÛ"
			@ 1,5 say "ß" color w+/n
			@ 1,6 say "Ûß" color (colorvar)

			@ 2,0 say " ÜÛ"
			@ 2,3 say "ßÛÜ" color w+/n
			
			@ 3,0 say "ÛÛ " color w+/n
			@ 3,3 say "ß" color (colorvar)
			@ 3,4 say " ÛÛ"
			@ 3,7 say "Ü" color (colorvar)
			
			@ 4,0 say " ßß   ßß" color (colorvar)
		case substr(instring,curlet,1) = "Y" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 9 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 10
			@ 0,0 say "ÛÛ"
			@ 0,2 say "Ü" color (colorvar)
			@ 0,3 say "   ÛÛ"
			@ 0,8 say "Ü" color (colorvar)

			@ 1,0 say " ÛÛ"
			@ 1,3 say "Ü" color (colorvar)
			@ 1,4 say " ÛÛ"
			@ 1,7 say "Ûß" color (colorvar)
			
			@ 2,0 say "  ßÛÛ"
			@ 2,5 say "ß " color w+/n
			@ 2,7 say "ß" color (colorvar)
			
			@ 3,3 say "ÛÛ " color w+/n
			
			@ 4,0 say "    ßß" color (colorvar)
		case substr(instring,curlet,1) = "Z" 
			define window ("letter" + alltrim(str(curlet))) ;
				 from startx,curenty to startx + 5,curenty + 6 ;
				 none noshadow 
			activate window ("letter" + alltrim(str(curlet)))
			curenty = curenty + 8
			@ 0,0 say "ß"
			@ 0,1 say "ßßßÛÛ" color w+/n
			@ 0,6 say "Ü" color (colorvar)
		
			@ 1,0 say "  ÜÛ"
			@ 1,4 say "ß " color w+/n
			@ 1,6 say "ß" color (colorvar)
			
			@ 2,0 say " ÛÛ"
			@ 2,3 say "ß " color w+/n
			
			@ 3,0 say "ÛÛÜÜ" color w+/n
			@ 3,4 say "ÜÜ"
			
			@ 4,0 say " ßßßßßß " color (colorvar)
	endcase
	curlet = curlet + 1
enddo
