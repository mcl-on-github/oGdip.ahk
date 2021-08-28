; In this example:
;   - loading Bitmap from Image and from memory buffer;
;   - scaling and transforming Bitmap;
;   - converting formats and changing palettes;
;   - applying various effects;
;   - clipping Graphics to restrict rendering area;
;   - getting Bitmap's histogram;
;   - using SetPixel and LockBits to manipulate raw pixel data.

#NoEnv
#Warn
SetWorkingDir %A_ScriptDir%

#Include ..\OGdip.ahk
OGdip.Startup()
OnExit(ObjBindMethod(OGdip, "Shutdown"))
CC := {Base:{__Get:OGdip.GetColor}}


Gui, Add, Picture, w768 h768
Gui, Show,, Bitmap Example

bmpExample := OGdipExampleBitmap()
bmpExample.SetToControl("Static1")
bmpExample := ""
Return

GuiEscape:
GuiClose:
ExitApp

; I'm wrapping everything into function so I don't have
; to deal with deleting objects myself before shutdown.

OGdipExampleBitmap() {
	; Let's load well-known test image
	bmpLenna := new OGdip.Bitmap("Lenna.jpg")
	
	; It's too big for us, let's make half-sized copy of that image
	bmpHalf := bmpLenna.Resize( bmpLenna.Width/2, bmpLenna.Height/2 )
	
	; These width and height will be used many times
	hw := bmpHalf.Width
	hh := bmpHalf.Height
	
	; Okay, let's make our canvas for 3x3 images
	bmpCanvas := new OGdip.Bitmap(hw * 3, hh * 3)
	
	; R1C1 - 2-color (1bpp) image
	bmpTest_I1 := new OGdip.Bitmap(bmpHalf)  ; Create copy of original bitmap
	bmpTest_I1.ConvertFormat("I1", "BW")    ; Convert to dithered black-n-white
	bmpTest_I1.SetPalette([ 0xFF4A2514, 0xFFD0BAA4 ])  ; Change palette
	bmpCanvas.G.DrawImage(bmpTest_I1, 0*hw, 0*hh)
	
	; R1C2 - 16-color (4bpp) image
	bmpTest_I4 := new OGdip.Bitmap(bmpHalf)
	bmpTest_I4.ConvertFormat("I4", "System", False)  ; Convert to non-dithered 16-color
	bmpTest_I4.SetAttribute("RemapTable"             ; Remap dark-yellow color with attribute.
	, [ OGdip.RGB(128,128,0)                         ; Attributes don't change original bitmap,
	,   OGdip.RGB(150,100,50) ])                     ; they only applied when drawing.
	bmpCanvas.G.DrawImage(bmpTest_I4, 1*hw, 0*hh)
	
	; R1C3 - 256-color (8bpp) image
	bmpTest_I8 := new OGdip.Bitmap(bmpHalf)
	bmpTest_I8.ConvertFormat("I8", "Web", "8x8")   ; Convert with ordered dithering.
	bmpCanvas.G.DrawImage(bmpTest_I8, 2*hw, 0*hh)
	
	
	; R2C1 - Blur image
	bmpTest_Blurry := new OGdip.Bitmap(bmpHalf)
	bmpTest_Blurry.ApplyEffect("Blur", 8)
	bmpCanvas.G.DrawImage(bmpTest_Blurry, 0*hw, 1*hh)
	
	; R2C2 - Alter image's hue
	bmpTest_Hue := new OGdip.Bitmap(bmpHalf)
	bmpTest_Hue.ApplyEffect("HSL", 150, 0, 0)
	bmpCanvas.G.DrawImage(bmpTest_Hue, 1*hw, 1*hh)
	
	; R2C3 - Invert image with color matrix
	bmpTest_Mx := new OGdip.Bitmap(bmpHalf)
	bmpTest_Mx.ApplyEffect("ColorMatrix", [ [-1,0,0,0,1],[0,-1,0,0,1], [0,0,-1,0,1] ])
	bmpCanvas.G.DrawImage(bmpTest_Mx, 2*hw, 1*hh)
	
	
	; R3C1 - Flip image and use clipping for caleidoscopic appearance
	bmpTest_Flip := new OGdip.Bitmap(bmpHalf)
	bmpCanvas.G.SetClip(0*hw, 2*hh, 0.5*hw, 0.5*hh)  ; Clip quarter of image
	bmpCanvas.G.DrawImage(bmpTest_Flip, 0*hw, 2*hh)
	
	bmpTest_Flip.Rotate("X")  ; Part 2
	bmpCanvas.G.SetClip(0.5*hw, 2*hh, 0.5*hw, 0.5*hh)
	bmpCanvas.G.DrawImage(bmpTest_Flip, 0*hw, 2*hh)
	
	bmpTest_Flip.Rotate("Y")  ; Part 3
	bmpCanvas.G.SetClip(0.5*hw, 2.5*hh, 0.5*hw, 0.5*hh)
	bmpCanvas.G.DrawImage(bmpTest_Flip, 0*hw, 2*hh)
	
	bmpTest_Flip.Rotate("X")  ; Part 4
	bmpCanvas.G.SetClip(0*hw, 2.5*hh, 0.5*hw, 0.5*hh)
	bmpCanvas.G.DrawImage(bmpTest_Flip, 0*hw, 2*hh)
	bmpCanvas.G.ResetClip()
	
	; R3C2 - Rotate image by 45°
	bmpTest_R45 := new OGdip.Bitmap(bmpHalf)
	bmpCanvas.G.DrawImageC(bmpTest_R45, 1.5*hw, 2.5*hh, -45, 0.7)
	
	; R3C3 - Create histogram - see another function
	bmpHist := Example_CreateHistogram(bmpHalf, "MemBuffer")  ; Try "SetPixel"/"LockBits"!
	bmpCanvas.G.DrawImage(bmpHist, 2*hw, 2*hw)
	
	Return bmpCanvas
}

