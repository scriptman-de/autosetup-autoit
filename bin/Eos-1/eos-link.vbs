Set objShell = CreateObject("WScript.Shell") 

sShortcut = "C:\Users\Public\Desktop\Eos.lnk" 

set objLink = objShell.CreateShortcut(sShortcut) 
objLink.TargetPath = "C:\Program Files (x86)\EOS\EOS.exe"
objLink.WorkingDirectory = "C:\Program Files (x86)\EOS"

objLink.Save