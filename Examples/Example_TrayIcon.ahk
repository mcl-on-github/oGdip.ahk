; This example is an obvious overkill, but it is nifty nonetheless.
; It draws simple icon and sets it as a tray icon 100+ times.


#Include ..\OGdip.ahk
OGdip.Startup()
OnExit(ObjBindMethod(OGdip, "Shutdown"))
CC := {Base:{__Get:OGdip.GetColor}}

b64_numbers := ""
. "iVBORw0KGgoAAAANSUhEUgAAAEcAAAAHCAYAAABa6FBzAAAAXElEQVQ4y+2TMQ4AIAgD7/+f"
. "1g9QBYXowOBgLcQcFGAYB+OOoSu/pRP0V+o4a+TnEXBwvEfgeHve9Fdw2IBrOJlwXsVhB+ck"
. "VmVwvJPN2rRMf8PJhPN7HCpitayZJxUl6W6fYe0AAAAASUVORK5CYII="


bmpNumbers := OGdip.Bitmap.FromBase64( b64_numbers )

bmpIcon := new OGdip.Bitmap(16, 16)
bmpIcon.G.Clear( 0x0 )
bmpIcon.G.SetBrush( CC.Black ).DrawRectangle(0, 0, 15, 15)
bmpIcon.G.SetBrush( CC.White )

Loop 100 {
	N1 := Floor((A_Index-1) / 10)
	N2 := Mod((A_Index-1), 10)
	
	bmpIcon.G.SetBrush( CC.White ).DrawRectangle(1, 1, 13,13)  ; BG
	bmpIcon.G.SetBrush( CC.Black ).DrawRectangle(2,10, N1, 3)  ; Progressbar
	bmpIcon.G.DrawImage(bmpNumbers, [2, 2], [N1*6, 0, 6, 7])   ; Number 1
	bmpIcon.G.DrawImage(bmpNumbers, [8, 2], [N2*6, 0, 6, 7])   ; Number 2
	hIcon := bmpIcon.GetHICON()
	
	Menu, Tray, Icon, % "HICON:*" . hIcon
	Sleep 50
}

bmpIcon.G.SetBrush( CC.White ).DrawRectangle(1, 1, 13, 13)
bmpIcon.G.SetBrush( CC.Black ).DrawImage(bmpNumbers, [2, 2], [60, 0, 11, 7])
bmpIcon.G.SetBrush( CC.Black ).DrawRectangle(2, 10, 11, 3)
hIcon := bmpIcon.GetHICON()

Menu, Tray, Icon, % "HICON:*" . hIcon

Sleep 3000
bmpNumbers := ""
bmpIcon := ""
ExitApp