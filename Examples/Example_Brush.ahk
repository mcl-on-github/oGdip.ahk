; In this example:
;   - Linear and path gradient brushes.
;   - Their various parameters, like scale, focus, colors and gamma.
;   - Short appearance of Graphics.Transform-functions.


#SingleInstance Force
#NoEnv
#Warn

#Include ..\OGdip.ahk
OGdip.Startup()
OnExit(ObjBindMethod(OGdip, "Shutdown"))
OGdip.autoGraphics := True
CC := {Base:{__Get:OGdip.GetColor}}


brushTwoColors   := [ CC.FA0, CC.04A ]
brushFourColors  := [ CC.F00, CC.0F6, CC.C0F, CC.CF0 ]
brushMultiColors := [ CC.Red, CC.Green, CC.Blue ]
brushFactors     := [ 0.0, 0.2, 0.8, 1.0, 0.5 ]
brushPositions   := [ 0.0, 0.4, 0.5, 0.6, 1.0 ]

bmpILinear := new OGdip.Bitmap(360, 130)
bmpIPath   := new OGdip.Bitmap(360, 150)
bmpILinear.G.SetOptions( {smooth:1} )
bmpIPath.G.SetOptions( {smooth:1} )


pathEllipse := new OGdip.Path()
pathEllipse.AddEllipse(10,10, 60,60)
pathSquare  := new OGdip.Path()
pathSquare.AddRectangle(10,10, 60,60)


Gui, +E0x02080000  ; WS_EX_COMPOSITED & WS_EX_LAYERED => Double Buffer - reduces flicker on bitmap reloading

Gui, Add, Text    , x010 y10  w360 h020 HwndHTLinear , % "Linear gradient brush:"
Gui, Add, Picture , x010 y30  w360 h130 HwndHILinear +0x800000
Gui, Add, Text    , x010 y180 w360 h020 HwndHTPath   , % "Path gradient brush:"
Gui, Add, Picture , x010 y200 w360 h150 HwndHIPath   +0x800000

Gui, Add, Text    , x010 y360 w060 h020 HwndHTFocus  +0x200, % "Focus:"
Gui, Add, Slider  , x080 y360 w180 h020 HwndHSFocus  +0x18  AltSubmit Range0-100, 100
Gui, Add, Text    , x010 y390 w060 h020 HwndHTScale  +0x200, % "Scale:"
Gui, Add, Slider  , x080 y390 w180 h020 HwndHSScale  +0x18  AltSubmit Range0-100, 100

Gui, Add, Checkbox, x290 y360 w080 h050 HwndHBGamma  +0x1000, % "Gamma"

GuiControl, +gUpdateParam, % HSFocus
GuiControl, +gUpdateParam, % HSScale
GuiControl, +gUpdateParam, % HBGamma


Gui, Show,, Brush Example
UpdateIDisplays()
Return

GuiEscape:
GuiClose:
ExitApp

_GetMousePosOnControl( hCtrl ) {
	Local
	
	CoordMode, Mouse, Screen
	MouseGetPos, mx, my
	
	VarSetCapacity(binPoint, 4*2, 0)
	NumPut(mx, binPoint, 0, "Int")
	NumPut(my, binPoint, 4, "Int")
	
	DllCall("ScreenToClient"
	, "Ptr",  hCtrl
	, "Ptr", &binPoint)
	
	mx := NumGet(binPoint, 0, "Int")
	my := NumGet(binPoint, 4, "Int")
	
	Return [ mx, my ]
}


UpdateParam(hCtrl) {
	UpdateIDisplays()
}


