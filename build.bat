@echo off
rem Build CampusGreenMobility and (optionally) deploy it to Tomcat 10.1. No IDE needed.
rem
rem Usage (Windows Command Prompt), from inside the CampusGreenMobility folder:
rem   set TOMCAT_HOME=C:\path\to\apache-tomcat-10.1.xx
rem   build.bat
rem In PowerShell use:   $env:TOMCAT_HOME="C:\path\to\apache-tomcat-10.1.xx"   then   .\build.bat
rem Without TOMCAT_HOME it still builds build\CampusGreenMobility.war and tells you where to put it.

setlocal
cd /d "%~dp0"

set APP=CampusGreenMobility
set LIB=WebContent\WEB-INF\lib
set MAVEN=https://repo1.maven.org/maven2
if not exist "%LIB%" mkdir "%LIB%"

rem The old Tomcat 9 style JSTL jar breaks Tomcat 10, so remove it if it is there
if exist "%LIB%\jstl-1.2.jar" del /q "%LIB%\jstl-1.2.jar"

rem ---- 1. make sure the three jar files are in WEB-INF\lib ----
dir /b "%LIB%\jakarta.servlet.jsp.jstl-api*.jar" >nul 2>&1
if errorlevel 1 (
    echo Downloading jakarta.servlet.jsp.jstl-api-3.0.0.jar ...
    curl -fL -o "%LIB%\jakarta.servlet.jsp.jstl-api-3.0.0.jar" %MAVEN%/jakarta/servlet/jsp/jstl/jakarta.servlet.jsp.jstl-api/3.0.0/jakarta.servlet.jsp.jstl-api-3.0.0.jar
    if errorlevel 1 goto dlfail
)
dir /b "%LIB%\jakarta.servlet.jsp.jstl-3*.jar" >nul 2>&1
if errorlevel 1 (
    echo Downloading jakarta.servlet.jsp.jstl-3.0.1.jar ...
    curl -fL -o "%LIB%\jakarta.servlet.jsp.jstl-3.0.1.jar" %MAVEN%/org/glassfish/web/jakarta.servlet.jsp.jstl/3.0.1/jakarta.servlet.jsp.jstl-3.0.1.jar
    if errorlevel 1 goto dlfail
)
dir /b "%LIB%\mysql-connector*.jar" >nul 2>&1
if errorlevel 1 (
    echo Downloading mysql-connector-j-8.4.0.jar ...
    curl -fL -o "%LIB%\mysql-connector-j-8.4.0.jar" %MAVEN%/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar
    if errorlevel 1 goto dlfail
)

rem ---- 2. compile the Java code into WEB-INF\classes ----
if exist build rmdir /s /q build
mkdir "build\%APP%"
xcopy /E /I /Y /Q WebContent "build\%APP%" >nul
mkdir "build\%APP%\WEB-INF\classes"
javac -encoding UTF-8 -d "build\%APP%\WEB-INF\classes" src\com\campusgreen\model\*.java src\com\campusgreen\dao\*.java src\com\campusgreen\util\*.java
if errorlevel 1 goto compilefail
echo Java code compiled.

rem ---- 3. package as a WAR ----
jar -cf "build\%APP%.war" -C "build\%APP%" .
if errorlevel 1 goto warfail
echo Built build\%APP%.war

rem ---- 4. deploy to Tomcat if we know where it is ----
if "%TOMCAT_HOME%"=="" goto nodeploy
if exist "%TOMCAT_HOME%\webapps\%APP%" rmdir /s /q "%TOMCAT_HOME%\webapps\%APP%"
if exist "%TOMCAT_HOME%\webapps\%APP%.war" del /q "%TOMCAT_HOME%\webapps\%APP%.war"
copy /Y "build\%APP%.war" "%TOMCAT_HOME%\webapps\" >nul
echo Deployed to %TOMCAT_HOME%\webapps
echo Start Tomcat with: %TOMCAT_HOME%\bin\startup.bat
echo Then open: http://localhost:8080/%APP%/
goto end

:nodeploy
echo TOMCAT_HOME is not set, so nothing was deployed.
echo Copy build\%APP%.war into the webapps folder of Tomcat 10.1, start Tomcat, then open http://localhost:8080/%APP%/
goto end

:dlfail
for %%f in ("%LIB%\*.jar") do if %%~zf==0 del "%%f"
echo Could not download a jar file. Download these three by hand and put them in %LIB%
echo   %MAVEN%/jakarta/servlet/jsp/jstl/jakarta.servlet.jsp.jstl-api/3.0.0/jakarta.servlet.jsp.jstl-api-3.0.0.jar
echo   %MAVEN%/org/glassfish/web/jakarta.servlet.jsp.jstl/3.0.1/jakarta.servlet.jsp.jstl-3.0.1.jar
echo   %MAVEN%/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar
exit /b 1

:compilefail
echo Compile failed. Check that a JDK is installed: type java -version and javac -version
exit /b 1

:warfail
echo Could not create the WAR file. Check that a JDK is installed: type javac -version
exit /b 1

:end
endlocal
