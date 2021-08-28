; This example shows some basic functions of OGdip.Image object:
;   - Loading image from file
;   - Retrieving image information (size, format, resolution, ...)
;   - Reading and writing image metadata properties
;   - Reading and writing multiframe images
;   - Using options to save images in different formats
; Look for !! comments


#SingleInstance Force
#NoEnv
#Warn
SetWorkingDir %A_ScriptDir%

#Include ..\OGdip.ahk
OGdip.Startup()
OnExit(ObjBindMethod(OGdip, "Shutdown"))


imgViewMeta := { images:[], controls:{}, lists:{}
	, currentImage: 0
	, currentIndex: 0
	, currentFrame: 0
	, currentFrameCount: 0
	, currentProperty: "" }

imgViewMeta.lists.formats        := ["BMP", "PNG", "JPG", "TIF", "GIF"]
imgViewMeta.lists.optQuality     := ["Auto", 100, 80, 60, 40, 20, 0]
imgViewMeta.lists.optTransform   := ["None", "Rotate 90°", "Rotate 180°", "Rotate 270°", "Flip X", "Flip Y"]
imgViewMeta.lists.optCompression := ["None", "LZW", "RLE", "CCITT3", "CCITT4"]
imgViewMeta.lists.optSaveAsCmyk  := ["No", "Yes"]
imgViewMeta.lists.optMultiframe  := ["Active frame: 1 file", "All frames: N files", "All frames: 1 file", "Reverse frames: 1 file"]
imgViewMeta.lists.optMonoframe   := ["Active frame: 1 file", "All frames: N files"]


CreateImgViewGui()  ; Keeping global scope as clean as possible
Return


JoinList(arr) {
	result := ""
	Loop % arr.Length() {
		result .= "|" . arr[A_Index]
	}
	Return result
}

IndexOf(arr, value) {
	Loop % arr.Length() {
		If (arr[A_Index] = value)
			Return A_Index
	}
}