UpdateIDisplays() {
	Global
	Local _focus, _scale
	Local lineBrush, pathBrush, pathBrush2
	
	GuiControlGet, _focus,, % HSFocus
	GuiControlGet, _scale,, % HSScale
	GuiControlGet, _gamma,, % HBGamma
	
	_focus /= 100,  _scale /= 100
	
	
	bmpILinear.G.Clear(0x0)
	
	; Linear brush display
	
	bmpILinear.G.Brush  :=  lineBrush  :=  new OGdip.Brush.LinearBrush(10,10, 350,10, brushTwoColors*)
	lineBrush.UseGamma := _gamma
	
	lineBrush.SetMode("Linear", _focus, _scale)
	bmpILinear.G.DrawRectangle(10, 10, 340, 20)
	
	lineBrush.SetMode("Smooth", _focus, _scale)
	bmpILinear.G.DrawRectangle(10, 40, 340, 20)
	
	lineBrush.SetMode("Custom", brushFactors, brushPositions)
	bmpILinear.G.DrawRectangle(10, 70, 340, 20)
	
	lineBrush.SetMode("Multi" , brushMultiColors)
	bmpILinear.G.DrawRectangle(10,100, 340, 20)
	
	bmpILinear.SetToControl(HILinear)
	
	; Path brush display
	
	bmpIPath.G.Clear(CC.Black)
	bmpIPath.G.TransformReset()
	
	; Top row - ellipses.
	; Elliptic paths have many points, so using only two colors usually gives best results.
	
	bmpIPath.G.Brush  :=  pathBrush  :=  new OGdip.Brush.PathBrush(pathEllipse)
	pathBrush.SetSurroundColors(brushTwoColors[1])
	pathBrush.SetCenterColor(brushTwoColors[2])
	pathBrush.UseGamma := _gamma
	
	pathBrush.SetMode("Linear", _focus, _scale)
	bmpIPath.G.DrawPath(pathEllipse)
	
	pathBrush.SetMode("Custom", brushFactors, brushPositions)
	bmpIPath.G.TransformMove(70, 0)
	bmpIPath.G.DrawPath(pathEllipse)
	
	pathBrush.SetMode("Smooth", _focus, _scale)
	pathBrush.SetCenterPoint(20, 20)
	bmpIPath.G.TransformMove(70, 0)
	bmpIPath.G.DrawPath(pathEllipse)
	
	pathBrush.SetCenterPoint(40, 40)  ; Return center point to the center
	
	pathBrush.SetMode("Smooth", _focus, _scale)
	pathBrush.SetFocusScales(0.25, 0.75)
	bmpIPath.G.TransformMove(70, 0)
	bmpIPath.G.DrawPath(pathEllipse)
	
	pathBrush.SetFocusScales(0, 0)  ; Return focus scales to single point
	
	pathBrush.SetMode("Inward", brushMultiColors, brushPositions)
	bmpIPath.G.TransformMove(70, 0)
	bmpIPath.G.DrawPath(pathEllipse)
	
	; Bottom row - squares.
	; Squares have four points (duh!), so using four surround colors gives best results.
	; Each point will have its own color.
	
	bmpIPath.G.TransformReset()
	bmpIPath.G.TransformMove(0, 70)
	
	bmpIPath.G.Brush  :=  pathBrush  :=  new OGdip.Brush.PathBrush(pathSquare)
	pathBrush.SetSurroundColors(brushFourColors)
	pathBrush.SetCenterColor(CC.White)
	pathBrush.UseGamma := _gamma
	
	pathBrush.SetMode("Linear", _focus, _scale)
	bmpIPath.G.DrawPath(pathSquare)
	
	pathBrush.SetMode("Custom", brushFactors, brushPositions)
	bmpIPath.G.TransformMove(70, 0)
	bmpIPath.G.DrawPath(pathSquare)
	
	pathBrush.SetMode("Smooth", _focus, _scale)
	pathBrush.SetCenterPoint(20, 20)
	bmpIPath.G.TransformMove(70, 0)
	bmpIPath.G.DrawPath(pathSquare)
	
	pathBrush.SetCenterPoint(40, 40)  ; Return center point to the center
	
	pathBrush.SetMode("Smooth", _focus, _scale)
	pathBrush.SetFocusScales(0.25, 0.75)  ; As you can see, focus scales do not work with multicolors
	bmpIPath.G.TransformMove(70, 0)
	bmpIPath.G.DrawPath(pathSquare)
	
	pathBrush.SetMode("Inward", brushMultiColors, brushPositions)
	bmpIPath.G.TransformMove(70, 0)
	bmpIPath.G.DrawPath(pathSquare)
	
	bmpIPath.SetToControl(HIPath)
}
