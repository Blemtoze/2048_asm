global _start

section .data
border1: db "######", 0xa
border1Len: equ $-border1
border2: db "#"
border2Len: equ $-border2
helloMsg1: db "Welcome to 2048! Rules are:"
helloMsg1Len: equ $-helloMsg1
helloMsg2: db "1. You play with powers of 2"
helloMsg2Len: equ $-helloMsg2
helloMsg3: db "2. You play in HEX format"
helloMsg3Len: equ $-helloMsg3
helloMsg4: db "3. Your goal --> B"
helloMsg4Len: equ $-helloMsg4
helloMsg5: db "Enter random key, then press <enter>: "
helloMsg5Len: equ $-helloMsg5
freeSpace19: db "                   "
freeSpace19Len: equ $-freeSpace19
commandLine: db ">>> "
commandLineLen: equ $-commandLine
controls: db "(u)p, (l)eft, (d)own, (r)ight, (b)ack, (e)xit"
controlsLen: equ $-controls
winMsg: db "⁚⁛⁚⁛⁚⁛⁚⁛⁚⁛Congratulations! You're win!⁚⁛⁚⁛⁚⁛⁚⁛⁚⁛"
winMsgLen: equ $-winMsg
loseMsg: db "You Lose!☹ ☹ ☹ "
loseMsgLen: equ $-loseMsg
opportunityMsg: db "No more turns. Continue game? (y -- yes, n -- no)"
opportunityMsgLen: equ $-opportunityMsg
endMsg: db "See You Next Time!"
endMsgLen: equ $-endMsg
field: db 0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30
fieldLen: equ $-field
testField: db 0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30
testFieldLen: equ $-testField
testField2: db 0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30
testFieldLen2: equ $-testField
temp: db 0
tempLen: equ $-temp
NL: db 0xa
NLLen: equ $-NL
generationOverflow: db 0 
isIgnore: db 0
genSeed: db 0x59;Y
genHandle: dd 0 
canRestore: db 0
isEqual: db 0

section .text
PrintNL:; Make newline
pushad
mov edx, NLLen
mov ecx, NL
mov ebx, 1 
mov eax, 4 
int 0x80
popad
ret

PrintFreeSpace19:
pushad
mov edx, freeSpace19Len
mov ecx, freeSpace19
mov ebx, 1
mov eax, 4
int 0x80
popad
ret

PrintBorder1: ;print low and high borders
pushad
call PrintFreeSpace19
mov edx, border1Len
mov ecx, border1
mov ebx, 1
mov eax, 4
int 0x80
popad
ret

PrintBorder2: ;print #
pushad
mov edx, border2Len
mov ecx, border2
mov ebx, 1
mov eax, 4
int 0x80
popad
ret

PrintCenter:; Print center field in game
pushad
mov ecx, field-4
mov edx, 4
CenterCycle:
call PrintFreeSpace19
call PrintBorder2
add ecx, edx
mov ebx, 1 
mov eax, 4
int 0x80
call PrintBorder2
call PrintNL
inc byte [temp]
cmp byte [temp], 4 
jne CenterCycle
mov byte [temp], 0
popad
ret

PrintGrid: ;Print game field
call PrintBorder1
call PrintCenter
call PrintBorder1
ret

PrintHello:
pushad
mov edx, helloMsg1Len
mov ecx, helloMsg1
mov ebx, 1
mov eax, 4
int 0x80
call PrintNL
mov edx, helloMsg2Len
mov ecx, helloMsg2
mov ebx, 1
mov eax, 4
int 0x80
call PrintNL
mov edx, helloMsg3Len
mov ecx, helloMsg3
mov ebx, 1
mov eax, 4
int 0x80
call PrintNL
mov edx, helloMsg4Len
mov ecx, helloMsg4
mov ebx, 1
mov eax, 4
int 0x80
call PrintNL
mov edx, helloMsg5Len
mov ecx, helloMsg5
mov ebx, 1 
mov eax, 4 
int 0x80
call PrintNL
popad
ret

