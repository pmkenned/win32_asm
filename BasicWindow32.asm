                                                ; Basic Window, 32 bit. V1.01
COLOR_WINDOW        EQU 5                       ; Constants
CS_BYTEALIGNWINDOW  EQU 2000h
CS_HREDRAW          EQU 2
CS_VREDRAW          EQU 1
CW_USEDEFAULT       EQU 80000000h
IDC_ARROW           EQU 7F00h
IDI_APPLICATION     EQU 7F00h
IMAGE_CURSOR        EQU 2
IMAGE_ICON          EQU 1
LR_SHARED           EQU 8000h
NULL                EQU 0
SW_SHOWNORMAL       EQU 1
WM_DESTROY          EQU 2
WS_EX_COMPOSITED    EQU 2000000h
WS_OVERLAPPEDWINDOW EQU 0CF0000h

WindowWidth         EQU 640
WindowHeight        EQU 480

extern _CreateWindowExA@48                      ; Import external symbols
extern _DefWindowProcA@16                       ; Windows API functions, decorated
extern _DispatchMessageA@4
extern _ExitProcess@4
extern _GetMessageA@16
extern _GetModuleHandleA@4
extern _IsDialogMessageA@8
extern _LoadImageA@24
extern _PostQuitMessage@4
extern _RegisterClassExA@4
extern _ShowWindow@8
extern _TranslateMessage@4
extern _UpdateWindow@4

global Start                                    ; Export symbols. The entry point

section .data                                   ; Initialized data segment
 WindowName db "Basic Window 32", 0
 ClassName  db "Window", 0

section .bss                                    ; Uninitialized data segment
 hInstance resd 1

section .text                                   ; Code segment
Start:
 push  NULL
 call  _GetModuleHandleA@4
 mov   dword [hInstance], EAX

 call  WinMain

.Exit:
 push  NULL
 call  _ExitProcess@4

WinMain:
 push  EBP                                      ; Set up a stack frame
 mov   EBP, ESP
 sub   ESP, 80                                  ; Space for 80 bytes of local variables

%define wc                 EBP - 80             ; WNDCLASSEX structure. 48 bytes
%define wc.cbSize          EBP - 80
%define wc.style           EBP - 76
%define wc.lpfnWndProc     EBP - 72
%define wc.cbClsExtra      EBP - 68
%define wc.cbWndExtra      EBP - 64
%define wc.hInstance       EBP - 60
%define wc.hIcon           EBP - 56
%define wc.hCursor         EBP - 52
%define wc.hbrBackground   EBP - 48
%define wc.lpszMenuName    EBP - 44
%define wc.lpszClassName   EBP - 40
%define wc.hIconSm         EBP - 36

%define msg                EBP - 32             ; MSG structure. 28 bytes
%define msg.hwnd           EBP - 32             ; Breaking out each member is not necessary
%define msg.message        EBP - 28             ; in this case, but it shows where each
%define msg.wParam         EBP - 24             ; member is on the stack
%define msg.lParam         EBP - 20
%define msg.time           EBP - 16
%define msg.pt.x           EBP - 12
%define msg.pt.y           EBP - 8

