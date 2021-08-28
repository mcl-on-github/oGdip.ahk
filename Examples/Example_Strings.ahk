; In this example:
; - Using StringFormat and its various properties;
; - Drawing string onto Graphics;
; - Measuring parts of string.


#SingleInstance Force
#NoEnv
#Warn

#Include ..\OGdip.ahk
OGdip.Startup()
OnExit(ObjBindMethod(OGdip, "Shutdown"))
OGdip.autoGraphics := False
CC := {Base:{__Get:OGdip.GetColor}}


; Load external font
textFont   := new OGdip.Font("Bangers.ttf", 24)
rectLayout := [20, 20, 0, 0]
textFormat := new OGdip.StringFormat(0)
textString := "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
textMeasure := "None"

textFormat.TabStops := [30, 70, 30]


Gui, +E0x02080000  ; WS_EX_COMPOSITED & WS_EX_LAYERED => Double Buffer - reduces flicker on bitmap reloading

Gui, Add, Picture ,  x010 y010 w600 h200  HwndHIDisplay  +0x800000
Gui, Add, Edit    ,  x010 y220 w470 h050  HwndHEText     , % textString

Gui, Add, Checkbox,  x010 y280 w210 h020  HwndHBLayout   +0x1000, % "Layout"
Gui, Add, Text    ,  x010 y310 w020 h020  HwndHTLayoutX  +0x200 , % "X"
Gui, Add, Slider  ,  x040 y310 w180 h020  HwndHSLayoutX  +0x18  AltSubmit ToolTip Range0-400, 20
Gui, Add, Text    ,  x010 y340 w020 h020  HwndHTLayoutY  +0x200 , % "Y"
Gui, Add, Slider  ,  x040 y340 w180 h020  HwndHSLayoutY  +0x18  AltSubmit ToolTip Range0-400, 20
Gui, Add, Text    ,  x010 y370 w020 h020  HwndHTLayoutW  +0x200 , % "W"
Gui, Add, Slider  ,  x040 y370 w180 h020  HwndHSLayoutW  +0x18  AltSubmit ToolTip Range0-600, 0
Gui, Add, Text    ,  x010 y400 w020 h020  HwndHTLayoutH  +0x200 , % "H"
Gui, Add, Slider  ,  x040 y400 w180 h020  HwndHSLayoutH  +0x18  AltSubmit ToolTip Range0-600, 0

Gui, Add, Text    ,  x240 y280 w110 h020  HwndHTAlign    +Center +0x200, % "Alignment:"
Gui, Add, Button  ,  x240 y310 w030 h030  HwndHBAlignTL
Gui, Add, Button  ,  x280 y310 w030 h030  HwndHBAlignTC
Gui, Add, Button  ,  x320 y310 w030 h030  HwndHBAlignTR
Gui, Add, Button  ,  x240 y350 w030 h030  HwndHBAlignCL
Gui, Add, Button  ,  x280 y350 w030 h030  HwndHBAlignCC
Gui, Add, Button  ,  x320 y350 w030 h030  HwndHBAlignCR
Gui, Add, Button  ,  x240 y390 w030 h030  HwndHBAlignBL
Gui, Add, Button  ,  x280 y390 w030 h030  HwndHBAlignBC
Gui, Add, Button  ,  x320 y390 w030 h030  HwndHBAlignBR

Gui, Add, Text    ,  x370 y280 w110 h020  HwndHTTrimming  +Center +0x200, % "Trimming:"
Gui, Add, DDL     ,  x370 y310 w110       HwndHLTrimming  , None||Char|Word|EChar|EWord|EMid
Gui, Add, Checkbox,  x370 y340 w110 h020  HwndHCNoWrap    , % "NoWrap"
Gui, Add, Checkbox,  x370 y370 w110 h020  HwndHCNoClip    , % "NoClip"
Gui, Add, Checkbox,  x370 y400 w110 h020  HwndHCLineLimit , % "LineLimit"

Gui, Add, Button  ,  x500 y220 w110 h020  HwndHBChooseFont, % "Font"
Gui, Add, Slider  ,  x500 y250 w110 h020  HwndHSFontSize  +0x18  AltSubmit ToolTip Range1-60,  24
Gui, Add, Checkbox,  x500 y280 w050 h020  HwndHBBold      +0x1000, % "&B"
Gui, Add, Checkbox,  x560 y280 w050 h020  HwndHBItalic    +0x1000, % "&I"
Gui, Add, Checkbox,  x500 y310 w050 h020  HwndHBUnderline +0x1000, % "&U"
Gui, Add, Checkbox,  x560 y310 w050 h020  HwndHBStrikeout +0x1000, % "&S"

Gui, Add, Text    ,  x500 y340 w110 h020  HwndHTTabsMeasure  +Center +0x200, % "Tabs && Measure"
Gui, Add, Edit    ,  x500 y370 w110 h020  HwndHETabStops     , 30  70  30
Gui, Add, DDL     ,  x500 y400 w110       HwndHLMeasure      , None||All|Chars|Words|Lines

