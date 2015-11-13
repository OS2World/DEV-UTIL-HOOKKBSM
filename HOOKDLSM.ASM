;---------------------------------------------------------------------------;
; M.F.Kaplon  Begun:Wed  09-30-1992    Revised:Fri  08-06-1993
; hookdlsm.asn  ; "Copyright 1992 M.F. Kaplon"
;
; This is the dll to be used with hookkbsm.asm
; Its purpose is to test the system message stream for WM_CHAR and when
; selected keys are struck to post a message to hookkbsm using WM_USER+300h.
;
; The criteria for selection are on KeyStroke Down:
; Shift Key and either Alt or Ctrl down+valid Scan Code indicated
; If those criteria are met then the msg ID is changed to WM_USER+0cfffh
; after mp1 and mp2 of the message are obtained and the mp1 and mp2
; of the message to be posted to hookkbsm are changed to contain
; mp1 = Alt/Ctrl flag = 0/1 if Alt/Ctrl down ; mp2 = Scan Code
; of Key on Down Stroke
;
; Additionally, it records all messages (with any restrictions as coded )
; when the flag (set by Shift-Ctrl-LeftArrow(White)) RecordOn = 1. The flag is
; turned off by Shift-Ctrl-RightArrow(White). The messages are stored in a
; buffer that is created in hookdlsm and whose address is passed to hookkbsm
; in the register EAX when the procedure INITIALIZE is called with EAX = 0.
;
; The function InputHook monitors the System message queue and responds
; whenever the WinGetMsg or WinPeekMsg is about to return a message.
;
; This is assembled and linked as dll by calling  dll-w386  hookdlsm
; The cmd file dll-w386 also moves the created dll to  c:\os2\dll
;
; In calling the procedure "InputHook" or "Initialize"  in hookdlsm.dll
; from hookkbsm  Values are passed in registers and the procedures are
; called as DllProcAddr1 for InputHook and DllProcAddr2 for Initialize.
; Parameters are passed by placing values in  registers just prior to
; the call  and return also in registers.
; The functions examine the registers and take appropriate action.
;
; Fri  08-06-1993  Increased Storage Buffer to 56000 = 2000 messages
;                  Changed Jumps to Calls to Procedures in this dll
;
; Fri  11-12-1993  Added passing message on after added Toggle in hookkbsm
;---------------------------------------------------------------------------;
;
;------------------ PRELIMINARIES ----------------------

NUMBUFS            equ    1     ; Uncomment if need number routines

.386             ;preceeding .MODEL makes USE32 default
.MODEL           FLAT,SYSCALL,OS_OS2

RecdLnth            equ 28

INCL_DOSMEMMGR      equ  1
INCL_WINERRORS      equ  1
INCL_WIN            equ  1

INCLUDE      c:\toolkt21\asm\os2inc\os2def.inc  ;structure defns includes POINTL
INCLUDE      c:\toolkt21\asm\os2inc\pmwin.inc   ;structure defns POINTL defn required
INCLUDE      c:\toolkt21\asm\os2inc\bsememf.inc ;memory
INCLUDE      c:\toolkt21\asm\os2inc\pmerr.inc   ;errors
INCLUDELIB   c:\toolkt21\os2lib\os2386.lib      ;Library

INCLUDE      d:\os2_asm\doswin32.mac                       ;macros for calls

.STACK    4096

.DATA

IFDEF NUMBUFS                      ;To use  UNCOMMENT NUMBUFS equate above
  $DefineNumBufs
ENDIF

;------------- handles --------
hab               DWORD   ?
ih_hab            DWORD   ?    ;Anchor block handle
hook              DWORD   ?    ;Handle of hookkbsm from Shared Mem offset 0
hook_handle       DWORD   ?    ;Handle passed in message queue Fri  11-12-1993
hook_msgID        DWORD   ?    ;message ID
hook_mp1          DWORD   ?    ;mp1 of message
hook_mp2          DWORD   ?    ;mp2 of message

JR_Counter        DWORD   0    ;Counter for records in JournalRecord
JR_Count          DWORD   ?    ;Final Count of JournalRecord Session
RecordOn          DWORD   0    ;Flag INdicating Record Off/ON = 0/1
MaxCount          DWORD   1000  ;Maximum qmsg structure counts
AddrCtr           DWORD   0    ;increment counter
toggle             BYTE   1    ;toggle indicator 1/0 = On/Off
;------------ structures
ih_qmsg           DWORD   ?    ;Address of InputHook Message structure
ih_opt            DWORD   ?    ;Change Option

;----Shared Memory Variables---
PlayBackQMSG    DWORD  56000 dup(0)  ;store 2000 recorded messages RecdLnth bytes per message

.CODE

;----------  ESTABLISH InputHook --------------
;Has the form BOOL EXPENTRY InputHook(HAB hab, PQMSG pQmsg,ULONG fs)
;QMSG STRUCT  has  following parms as offsets
;offset 0 hwnd ,offset 4 msg ,offset 8 mp1 ,offset 12 mp2 ,etc.
;fs contains flags from WinPeekMsg function
InputHook     proc
;---- GET PARAMETERS FROM STACK ---
    push   ebp                  ;return address = 4 bytes,this push = 4 bytes
    mov    ebp,esp              ;so first parameter is 8() bytes from top
    mov    eax,[ebp+8]          ;hab
    mov    ih_hab,eax           ;anchor block handle
    mov    eax,[ebp+12]         ;address of qmsg truct
    mov    ih_qmsg,eax          ;store address of QMSG STRUCT structure
    mov    eax,[ebp+16]         ;change option
    mov    ih_opt,eax