PrintControls:
pushad
mov edx, controlsLen
mov ecx, controls
mov ebx, 1
mov eax, 4
int 0x80
call PrintNL
popad
ret

PrintCommandLine:
pushad
mov edx, commandLineLen
mov ecx, commandLine
mov ebx, 1
mov eax, 4
int 0x80
popad
ret

Opportunity:
pushad
OpportunityCycle:
call PrintOpp
call PrintNL
call PrintCommandLine
mov byte [isIgnore], 0 ; unset ignore status
mov eax, 3 
mov ebx, 0 
mov ecx, temp
mov edx, 2
int 0x80
mov al, byte [temp]
mov byte [temp], 0 
cmp al, 0x59;Y
je ReEnter
cmp al, 0x79;y
je ReEnter
cmp al, 0x4E;N
je GameOver
cmp al, 0x6E;n
je GameOver
jmp OpportunityCycle
popad

PrintOpp:
pushad
times 40 call PrintNL
call FieldUpdateNums
call PrintControls
call PrintGrid
mov edx, opportunityMsgLen
mov ecx, opportunityMsg
mov ebx, 1 
mov eax, 4 
int 0x80
popad
ret

PrintWin:
pushad
mov edx, winMsgLen
mov ecx, winMsg
mov ebx, 1
mov eax, 4
int 0x80
call PrintNL
call PrintGrid
popad
ret

PrintLose:
pushad
mov edx, loseMsgLen
mov ecx, loseMsg
mov ebx, 1
mov eax, 4
int 0x80
call PrintNL
call PrintGrid
popad
ret

PrintExit:
pushad
mov edx, endMsgLen
mov ecx, endMsg
mov ebx, 1 
mov eax, 4 
int 0x80
call PrintNL
popad
ret

GenRandom:;Generate "random" number
pushad
mov al, byte [genSeed]
mov byte [genHandle], al
xor ecx, ecx
xor edx, edx
xor eax, eax
mov dl, 0x6D ;multiply
mov dh, 0x31 ;add
CycleGetRandom:
cmp cl, 0x11
je SetGenerationOverflow
mov al, byte [genHandle]
mul dl 
add al, dh 
and al, 1111b 
mov byte [genHandle], al
inc cl
movzx eax, al
cmp byte [field + eax], 0x30 
jne CycleGetRandom
inc byte [field + eax]
and byte [genHandle], 111b;2 times of 7 is '2' 
cmp byte [genHandle], 110b;
ja IncreaseTwise
jmp SetGenerationOverflowRet
IncreaseTwise:
inc byte [field + eax]
SetGenerationOverflowRet:
mov ch, byte [field + eax]
mov byte [genHandle], 0
call UpdateSeed
popad
ret

SetGenerationOverflow:
mov byte [generationOverflow], 1 
jmp SetGenerationOverflowRet

UpdateSeed:
inc byte [genSeed]
cmp byte [genSeed], 0xFF
jne UpdateSeedEnd
mov byte [genSeed], 0x31
UpdateSeedEnd:
ret

ReadCharMakeMove: ;Read control keys
pushad
call PrintCommandLine
mov byte [isIgnore], 0 ; unset ignore status
mov eax, 3 
mov ebx, 0 
mov ecx, temp
mov edx, tempLen
int 0x80
mov al, byte [temp]
mov byte [temp], 0 
cmp al, 0x62; b for step back
je StepBack
cmp al, 0x64; d for down
je MovementDownJump
cmp al, 0x65; e for exit
je ExitProgram
cmp al, 0x6C; l for left
je MovementLeftJump
cmp al, 0x72; r for right
je MovementRightJump
cmp al, 0x75; u for up
je MovementUpJump
; cmp al, 0x77; w for win
; je MovementWin
ReadCharRet:
cmp al, 0 ;after successful key infup we put al to zero, so non-zero -- non infup
jne IgnoreInput
mov byte [canRestore], 1
IgnoreInputRet:
popad
ret