CreateImgViewGui() {
	Global imgViewMeta
	
	Gui, imgView:New, +LabelIVGui_On  +E0x02080000  ; WS_EX_COMPOSITED & WS_EX_LAYERED => Double Buffer - reduces flicker on bitmap reloading
	
	; Left panel - Image preview, page buttons and short info
	Gui, imgView:Add, Picture, x010 y010 w250 h250 HWNDhImgPreview +0x0E
	Gui, imgView:Add, Button , x010 y270 w040 h030 HWNDhFrameFirst  , |<<
	Gui, imgView:Add, Button , x060 y270 w070 h030 HWNDhFramePrev   , <
	Gui, imgView:Add, Button , x140 y270 w070 h030 HWNDhFrameNext   , >
	Gui, imgView:Add, Button , x220 y270 w040 h030 HWNDhFrameLast   , >>|
	Gui, imgView:Add, Text   , x010 y310 w250 r3   HWNDhImageInfo   , Frame 0/0
	
	; Center panel - properties list and editing field
	Gui, imgView:Add, ListBox, x280 y010 w150 h250 HWNDhPropertyList  +0x100
	Gui, imgView:Add, Button , x280 y270 w150 h030 HWNDhPropertySet   , Set property ↑
	Gui, imgView:Add, Edit   , x280 y310 w150 r1   HWNDhPropertyValue  
	
	; Right panel - Save button and set of options
	Gui, imgView:Add, Button , x450 y010 w120 h040 HWNDhSaveButton    , Save...
	Gui, imgView:Add, Text   , x450 y060 w120 h020 HWNDhFormatText    , Save format:
	Gui, imgView:Add, DDL    , x450 y080 w120      HWNDhFormatValue   , % JoinList(imgViewMeta.lists.formats)
	Gui, imgView:Add, Text   , x450 y130 w120 h020 HWNDhOption1Text   , Option 1:
	Gui, imgView:Add, DDL    , x450 y150 w120      HWNDhOption1Value  , 
	Gui, imgView:Add, Text   , x450 y190 w120 h020 HWNDhOption2Text   , Option 2:
	Gui, imgView:Add, DDL    , x450 y210 w120      HWNDhOption2Value  , 
	Gui, imgView:Add, Text   , x450 y290 w120 h020 HWNDhOptionMFText  , Multiframe:
	Gui, imgView:Add, DDL    , x450 y310 w120      HWNDhOptionMFValue , 
	
	hControls := {}
	hControls.ImgPreview := hImgPreview
	hControls.FrameFirst := hFrameFirst
	hControls.FramePrev  := hFramePrev
	hControls.FrameNext  := hFrameNext
	hControls.FrameLast  := hFrameLast
	hControls.ImageInfo  := hImageInfo
	
	hControls.PropertyList  := hPropertyList
	hControls.PropertySet   := hPropertySet
	hControls.PropertyValue := hPropertyValue
	
	hControls.SaveButton    := hSaveButton
	hControls.FormatText    := hFormatText
	hControls.FormatValue   := hFormatValue
	hControls.Option1Text   := hOption1Text
	hControls.Option1Value  := hOption1Value
	hControls.Option2Text   := hOption2Text
	hControls.Option2Value  := hOption2Value
	hControls.OptionMFText  := hOptionMFText
	hControls.OptionMFValue := hOptionMFValue
	
	; Associate GLabels
	GuiControl, +gSelectImages, % hControls.ImgPreview
	
	GuiControl, +gChangeFrame , % hControls.FrameFirst
	GuiControl, +gChangeFrame , % hControls.FramePrev
	GuiControl, +gChangeFrame , % hControls.FrameNext
	GuiControl, +gChangeFrame , % hControls.FrameLast
	
	GuiControl, +gReadProperty , % hControls.PropertyList
	GuiControl, +gWriteProperty, % hControls.PropertySet
	
	GuiControl, +gSaveImageToFile , % hControls.SaveButton
	GuiControl, +gChangeSaveFormat, % hControls.FormatValue
	
	GuiControl, Text, % hControls.ImgPreview, Click here`nor drag'n'drop files`nto load images
	GuiControl, Disable, % hControls.SaveButton
	GuiControl, Disable, % hControls.PropertySet
	
	imgViewMeta.controls := hControls
	
	UpdateFrameNavButtons()
	Gui, imgView:Show, w580 h360
	
	Return
}


IVGui_OnDropFiles:
LoadImagesToViewer( StrSplit(A_GuiEvent, "`n") )
Return


IVGui_OnClose:
IVGui_OnEscape:
ExitApp



SelectImages() {
	FileSelectFile, imageFilelist, M3,, Select images to load...
	, % "Image Files (*.bmp; *.png; *.gif; *.tif; *.tiff; *.jpg; *.jpeg)"
	
	If (imageFilelist == "")
		Return
	
	; Convert to array of full path names
	imageFilelist := StrSplit(imageFilelist, "`n")
	imagesPath := imageFilelist.RemoveAt(1)
	Loop % imageFilelist.Length() {
		imageFilelist[A_Index] := imagesPath . "\" . imageFilelist[A_Index]
	}
	
	LoadImagesToViewer(imageFilelist)
}


LoadImagesToViewer(imageFilelist) {
	Global imgViewMeta
	
	; Clear previous images
	imgViewMeta.images := []
	
	; Load dropped images
	Loop, % imageFilelist.Length()
	{
		; !!  Creating Image object from filename:
		oImage := new OGdip.Bitmap( imageFilelist[A_Index] )
		
		; If image can't be loaded from given file,
		; its GDI+ pointer will be zero.
		If (oImage._pImage == 0)
			Continue
		
		imgViewMeta.images.Push(oImage)
	}
	
	SelectImageToViewer(1, 1)
	
	Return
}


