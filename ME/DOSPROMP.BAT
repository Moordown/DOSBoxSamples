: Some earlier versions of DOS did not support the @ECHO OFF command.
: If you get a Bad command or file name, simply remove the "@" from the
: next line.
@Echo off
: You can use the echo statement below on most versions of COMMAND.COM,
: which will have the advantage of dropping down to the line below the
: previously entered DOS command.  If using this looks bad, simply remove
: the next line.
Echo:
Echo Type "EXIT" to return to Multi-Edit
: Check to see if 4Dos is being used as a command interpreter
PROMPT (Multi-Edit)%PROMPT%
If "%1" == "__4DOS__" Goto Exit
%comspec%
:Exit