; MovementWin:
; pushad
; xor ecx, ecx
; MovWinJmp:
; mov dword [field + ecx], 0x41
; inc cl 
; cmp cl, 16 
; jne MovWinJmp
; popad
; jmp IgnoreInputRet

IgnoreInput:
mov byte [isIgnore], 1 
jmp IgnoreInputRet

CompareFields:
pushad
xor eax, eax
xor ebx, ebx
mov eax, 0
CompareFieldsCycle:
inc eax
cmp eax, 17
je Equal
mov bl, byte[testField2 + eax - 1]
cmp bl, byte[field + eax - 1]
je CompareFieldsCycle
jmp NonEqual
Equal:
mov byte [isEqual], 1 
NonEqual:
popad
ret

CanMoveLeft:
mov byte [isEqual], 0 
call BackupField2
call MovementLeft
call CompareFields
call RestoreField2
ret

CanMoveRight:
mov byte [isEqual], 0 
call BackupField2
call MovementRight
call CompareFields
call RestoreField2
ret

CanMoveUp:
mov byte [isEqual], 0 
call BackupField2
call MovementUp
call CompareFields
call RestoreField2
ret

CanMoveDown:
mov byte [isEqual], 0 
call BackupField2
call MovementDown
call CompareFields
call RestoreField2
ret

MovementDownJump: ;Help func
call CanMoveDown
cmp byte [isEqual], 1 
je IgnoreInput
call BackupField
call MovementDown 
jmp ReadCharRet

MovementDown: 
xor eax, eax
call ShiftDown
call DownCombine
call ShiftDown
ret

MovementUpJump: ;Help func
call CanMoveUp
cmp byte [isEqual], 1 
je IgnoreInput
call BackupField
call MovementUp 
jmp ReadCharRet

MovementUp:
xor eax, eax
call ShiftUp
call UpCombine
call ShiftUp
ret

MovementLeftJump: ;Help func
call CanMoveLeft
cmp byte [isEqual], 1
je IgnoreInput
call BackupField
call MovementLeft 
jmp ReadCharRet

MovementLeft:
xor eax, eax
call ShiftLeft
call LeftCombine
call ShiftLeft
ret

MovementRightJump: ;Help func
call CanMoveRight
cmp byte [isEqual], 1
je IgnoreInput
call BackupField
call MovementRight 
jmp ReadCharRet

MovementRight:
xor eax, eax
call ShiftRight
call RightCombine
call ShiftRight
ret

ShiftLeft:
pushad
mov byte [temp], 3
ShiftLeftCycle:
xor eax, eax
xor ebx, ebx
xor ecx, ecx
xor edx, edx
ShiftLeftRowCycle:
mov cl, 4
ShiftLeftRow:
inc dl
dec cl
cmp cl, 0
je ShiftLeftRowUpdate
cmp byte [field + edx + eax - 1], 0x30
jne ShiftLeftRow
mov bl, byte [field + edx + eax]
mov byte [field + edx + eax - 1], bl
mov byte [field + edx + eax], 0x30
xor ebx, ebx
jmp ShiftLeftRow
ShiftLeftRowUpdate:
cmp eax, 0xC
je EndShiftLeftCycle
add eax, 4 
xor edx, edx
jmp ShiftLeftRowCycle
EndShiftLeftCycle:
dec byte [temp]
cmp byte [temp], 0 
jne ShiftLeftCycle
popad
ret

LeftCombine:
pushad
xor edx, edx
xor ebx, ebx
LeftCombineCycle:
cmp bl, 16
je LeftCombineEnd
inc bl 
test bl, 00000011b ;skip compare between rows
jz LeftCombineCycle
mov dl, byte [field + ebx - 1]
cmp byte [field + ebx], dl
je LeftMakeCombineCheck
jmp LeftCombineCycle
LeftMakeCombineCheck:
cmp byte [field + ebx - 1], 0x30
je LeftCombineCycle
inc byte [field + ebx - 1]
mov byte [field + ebx], 0x30 
jmp LeftCombineCycle
LeftCombineEnd:
popad
ret

