include /masm32/include/windows.inc


; The address of the size of mine area.
MINE_WIDTH_PTR  equ     01005334h
MINE_HEIGHT_PTR equ     01005338h

; The address of mine data.
MINE_AREA       equ     01005340h

; The byte value of a mine.
MINE            equ     8Fh

; The pixel coordinate of the top-left corner is (12, 55).
TOP_LEFT_X      equ     12
TOP_LEFT_Y      equ     55


DllMain         proto   inst: HINSTANCE, reason: DWORD, reserved: DWORD

; The new window process callback.
WndProc         proto   wnd: HWND, msg: DWORD, wparam: WPARAM, lparam: LPARAM

; Get the mine area position by the mouse coordinate.
GetMineAreaPos  proto   pixel_x: DWORD, pixel_y: DWORD, x: ptr DWORD, y: ptr DWORD

; Check if a position has a mine.
HasMine         proto   x: DWORD, y: DWORD

Hook            proto

Unhook          proto