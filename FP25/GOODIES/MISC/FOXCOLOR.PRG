IF SET("TALK") = "ON"		&& TALK has to be handled
   SET TALK OFF				&& as a special case.
   savetalk = "ON"
ELSE
   savetalk = "OFF"
ENDIF
SET TALK OFF
r = INT((SROWS() - 14) / 2)
c = INT((SCOLS() - 80) / 2)
=SYS(2008, "O", 2)
SET TALK &savetalk
*** F ***
@ r,c+1  FILL TO r+3,c+16  COLOR GR+/B  && Change to BG/B for default color set
@ r+4,c+1  FILL TO r+10,c+8  COLOR GR+/B  && Change to BG/B for default color set
*** o ***
@ r+4,c+10 FILL TO r+10,c+22 COLOR R+/B
*** x ***
@ r+4,c+23 FILL TO r+10,c+35 COLOR R/B
*** P ***
@ r,c+36 FILL TO r+10,c+50 COLOR BG/B
*** r ***
@ r+4,c+51 FILL TO r+10,c+63 COLOR G/B
*** o ***
@ r+4,c+64 FILL TO r+10,c+79 COLOR B+/B
*** Copyright notice ***
@ r+11,c FILL TO r+14,c+79 COLOR W/B && Change to W/B for default color set