;---- restore stack pointer
    pop    ebp                  ;back to  way it was at entrance
   pusha
;---- Get Message Signature
    mov    esi,ih_qmsg          ;point to message
;save message parameters
    mov  eax,[esi]              ;window handle in message Fri  11-12-1993
    mov  hook_handle,eax
    mov  eax,[esi+4]            ;message ID
    mov  hook_msgID,eax
    mov  eax,[esi+8]            ;mp1
    mov  hook_mp1,eax
    mov  eax,[esi+12]           ;mp2
    mov  hook_mp2,eax
;---- IF Recording, send same parameters as in JournalRecordHook back to hookkbsm
;---- 4864 = 1300h = WM_USER+300h
;---- Inclusion of WM_TIMER realaly slows down playback
    .IF RecordOn == 1 && hook_msgID != WM_TIMER
        mov  edi,offset PlayBackQMSG
        inc  JR_Counter
        mov  ebx,AddrCtr
        mov  eax,[esi]          ;hwnd
        mov  [edi+ebx],eax
        mov  eax,[esi+4]        ;message ID
        mov  [edi+4+ebx],eax
        mov  eax,[esi+8]        ;mp1
        mov  [edi+8+ebx],eax
        mov  eax,[esi+12]       ;mp2
        mov  [edi+12+ebx],eax
        mov  eax,[esi+16]       ;time
        mov  [edi+16+ebx],eax
        mov  eax,[esi+20]
        mov  [edi+20+ebx],eax   ;x coordinate
        mov  eax,[esi+24]
        mov  [edi+24+ebx],eax   ;y coordinate
        Add  AddrCtr,RecdLnth
        mov  eax,JR_Counter
        .IF  eax > MaxCount
             mov   RecordOn,0
             $WinInfMsg   "  !! Buffer Limit                Shft-Ctrl-RightArrow to EndRecord!!"
        .ENDIF
    .ENDIF
;---- IF ONLY WM_CHAR MESSAGE DETECTED test for keystrokes-----
    .IF hook_msgID == WM_CHAR
     ;------Test for Shift Key,Alt/Ctrl Down and Valid Scan Key
         mov    ebx,hook_mp1
         test   bx,KC_KEYUP     ;KeyDown ?
         jnz    wm0             ;accept only on down stroke
         test   bx,KC_SCANCODE  ;test scan code
         jz     wm0             ;jump if no valid scan code
         test   bx,KC_SHIFT
         jz     wm0             ;shift key not down - dont process
         test   bx,KC_ALT       ;? Alt Key down when msg generated
         jz     wm1             ;jump if Alt Key Not Hit & test Ctrl key
         mov    hook_mp1,0      ;Alt/Ctrl flag
         jmp    wm2
wm1:     test   bx,KC_CTRL      ;? Ctrl-Key down
         jz     wm0             ;Was neither
         mov    hook_mp1,1      ;Alt/Ctrl flag
wm2:     xor    edx,edx
         shld   edx,ebx,8       ;get high 8 bits of mp1 into dl
         mov    hook_mp2,edx    ;scan code
         .IF hook_mp2 == 76     ;Shift-ALt-5  Toggle called
                $Call WinPostMsg,hook,WM_USER+300h,hook_mp1,hook_mp2
                 popa
                 mov    eax,TRUE        ;do not pass to next hook
                 ret
         .ENDIF
         .IF toggle == 1        ;Active
             ;----- WinPostMessage to HOOKKBSM Using SEND causes problem on Macro playbacks
             $Call WinPostMsg,hook,WM_USER+300h,hook_mp1,hook_mp2
             popa
             mov    eax,TRUE        ;do not pass to next hook
             ret
         .ELSE
             jmp    wm0
         .ENDIF
         ret
    .ENDIF                      ;IF WM_CHAR
wm0:popa
    mov    eax,FALSE            ;pass to next hook in chain
    ret
InputHook  endp

Initialize  Proc                ;HwndMainFrame  in ebx
    .IF   eax == 0              ;Initialization set up
        mov    hook,ebx
        mov    eax,offset PlayBackQMSG
        ret
    .ENDIF
    .IF   eax == 1             ;Initialize for Recording Session
        mov   RecordOn,1
        mov   JR_Count,0
        mov   JR_Counter,0
        mov   AddrCtr,0
        ret
    .ENDIF
    .IF   eax == 2             ;Save Count Return Total in eax
        .IF   RecordOn != 0    ;stopped below maxCount
            mov   RecordOn,0
        .ENDIF
        mov   eax,JR_Counter     ;return total count
       ret
    .ENDIF
    .IF   eax == 3
        .IF toggle == 0
            mov   toggle,1
         .Else
            mov   toggle,0
         .Endif
         ret
    .ENDIF
Initialize  Endp

End

