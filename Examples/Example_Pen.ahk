; In this example:
; - Pen and its various settings;
; - Path and how to chain methods;
; - custom pen caps: adjustable ArrowCap and path-based CustomCap;
; - short appearance of Hatch and Linear brushes (use Shift/Ctrl+Shift on color button);
; - short appearance of Bitmap and how to set it to Picture or Button control;
; - ChooseColor dialog and CC color-shortcut.

#SingleInstance Force
#NoEnv
#Warn

#Include ..\OGdip.ahk
OGdip.Startup()
OnExit(ObjBindMethod(OGdip, "Shutdown"))
OGdip.autoGraphics := False
CC := {Base:{__Get:OGdip.GetColor}}


; Create two pens that will be customized and used in this example.
; One is solid color pen, another is brush-based.
; You can switch pen type by Shift+[Ctrl+]clicking the Color button.
displaySolidPen := new OGdip.Pen(0, 1)
displayBrushPen := new OGdip.Pen( new OGdip.Brush(CC.Red), 1 )

; Bitmap to display sample path drawn with customized pen.
displayBmp := new OGdip.Bitmap(400, 140)
displayBmp.GetGraphics()                   ; Autographics is off, need to init manually.
displayBmp.G.SetOptions( {smooth:"8x8"} )  ; Enable antialiasing for drawn lines
displayBmp.G.Pen := displaySolidPen        ; Link pen to the Graphics


; Sample path that will be drawn to show various pen features.
displayPath := new OGdip.Path()
displayPath.AddRectangle(20, 20, 50, 100)
displayPath.AddArc( 90, 20, 100, 100, 90, 180).CloseFigure()  ; Chaining!
displayPath.AddArc(160, 20, 100, 100, 90, 180).StartFigure()  ; This arc won't be closed

displayPath  ; Chaining galore!
.AddLine(310,20, 230,40)                    ; End point of this line and
.AddBezier(270,50, 260,50, 250,60, 250,70   ; start point of this Bezier arc,
        ,  250,80, 260,90, 270,90)          ; as well as the end of this arc and the start
.AddLine(230,100, 310,120)                  ; of this line will connect automatically.
.StartFigure()

displayPath.AddLine(330,20, 380,20, 380,70, 330,70, 380,120)


; Custom stroke caps: adjustable arrow and path-based:
customArrowCap := new OGdip.Pen.ArrowCap(3, 3, 1)
customArrowCap.SetInset(1)

; Note: CustomCap's path must intersect negative Y-axis.
customCapPath := new OGdip.Path()
customCapPath.AddEllipse(-1, -1, 2, 2)
customPathCap := new OGdip.Pen.CustomCap( customCapPath, False, 0.5 )


Gui, +E0x02080000  ; WS_EX_COMPOSITED & WS_EX_LAYERED => Double Buffer - reduces flicker on bitmap reloading
Gui, Add, Picture, x010 y010 w400 h140 HwndHIDisplay +0x800000

; Left control panel
Gui, Add, Text   , x010 y160 w060 h020 HwndHTWidth  +0x200, % "Pen Width:"
Gui, Add, Slider , x080 y160 w120 h020 HwndHSWidth  +0x18  AltSubmit ToolTip  Range1-15

Gui, Add, Text   , x010 y190 w060 h020 HwndHTScale  +0x200, % "Scale:"
Gui, Add, Slider , x080 y190 w120 h020 HwndHSScale  +0x18  AltSubmit ToolTip  Range25-300 Line25 Page25

Gui, Add, Text   , x010 y220 w060 h020 HwndHTRotate +0x200, % "Rotate:"
Gui, Add, Slider , x080 y220 w120 h020 HwndHSRotate +0x18  AltSubmit ToolTip  Range0-360  Line5 Page15

Gui, Add, Text   , x010 y250 w060 h020 HwndHTLJoin  +0x200, % "Line Join:"
Gui, Add, DDL    , x080 y250 w060      HwndHLLJoin  , Miter||Bevel|Round|MClip
Gui, Add, Slider , x150 y250 w050 h020 HwndHSMiter  +0x18  AltSubmit ToolTip  Range0-10

; Right control panel
Gui, Add, DDL    , x220 y160 w060      HwndHLDashes   , Solid||Dash|Dot|DashDot|Custom
Gui, Add, Edit   , x290 y160 w120 h020 HwndHEDashes   , % "2  0.5  0.5  0.5"