SelectImageToViewer(imageIndex, frameIndex) {
	Global imgViewMeta
	
	imageIndex := Min(imageIndex, imgViewMeta.images.Length())
	
	oImage := imgViewMeta.currentImage := imgViewMeta.images[imageIndex]
	
	If (oImage == "") {
		imgViewMeta.currentIndex := 0
		imgViewMeta.currentFrame := 0
		imgViewMeta.currentFrameCount := 0
		
		oDummy := new OGdip.Bitmap(10,10)
		oDummy.SetToControl(imgViewMeta.controls.ImgPreview)
		
	} Else {
		imgViewMeta.currentIndex      := imageIndex
		imgViewMeta.currentFrameCount := oImage.GetFrameCount()
		imgViewMeta.currentFrame      := Min(frameIndex, imgViewMeta.currentFrameCount)
		
		; !!  Selecting active frame in a multiframe image.
		oImage.SelectFrame(imgViewMeta.currentFrame)
		
		; !!  Create scaled-down version of image
		; Often we can use simple method to determine image size:
		;   > imgW := oImage.Width
		;   > imgH := oImage.Height
		; but for multiframe images this will return only size of the first frame.
		; We need to use .GetBounds to determine size of each frame individually.
		imgBounds := oImage.GetBounds()
		imgW := imgBounds[3]
		imgH := imgBounds[4]
		
		previewScaleFactor := Min(1, 250 / imgW, 250 / imgH )
		imgW *= previewScaleFactor
		imgH *= previewScaleFactor
		
		; !!  Create empty bitmap and draw resized image to preview
		oPreview := new OGdip.Bitmap(250,250)
		oPreview.G.DrawImage(oImage, 0, 0, imgW, imgH)
		
		; !!  Put preview bitmap to GUI Picture control (requires style +0x0E to be set)
		oPreview.SetToControl(imgViewMeta.controls.ImgPreview, "Fit")
	}
	
	UpdateImageInfotext()
	UpdatePropertyList()
	UpdateFrameNavButtons()
}


UpdatePropertyList() {
	Global imgViewMeta
	
	If (imgViewMeta.currentImage == "") {
		GuiControl,, % imgViewMeta.PropertyList, % "|"
		Return
	}
	
	; !!  Getting all metadata properties for the current Image.
	imgProperties := imgViewMeta.currentImage.GetAllProperties()
	propertyNames := []
	
	For propName, propInfo In imgProperties {
		propertyNames.Push(propName)
	}
	
	GuiControl,, % imgViewMeta.controls.PropertyList, % JoinList(propertyNames)
	GuiControl,, % imgViewMeta.controls.PropertyValue
}


UpdateImageInfotext() {
	Global imgViewMeta
	
	oImage := imgViewMeta.currentImage
	
	If (oImage == "") {
		GuiControl,, % imgViewMeta.controls.ImageInfo, % "No image"
		Return
	}
	
	; !!  Retrieving various information about image
	imageInfo   := oImage.GetInfo()
	imageDPI    := oImage.GetResolution()
	imageBounds := oImage.GetBounds()
	
	GuiControl,, % imgViewMeta.controls.ImageInfo
	, % Format("Image {1}/{2}; Frame {3}/{4}; Size: {5}×{6}"
	.   "`n" . "Format: {7} {8}, Color space: {9}"
	.   "`n" . "DPI: {10:.1f}:{11:.1f}, Bounds: {12:d}:{13:d}:{14:d}:{15:d}"
	
	, imgViewMeta.currentIndex      ;  1
	, imgViewMeta.images.Length()   ;  2
	, imgViewMeta.currentFrame      ;  3
	, imgViewMeta.currentFrameCount ;  4
	, oImage.Width                  ;  5
	, oImage.Height                 ;  6
	, imageInfo.rawFormat           ;  7
	, oImage.GetPixelFormat(True)   ;  8
	, imageInfo.colorSpace          ;  9
	, imageDPI[1]                   ; 10
	, imageDPI[2]                   ; 11
	, imageBounds[1]                ; 12
	, imageBounds[2]                ; 13
	, imageBounds[3]                ; 14
	, imageBounds[4])               ; 15
}


