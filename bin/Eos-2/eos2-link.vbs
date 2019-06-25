Set objShell = CreateObject("WScript.Shell") 

sShortcut = "C:\Users\Public\Desktop\Eos2.lnk" 

set objLink = objShell.CreateShortcut(sShortcut) 
objLink.TargetPath = "C:\Program Files (x86)\EOS2\Eos.bat"
objLink.WorkingDirectory = "C:\Program Files (x86)\EOS2"

objLink.Save