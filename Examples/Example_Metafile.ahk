; This example shows basics of creating metafile.
; It can be viewed or imported to a vector graphics editor (ex. Inkscape).
; As I don't expect that many people are eager to use metafiles, I'll keep it simple.


#NoEnv
#Warn
SetWorkingDir %A_ScriptDir%

#Include ..\OGdip.ahk
OGdip.Startup()
OnExit(ObjBindMethod(OGdip, "Shutdown"))
CC := {Base:{__Get:OGdip.GetColor}}

; Start recording metafile. Note that it uses non-standard constructor!
mf := OGdip.Metafile.RecordTo(0, "Example.emf",, [0, 0, 3*260, 3*100], "Pixel")

; Calling Graphics functions cause recording to metafile.
mf.G.Brush := CC.Black
mf.G.TransformScale(3, 3)

mf.G.DrawEllipse(20, 30, 40, 40)

mf.G.DrawEllipse(70, 30, 40, 40)
pathArc := new OGdip.Path()
pathArc.AddEllipse(70, 50, 40, 40).AddEllipse(80, 60, 20, 20)
mf.G.DrawRectangle(100, 30, 10, 40)
mf.G.SetClip(90, 70, 30, 30).DrawPath(pathArc).ResetClip()
mf.G.DrawRectangle(70, 80, 20, 10)

mf.G
.DrawEllipse(120, 30, 40, 40)
.DrawRectangle(150, 10, 10, 60)
.DrawRectangle(175, 30, 10, 40)
.DrawRectangle(175, 10, 10, 10)
.DrawEllipse(200, 30, 40, 40)
.DrawRectangle(200, 30, 10, 60)

mf.G.SetBrush( CC.E33 ).DrawEllipse( 30, 40, 20, 20)
mf.G.SetBrush( CC.EC4 ).DrawEllipse( 80, 40, 20, 20)
mf.G.SetBrush( CC.8D2 ).DrawEllipse(130, 40, 20, 20)
mf.G.SetBrush( CC.69C ).DrawEllipse(210, 40, 20, 20)

; Delete Graphics and close Metafile to write recorded data.
mf.G := ""
mf := ""

MsgBox % "You should now have 'Example.emf'."