UpdateFrameNavButtons() {
	Global imgViewMeta
	
	backAllowed := False
	|| (imgViewMeta.currentIndex > 1)
	|| (imgViewMeta.currentFrame > 1)
	
	frwdAllowed := False
	|| (imgViewMeta.currentIndex < imgViewMeta.images.Length())
	|| (imgViewMeta.currentFrame < imgViewMeta.currentFrameCount)
	
	GuiControl, % (backAllowed ? "Enable" : "Disable"), % imgViewMeta.controls.FrameFirst
	GuiControl, % (backAllowed ? "Enable" : "Disable"), % imgViewMeta.controls.FramePrev
	GuiControl, % (frwdAllowed ? "Enable" : "Disable"), % imgViewMeta.controls.FrameNext
	GuiControl, % (frwdAllowed ? "Enable" : "Disable"), % imgViewMeta.controls.FrameLast
	
	Return
}


ChangeFrame(hCtrl) {
	Global imgViewMeta
	
	If (hCtrl == imgViewMeta.controls.FrameFirst) {
		newImageIndex := 1
		newFrameIndex := 1
		
	} Else
	If (hCtrl == imgViewMeta.controls.FramePrev) {
		newImageIndex := imgViewMeta.currentIndex
		newFrameIndex := imgViewMeta.currentFrame - 1
		
		If (newFrameIndex < 1) {
			newFrameIndex := 999
			newImageIndex -= 1
		}
		
	} Else
	If (hCtrl == imgViewMeta.controls.FrameNext) {
		newImageIndex := imgViewMeta.currentIndex
		newFrameIndex := imgViewMeta.currentFrame + 1
		
		If (newFrameIndex > imgViewMeta.currentFrameCount) {
			newFrameIndex := 1
			newImageIndex += 1
		}
		
	} Else
	If (hCtrl == imgViewMeta.controls.FrameLast) {
		newImageIndex := imgViewMeta.images.Length()
		newFrameIndex := 999
	}
	
	SelectImageToViewer(newImageIndex, newFrameIndex)
}


ReadProperty() {
	Global imgViewMeta
	
	hPropValue := imgViewMeta.controls.PropertyValue
	hPropSet   := imgViewMeta.controls.PropertySet
	
	GuiControlGet, selectedPropertyName,, % imgViewMeta.controls.PropertyList
	
	; !!  Getting image property by name
	propertyInfo := imgViewMeta.currentImage.GetProperty(selectedPropertyName)
	imgViewMeta.currentProperty := propertyInfo
	
	If (IsObject(propertyInfo) == False) {
		GuiControl,, % hPropValue, % "<READ_ERROR>"
		GuiControl, Disable, % hPropValue
		GuiControl, Disable, % hPropSet
		
	} Else
	If (propertyInfo.value == "") {
		GuiControl,, % hPropValue, % Format("<BINARY:{}>", propertyInfo.length)
		GuiControl, Disable, % hPropValue
		GuiControl, Enable , % hPropSet
		GuiControl,, % hPropSet, % "Export property"
		
	} Else {
		GuiControl,, % hPropValue, % propertyInfo.value
		GuiControl, Enable, % hPropValue
		GuiControl, Enable, % hPropSet
		GuiControl,, % hPropSet, % "Set property ↑"
	}
}