; Binding G-label event handlers
GuiControl, +gUpdateText, % HEText

GuiControl, +gUpdateLayout, % HBLayout
GuiControl, +gUpdateLayout, % HSLayoutX
GuiControl, +gUpdateLayout, % HSLayoutY
GuiControl, +gUpdateLayout, % HSLayoutW
GuiControl, +gUpdateLayout, % HSLayoutH

GuiControl, +gUpdateAlign, % HBAlignTL
GuiControl, +gUpdateAlign, % HBAlignTC
GuiControl, +gUpdateAlign, % HBAlignTR
GuiControl, +gUpdateAlign, % HBAlignCL
GuiControl, +gUpdateAlign, % HBAlignCC
GuiControl, +gUpdateAlign, % HBAlignCR
GuiControl, +gUpdateAlign, % HBAlignBL
GuiControl, +gUpdateAlign, % HBAlignBC
GuiControl, +gUpdateAlign, % HBAlignBR

GuiControl, +gUpdateOther, % HLTrimming
GuiControl, +gUpdateOther, % HCNoWrap
GuiControl, +gUpdateOther, % HCNoClip
GuiControl, +gUpdateOther, % HCLineLimit

GuiControl, +gChooseFont, % HBChooseFont
GuiControl, +gUpdateFont, % HSFontSize 
GuiControl, +gUpdateFont, % HBBold     
GuiControl, +gUpdateFont, % HBItalic   
GuiControl, +gUpdateFont, % HBUnderline
GuiControl, +gUpdateFont, % HBStrikeout

GuiControl, +gUpdateTabs, % HETabStops
GuiControl, +gUpdateMeasure, % HLMeasure

Gui, Show,, String Example
UpdateDisplay()

Return


#IfWinActive ahk_class AutoHotkeyGUI
Tab::
TabsForEdit() {
	ControlGetFocus, ctrlName, A
	
	If (ctrlName == "Edit1") {
		Send ^{Tab}
	} Else {
		Send {Tab}
	}
	Return
}
#If


GuiEscape:
GuiClose:
textFont := ""
textFormat := ""
ExitApp


UpdateText(hCtrl) {
	Global textString
	
	GuiControlGet, textString,, % hCtrl
	
	UpdateDisplay()
}


UpdateLayout() {
	Global
	Local _vBLayout, _vSLayoutX, _vSLayoutY, _vSLayoutW, _vSLayoutH
	
	GuiControlGet, _vBLayout ,, % HBLayout
	GuiControlGet, _vSLayoutX,, % HSLayoutX
	GuiControlGet, _vSLayoutY,, % HSLayoutY
	GuiControlGet, _vSLayoutW,, % HSLayoutW
	GuiControlGet, _vSLayoutH,, % HSLayoutH
	
	; If 'Layout' button is pressed, only origin point will be used.
	GuiControl, % (_vBLayout ? "Disable" : "Enable"), % HSLayoutW
	GuiControl, % (_vBLayout ? "Disable" : "Enable"), % HSLayoutH
	
	rectLayout := ( _vBLayout
	?  [ _vSLayoutX, _vSLayoutY, 0, 0 ]
	:  [ _vSLayoutX, _vSLayoutY, _vSLayoutW, _vSLayoutH ] )
	
	UpdateDisplay()
}


UpdateAlign(hCtrl) {
	Global
	Local _hAlign, _vAlign
	
	If (hCtrl == HBAlignTL)
	|| (hCtrl == HBAlignTC)
	|| (hCtrl == HBAlignTR)
		_vAlign := "Top"
	Else
	If (hCtrl == HBAlignCL)
	|| (hCtrl == HBAlignCC)
	|| (hCtrl == HBAlignCR)
		_vAlign := "Middle"
	Else
	If (hCtrl == HBAlignBL)
	|| (hCtrl == HBAlignBC)
	|| (hCtrl == HBAlignBR)
		_vAlign := "Bottom"
	
	
	If (hCtrl == HBAlignTL)
	|| (hCtrl == HBAlignCL)
	|| (hCtrl == HBAlignBL)
		_hAlign := "Left"
	Else
	If (hCtrl == HBAlignTC)
	|| (hCtrl == HBAlignCC)
	|| (hCtrl == HBAlignBC)
		_hAlign := "Center"
	Else
	If (hCtrl == HBAlignTR)
	|| (hCtrl == HBAlignCR)
	|| (hCtrl == HBAlignBR)
		_hAlign := "Right"
	
	
	textFormat.Align := _hAlign
	textFormat.LineAlign := _vAlign
	
	UpdateDisplay()
}


UpdateOther(hCtrl) {
	Global
	Local _vCtrl
	
	GuiControlGet, _vCtrl,, % hCtrl
	
	If (hCtrl == HLTrimming)
		textFormat.Trimming := _vCtrl
	Else
	If (hCtrl == HCNoWrap)
		textFormat.NoWrap := _vCtrl
	Else
	If (hCtrl == HCNoClip)
		textFormat.NoClip := _vCtrl
	Else
	If (hCtrl == HCLineLimit)
		textFormat.LineLimit := _vCtrl
	
	UpdateDisplay()
}