Gui, Add, DDL    , x220 y190 w060      HwndHLStartCap , Flat||Square|Round|Triangle|*Square|*Round|*Triangle|Arrow|C-Arrow|Custom
Gui, Add, DDL    , x290 y190 w050      HwndHLDashCap  , Flat||Round|Triangle
Gui, Add, DDL    , x350 y190 w060      HwndHLEndCap   , Flat||Square|Round|Triangle|*Square|*Round|*Triangle|Arrow|C-Arrow|Custom

Gui, Add, DDL    , x220 y220 w060      HwndHLStroke   , Center||Inset|Double|Triple|Left|Right|Custom
Gui, Add, Edit   , x290 y220 w120 h020 HwndHEStroke   , % "0  0.25  0.5  1"

Gui, Add, Text   , x220 y250 w060 h020 HwndHTColor +0x200, % "Color:"
Gui, Add, Button , x290 y250 w050 h020 HwndHBColor +0x8000
Gui, Add, Button , x350 y250 w060 h020 HwndHBInfo, % "Info"

Gui, Show,, Pen Example


; Set default values and styles first,
; so we don't trigger events.
GuiControl, Disable, % HEDashes
GuiControl, Disable, % HEStroke
GuiControl,, % HSWidth, 5
GuiControl,, % HSScale, 100
GuiControl,, % HSMiter, 10

; Now we can bind events.
GuiControl, +gUpdatePenWidth   , % HSWidth
GuiControl, +gUpdatePenMatrix  , % HSScale
GuiControl, +gUpdatePenMatrix  , % HSRotate
GuiControl, +gUpdateLineJoin   , % HLLJoin
GuiControl, +gUpdateLineJoin   , % HSMiter
GuiControl, +gUpdateDashes     , % HLDashes
GuiControl, +gUpdateDashes     , % HEDashes
GuiControl, +gUpdateCaps       , % HLStartCap
GuiControl, +gUpdateCaps       , % HLDashCap
GuiControl, +gUpdateCaps       , % HLEndCap
GuiControl, +gUpdateStroke     , % HLStroke
GuiControl, +gUpdateStroke     , % HEStroke
GuiControl, +gOnPenColor       , % HBColor
GuiControl, +gOnPenInfo        , % HBInfo

UpdatePenWidth()
SetPenColor(CC.LBlue)
Return

GuiClose:
GuiEscape:
	displaySolidPen := ""
	displayBrushPen := ""
	displayBmp  := ""
	displayPath := ""
	ExitApp


UpdatePenWidth() {
	Global
	
	GuiControlGet, newPenWidth,, % HSWidth
	
	displaySolidPen.Width := newPenWidth
	displayBrushPen.Width := newPenWidth
	
	UpdateIDisplay()
}


UpdatePenMatrix() {
	Global
	Local _penScale
	Local _penRotate
	Local _penMatrix
	
	GuiControlGet, _penScale ,, % HSScale
	GuiControlGet, _penRotate,, % HSRotate
	
	; Two methods below are similar and should have same result.
	; Note: order of transformations does matter!
	; One method is to transform pen itself:
	displaySolidPen.TransformReset()
	displaySolidPen.TransformRotate(_penRotate)
	displaySolidPen.TransformScale(1, _penScale / 100)
	
	; Another method is to pass pre-transformed matrix:
	_penMatrix := new OGdip.Matrix()
	_penMatrix.Rotate(_penRotate)
	_penMatrix.Scale(1, _penScale / 100)
	
	displayBrushPen.SetTransformMatrix( _penMatrix )
	
	UpdateIDisplay()
}


UpdateLineJoin() {
	Global
	Local _penLJoin
	Local _penMiter
	
	GuiControlGet, _penLJoin,, % HLLJoin
	GuiControlGet, _penMiter,, % HSMiter
	
	displaySolidPen.SetLineJoin( _penLJoin, _penMiter)
	displayBrushPen.SetLineJoin( _penLJoin, _penMiter)
	
	UpdateIDisplay()
}


_TextStringToNumberArray( strText ) {
	charPos := 1, resultArray := []
	Loop {
		charPos := RegexMatch(strText, "[\d\.]+", match, charPos)
		If (charPos == 0)
			Break
		
		resultArray.Push(0+match)
		charPos += StrLen(match)
	}
	Return resultArray
}


UpdateDashes() {
	Global
	Local _dashPreset
	Local _dashPattern
	
	GuiControlGet, _dashPreset  ,, % HLDashes
	GuiControlGet, _dashPattern ,, % HEDashes
	
	GuiControl, % (_dashPreset = "Custom") ? "Enable" : "Disable", % HEDashes
	
	If (_dashPreset = "Custom") {
		_dashPreset := _TextStringToNumberArray(_dashPattern)
	}
	
	displaySolidPen.SetDash(_dashPreset)
	displayBrushPen.SetDash(_dashPreset)
	
	UpdateIDisplay()
}