WriteProperty(args*) {
	Global imgViewMeta
	
	newPropValue := ""
	GuiControlGet, newPropValue,, % imgViewMeta.controls.PropertyValue
	
	propInfo := imgViewMeta.currentProperty
	
	; !!  Export binary property to file
	If (propInfo.value == "") {
		FileSelectFile, outBinaryFile, 16
		, % Format("Image_{1}_{2}.bin", imgViewMeta.currentIndex, propInfo.propName)
		, Save image binary metadata, Binary file (*.bin)
		
		If (outBinaryFile != "") {
			outFile := FileOpen(outBinaryFile, "w")
			outFile.RawWrite( propInfo.GetAddress("binary"), propInfo.length )
			outFile.Close()
		}
		
		Return
	}
	
	; !!  Delete property if new value is empty
	If (newPropValue == "") {
		MsgBox, 0x24, Delete property?
		, % ("Delete property " . propInfo.propName . "?")
		
		IfMsgBox Yes
		{
			imgViewMeta.currentImage.RemoveProperty(propInfo.propId)
			UpdatePropertyList()
		}
		
		Return
	}
	
	; !!  Set property to Image and reload it to ensure that changes were made
	imgViewMeta.currentImage.SetProperty(propInfo.propId, propInfo.typeId, newPropValue)
	ReadProperty()
}



ChangeSaveFormat() {
	Global imgViewMeta
	
	hCtrl := imgViewMeta.controls
	GuiControlGet, saveFormat,, % hCtrl.FormatValue
	
	If (saveFormat = "JPG") {
		; Set option 1 to quality
		GuiControl,, % hCtrl.Option1Text , Quality:
		GuiControl,, % hCtrl.Option1Value, % JoinList(imgViewMeta.lists.optQuality)
		GuiControl, Choose, % hCtrl.Option1Value, 1
		GuiControl, Enable, % hCtrl.Option1Value
		
		; Set option 2 to transform
		GuiControl,, % hCtrl.Option2Text , Transform:
		GuiControl,, % hCtrl.Option2Value, % JoinList(imgViewMeta.lists.optTransform)
		GuiControl, Choose, % hCtrl.Option2Value, 1
		GuiControl, Enable, % hCtrl.Option2Value
		
		; Disable some multiframe options
		
	} Else
	If (saveFormat = "TIF") {
		; Set option 1 to compression
		GuiControl,, % hCtrl.Option1Text , Compression:
		GuiControl,, % hCtrl.Option1Value, % JoinList(imgViewMeta.lists.optCompression)
		GuiControl, Choose, % hCtrl.Option1Value, 1
		GuiControl, Enable, % hCtrl.Option1Value
		
		; Set option 2 to saveAsCmyk
		GuiControl,, % hCtrl.Option2Text , Save as CMYK:
		GuiControl,, % hCtrl.Option2Value, % JoinList(imgViewMeta.lists.optSaveAsCmyk)
		GuiControl, Choose, % hCtrl.Option2Value, 1
		GuiControl, Enable, % hCtrl.Option2Value
		
		; Enable some multiframe options
	} Else
	If (saveFormat = "GIF")
	|| (saveFormat = "BMP")
	|| (saveFormat = "PNG")
	{
		; Disable both options
		GuiControl, Disable, % hCtrl.Option1Value
		GuiControl, Disable, % hCtrl.Option2Value
	}
	
	; Multiframe options:
	GuiControlGet, lastMFValue,, % hCtrl.OptionMFValue
	lastMFIndex := IndexOf(imgViewMeta.lists.optMultiframe, lastMFValue)
	
	newMFList := ((saveFormat = "TIF") || (saveFormat = "GIF"))
	?  imgViewMeta.lists.optMultiframe
	:  imgViewMeta.lists.optMonoframe
	
	GuiControl,, % hCtrl.OptionMFValue, % JoinList(newMFList)
	GuiControl, Choose, % hCtrl.OptionMFValue, % (lastMFIndex > newMFList.Length()) ? 1 : lastMFIndex
	
	GuiControl, Enable, % hCtrl.SaveButton
	
	Return
}