ShiftRight:
pushad
mov byte [temp], 3
ShiftRightCycle:
xor eax, eax
xor ebx, ebx
xor ecx, ecx
xor edx, edx
ShiftRightRowCycle:
mov cl, 0
mov dl, 4
ShiftRightRow:
dec dl
inc cl
cmp cl, 4
je ShiftRightRowUpdate
cmp byte [field + edx + eax], 0x30
jne ShiftRightRow
mov bl, byte [field + edx + eax - 1]
mov byte [field + edx + eax], bl
mov byte [field + edx + eax - 1], 0x30
xor ebx, ebx
jmp ShiftRightRow
ShiftRightRowUpdate:
cmp eax, 0xC
je EndShiftRightCycle
add eax, 4 
jmp ShiftRightRowCycle
EndShiftRightCycle:
dec byte [temp]
cmp byte [temp], 0 
jne ShiftRightCycle
popad
ret

RightCombine:
pushad
xor edx, edx
mov ebx, 16
RightCombineCycle:
cmp bl, 0
je RightCombineEnd
dec bl 
test bl, 00000011b 
jz RightCombineCycle
mov dl, byte [field + ebx]
cmp byte [field + ebx - 1], dl
je RightMakeCombineCheck
jmp RightCombineCycle
RightMakeCombineCheck:
cmp byte [field + ebx], 0x30
je RightCombineCycle
inc byte [field + ebx]
mov byte [field + ebx - 1], 0x30 
jmp RightCombineCycle
RightCombineEnd:
popad
ret

ShiftUp:
pushad
mov byte [temp], 3
ShiftUpCycle:
xor eax, eax
xor ebx, ebx
xor ecx, ecx
xor edx, edx
ShiftUpColCycle:
mov ecx, 0
ShiftUpCol:
add edx, 4
inc cl
cmp cl, 4
je ShiftUpColUpdate
cmp byte [field + edx + eax - 4], 0x30
jne ShiftUpCol
mov bl, byte [field + edx + eax]
mov byte [field + edx + eax - 4], bl
mov byte [field + edx + eax], 0x30
xor ebx, ebx
jmp ShiftUpCol
ShiftUpColUpdate:
cmp eax, 0x3
je EndShiftUpCycle
inc eax
xor edx, edx
jmp ShiftUpColCycle
EndShiftUpCycle:
dec byte [temp]
cmp byte [temp], 0 
jne ShiftUpCycle
popad
ret

UpCombine:
pushad
xor eax, eax
xor ebx, ebx
xor ecx, ecx
xor edx, edx
mov ebx, 0
UpCombineCycle:
cmp bl, 12
je UpCombineEnd
inc bl
mov dl, byte [field + ebx + 3]
cmp byte [field + ebx - 1], dl
je UpMakeCombineCheck
jmp UpCombineCycle
UpMakeCombineCheck:
cmp byte [field + ebx - 1], 0x30
je UpCombineCycle
inc byte [field + ebx - 1]
mov byte [field + ebx + 3], 0x30 
jmp UpCombineCycle
UpCombineEnd:
popad
ret

ShiftDown:
pushad
mov byte [temp], 3
ShiftDownCycle:
mov eax, -3
xor ebx, ebx
xor ecx, ecx
xor edx, edx
ShiftDownColCycle:
mov cl, 0
mov edx, 19
ShiftDownCol:
sub edx, 4
inc cl
cmp cl, 4
je ShiftDownColUpdate
cmp byte [field + edx + eax], 0x30
jne ShiftDownCol
mov bl, byte [field + edx + eax - 4]
mov byte [field + edx + eax], bl
mov byte [field + edx + eax - 4], 0x30
jmp ShiftDownCol
ShiftDownColUpdate:
cmp eax, 0
je EndShiftDownCycle
inc eax
jmp ShiftDownColCycle
EndShiftDownCycle:
dec byte [temp]
cmp byte [temp], 0 
jne ShiftDownCycle
popad
ret