%define hWnd               EBP - 4

 mov   dword [wc.cbSize], 48                    ; [EBP - 80]
 mov   dword [wc.style], CS_HREDRAW | CS_VREDRAW | CS_BYTEALIGNWINDOW  ; [EBP - 76]
 mov   dword [wc.lpfnWndProc], WndProc          ; [EBP - 72]
 mov   dword [wc.cbClsExtra], NULL              ; [EBP - 68]
 mov   dword [wc.cbWndExtra], NULL              ; [EBP - 64]
 mov   EAX, dword [hInstance]                   ; Global
 mov   dword [wc.hInstance], EAX                ; [EBP - 60]

 push  LR_SHARED
 push  NULL
 push  NULL
 push  IMAGE_ICON
 push  IDI_APPLICATION
 push  NULL
 call  _LoadImageA@24                           ; Large program icon
 mov   dword [wc.hIcon], EAX                    ; [EBP - 56]

 push  LR_SHARED
 push  NULL
 push  NULL
 push  IMAGE_CURSOR
 push  IDC_ARROW
 push  NULL
 call  _LoadImageA@24                           ; Cursor
 mov   dword [wc.hCursor], EAX                  ; [EBP - 52]

 mov   dword [wc.hbrBackground], COLOR_WINDOW + 1  ; [EBP - 48]
 mov   dword [wc.lpszMenuName], NULL            ; [EBP - 44]
 mov   dword [wc.lpszClassName], ClassName      ; [EBP - 40]

 push  LR_SHARED
 push  NULL
 push  NULL
 push  IMAGE_ICON
 push  IDI_APPLICATION
 push  NULL
 call  _LoadImageA@24                           ; Small program icon
 mov   dword [wc.hIconSm], EAX                  ; [EBP - 36]

 lea   EAX, [wc]                                ; [EBP - 80]
 push  EAX
 call  _RegisterClassExA@4

 push  NULL
 push  dword [hInstance]                        ; Global
 push  NULL
 push  NULL
 push  WindowHeight
 push  WindowWidth
 push  CW_USEDEFAULT
 push  CW_USEDEFAULT
 push  WS_OVERLAPPEDWINDOW
 push  WindowName                               ; Global
 push  ClassName                                ; Global
 push  WS_EX_COMPOSITED
 call  _CreateWindowExA@48
 mov   dword [hWnd], EAX                        ; [EBP - 4]

 push  SW_SHOWNORMAL
 push  dword [hWnd]                             ; [EBP - 4]
 call  _ShowWindow@8

 push  dword [hWnd]                             ; [EBP - 4]
 call  _UpdateWindow@4

.MessageLoop:
 lea   EAX, [msg]                               ; [EBP - 32]
 push  NULL
 push  NULL
 push  NULL
 push  EAX
 call  _GetMessageA@16
 cmp   EAX, 0
 je    .Done

 lea   EAX, [msg]                               ; [EBP - 32]
 push  EAX
 push  dword [hWnd]                             ; [EBP - 4]
 call  _IsDialogMessageA@8                      ; For keyboard strokes
 cmp   EAX, 0
 jne   .MessageLoop                             ; Skip TranslateMessage and DispatchMessage

 lea   EAX, [msg]                               ; [EBP - 32]
 push  EAX
 call  _TranslateMessage@4

 lea   EAX, [msg]                               ; [EBP - 32]
 push  EAX

 call  _DispatchMessageA@4
 jmp   .MessageLoop

.Done:
 mov   ESP, EBP                                 ; Remove the stack frame
 pop   EBP
 xor   EAX, EAX
 ret

WndProc:
 push  EBP                                      ; Set up a Stack frame
 mov   EBP, ESP

%define hWnd    EBP + 8                         ; Location of the 4 passed parameters from
%define uMsg    EBP + 12                        ; the calling function
%define wParam  EBP + 16                        ; We can now access these parameters by name
%define lParam  EBP + 20

 cmp   dword [uMsg], WM_DESTROY                 ; [EBP + 12]
 je    WMDESTROY

DefaultMessage:
 push  dword [lParam]                           ; [EBP + 20]
 push  dword [wParam]                           ; [EBP + 16]
 push  dword [uMsg]                             ; [EBP + 12]
 push  dword [hWnd]                             ; [EBP + 8]
 call  _DefWindowProcA@16

 mov   ESP, EBP                                 ; Remove the stack frame
 pop   EBP
 ret   16                                       ; Pop 4 parameters off the stack and return

WMDESTROY:
 push  NULL
 call  _PostQuitMessage@4

 xor   EAX, EAX                                 ; WM_DESTROY has been processed, return 0
 mov   ESP, EBP                                 ; Remove the stack frame
 pop   EBP
 ret   16                                       ; Pop 4 parameters off the stack and return
