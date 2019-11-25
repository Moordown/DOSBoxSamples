procedure temptrac
parameter dodebug
push key clear
wait window "Escape and function keys are disabled while trace window is opened" timeout 2
_throttle = .10
if dodebug = 1
	activate window debug
	activate window trace
	play macro debugit
	suspend
else
	activate window trace
endif

for counter = 1 to 10
	testnum1 = counter * 3
	looptalk = "This small routine"
	looptalk = "demonstrates using"
	looptalk = "trace and debug"
	testnum2 = counter/2
endfor

release window trace
if dodebug = 1
	release window debug
endif
pop key