; This function creates histogram with one of three different methods
Example_CreateHistogram(source, method) {
	; Get histogram array, normalized to maximum value of all channels
	histData := source.GetHistogram("RGB", "MaxAll", 255)
	
	; Prepare to do hard work and measure it
	SetBatchLines -1
	ListLines Off
	timeStart := A_TickCount
	
	sizeX := histData.entries
	sizeY := source.height
	
	; Fast way: fill memory buffer first, then create image from it.
	If (method == "MemBuffer") {
		; Create memory buffer
		VarSetCapacity(memBuffer, source.height * histData.entries * 4)
		
		Loop % sizeY {
			py := A_Index-1
			
			Loop % sizeX {
				px := A_Index-1
				
				r := (histData.R[px]  >  py)  ?  0xFF : 0x20
				g := (histData.G[px]  >  py)  ?  0xFF : 0x20
				b := (histData.B[px]  >  py)  ?  0xFF : 0x20
				rgbColor := OGdip.RGB(r, g, b)
				
				NumPut(rgbColor, memBuffer, 4*(px + py * sizeY), "UInt")
			}
		}
		
		bmpHist := new OGdip.Bitmap(sizeX, sizeY, &memBuffer, "ARGB32", 4*sizeY)
		
	} Else
	; Slow way: set each pixel individually.
	If (method == "SetPixel") {
		bmpHist := new OGdip.Bitmap(source)
		
		Loop % sizeY {
			py := A_Index-1
			
			Loop % sizeX {
				px := A_Index-1
				
				r := (histData.R[px]  >  py)  ?  0xFF  : 0x20
				g := (histData.G[px]  >  py)  ?  0xFF  : 0x20
				b := (histData.B[px]  >  py)  ?  0xFF  : 0x20
				rgbColor := OGdip.RGB(r, g, b)
				
				bmpHist.SetPixel(px, py, rgbColor)
			}
		}
		
	} Else
	; Fast way: create image and get its data as memory buffer.
	If (method == "LockBits") {
		bmpHist := new OGdip.Bitmap(source)
		lockedBmpData := bmpHist.LockBits(0, 0, source.width, source.height)
		
		Loop % sizeY {
			py := A_Index-1
			
			Loop % sizeX {
				px := A_Index-1
				
				r := (histData.R[px]  >  py)  ?  0xFF  : 0x20
				g := (histData.G[px]  >  py)  ?  0xFF  : 0x20
				b := (histData.B[px]  >  py)  ?  0xFF  : 0x20
				rgbColor := OGdip.RGB(r, g, b)
				
				NumPut(rgbColor, 0+lockedBmpData.scan0, 4*px + lockedBmpData.stride*py, "UInt")
			}
		}
		
		bmpHist.UnlockBits(lockedBmpData)
		
	} Else {
		Return "There is no such method"
	}
	
	timeEnd := A_TickCount
	
	; Resulting histogram's bottom is on top, so flip it:
	bmpHist.Rotate("Y")
	
	; Print measured time
	timeString := Format("Histogram`n{1} method: {2} ms", method, timeEnd-timeStart)
	bmpHist.G.SetBrush(0xFFFFFFFF)    ; White brush for text
	bmpHist.G.SetOptions( {textHint:"BitmapHint"} )  ; Enable hinting, disable antialiasing
	bmpHist.G.DrawString(timeString, {family:"Arial", size:11}, 16, 16)
	
	Return bmpHist
}