SaveImageToFile() {
	Global imgViewMeta
	
	hCtrl := imgViewMeta.controls
	
	GuiControlGet, format  ,, % hCtrl.FormatValue
	GuiControlGet, option1 ,, % hCtrl.Option1Value
	GuiControlGet, option2 ,, % hCtrl.Option2Value
	GuiControlGet, optionMF,, % hCtrl.OptionMFValue
	
	FileSelectFile, outputFilename, S18
	, % ("Image." . format)
	, % "Image Files (*.bmp; *.png; *.gif; *.tif; *.tiff; *.jpg; *.jpeg)"
	
	If (outputFilename == "")
		Return
	
	RegexMatch(outputFilename, "O)^(.+?)(\.([^\.]+))?$", slicedFilename)
	outputFileNoExt  := slicedFilename[1]
	outputFileExt    := Format("{:L}", format)
	outputFilename   := outputFileNoExt . "." . outputFileExt
	
	
	saveOptions := {}
	
	If (format = "JPG") {
		; Quality - number from 0 to 100
		If (option1 != "Auto")
			saveOptions.quality := option1
		
		; Transform - one of the following values: 90, 180, 270, X, Y
		; Transform is possible when source image is also in JPEG format.
		; If quality option is omitted (auto), transform is (almost) lossless.
		If (option2 != "None") {
			saveOptions.transform := False ? ""
			:  (option2 == "Rotate 90°")  ?   90
			:  (option2 == "Rotate 180°") ?  180
			:  (option2 == "Rotate 270°") ?  270
			:  (option2 == "Flip X")      ?  "X"
			:  (option2 == "Flip Y")      ?  "Y"  :  90
		}
	}
	
	If (format = "TIF") {
		saveOptions.compression := option1
		
		; !!  Only presence of 'saveAsCmyk' key is important, its value is ignored.
		If (option2 = "Yes")
			saveOptions.saveAsCmyk := 1
	}
	
	
	If (optionMF == "Active frame: 1 file")
	|| (optionMF == "")
	{
		; !!  Save selected frame to file
		oImage := imgViewMeta.currentImage
		oImage.Save( outputFilename, saveOptions )
		
	} Else
	If (optionMF == "All frames: N files") {
		; Save each frame of each image to separate file:
		
		For imageIndex, oImage In imgViewMeta.images {
			imageFrameCount := oImage.GetFrameCount()
			
			If (imageFrameCount > 10) {
				MsgBox, 0x24, Warning: huge frame count
				, % Format("Image #{1} have {2} frames.`nStill want to save all of them?"
					, imageIndex, imageFrameCount)
				
				IfMsgBox No
					Continue
			}
			
			Loop % oImage.GetFrameCount() {
				loopItemFilename := Format("{1}_{2}-{3}.{4}"
				, outputFileNoExt
				, imageIndex
				, A_Index
				, outputFileExt)
				
				oImage.SelectFrame(A_Index)
				oImage.Save(loopItemFilename)
			}
		}
		
	} Else {
		; Start saving multiframe image
		saveInReverse := (optionMF == "Reverse frames: 1 file")
		firstImage := False
		dimension := (format == "GIF") ? "time" : "page"
		
		Loop % imgViewMeta.images.Length() {
			imageIndex := saveInReverse  ?  (imgViewMeta.images.Length() - A_Index + 1)  :  A_Index
			oImage := imgViewMeta.images[imageIndex]
			
			imageFrameCount := oImage.GetFrameCount()
			
			Loop % imageFrameCount {
				frameIndex := saveInReverse  ?  (imageFrameCount - A_Index + 1)  :  A_Index
				
				oImage.SelectFrame(frameIndex)
				
				If (firstImage == False) {
					; !!  First call to Save first frame, setting format and options
					saveOptions.multiframe := True
					oImage.Save(outputFilename, saveOptions)
					firstImage := oImage
					
				} Else {
					; !!  Adding frames to saved file
					firstImage.SaveAdd(dimension, oImage)
				}
			}
		}
		
		; !!  When all frames are saved, last call to flush image to disk.
		firstImage.SaveAdd()
	}
}
