set TEST_FILES=src/tests
set DEPENDENCIES=dependencies
set GOAL_RUNTIME=%DEPENDENCIES%/runtime-2.0.2-SNAPSHOT-jar-with-dependencies.jar
set GOAL_SETTINGS=%DEPENDENCIES%/settings.yaml
set GOAL_RUN=goal.tools.eclipse.RunTool
set RESULTS_PATH=results
set RESULT_FILE=result.res
set RESULTS=%RESULTS_PATH%/%RESULT_FILE%

mkdir %RESULTS_PATH%
del %RESULTS_PATH%\*.res

for %%f in (%TEST_FILES%/*.test2g) do (
	echo %%~nf	
	java -cp %GOAL_RUNTIME% %GOAL_RUN% %GOAL_SETTINGS% %TEST_FILES%/%%f -v > %RESULTS_PATH%/%%f.res
)

@echo off
for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
set ldt=%ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2% %ldt:~8,2%:%ldt:~10,2%:%ldt:~12,6%
echo Tests of %ldt% > %RESULTS%
echo. >> %RESULTS%
set /a counter=0
set /a failed=0
set /a passed=0
set /a tsterr=0
for %%f in (%RESULTS_PATH%/*.test2g.res) do (
	set /a counter+=1
	find "test passed" %RESULTS_PATH%/%%f
	if ERRORLEVEl 1 ( 
		set /a failed+=1
		echo %%~nf failed >> %RESULTS%
	) else (
		find "test passed" %RESULTS_PATH%/%%f
		if ERRORLEVEl 0 ( 
			set /a passed+=1
			echo %%~nf passed >> %RESULTS%
		) else (
			set /a tsterr+=1
			echo %%~nf errored?? >> %RESULTS%
		)
	)
)

echo. >> %RESULTS%
if %counter% equ %passed% (
	echo TESTS PASSED >> %RESULTS%
) else (
	echo TEST FAILURE >> %RESULTS%
)
echo Number of tests: %counter%  >> %RESULTS%
echo Tests failed: %failed% >> %RESULTS%
echo Tests errored: %tsterr% >> %RESULTS%
echo Tests passed: %passed% >> %RESULTS%

type %RESULTS_PATH%\%RESULT_FILE%

start notepad %RESULTS%