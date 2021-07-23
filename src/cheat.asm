.386
.model flat, stdcall
option casemap :none

include cheat.inc

include /masm32/include/masm32rt.inc


.const
cheat_title     BYTE    "Mlnesweeper", 0
origin_title    BYTE    "Minesweeper", 0


.data
; The original window process callback.
wnd_proc        LPVOID  NULL
; The handle of the main window.
main_wnd        HWND    NULL


.code
DllMain     proc    inst: HINSTANCE, reason: DWORD, reserved: DWORD
    .if     reason == DLL_PROCESS_ATTACH
        invoke  Hook
    .elseif reason == DLL_PROCESS_DETACH
        invoke  Unhook
    .endif
    mov     eax, TRUE
    ret
DllMain     endp


WndProc     proc    wnd: HWND, msg: DWORD, wparam: WPARAM, lparam: LPARAM
    local   @pixel_x: DWORD
    local   @pixel_y: DWORD
    local   @mine_x: DWORD
    local   @mine_y: DWORD

    pushad
    .if     msg == WM_MOUSEMOVE
        ; Get the pixel coordinates of the mouse.
        mov     eax, lparam
        movzx   ecx, ax
        mov     @pixel_x, ecx
        shr     eax, 16
        mov     @pixel_y, eax

        ; Convert them into the position of the mine area.
        invoke  GetMineAreaPos, @pixel_x, @pixel_y, addr @mine_x, addr @mine_y
        .if     @mine_x < 0 || @mine_y < 0
            invoke  SetWindowText, main_wnd, addr origin_title
            jmp     _end
        .endif

        ; Check the mine.
        invoke  HasMine, @mine_x, @mine_y
        .if     eax == TRUE
            invoke  SetWindowText, main_wnd, addr cheat_title
        .else
            invoke  SetWindowText, main_wnd, addr origin_title
        .endif
    .endif

_end:
    popad
    ; Call the original window process callback.
    push    lparam
    push    wparam
    push    msg
    push    wnd
    mov     edx, wnd_proc
    call    edx
    ret
WndProc     endp


Hook        proc
    .if     wnd_proc != NULL
        jmp     _end
    .endif

    invoke  FindWindow, NULL, addr origin_title
    .if     eax == NULL
        invoke  OutputDebugStringW, uc$("Failed to find the game window.")
        jmp     _end
    .endif
    mov     main_wnd, eax
    invoke  SetWindowLongW, main_wnd, GWL_WNDPROC, offset WndProc
    mov     wnd_proc, eax

_end:
    ret
Hook        endp


Unhook      proc
    invoke  SetWindowLongW, main_wnd, GWL_WNDPROC, wnd_proc
    ret
Unhook      endp


GetMineAreaPos  proc    pixel_x: DWORD, pixel_y: DWORD, x: ptr DWORD, y: ptr DWORD
    local   @mine_width: DWORD
    local   @mine_height: DWORD

    mov     eax, x
    mov     dword ptr [eax], -1
    mov     eax, y
    mov     dword ptr [eax], -1

    .if     pixel_x < TOP_LEFT_X || pixel_y < TOP_LEFT_Y
        jmp     _end
    .endif

    ; Get the size of the mine area.
    mov     eax, dword ptr [MINE_WIDTH_PTR]
    mov     @mine_width, eax
    mov     eax, dword ptr [MINE_HEIGHT_PTR]
    mov     @mine_height, eax

    mov     eax, pixel_x
    sub     eax, TOP_LEFT_X
    ; The side length of a block is 16.
    shr     eax, 4
    inc     eax
    .if     eax > @mine_width
        jmp     _end
    .endif
    mov     ebx, x
    mov     dword ptr [ebx], eax

    mov     eax, pixel_y
    sub     eax, TOP_LEFT_Y
    shr     eax, 4
    inc     eax
    .if     eax > @mine_height
        jmp     _end
    .endif
    mov     ebx, y
    mov     dword ptr [ebx], eax

_end:
    ret
GetMineAreaPos  endp


HasMine         proc    x: DWORD, y: DWORD
    mov     ebx, MINE_AREA
    mov     eax, y
    ; Each row of mine data is 32 bytes.
    shl     eax, 5
    add     eax, x
    .if     byte ptr [ebx + eax] == MINE
        mov     eax, TRUE
    .else
        xor     eax, eax
    .endif
    ret
HasMine         endp

end DllMain