UpdateCaps() {
	Global
	Local _sCap, _dCap, _eCap
	
	GuiControlGet, _sCap,, % HLStartCap
	GuiControlGet, _dCap,, % HLDashCap
	GuiControlGet, _eCap,, % HLEndCap
	
	_sCap := (_sCap = "C-Arrow") ? customArrowCap
	:        (_sCap = "Custom")  ? customPathCap  : _sCap
	
	_eCap := (_eCap = "C-Arrow") ? customArrowCap
	:        (_eCap = "Custom")  ? customPathCap  : _eCap
	
	displaySolidPen.SetCaps( _sCap, _dCap, _eCap )
	displayBrushPen.SetCaps( _sCap, _dCap, _eCap )
	
	UpdateIDisplay()
}


UpdateStroke() {
	Global
	Local _strokeType
	Local _compoundArray
	
	GuiControlGet, _strokeType   ,, % HLStroke
	GuiControlGet, _compoundArray,, % HEStroke
	
	GuiControl, % (_strokeType = "Custom") ? "Enable" : "Disable", % HEStroke
	
	If (_strokeType = "Custom") {
		_strokeType := _TextStringToNumberArray(_compoundArray)
	}
	
	; Inset stroke works only on closed figures (like rectangles)
	; Note: after you set any compound array, you can't return 'Inset' stroke style.
	
	displaySolidPen.SetStroke(_strokeType)
	displayBrushPen.SetStroke(_strokeType)
	
	UpdateIDisplay()
}


OnPenColor() {
	Global
	
	If (GetKeyState("Shift") == True) {
		SetPenBrush( GetKeyState("Ctrl") )
		Return
	}
	
	Local chosenColor := OGdip.ChooseColor( displaySolidPen.Color )
	
	; Not necessary, but make sure to restore window focus after ChooseColor().
	; Using .SetControl by control name requires window to be active.
	WinActivate, Pen Example ahk_class AutoHotkeyGUI
	
	If (chosenColor != "")
		SetPenColor(chosenColor)
}


_SetButtonFillColor(buttonName, fillColor) {
	Global
	
	Local emptyBmp := new OGdip.Bitmap(1,1)
	emptyBmp.SetPixel(0, 0, fillColor)
	
	; Using .SetControl by control name requires window to be active.
	; Using HWND of the control is usually more reliable.
	emptyBmp.SetToControl(buttonName, "Stretch")
}


SetPenColor(newPenColor) {
	Global
	
	displaySolidPen.Color := newPenColor | 0xFF000000  ; Make alpha 0xFF again
	displayBmp.G.Pen := displaySolidPen
	
	_SetButtonFillColor("Button1", displaySolidPen.Color)
	
	UpdateIDisplay()
}


SetPenBrush( setLinearBrush := False ) {
	Global
	Local _randomHatch
	Random, _randomHatch, 0, 52
	
	Local _penFillBrush := setLinearBrush
	?  new OGdip.Brush([0,0, 0,140], CC.Rnd, CC.Rnd)
	:  new OGdip.Brush(_randomHatch, CC.Rnd, CC.Rnd)
	
	displayBrushPen.Color := _penFillBrush
	displayBmp.G.Pen := displayBrushPen
	
	UpdateIDisplay()
}


_JoinArray( arr ) {
	jText := "["
	Loop % arr.Length() {
		jText .= ((A_Index == 1) ? "" : "; ") . Format("{:.2f}", arr[A_Index])
	}
	Return jText . "]"
}


OnPenInfo() {
	Global
	
	Local textInfo := "SOLID PEN:`n"
	
	For key, value In displaySolidPen.GetInfo() {
		textInfo .= Format("    {}:`t{}`n", key, IsObject(value) ? _JoinArray(value) : value)
	}
	
	textInfo .= "`nBRUSH PEN:`n"
	
	For key, value In displayBrushPen.GetInfo() {
		textInfo .= Format("    {}:`t{}`n", key, IsObject(value) ? _JoinArray(value) : value)
	}
	
	MsgBox % textInfo
}


UpdateIDisplay() {
	Global
	
	displayBmp.G.Clear(0x0)
	displayBmp.G.DrawPath(displayPath)
	
	displayBmp.SetToControl("Static1")
}