DownCombine:
pushad
xor edx, edx
mov ebx, 16
DownCombineCycle:
cmp bl, 0
je DownCombineEnd
dec bl
mov dl, byte [field + ebx]
cmp byte [field + ebx - 4], dl
je DownMakeCombineCheck
jmp DownCombineCycle
DownMakeCombineCheck:
cmp byte [field + ebx], 0x30
je DownCombineCycle
inc byte [field + ebx]
mov byte [field + ebx - 4], 0x30 
jmp DownCombineCycle
DownCombineEnd:
popad
ret

BackupField:
pushad
mov ecx, 0
BackupCycle:
mov ebx, dword [field + ecx * 4]
mov dword [testField + ecx * 4], ebx
inc ecx
cmp ecx, 4
jne BackupCycle
popad
ret

RestoreField:
pushad
mov ecx, 0
RestoreCycle:
mov ebx, dword [testField + ecx * 4]
mov dword [field + ecx * 4], ebx
inc ecx
cmp ecx, 4
jne RestoreCycle
popad
ret

BackupField2:
pushad
mov ecx, 0
BackupCycle2:
mov ebx, dword [field + ecx * 4]
mov dword [testField2 + ecx * 4], ebx
inc ecx
cmp ecx, 4
jne BackupCycle2
popad
ret

RestoreField2:
pushad
mov ecx, 0
RestoreCycle2:
mov ebx, dword [testField2 + ecx * 4]
mov dword [field + ecx * 4], ebx
inc ecx
cmp ecx, 4
jne RestoreCycle2
popad
ret

CanMove:
mov byte [generationOverflow], 0 ;unset generationOverflow
mov byte [isEqual], 0 ;unset isEqual
call CanMoveRight
cmp byte [isEqual], 0 
je ReEnter
call CanMoveUp
cmp byte [isEqual], 0
je ReEnter
call CanMoveLeft
cmp byte [isEqual], 0 
je ReEnter
call CanMoveDown
cmp byte [isEqual], 0 
je ReEnter
call Opportunity
jmp GameOver

FieldUpdateNums: ; Chekc field for more than 0x39 code
pushad
xor ecx, ecx
UpdateCycle:
cmp byte [field + ecx], 0x3A
je ChangeNum
inc ecx
cmp ecx, 16
je EndFieldUpdateNums
jmp UpdateCycle
ChangeNum:
mov byte [field + ecx], 0x41
inc ecx
jmp UpdateCycle
EndFieldUpdateNums:
popad
ret

AnyKeyPress:
pushad
call PrintCommandLine
mov eax, 3 
mov ebx, 0 
mov ecx, genSeed 
mov edx, 2
int 0x80
popad
ret

StepBack:
cmp byte [canRestore], 0 
je IgnoreInput
call RestoreField
mov byte [canRestore], 0
jmp IgnoreInput

CheckFieldForWin:
pushad
mov ecx, 0 
CheckFieldForWinCycle:
cmp byte [field + ecx], 0x42
je Win
inc ecx
cmp ecx, 16
jne CheckFieldForWinCycle
popad
ret

Game:
times 40 call PrintNL
call PrintHello
call AnyKeyPress
times 2 call GenRandom
ReEnter:
call FieldUpdateNums
times 40 call PrintNL 
call PrintControls
call PrintGrid
call ReadCharMakeMove
cmp byte [isIgnore], 1 
je ReEnter
call CheckFieldForWin
call GenRandom
call CanMove
ret

_start: 
call Game

Win:
times 40 call PrintNL
call PrintWin
jmp ExitProgram

GameOver:
times 40 call PrintNL
call PrintLose
jmp ExitProgram

ExitProgram:
call PrintExit
mov eax, 1 
int 0x80
