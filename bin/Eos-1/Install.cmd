echo Installation von EOS 1

REM Pfad erstellen
SET EOS_PATH="%ProgramFiles(x86)%\EOS\"
md %EOS_PATH%

REM programm entpacken
"%programfiles%\7-zip\7z.exe" x "%~dp0eos.zip" -o%EOS_PATH% eos.exe

REM verknüpfung erstellen
cscript "%~dp0eos-link.vbs"