* CPZERO -- Poke a codepage byte into a database header
* Author: Walter Kennamer
* Copyright Microsoft Corp, 1993
*
* Usage: 
*    DO CPZERO WITH dbfname                     && marks the database with codepage 0 (i.e., no codepage)
* 
*    DO CPZERO WITH dbfname, codepage_number    && marks the database with specified codepage
*
* Some common valid numbers are:
*   Windows            1252
*   DOS                 437
*   International DOS   850
*

PARAMETER m.fname, m.cpbyte
IF SET("TALK") = "ON"
   SET TALK OFF
   m.mtalk = "ON"
ELSE
   m.mtalk = "OFF"
ENDIF   

#define C_TOTAL 20     && total code page numbers suppoted

IF PARAMETERS() < 2
   m.cpbyte = 0
ENDIF   

PRIVATE m.mtalk, m.vuename

#define c_buf_size 8096

#define c_noopen   1
#define c_badbyte  2
#define c_maxerror 3

m.vuename = ""

DECLARE error_array[c_maxerror]
error_array[c_noopen] = "The database could not be opened"
error_array[c_badbyte] = "Invalid code page specified."

DO setup
DO main
DO cleanup

PROCEDURE setup
m.vuename = SYS(2023)+"\"+SYS(3)+".VUE"
CREATE VIEW (m.vuename)


PROCEDURE cleanup
IF FILE(m.vuename)
   SET VIEW TO (m.vuename)
   DELETE FILE (m.vuename)
ENDIF   
SET TALK &mtalk

PROCEDURE main
PRIVATE m.fp_in, m.buf, m.found_one, m.i, m.outbyte

* Set up table of code pages and DBF bytes numbers
DIMENSION cpnums[C_TOTAL,2] 
cpnums[ 1,1] = 437
cpnums[ 1,2] = 1
cpnums[ 2,1] = 850
cpnums[ 2,2] = 2
cpnums[ 3,1] = 1252
cpnums[ 3,2] = 3
cpnums[ 4,1] = 10000
cpnums[ 4,2] = 4
cpnums[ 5,1] = 852
cpnums[ 5,2] = 100
cpnums[ 6,1] = 866
cpnums[ 6,2] = 101
cpnums[ 7,1] = 865
cpnums[ 7,2] = 102
cpnums[ 8,1] = 861
cpnums[ 8,2] = 103
cpnums[ 9,1] = 895
cpnums[ 9,2] = 104
cpnums[10,1] = 620
cpnums[10,2] = 105
cpnums[11,1] = 737
cpnums[11,2] = 106
cpnums[12,1] = 857
cpnums[12,2] = 107
cpnums[13,1] = 10007
cpnums[13,2] = 150
cpnums[14,1] = 10029
cpnums[14,2] = 151
cpnums[15,1] = 10006
cpnums[15,2] = 152
cpnums[16,1] = 1250
cpnums[16,2] = 200
cpnums[17,1] = 1251
cpnums[17,2] = 201
cpnums[18,1] = 1253
cpnums[18,2] = 202
cpnums[19,1] = 1254
cpnums[19,2] = 203
cpnums[20,1] = 0
cpnums[20,2] = 0

IF EMPTY(m.fname)
   m.fname = getfile("DBF|SCX|FRX|LBX|MNX","DBF name")
ENDIF
IF !EMPTY(m.fname)
   CLOSE DATABASES
   m.outbyte = m.cpbyte
   m.found_one = .F.
   FOR m.i = 1 TO C_TOTAL
      IF m.cpbyte = cpnums[m.i,1]
         m.outbyte = cpnums[m.i,2]
         m.found_one = .T.
         EXIT
      ENDIF
   ENDFOR
   IF m.found_one
      m.cpbyte = m.outbyte
   ELSE
      * Was it a valid DBF byte if it wasn't a valid code page?
      FOR m.i = 1 TO C_TOTAL
         IF m.cpbyte = cpnums[m.i,2]
            m.found_one = .T.
         ENDIF
      ENDFOR
      IF !m.found_one
         DO errormsg WITH c_badbyte
         RETURN TO poke
      ENDIF
   ENDIF
   
   IF FILE(m.fname)
       m.fp_in = fopen(m.fname,2)
       IF m.fp_in > 0
          =fseek(m.fp_in,29)
          =fwrite(m.fp_in,CHR(m.cpbyte))   && poke codepage number into byte 29
          =fclose(m.fp_in)
       ELSE
          DO errormsg WITH c_noopen
          RETURN TO poke
       ENDIF
    ELSE
       DO errormsg WITH c_noopen
       RETURN TO poke
    ENDIF
ENDIF      


PROCEDURE errormsg
PARAMETER num
WAIT WINDOW error_array[num] NOWAIT