ChooseFont() {
	Global
	
	Local newFont := OGdip.ChooseFont(textFont)
	
	If (newFont == 0)
		Return
	
	If (IsObject(newFont)) {
		textFont := newFont
		GuiControl,, % HSFontSize  , % newFont.GetSize()
		
		Local _style := newFont.GetStyle()
		GuiControl,, % HBBold      , % !!(_style & 0x01)
		GuiControl,, % HBItalic    , % !!(_style & 0x02)
		GuiControl,, % HBUnderline , % !!(_style & 0x04)
		GuiControl,, % HBStrikeout , % !!(_style & 0x08)
		
	} Else {
		Local _rnd1, _rnd2, _rnd3
		Local _availableFamilies := OGdip.GetInstalledFontFamilies()
		Random, _rnd1, 1, % _availableFamilies.Length()
		Random, _rnd2, 1, % _availableFamilies.Length()
		Random, _rnd3, 1, % _availableFamilies.Length()
		
		MsgBox, % "Can't load font - perhaps it's not TrueType."
		. "`n" . "Try loading one of these families:"
		. "`n  * " . _availableFamilies[_rnd1]
		. "`n  * " . _availableFamilies[_rnd2]
		. "`n  * " . _availableFamilies[_rnd3]
	}
	
	UpdateDisplay()
}


UpdateFont(hCtrl) {
	Global
	Local _fontSize, _fontB, _fontI, _fontU, _fontS
	
	If (hCtrl == HSFontSize) {
		GuiControlGet, _fontSize,, % HSFontSize
		textFont.SetSize(_fontSize)
		
	} Else {
		GuiControlGet, _fontB,, % HBBold
		GuiControlGet, _fontI,, % HBItalic
		GuiControlGet, _fontU,, % HBUnderline
		GuiControlGet, _fontS,, % HBStrikeout
		
		_newStyle := ""
		. (_fontB ? "B" : "")
		. (_fontI ? "I" : "")
		. (_fontU ? "U" : "")
		. (_fontS ? "S" : "")
		
		textFont.SetStyle(_newStyle)
	}
	
	UpdateDisplay()
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


UpdateTabs() {
	Global
	Local _textTabs
	
	GuiControlGet, _textTabs,, % HETabStops
	
	textFormat.TabStops := _TextStringToNumberArray(_textTabs)
	
	UpdateDisplay()
}


UpdateMeasure() {
	Global textMeasure, HLMeasure
	
	GuiControlGet, textMeasure,, % HLMeasure
	
	UpdateDisplay()
}


UpdateDisplay() {
	Global
	Local bmpText
	
	bmpText := new OGdip.Bitmap(600, 200)
	bmpText.GetGraphics()
	
	bmpText.G.Clear(CC.White)
	bmpText.G.SetOptions( {textHint:"Antialias"})  ; Try also 'AntialiasHint' and 'ClearType'
	
	; Draw layout rectangle / origin point.
	Local _RL := rectLayout
	bmpText.G.SetPen(CC.LGray).SetBrush(CC.EEE)
	
	If ((_RL[3] == 0) || (_RL[4] == 0)) {
		; Either width or height is zero. Draw crosshair for the origin point.
		bmpText.G.DrawLine(_RL[1]-20,  _RL[2],  _RL[1]+_RL[3]+20,  _RL[2])
		bmpText.G.DrawLine(_RL[1],  _RL[2]-20,  _RL[1],  _RL[2]+_RL[4]+20)
		
	} Else {
		; Draw layout rectangle. If width or height is zero, it is treated as infinite.
		bmpText.G.DrawRectangle( _RL[1], _RL[2]
			, ((_RL[3] == 0) ? 9001 : _RL[3])
			, ((_RL[4] == 0) ? 9001 : _RL[4]))
	}
	
	
	Local _displayString := StrReplace(textString, "``t", "`t")
	
	bmpText.G.SetPen("")
	
	; Measurements
	If (textMeasure != "None") {
		Local msrColor := CC.Rnd & 0x60FFFFFF
		measurements := bmpText.G.MeasureString(_displayString, textFont, rectLayout, textFormat, textMeasure)
		
		
		; Measurement 'All' returns bounding box array.
		If (IsObject(measurements))
		&& (IsObject(measurements[1]) == False)
		{
			bmpText.G.SetBrush(msrColor)
			bmpText.G.DrawRectangle(measurements*)
			
		} Else {
			; Draw all measured regions with different colors.
			Loop % measurements.Length() {
				msrColor := CC.Rnd & 0x60FFFFFF
				bmpText.G.SetBrush(msrColor).FillRegion( measurements[A_Index] )
			}
		}
	}
	
	bmpText.G.SetBrush(CC.Black)
	bmpText.G.DrawString(_displayString, textFont, rectLayout, textFormat)
	
	bmpText.SetToControl(HIDisplay)
}
