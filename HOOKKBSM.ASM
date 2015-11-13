; M.F.Kaplon  Begun:Wed  09-30-1992    Revised:Mon  11-08-1993
; Title : hookkbsm.asm
;
; "Copyright 1992 M.F. Kaplon"
;
;  10-27-92  Add ShutDown Procedure via Shift-Alt-End(White)
;  11-04-92  Add Display of Small Window in Lower Right Hand Corner
;  11-06-92  Display Text in Window for RecordOff,Recording,Playback
;  11-18-92  Finally got Macro Recording to Sort of Work
;  11-30-92  Write out Message Records to Disk File in ASCII #'s in HEX
;            S-C-PgDn writes out the current macro to hookkbsm.mac
;  12-07-92  Revised Key Assignments
;            Start Macro Recording              S-C-LeftArrow(White)
;            End   Macro Recording              S-C-RightArrow(White)
;            PlayBack Macro                     S-C-Ins(White)
;            Open Small OS/2 Window             S-A-Ins(White)
;            Display ProgramDefined HotKeys     S-A-?  c:\os2\hot-keys.prg
;            Display UserDefined HotKeys        S-C-?  c:\os2\hot-keys.usr
;            Write Current Macro to ASCII File  S-C-PgDn(White)
;  12-14-92  Add inclusion of WindowNames, obtained from TaskList
;            for each Handle obtained when Recording. Window Names will
;            be first 28 characters of name in TaskList(this is default width)
;  12-27-92  Restructured to allow revision of hot-keys.dat and updating
;            by hotkey activation. Hot Key Assigned = Shift-Alt-UpArrow
;            Displays message DAT Updated in window.
;  04-13-93  Unable to effect release of DLL from Memory. It is FREED
;            but somehow there must still be a reference to it since it
;            is not released from memory. Replace JMP's with Calls to DLL
;  04-30-93  The reason getting errors on editing file was that some editors
;            put Ctrl-Z at EOF and as written was not acceptable. Changed to
;            accept that.
;  07-20-93  Changed pusha/popa -> pushad/popad
;            Changed toolkt20 -> toolkt21 for compiles etc
;            Added switches to command line /s|Scommand_processor This command processor
;            is used for Shift-Alt-Ins window and to load  the 2 hot-key windows
;  07-21-93  Add Switch /j|J to command line to make HooK non-jumpable
;            Make Start Visible Default with option /I|i to start InVisible
;            If /I|i is chosen, then window is made visible when Recording
;            and playing back Macros in order to show progress. Similarly
;            for updating *.dat files.
;            Code modified so that when any messages displayed, regardless
;            of start modes, HOOK window is visible and displays messages.
;  07-22-93  MAKE NONJUMPABLE The Default /j|J now makes it JUMPABLE
;            Option /L|R (Or l|r)to set origin at Lower Left or Lower Right
;            Default is Lower Left
;
;  07-28-93  The program will load the command processor being used from
;            the environment using COMSPEC and DosScanEnv.
;            The user may still pass another on the command line.
;
;  08-01-93  Discovered that the handle for Ctrl-ESc has changed from 2.0
;            2.1 Beta to 2.1 GA. Need to obtain  version to set the
;            handle value for Ctrl-Esc. Get it from Base Entry in Switch
;            List. GetTaskList Procedure
;
;  08-04-93  Starting to create procedures to store macro  to binary
;  08-05-83  file name hookkbsm.hex and to read it back into buffer.
;            WriteMacroBin/ReadMacroBin are procedures to do this.
;            After Reading in (Ctrl-PgUp) need to obtain size and reset
;            value of JR_Count.
;
;  08-08-93  Use WinQuerySysValue to get Screen Size and Set parameters
;            for window opened by Alt-Shift-Ins(w)
;
;  08-09-93  Revised Methods of Setting HOOK window size to use parms
;            returned by above.
;
;  08-11-93  Added Code to get rid of ICON loaded on bootup when using /i
;            option in c:\startup.cmd to start hookkbsm. Gets rid of on
;            on first use of a hot key.
;
;  08-12-93  Modified PlayBack to accomodate Alt-x commands from windows.
;            Size or Position seems to wait for user Input on playback.
;
;  09-02-93  Adding WinFileDlg procedures to save and load macro files
;            Prototyping done in test-pm.asm
;
;  09-03-93  Added Messages to display status on Shift_Ctrl-PgUp actions
;
;  10-12-93  Changed storage for macros to c:\os2\hook\*.hex
;            Changed storage for *.dat & hot-keys.* files to c:\os2\hook
;
;  10-17-93  Added Code to do following:
;            1-Pass TaskListName in Task List on Command Line as \t|TList_Name/
;            2-Pass ProgName in Task List on Command Line as \p|PProg Name/
;            3-In above / is terminator - allows spaces to be passed
;            4-Assign Shift-ALt-Home(White) as key assigned to load program
;              passed with /P...\  only when program whose name is passed
;              on command line via /T...\ is Active Program
;              The test for names is CASE SENSITIVE
;
;  10-18-93  Hot Key changed from Shift-Alt-Home to Ahift-Alt-W. Corresponding
;            Changes made in hot-keys.prg and hot-keys.usr
;            Only Pass ProgName on TaskList - Other not recognized
;
;  10-19-93  When Hot Key is Struck A message is sent to the program whose
;            window title was passed on the Command Line.
;            The lowest Byte of Parm 1 will contain the Scan Code and the
;            next Higher Byte will contain a Flag indicating whether Alt (0)
;            or Ctrl(1) key was struck. Parm 2 will contain the handle
;            of the Active Window when Hot Key was struck.
;
;  10-20-93  Use Test-PM.EXE as target program for testing purposes.
;            Message ID is WM_User+301h  (one more than DLL uses)
;
;            Further Modified pass via the Message ID as above for any
;            key defined in hot-keys.dat as a Hot Key. Programs not
;            loaded but just the info above sent. Uses the absence of
;            09 as session ID as the key.
;            The data file hot-keys.dat must be formatted as
;            Ap 0  sx 0 ;  for an Shift-Alt-key  combination to be recognized
;            C2 0  sx 0 ;  for a  Shift-Ctrl-Key combination to be recognized
;            If the key is not to be recognized do not list it at all
;            or have it prefixed with a ";"S
;
;   10-21-93 Changed the hot-keys.dat format to be of form
;            Ax 8  sx  ;  for Key to be recognized as hot key to send message
;            Ax 9  sx  ;  for Key not to be recognized at All
;            Makes updating and selecting much simpler. The included
;            hookkbsm.dat file is set up for all Key Selections.
;            Ax as before to call a program
;
;   10-24-93 Changed Title to Append Program Name to ALt-X/Ctl-X so that
;            more info is carried in Frame and Task List Title - Suggesiton
;            due to Bill Loughborough
;
;   10-31-93 Got rid of unnecessary messages if Esc option chosen on
;            saving Macro to disk. Also on Hot-Keys send handle of
;            Window with Focus instead of Active Window
;   11-02-93 Installed a WinMessage that informs user of what to do to
;            start recording with respect to the Focus.
;
;   11-05-93 Cleaning Up File
;
;   11-06-93 Fixed /i option on load from DeskTop
;
;   11-08-93 Some programs load with the Window title different than Program
;            Name. In that Case TaskList title is Window title and Alt-x does
;            NOt work. For those programs have to test and if so change to
;            Having ALt-x prefix the title in Task List
;
;   11-11-93 Put in test for Class Name. If #1 (WC_FRAME) set frame_flag = 1
;            and test on next Hot-Key for flag set and then correct.
;            Added a toggle On/Off Key Shift-Alt-DownArrow(W) toggles
;            hot-keys On/Off startup default is ON. When  Off get double beep.
;            Changed Terminator for Command Line string from '\' to '}'
;            This allows passing of directories without problem.
;            When Toggle off other programs access Shift-Alt|Ctrl-X
;
;   11-12-93 Changed Maximized Size of HOOK to same as that of window
;            created by Shift-Alt-Ins
;
;   11-15-93 Fixed /i option for Macro Play back
;
; Listing of Procedures Called in hot-keys.asm - This is order listed in asm
; AS of Sun  10-17-1993
;
; MainWinProc MainPaint MainPaint MainKeyBoard ExitWin SwitchListAlloc
; GetSwitchList GetNameFromHandle CloseDown UnloadKBHook SetShiftInsWinSize
; DefineWindowSize SetWindow RecordMacroON RecordMacroOFF PlaybackMacro
; UseCurWindows WriteMacroAsciiHex WriteMacroBin WriteMacroBin
; ReadDatFile ReadMacroBin SkipSpaces SkipCommentsToEOL DataFormatErr
; SetJump GetTaskList InvFlagAction GetUserFile TaskListSwitch MatchStrings
; GetFocusWindow GetTargetHandle TimeDelay CheckTitle
;
; This program:
; INITIALIZES,CREATES MESSAGE QUEUE, REGISTERS CLASS,CREATES STANDARD WINDOW
; ESTABLISHES MAIN MESSAGE LOOP, ESTABLISHES MAIN WINDOW PROCEDURE, Reads in
; C:\os2\hook\hookkbsm.dat, Establishes Hook to HK_INPUT and INITIALIZE which
; are procedures in HOOKDLSM.DLL, Receives Filtered Messages from hookdlsm
; where mp1 = Alt/Ctrl flag, mp2 = scan code and
; takes appropriate action. Uses WM_USER+300h to receive message.
;
; For System Function Calls
;
; 1 - Must use the C Calling Convention which means Arguments Pushed on Stack
;     in Reverse Order than declared in function
;     And the stack pointer reset after call.
;     This is done by the MACRO   $Call defined in DOSWIN32.MAC
; 2 - Use  .MODEL FLAT. When using a pointer, all you have to do is push
;     the offset of the variable since in FLAT model everyting is NEAR
;     in the 32 bit space ; 3 - Uses a  16K stack
;
; It is assumed that the Developers toolkit for OS/2 2.1 is installed
; on the users C:drive in the default installation. The assembler
; used is MicroSoft's MASM 6.00B
;
; The files needed to create the functioning program are:
; doswin32.mac  Macros and Equates used by Program
; hookkbsm.asm  Source for Executable  Assembled and Linked by mlc-w386.cmd
; hookdlsm.def Define file needed by IMPLIB and LINK386 for DLL
; hookdlsm.asm  Source for DLL = Assembled and linked by dll-w386.cmd
; hookkbsm.dat  Text File assigning USER defined programs to key strokes,
;               read by hot-keys The user creates this file according to the
;               structure outlined in sample. MUST BE LOCATED IN C:\OS2\Hook
; hot-keys.usr  Text file Template to be filled in reflecting USER defined
;               hotkeys asdefined in hot-keys.dat. Must be in C:\OS2\Hook
;               This is displayed when Shift-Ctrl-/(?) is struck. Do Not Change
; hot-keys.prg  Text File containing program defined (hard coded) key
;               assignments. Must be in C:\OS2\Hook
;               Actuated by Shift-Alt-? DO NOT CHANGE
; BOTH hot-keys.usr and hot-keys.prg must be in C:\os2\hook
; dll-w386.cmd Command File to create the hookdlsm.dll and copy to c:\os2\dll
; mlc-w386.cmd  Command File to Assemble and Link hot-keys.asm
; Except as noted, all files should be in the same directory.
; To assemble and link use the directory holding the above files as default
; and use the commands
; dll-w386  hookdlsm ;creates hookdlsm.dll from hookdlsm.asm,moves to c:\os2\dll
; mlc-w386  hot-keys ;creates hot-keys.exe from  hot-keys.asm
;
; hot-keys.exe is placed in the directory holding the above files
;
; There is one warning message
;
; LINK : warning L4036: no automatic data segment
;
; This message has to do with no DGROUP being defined
; It can be suppressed with DATA NONE in a "DEF" file
;
; A command processor is called into a 2-line window centered in the screen
; by the keystroke combination Shift-Alt-Ins(white upper keys)
; The default command processor is c:\os2\cmd.exe
; To load a different one to be called in the window pass its entire
; file specification on the command line when hot-keys is called as
;
; start hookkbsm c:\4os2\4os2.exe
;
; Note additional parameters passed on command line are /i|I /j|J /L|R or l/r
; and /P|pTaskListTitle}
; indicating respectively Window is Invisible /Jumpable
; /Located Lower Left/Right  Default is Visible NotJumpable LowerLeft
; TaskListTitle of a program to receive messages via selected Hot-Keys.
;
; In calling the procedure "Initialize" in hookdlsm.dll values are
; passed and returned in registers and the procedures are called as Procedures
; with names defined in setting up the HOOK.
;
; The example uses the 4OS2 command processor
;---------------------------------------------------------------------------;
;USES HOOK HK_INPUT and INITIALIZE: both in HOOKDLSM.DLL
;-----------------PRELIMINARIES ----------------


.386             ;preceeding .MODEL makes USE32 default
.MODEL           FLAT,SYSCALL,OS_OS2

;---------- Conditionally required equates -------------
NUMBUFS            equ    1     ; Uncomment if need number routines
;DOSERROR           equ    1     ; Uncomment if need DosError Messages

RecdLnth           equ    28
RecdLnth_x_3       equ    28*3

INCL_WINERRORS     equ    1
INCL_WIN           equ    1
INCL_WINSYS        equ    1
INCL_DOSMEMMGR     equ    1
INCL_DOS           equ    1
INCL_DOSFILEMGR    equ    1
INCL_WINSWITCHLIST equ    1
INCL_GPICONTROL    equ    1
INCL_DEV           equ    1
INCL_WINWINDOWMGR  equ    1
INCL_NLS           equ    1
INCL_WINSTDFILE    equ    1
INCL_WINENTRYFIELD equ    1
INCL_WINDIALOGs    equ    1


INCLUDE      doswin32.mac             ;macros used by *.asm
INCLUDE      c:\toolkt21\asm\os2inc\os2def.inc   ;structure defns includes POINTL
INCLUDE      c:\toolkt21\asm\os2inc\pmwin.inc    ;structure defns POINTL defn required
INCLUDE      c:\toolkt21\asm\os2inc\pmgpi.inc    ;graphics
INCLUDE      c:\toolkt21\asm\os2inc\pmdev.inc    ;devices
INCLUDE      c:\toolkt21\asm\os2inc\pmerr.inc    ;errors
INCLUDE      c:\toolkt21\asm\os2inc\pmshl.inc
INCLUDE      c:\toolkt21\asm\os2inc\bsememf.inc  ;memory
INCLUDE      c:\toolkt21\asm\os2inc\bsedos.inc   ;files
INCLUDE      c:\toolkt21\asm\os2inc\pmstddlg.inc ;Standard File Dialog structures etc.
INCLUDELIB   c:\toolkt21\os2lib\os2386.lib       ;Library


ExecOnKB     STRUCT      ;Structure used in program-stores data from hook_kb.dat
   Exec     DWORD   ?    ;Address of ASCIIZ str - name of exec program
   CmdLn    DWORD   ?    ;Address of ASCIIZ str - command line parms
   SessT     WORD   ?    ;Session Type
ExecOnKB       ENDS      ;structure length now = 10

LenExec     equ    10    ;length of ExecOn Kb

.STACK    16384          ;16K stack

.DATA

IFDEF NUMBUFS                      ;To use  UNCOMMENT NUMBUFS equate above
  $DefineNumBufs
ENDIF
IFDEF DOSERROR
   $DOSErrorMessages
ENDIF

; Copyright Notice
notice          BYTE   "Copyright 1992 M.F. Kaplon"

;------------- handles --------
hab             DWORD   0           ;Anchor block Handle
hmq             DWORD   0           ;Message Queue Handle
hwndMainFrame   DWORD   0           ;Handle to Main Frame Window of application hwndmain
hwndMain        DWORD   0           ;Handle to client application window hwndMain
hps             DWORD   0           ;Presentation Space Handle
hwndActive      DWORD   0           ;ACtive Window
henum           DWORD   0           ;WindowEnumerationHandle
hwndNext0       DWORD   0           ;Temporary Window Handles
hwndNext1       DWORD   0           ;Temporary Window Handles
hwndNext2       DWORD   0           ;Temporary Window Handles
TaskListHandle  DWORD   0           ;SEt by Call to GetTaskList
SessionTitle    BYTE    (MAXNAMEL+1) dup(0)
SessionLnth     DWORD   ?           ;Length of Title

;------------- GPI & DEV variables --------
Scr_Width_Pels  DWORD   ?           ;Screen Width in Pels from WinQuerySysValue
Scr_Height_Pels DWORD   ?           ;Screen Height in Pels from WinQuerySysValue

;------------- Text Strings --------
szAppName             BYTE   "Main0",0    ;Class Name of Window Procedure
szWinTitle            BYTE   "Hook",0     ;Window Title
textMsgOn             BYTE   "Recording",0
textMsgPlay           BYTE   "PlayBack",0
textMsgUpdateDat      BYTE   "USER Updated",0
textMsgToggleOff      BYTE   "!Inactive!",0

msgFileErr            BYTE "hookkbsm.dat File format Error - Aborting",0
msgDosStartSess       BYTE "  DosStartSession",0
msgDosLoadModule      BYTE "  DosLoadModule",0
msgDosQueryProc1Addr  BYTE "  DosQueryProc1Addr",0
msgDosQueryProc2Addr  BYTE "  DosQueryProc2Addr",0
msgPG1                BYTE "  PG_Entry Length",0

;------------- Styles --------
msgBoxStyle     DWORD   (MB_YESNO OR MB_DEFBUTTON1)
flStyle         DWORD   WS_SYNCPAINT OR WS_DISABLED     ;Window Style Automatic Update
flCtlData       DWORD   (((( FCF_SYSMENU       OR \    ;Window Control Styles
                            FCF_MINMAX)        OR \
                            FCF_SIZEBORDER)    OR \
                            FCF_TASKLIST)      OR \
                            FCF_TITLEBAR ) ;    OR \
                         ;  FCF_SHELLPOSITION)        ;not reqd if sizing
;------------- structures --------
quemsg           QMSG    {}              ;Queue message structure
rect            RECTL    {,,,}           ;Rectangle structure
AltX            ExecOnKB 36 dup({offset TitleAlt,0,9}) ;Array for  Alt-# 0-9,A-Z default Initialization
CtrlX           ExecOnKB 36 dup({offset TitleCtl,0,9}) ;Array for Ctrl-# 0-9,A-Z default Initialization
WinPosX         DWORD    0               ;Window Position x
WinPosY         DWORD    0               ;Window Position y

;------------- Miscellaneous --------
parm1           DWORD   ?           ;handle of window sending message
parm2           DWORD   ?           ;message id value
parm3           DWORD   ?           ;message mp1
parm4           DWORD   ?           ;message mp2
parm5           DWORD   ?           ;message time
nwritten        DWORD   ?
Alt_Ctrl        DWORD   ?           ;0/1 if Alt/Ctrl key struck
lookup0          BYTE   'Q'-37h,'W'-37h,'E'-37h,'R'-37h,'T'-37h,'Y'-37h,'U'-37h,'I'-37h,'O'-37h,'P'-37h ;26,32,14,27,29,34,30,18,24,25 ;
lookup1          BYTE   'A'-37h,'S'-37h,'D'-37h,'F'-37h,'G'-37h,'H'-37h,'J'-37h,'K'-37h,'L'-37h         ;10,28,13,15,16,17,19,20,21 ;
lookup2          BYTE   'Z'-37h,'X'-37h,'C'-37h,'V'-37h,'B'-37h,'N'-37h,'M'-37h                         ;35,33,12,31,11,23,22 ;
textPos         DWORD   DT_CENTER OR DT_VCENTER      ;Position of text on screen

ExitMsg          BYTE  "          !! <Esc> Aborts Close Down !!",0
ExitTitle        BYTE  "Close OS/2 ??",0
RemoveTitle      BYTE  "Remove HOOKKBSM ??",0
RemoveMsg        BYTE  "         !! <Esc> Aborts Closing TSR !!",0
RecordOn         BYTE   0     ;flag indicates MacroRecording Off/On/Playback = 0/1/2
LeftX           DWORD   0     ;coordinates for screen rectangle
LowerY          DWORD   0
RightX          DWORD   ?
UpperY          DWORD   ?

;------------ Specific to TSR Hook  use -----
DllLoadError     BYTE  100 dup(0)   ;Buffer for name of object contributing to error
DllHandle       DWORD 0             ;Handle of Dynamic LInk Module returned here
DllFullModName   BYTE  "c:\os2\dll\hookdlsm.dll",0
DllProcAddr1    DWORD 0             ;address of proc 1 in dynamic link module
DllProcAddr2    DWORD 0             ;address of proc 2 in exec module

;-DosStartSession structure Offset ------------ Identification --------------
StartData0       WORD  32    ; 0  Length of Structure for all but Shift-Alt-Ins(W)
                 WORD  0     ; 2  Related 0 is independent, 1 is child
                 WORD  0     ; 4  0/1 Start in Foreground/Background
                 WORD  0     ; 6  Trace Option 0 is no trace
                DWORD  0     ; 8  ProgramTitle 0 uses Program Name
                DWORD  0     ;12  Address of ASCZII string with fully qualified program name
                DWORD  0     ;16  Address of Input Args to Pgm - 0 is none
                DWORD  0     ;20  TermQ 0 is no Queue
                DWORD  0     ;24  Environment - must be 0 for DOS
                 WORD  0     ;28  InheritOp 0 Inherits Shell Environment
                 WORD  ?     ;30  SessType see p.2-345 of Control Prog Ref.
                DWORD  0     ;32  ICON File
                DWORD  0     ;36  PgmHandle
                 WORD SSF_CONTROL_SETPOS   ;40  PgmControl-use specified size for S-A-Ins
                 WORD  ?  ;250; 140 ;640x480  ;42  InitXPos  for Shift-Alt-= 800x600
                 WORD  ?  ;250; 200 ;640x480  ;44  InitYPos  for Shift-Alt-= 800x600
                 WORD  ?  ;300; 350 ;640x480  ;46  InitXSize for Shift-Alt-= 800x600
                 WORD  ?  ;100;  60 ;640x480  ;48  InitYSize for Shift-Alt-= 800x600
                 WORD  0     ;50  Reserved for future use
                DWORD  0     ;52  Object Buffer
                DWORD  0     ;56  Object Buff Len
SessID          DWORD  0     ;receives Session ID for Alt-1
ProcID          DWORD  0     ;receives ProcessID  for Alt-1
TitleAlt         BYTE  "Alt-  ",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ;space filled in with # or letter
TitleCtl         BYTE  "Ctl-  ",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  ;space filled in with # or letter
HotKeyID         BYTE   ?         ;Identifies HotKey Selected
InsProg          BYTE   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; use command processor in COMSPEC as default
DisplayUser      BYTE  "/c type c:\os2\hook\hot-keys.usr & pause & exit",0 ;display User Hot Key Assignments
DisplayPrg       BYTE  "/c type c:\os2\hook\hot-keys.prg & pause & exit",0 ;display Prog Hot Key Assignments
DosEnvValue      BYTE  "DPMI_DOS_API=ENABLED",0

;-------------- parameters for memory usage and file opening
memAddr         DWORD   0                        ;address of memory block
memFlags        DWORD 10h OR 3;  PAG_COMMIT OR (PAG_WRITE OR PAG_READ) ;read-write access required
JR_Count        DWORD   0                        ;Count of records recorded
JR_Counter      DWORD   0                        ;Counter for recording records
PB_Ctr          DWORD   0                        ;PlayBack record counter
msgParms        DWORD   0                        ;offset of PlayBackQMSG in dll
MaxCount        DWORD   2660 ;Maximum qmsg structure counts
AddrCtr         DWORD   0    ;increment counter
Delta_t         DWORD   0    ;Time Delay in Milliseconds

fName            BYTE    "c:\os2\hook\hookkbsm.dat",0  ;Address of data file
fmName           BYTE    CCHMAXPATH+2 dup(0)     ;Length of filespec for dialog
fhandle         DWORD   ?                        ;Address of Handle for File
fActionTaken    DWORD   ?                        ;Address for action taken
fSize           DWORD   ?                        ;Logical size of file
fAttribute      DWORD   0
fOpenFlag       DWORD   OPEN_ACTION_OPEN_IF_EXISTS
fOpenMode       DWORD   OPEN_SHARE_DENYNONE OR OPEN_ACCESS_READWRITE
fExtaBuf        DWORD   0                        ;no extended attributes
fmhandle        DWORD   ?                        ;Address of Handle for File
fmActionTaken   DWORD   ?                        ;Address for action taken
fmSize          DWORD   ?                        ;Logical size of file
fmAttribute     DWORD   FILE_NORMAL              ;Read or Write
fmOpenFlag      DWORD   OPEN_ACTION_CREATE_IF_NEW OR OPEN_ACTION_OPEN_IF_EXISTS
fmOpenMode      DWORD   OPEN_SHARE_DENYNONE OR OPEN_ACCESS_READWRITE
fmExtaBuf       DWORD   0                        ;no extended attributes
fmWritten       DWORD   0                        ;bytes written per write
fmPtrLoc        DWORD   0                        ;File Pointer Locationn
fmBuffer         BYTE   82 dup(' '),13,10        ;Buffer for writing a record
fmHeader         BYTE   "WinHandle MessageID msgParam1 msgParam2  msgTime  X_ScreenP Y_ScreenP TaskListName",13,10
NoNameListed     BYTE   "NoNameinList"           ;Error Message
NameHitFlag     DWORD   0                        ;0/1 Name notin/isin TaskList
HandFromMsg     DWORD   0                        ;handle from msgQueue
TaskNameAddr    DWORD   ?                        ;Address of TaskListName
fpointer0       DWORD   ?                        ;file pointer start file
fpointer1       DWORD   ?                        ;file pointer end file
EOFflag         DWORD   0                        ;EndOfFile flag

;------------ switch list parameters -------------
numitems        DWORD   ?                        ;#items in list
baseaddr        DWORD   ?                        ;of SWBLOCK {,}

ClassNameBuf     BYTE   20 dup(0)                ;Buffer for ClassNameID
CoverPage        BYTE   "CLASS_COVERPAGE "        ;name for comparison
CurrentTime     DWORD   ?                        ;Store Time Delay
UpdateDat       DWORD   0                        ;FlagFor Update Display
JumpFlag         BYTE   0                        ;If 1 Make Hook Jumpable
InvFlag          BYTE   0                        ;If 1 make Invisible
SetOrigin        BYTE   0                        ;If 1 xorgn,yorgn passed
xorigin          BYTE   10 dup(0)                ;x origin position
yorigin          BYTE   10 dup(0)                ;y origin position
posorigin        BYTE   0                        ;default LowerLeft Corner
EnvVar           BYTE   "COMSPEC",0              ;Command Processor
PtrToEnvStr      DWORD  0                        ;P0inter To Env String
PG_Entry         BYTE   64 dup(0)                ;Buffer for /p|P parm on command Line
PG_Len          DWORD   0                        ;Length of PG String Passed
MParm1          DWORD   0                        ;For sending message to
MParm2          DWORD   0                        ;Window loaded by Ctrl-X
WinTarget       DWORD   0                        ;Handle  of Window loaded by Ctrl-X
ScanCode        DWORD   0                        ;Holds Scan Code
norecs           BYTE   0                        ;0/1 = no records/records

;-------------File Dialog Parms
fdFileDlg     FILEDLG  {0,0,0,0,0,0,0,0,0,0,0,0,0,,0,0,0,0,0,0}  ;File Dialog Structure
fdTitle0         BYTE  "Select Macro To Load for Playback",0      ;Window title
fdTitle1         BYTE  "Save Macro just Recorded To *.HEX file",0 ;Window title
fdFileName       BYTE  "c:\os2\hook\*.hex",0                      ;default filter
fdlghwnd        DWORD  ?                                         ;file dialog handle
dlgOpt           BYTE  ?     ;0 is Select File / 1 is Save File
frame_flag       BYTE  0     ;program is WC_FRAME indicator
toggle           BYTE  1     ;Toggle Hot-Keys On/Off = 1/0

.CODE

startup:                         ;need to do this way with flat model

;----------  Get Command Processor -------
$Call DosScanEnv,offset EnvVar,offset PtrToEnvStr
mov    edi,offset InsProg       ;address of where to store
mov    esi,PtrToEnvStr
.WHILE  byte ptr [esi] != 0
     mov   al, byte ptr[esi]
     mov   [edi],al
     inc   esi
     inc   edi
.ENDW                           ;do not need term 0 as already there

;----------  GET COMMANDLINE PARMS -------
$GetCmdLine                    ;macro esi has offset of command line
.WHILE byte ptr[esi] != 0     ;go past program name
      inc    esi
.ENDW
Inc    esi                     ;now points to  1st space after command name
.WHILE  byte ptr[esi] != 0    ;go to end of command line
     .WHILE   byte ptr[esi] == ' '
          inc   esi
     .ENDW          ;below added Tue  07-20-1993
     .IF byte ptr[esi] != '/'
         inc    esi
         .CONTINUE
     .ENDIF
     .IF byte ptr[esi] == '/' && (byte ptr[esi+1] == 'j' || byte ptr[esi+1] == 'J')
         add  esi,2       ;advance for next test
         mov  JumpFlag,1  ;Flag Indicating Hook to be JUMPABLE
         .CONTINUE
     .ENDIF
     .IF byte ptr[esi] == '/' && (byte ptr[esi+1] == 'i' || byte ptr[esi+1] == 'I')
         add  esi,2                ;advance for next test
         mov  InvFlag,1            ;Set Invisible Flag
         .CONTINUE
     .ENDIF
     .IF byte ptr[esi] == ' ' && (byte ptr [esi+1] == 'S' || byte ptr [esi+1] == 's')
         add    esi,2     ;go to string passed
         mov    edi,offset InsProg   ;destination
         .WHILE byte ptr[esi] != '\' && byte ptr[esi] != 0 && byte ptr[esi] != '/'
              mov   al,byte ptr[esi]
              mov   [edi],al
              inc   esi
              inc   edi
         .ENDW                  ;on exit esi,edi point to next place
         mov  al,0
         mov  [edi],al          ;terminating NULL
         .CONTINUE
     .ENDIF
     ;Pass this string terminated with } as /PProgram Name in Task List-
     .IF byte ptr[esi] == '/' && (byte ptr [esi+1] == 'P' || byte ptr [esi+1] == 'p')
         add    esi,2     ;go to string passed
         mov    edi,offset PG_Entry   ;destination
         mov    ecx,0
         .WHILE  byte ptr[esi] != 0 && byte ptr[esi] != '}'
              .BREAK .IF byte ptr[esi] == ' ' && byte ptr[esi+1] == ' '
              mov   al,byte ptr[esi]
              mov   [edi],al
              inc   esi
              inc   edi
              inc   ecx
         .ENDW                  ;on exit esi,edi point to next place
         mov  al,0
         mov  [edi],al          ;terminating NULL
         mov  PG_Len,ecx
         .CONTINUE
     .ENDIF
     .IF byte ptr[esi] == '/' && (byte ptr[esi+1] == 'l' || byte ptr[esi+1] == 'L')
         add  esi,2                ;advance to next command line aspect
         mov  posorigin,0
         .CONTINUE
     .ENDIF
     .IF byte ptr[esi] == '/' && (byte ptr[esi+1] == 'r' || byte ptr[esi+1] == 'R')
         add  esi,2                ;advance to next command line aspect
         mov  posorigin,1
         .CONTINUE
     .ENDIF
.ENDW
;----------  ESTABLISH WINDOW ------------

;-----Initialize Window -Anchor block handle returned = hab
$Call WinInitialize,0            ;called with argument 0
mov    hab,eax                   ;return value
.IF hab == NULL
    $Alarm0
    $Call WinTerminate,hab
    $DosExit
.ENDIF

;-----Create MessageQue  QueueHandle returned = hmq
$Call WinCreateMsgQueue,hab,0    ; 0 is default size of queue
mov      hmq,eax                 ;returned queue handle
.IF hmq == NULL
   $WinErrMsg " : WinCreateMsgQueue"
   $DosExit
.ENDIF

;---- Register Window Class Returned value is TRUE or FALSE
$Call WinRegisterClass,hab,offset szAppName,offset MainWinProc,flStyle,0
.IF eax == FALSE
    $WinErrMsg " : WinRegisterClass"
    $Call WinTerminate,hab
    $DosExit
.ENDIF

;---- CreateStandard Window - Returns handle for Main Window Frame and client Window
.IF invflag == 1
    mov    eax,0
.ELSE
    mov    eax,WS_VISIBLE
.ENDIF
$Call WinCreateStdWindow,HWND_DESKTOP,eax,offset flCtlData,offset szAppName,\
                    offset szWinTitle,0,0,0,offset hwndMain
mov   hwndMainFrame,eax          ;returned Frame Window handle
.IF eax == 0
   $WinErrMsg " : WinCreateStdWindow"
   Call   ExitWin
.ENDIF

Call SetShiftInsWinSize   ;Get Window Size Set Alt-Shift-Ins window size Get Window Size
Call DefineWindowSize     ;must be called in
Call SetWindow            ;this order

;The way to proceed is to install a System Hook. This has to go into a DLL
;otherwise it cannot be called by other programs. The 1st procedure in hookdlsm
;will inspect WM_CHAR and if the ShiftKey and one of Alt or Ctrl key is down
;and if there is a valid Scan Code THEN it posts a message to this program
;with the mp1 and mp2 parms using using WM_USER+300h
;The second procedure is  Initialize and it is used to pass flags and handles
;between the dll and this program

;--------- Load DLL -------------
$Call DosLoadModule,offset DllLoadError,LENGTHOF DllLoadError,offset DllFullModName,offset DllHandle
.IF eax != 0
    $WinErrMsg " DosLoadModule"
.ENDIF

;---------  Get Addresses of the two procedures in DLL
$Call DosQueryProcAddr,DllHandle,1,NULL,offset DllProcAddr1 ;InputHook Proc
.IF eax != 0
    $WinDebugMessage msgDosQueryProc1Addr
.ENDIF

$Call DosQueryProcAddr,DllHandle,2,NULL,offset DllProcAddr2  ;Initialize Proc
.IF eax != 0
    $WinDebugMessage msgDosQueryProc2Addr
.ENDIF

;-------- This establishes procedure 1 in the DLL as an Input Hook
$Call WinSetHook,hab,NULLHANDLE,HK_INPUT,DllProcAddr1,DllHandle ;Input Hook
.IF eax != TRUE
   $WinErrMsg " WinSetINPUTHook"
   Call   UnloadKBHook
.ENDIF

;---- Reads In hot-keys.dat and writes to memory buffer
Call ReadDatFile

;---------  ALLOCATE MEMORY FOR SWITCH LIST STRUCTURE -------
Call SwitchListAlloc

; These must be located here else get error on loading hot-keys
.IF JumpFlag == 0      ;JumpFlag set on command line
   Call SetJump        ;Sets hot-keys as non-jumpable THIS IS DEFAULT
.ENDIF
Call GetTaskList       ;Get Handle of Task List

;------ pass the window frame handle in ebx
;-----  returns PlayBackQMSG in eax
;esp checks before and after call
mov    ebx,hwndMainFrame  ;value of this
mov    eax,0              ;Initialization Identifier
call    DllProcAddr2
mov    msgParms,eax       ;address of message variables from DLL when Recording
;$WinInfMsg  "   address of msgParms"   ;OK
;msgParms    offset   Variable
;              0      hwnd
;              4      msgID
;              8      mp1
;             12      mp2
;             16      time
;             20      x coordinate (Screen Based)
;             24      y coordinate (Screen Based)

;---------  CREATE MAIN MESSAGE LOOP -----------

mml: $Call WinGetMsg,hab,offset quemsg,0,0,0    ;Note: differs from usual
     .IF eax == TRUE                            ;msg loop - done so that program
         $Call WinDispatchMsg,hab,offset quemsg ;can only be terminated
         jmp   mml                              ;by the keystroke Shift-Alt-Del
     .ELSE                                      ;or by Alt-F4 or Alt-Close
         Call  UnloadKBHOok                     ;when Window has focus
         mov   eax,TRUE
         jmp   mml                              ;if ESc option chosen
     .ENDIF                                     ;as notified from the DLL

;Normally an Exit routine would go here, as indicated below but which
;is commented out. It is not required since it can never be reached.

;----------  EXIT ---------------
;Call UnloadKBHOok
;.ENDIF            ;Tue  04-13-1993
;---------------- End of Main Program -------------------

;-------------  PROCESS MESSAGE QUEUE FOR hook_KB ------------
;------------------ MainWinProc -----------------
;parm1 = hwnd,parm2 = msg,parm3  = mp1,parm4 = mp2
;this is called from System and so has to do everything itself
MainWinProc Proc Near
    ;----------- GET PASSED PARAMETERS FROM STACK ------------
    push   ebp           ;return address is 4 bytes and this push is 4 bytes
    mov    ebp,esp       ;so first parameter is 8 bytes from top
    mov    eax,[ebp+8]
    mov    parm1,eax     ;hwnd
    mov    eax,[ebp+12]
    mov    parm2,eax     ;msg
    mov    eax,[ebp+16]
    mov    parm3,eax     ;mp1
    mov    eax,[ebp+20]
    mov    parm4,eax     ;mp2
    mov    eax,[ebp+24]
    mov    parm5,eax     ;time of message
   ;----- RESTORE STACK POINTER AND STACK STATUS  ---
    mov      esp,ebp     ;restore  stack pointer
    pop      ebp
    pushad  ;  Tue  07-20-1993 pusha -> pushad
    ;---------------- WM_CREATE ----------------
    .IF parm2 == WM_CREATE
         Call InitMainWindow
         jmp  wm0
    .ENDIF
    ;---------------- WM_PAINT ----------------
    .IF parm2 == WM_PAINT ; && parm1 == hwndMain
         Call MainPaint
         jmp  wm0
    .ENDIF
    ;---------------- WM_CHAR ----------------
    .IF parm2 == WM_CHAR
         Call MainKeyboard
         jmp  wm0
    .ENDIF
    ;---------------- WM_SIZE ------------
    .IF parm2 == WM_SIZE
         jmp  wm0
    .ENDIF
    ;---------------- WM_MINMAXFRAME ----------------------
    ; here we set the maximized window size the same as that of Shift-Alt-Ins
    .IF parm2 == WM_MINMAXFRAME
        mov   esi,parm3      ;pointer to SWP
        .IF dword ptr[esi] & SWP_MAXIMIZE     ;set to Shift-Alt-Ins size
            xor   eax,eax
            mov   ax,word ptr[StartData0+48]
            mov   dword ptr [esi+4],eax       ;cx
            mov   ax,word ptr[StartData0+46]
            mov   dword ptr [esi+8],eax       ;cy
            mov   ax,word ptr[StartData0+44]
            mov   dword ptr [esi+12],eax      ;x
            mov   ax,word ptr[StartData0+42]
            mov   dword ptr [esi+16],eax      ;y
            mov   eax,FALSE
            jmp   wm0
        .ENDIF
    .ENDIF
    ;---------------- WM_USER+300H ----------------
    .IF parm2 == WM_USER+300h                    ;posted message
    ; if here know that Shift Key was down and at least one of Alt or Ctrl
    ; This is here to set Task List Title for Windows of type WC_FRAME
    ; and is needed for those cases where the window may set information
    ; in its title as well as those whose titles are different than prog names
    ; frame_flag is set after program loaded by call to WinQueryClassName
    ;GET SCAN CODE AND ALT/CTRL FLAG From Parms
         mov    edx,parm4       ;scan code
         mov    ScanCode,edx
         mov    eax,parm3       ;Alt/Ctrl Flag = 0/1
         mov    Alt_Ctrl,eax    ;Alt-Ctrl flag
    .IF  frame_flag == 1                  ;checklistmessage
         mov   frame_flag,0
         Call CheckTitle                  ;resets tasklist title ifnot correct
         jmp  wm0
    .ENDIF
    ;Test for Shift-Alt-5(Cursor Pad W) for Toggle
    .IF  parm4 == 76 && Alt_Ctrl == 0     ;Shift-Alt-5(White)
       .IF  toggle == 1                   ;Tue  04-13-1993
            mov    toggle,0               ;make inactive
            $Call WinAlarm,HWND_DESKTOP,WA_WARNING
       .Else
            mov    toggle,1               ;reactivate
       .ENDIF
       Call InvFlagAction
       $Call WinInvalidateRect,hwndMain,offset rect,TRUE
       .IF invflag == 1            ;hide again after 500 ms
             $Call DosSleep,500
             $Call WinSetWindowPos,hwndMainFrame,0,0,0,0,0,SWP_MINIMIZE
       .ENDIF
       mov     eax,3                      ;Fri  11-12-1993  Reset in dll
       call    DllProcAddr2
       jmp   wm0
    .ENDIF
    ;Test for Shift-Alt-Del(white) for Unloading KBHook
         .IF edx == 83 && Alt_Ctrl == 0      ; Shift-Alt-Del (White Del key)
            Call UnloadKBHook
            jmp     wm0
         .ENDIF
    ;Test for Shift-Alt-End(white) for CloseDown
         .IF  edx == 79 && Alt_Ctrl == 0      ;Shift-Alt-End(White)
            Call  CloseDown                   ;Tue  04-13-1993
            jmp   wm0
         .ENDIF
    ;Test for Shift-Ctrl-LeftArrow - Start Record
         .IF  edx == 75 && Alt_Ctrl == 1      ;Shift-Ctrl-LeftArrow(White)
            Call InvFlagAction
            Call  RecordMacroON
            jmp   wm0
         .ENDIF
    ;Test for Shift-Ctrl-RightArrow  - Stop Record
         .IF  edx == 77 && Alt_Ctrl == 1      ;Shift-Ctrl-RightArrow(White)
            Call  RecordMacroOFF
            .IF norecs == 0
               jmp   wm0
            .ENDIF
            .IF InvFlag == 1       ;hide atter 500 ms
               $Call DosSleep,500
               $Call WinSetWindowPos,hwndMainFrame,0,0,0,0,0,SWP_MINIMIZE
            .ENDIF
            mov   dlgOpt,1                     ;Select Macro Name to Save to
            Call  GetUserFile
            .IF  eax != 0                      ; name given
                Call  WriteMacroAsciiHex
                Call  WriteMacroBin                ;For Playback
            .ENDIF
             $WinInfoMsg   "Shift-Ctrl-Ins Plays Back Macro in Memory"
            jmp   wm0
         .ENDIF
    ;Test for Shift-Ctrl-Ins(white)    - Playback Record Parms Basis
         .IF  edx == 82 && Alt_Ctrl == 1      ;Shift-Ctrl-Ins(White)
           .IF RecordOn == 1
               Call RecordMacroOff
               mov  JR_Count,0
                mov    eax,0
                $WinInfoMsg   " !! Aborting Macro Recording - Cannot PlayBack while Recording !!"
               jmp    wm0
           .ENDIF
           .IF  JR_Count == 0  || JR_Count == 8     ;8 is 3 StartUp and 5 Close WM_CHAR messages
                mov    eax,0
                $WinInfMsg   " Messages to Play back !!"
               jmp    wm0
           .ENDIF
            Call  InvFlagAction
            Call  PlaybackMacro
            .IF InvFlag == 1        ;hide after 500 ms
               $Call DosSleep,500
               $Call WinSetWindowPos,hwndMainFrame,0,0,0,0,0,SWP_MINIMIZE
            .ENDIF
            jmp   wm0
         .ENDIF
    ;Test for Shift_Ctrl-PgDn(White)   - Write Macro File Out
         .IF  edx == 81 && Alt_Ctrl == 1      ;Shift-Ctrl-PgDn(White)
            .IF  JR_Count == 0  || JR_Count == 8     ;8 is 3 StartUp and 5 Close WM_CHAR messages
                mov    eax,0
                $WinInfoMsg   " No Macro Recorded to Save !!"
            .ELSE
                mov   dlgOpt,1                     ;Save Macro
                Call  GetUserFile
               .IF  eax != 0                      ; name given
                  Call  WriteMacroAsciiHex
                  Call  WriteMacroBin             ;For Playback
                  $WinInfoMsg "Macro Saved to Disk"     ;needed to restore window
               .ELSE                               ;no name given
                  $WinInfoMsg "Macro Not Saved to Disk" ;needed to restore window
               .ENDIF
            .ENDIF
           jmp   wm0
         .ENDIF
    ;Test for Shift_Ctrl-PgUp(White)   - Read MacroHex File In
         .IF  edx == 73 && Alt_Ctrl == 1      ;Shift-Ctrl-PgUp(White)
            mov   dlgOpt,0                    ;Select Macro
            Call  GetUserFile
            .IF eax == 1                      ; file read in
                 Call  ReadMacroBin           ;For Playback
                 $WinInfoMsg "Macro Loaded - Shift-Ctrl-Ins Plays Back"
            .ELSE
                 $WinInfoMsg "No File to Load"
            .ENDIF
            jmp   wm0
         .ENDIF
    ;Test for Shift-Alt-UpArrow    - Call ReadDatFile Update hot-keys.dat
         .IF  edx == 72 && Alt_Ctrl == 0      ;Shift-Alt-UpArrow(White)
            Call  InvFlagAction
            mov   UpdateDat,1
            $Call WinInvalidateRect,hwndMain,offset rect,TRUE
            Call  ReadDatFile
            $Call DosSleep,500
            mov   UpdateDat,0
            $Call WinInvalidateRect,hwndMain,offset rect,TRUE  ;reset
            .IF InvFlag == 1     ;wait for 500 ms
               $Call DosSLeep,500
               $Call WinSetWindowPos,hwndMainFrame,0,0,0,0,0,SWP_MINIMIZE
            .ENDIF
            jmp   wm0
         .ENDIF
;ELSE TEST FOR ASSIGNED KEYS
;SETUP DATA STRUCTURES FOR ACTIVATING HOT KEY
;---- Code in this group places the offset into the array ExecOnKB into EDX
         .IF  edx == 82 && Alt_Ctrl == 0      ;Shift-Alt-Ins
              mov    esi,offset StartData0    ;data structure for DosStartSession
              mov    word ptr [esi],50        ;for Alt-=
              mov    HotKeyID,'ê'             ;For Program Title
              mov    edi,offset TitleAlt
              mov    cl,HotKeyID
              mov    byte ptr [edi+4],cl
              mov    dword ptr[esi+8],offset TitleAlt  ;program title
              mov    eax,offset InsProg       ;address of command processor
              mov    [esi+12],eax
              mov    dword ptr[esi+16],0      ;no command line parms
              mov    word ptr[esi+30],2 ;0    ;Session Type, 0 also works
              mov    dword ptr[esi+24],0      ;default value reset
              jmp    wmexe
         .ELSE
              mov    word ptr StartData0,32
         .ENDIF
         .IF  edx == 53 && Alt_Ctrl == 1      ; Shift-Ctrl-?:/  key
              mov    esi,offset StartData0     ;data structure for DosStartSession
              mov    word ptr StartData0,32    ;
              mov    HotKeyID,'?'             ;For Program Title
              mov    edi,offset TitleAlt
              mov    cl,HotKeyID
              mov    byte ptr [edi+4],cl
              mov    dword ptr[esi+8],offset TitleAlt  ;program title
              mov    eax,offset InsProg   ;address of Exec program
              mov    [esi+12],eax
              mov    eax,offset DisplayUser
              mov    dword ptr[esi+16],eax    ; command line
              mov    word ptr[esi+30],2       ;Session Type
              jmp    wmexe
         .ENDIF
         .IF  edx == 53 && Alt_Ctrl == 0      ; Shift-Alt-?:/  key
              mov    esi,offset StartData0     ;data structure for DosStartSession
              mov    word ptr StartData0,32    ;
              mov    HotKeyID,'/'             ;For Program Title
              mov    edi,offset TitleAlt
              mov    cl,HotKeyID
              mov    byte ptr [edi+4],cl
              mov    dword ptr[esi+8],offset TitleAlt  ;program title
              mov    eax,offset InsProg   ;address of Exec program
              mov    [esi+12],eax
              mov    eax,offset DisplayPrg
              mov    dword ptr[esi+16],eax    ; command line
              mov    word ptr[esi+30],2       ;Session Type
              jmp    wmexe
         .ENDIF
         .IF    edx >= 2 && edx <= 11     ;scan code for 1..9,0
             .IF  edx >= 2 && edx <= 10
                 sub   edx,1       ;convert to number 1 - 9
             .ELSE
                 mov   edx,0       ; 0 offset for 0
             .ENDIF
             mov   HotKeyID,dl
             add   HotKeyID,30h    ;convert to ASCII
             jmp   wmok
         .ENDIF
          xor   ecx,ecx
         .IF  edx >= 16 && edx <= 25; && edx != 17 ; q,w,e,r,t,y,u,i,o,p
               mov   esi,offset lookup0
               sub   edx,16
               jmp   wmoj
         .ENDIF
         .IF edx >= 30 && edx <= 38 ; a,s,d,f,g,h,j,k,l
               mov   esi,offset lookup1
               sub   edx,30
               jmp   wmoj
         .ENDIF
         .IF  edx >= 43 && edx <= 50  ;z,x,c,v,b,n,m
               mov   esi,offset lookup2
               sub   edx,44
               jmp   wmoj
         .ELSE
               jmp   wm0
         .ENDIF
wmoj:     mov   cl,byte ptr [esi+edx]  ;cl has value - cl+37h is UC letter
          mov   HotKeyID,cl            ;identifies letter
          add   HotKeyID,37h
          xor   edx,edx
          mov   dl,cl
wmok:     ;- Alt_Ctrl has Alt_Ctrl Flag and dl has offset into array
         .IF  edx >= 0 && edx <= 35
              xor  eax,eax
              mov   al,dl
              mov  esi,offset StartData0  ;data structure for DosStartSession
              .IF  Alt_Ctrl == 0
                  mov   ebx,offset AltX  ;Alt Definitions
                  mov   edi,offset TitleAlt
                  mov   cl,HotKeyID
                  mov   byte ptr [edi+4],cl
                  mov   dword ptr[esi+8] ,offset TitleAlt  ;program title
              .ENDIF
              .IF  Alt_Ctrl == 1
                  mov   ebx,offset CtrlX ;Ctrl Definitions
                  mov   edi,offset TitleCtl
                  mov   cl,HotKeyID
                  mov   byte ptr [edi+4],cl
                  mov   dword ptr[esi+8],offset TitleCtl  ;program title
              .ENDIF
              mov    cl,LenExec
              mul    cl             ;Structure Length 10
              add    ebx,eax        ;element # of structure
              ;[ebx+8] != 8 is flag that keystroke is assigned as Hot Key
              .IF  word ptr [ebx+8] == 8
                  .IF PG_Len == 0         ; no Program Name passed
                      $Call WinQueryFocus,HWND_DESKTOP
                      push   eax                        ;save focus
                      $WinInfoMsg  "No Program Name Passed on Command Line"
                      pop    eax
                      $Call WinSetFocus,HWND_DESKTOP,eax      ;reset
                      jmp   wm0            ;exit nothing to do
                  .ENDIF
                  ; Format  Parm1 with lowest byte = Scan Code and Next
                  ; lowest byte = 0/1 for Alt/Ctrl Key struck
                  Call GetTargetHandle
                  mov  eax,0
                  mov  ebx,ScanCode
                  mov  al,bl       ;Scan Code
                  mov  ebx,Alt_Ctrl
                  mov  ah,bl        ;Alt or Ctrl struck
                  mov  Mparm1,eax   ;Mparm 1 done
                  Call GetFocusWindow
                  jmp  wm0           ;Finished
              .ENDIF
              .IF  word ptr [ebx+8] != 9
              ;here append program name onto TitleALt/TitleCtl
              ;edi is offset of Titlexxx  ebx is address of Progran name
                  pushad
                  mov    esi,[ebx]
                  xor    ecx,ecx
                  mov  al,byte ptr[esi+ecx]
                  .WHILE ecx < 24 && al != ' '
                      mov  byte ptr[edi+6+ecx],al
                      inc  ecx
                      mov  al,byte ptr[esi+ecx]
                  .ENDW
                  popad
                  mov  eax,[ebx]              ;address of Exec program
                  mov  [esi+12],eax
                  mov  eax,[ebx+4]            ;address of command line
                  mov  [esi+16],eax
                  mov  ax,word ptr [ebx+8]    ;Session type
                  mov  [esi+30],ax
                  .IF ax == 4 || ax == 7    ;set environment string DPMI_DOS_API for Borland IDE
                      mov dword ptr[esi+24],offset DosEnvValue
                  .ELSE
                      mov  dword ptr[esi+24],0   ;default value reset
                  .ENDIF

;GO THRU SWITCH LIST TO SEE IF HOT KEY ACTIVE
                   ;-- called before DosStartSession to see if program loaded
                   ;-- esi=offset into StartData0
                   ;-- go thru Switch List to see if loaded and if so switch to
                   ;-- The test made on 4th char of TitleAlt/TitleCtl which
                   ;-- is the title in the window and Task List
wmexe:             pushad  ; Tue  07-20-1993   pusha -> pushad
                   $NumSwitchListEntries
                   mov  numitems,eax      ;number of switch list entries
                   dec numitems
                   Call GetSwitchList     ;activate structure
                   mov  edi,baseaddr      ;address of switch list
                   mov  ecx,0
                   .IF  Alt_Ctrl == 0
                        mov    bl,'A'
                   .ELSE
                        mov    bl,'C'
                   .ENDIF
                   .WHILE  ecx < numitems           ;starts at offset 0
                       mov   al,byte ptr[edi+40]  ;5-th char TaskList title
                       mov   dl,byte ptr[edi+36]  ;1stChar of Title A/C
                       ;IF ACTIVE SWITCH TO
                       .IF al == HotKeyID && bl == dl
                            ;Now Switch to that window - get switch handle
                            mov  eax,[edi+8]      ;Mon  08-09-1993  window handle
                            mov  hwndActive,eax   ;Mon  08-09-1993
                            mov  eax,[edi+4]
                            $Call WinSwitchToProgram,eax
                            popad ; Tue  07-20-1993   popa ->popad
                            jmp  wm0                ;do not reload
                       .ENDIF
                       inc   ecx
                       add   edi,swblksize           ;next element in structure
                   .ENDW
                   popad ;Tue  07-20-1993 popa ->popad
                   ;ELSE ACTIVATE HOT KEY PROGRAM
                   mov   frame_flag,0
                   $Call  WinSetFocus,HWND_DESKTOP,hwndMainFrame ;required for program started to be in foreground
                   $Call DosStartSession,esi,offset SessID,offset ProcID
                   .IF eax > 0
                        $WinDebugMessage  msgDosStartSess
                   .ENDIF
                   $Call WinQueryFocus,HWND_DESKTOP
                   $Call WinQueryClassName,eax,nwritten,offset ClassNameBuf
                   .IF  [ClassNameBuf] == '#' && [ClassNameBuf+1] == '1'
                        mov   frame_flag,1
                   .ENDIF
             .ENDIF
         .ENDIF
    .ENDIF                                     ;End WM_USER+300h
   wm0:popad     ; Tue  07-20-1993 popa ->popad
   ;----- Default Procedure * Return Value in eax ------
   $Call WinDefWindowProc,parm1,parm2,parm3,parm4
   ret
MainWinProc  endp

;-------------- MainPaint * WM_PAINT --------------
MainPaint  proc
      $Call WinBeginPaint,hwndMain,NULL,offset rect    ;offset rect
      mov  hps,eax        ;returns cache presentation space handle
      $Call WinQueryWindowRect,hwndMain,offset rect
      $Call WinFillRect,hps,offset rect,CLR_YELLOW  ;SYSCLR_WINDOW
      .IF RecordOn == 1
          $Call WinDrawText,hps,-1,offset textMsgOn,offset rect,CLR_BLUE,CLR_YELLOW,TextPos
      .ENDIF
      .IF RecordOn == 2
          $Call WinDrawText,hps,-1,offset textMsgPlay,offset rect,CLR_BLUE,CLR_YELLOW,TextPos
      .ENDIF
      .IF UpdateDat == 1
          $Call WinDrawText,hps,-1,offset textMsgUpdateDat,offset rect,CLR_BLUE,CLR_YELLOW,TextPos
      .ENDIF
      .IF toggle == 0
          $Call WinDrawText,hps,-1,offset textMsgToggleOff,offset rect,CLR_BLUE,CLR_YELLOW,TextPos
      .ENDIF
      $Call WinEndPaint,hps
      mov   eax,TRUE
      ret
MainPaint  endp

;-------------- InitMainWindow * WM_CREATE --------------
;var1 = hwnd, var2 = mp1, var3 = mp2
InitMainWindow Proc
       $Call WinDefWindowProc,parm1,parm2,parm3,parm4
       ret
InitMainWindow Endp

;-------------- MainKeyBoard * WM_CHAR --------------
;var1 = mp1,var2 = mp2,var3 = hwnd
MainKeyBoard  Proc
      $Call WinDefWindowProc,parm1,parm2,parm3,parm4
      ret
MainKeyBoard Endp

ExitWin  Proc
    $Call WinDestroyMsgQueue,hmq
    $Call WinTerminate,hab
    $Call DosFreeModule,DllHandle
    $DosExit    ;so exit
    ret
ExitWin  Endp

SwitchListAlloc  Proc          ;allocate memory for a switch list of 30
    mov     ecx,00000002h   ;write access flags for Dos alloc
    or      ecx,00000010h   ;page commit
    $Call DosAllocMem,offset baseaddr,3000,ecx
    .IF  eax != 0
       $WinErrMsg  " : DosAllocMem SwitchList"
       Call Exitwin
    .ENDIF
    ret
SwitchListAlloc  Endp

GetSwitchList   Proc   ;puts address into baseaddr
    pushad
    $Call  WinQuerySwitchList,hab,baseaddr,3000
    .IF eax == 0
        $WinErrMsg " : WinQuerySwitchList"
        Call ExitWin
    .ENDIF
;    $WinInfMsg "  = Number of TAsk List entries"  ;used for debugging
    popad
    ret
GetSwitchList   Endp

;---- This procedure uses the handle returned from the message and uses
;---- that to obtain the first 24 characters of the name associated
;---- with that handle from SwitchList for which space is already allocated
;---- this is called with handle in eax
GetNameFromHandle  Proc
    pusha
    $Call  WinQuerySwitchList,hab,baseaddr,3000
    mov   numitems,eax      ;number of switch list entries
    mov   edi,baseaddr      ;address of switch list
    mov   ecx,1
    mov   NameHitFlag,0     ;reset
    mov   eax,HandFromMsg
    .WHILE  ecx <= numitems           ;starts at offset 0
         ;--- This group displays SwitchList Title and Iconsn
         .IF   eax == [edi+8]        ;hwnd of FrameWindow of Program returned by msgQueue
               mov    NameHitFlag,1
               mov    eax,edi
               add    eax,36         ;address of name
               mov    TaskNameAddr,eax
              .BREAK
         .ENDIF
         ;;--- Displays programTitles
         push  ecx
         $Call WinQueryWindow,HandFromMsg,QW_PARENT
         pop   ecx
         .BREAK .IF eax == 0
         .IF   eax == [edi+8]        ;hwnd of FrameWindow of Program returned by msgQueue
               mov    NameHitFlag,1
               mov    eax,edi
               add    eax,36         ;address of name
               mov    TaskNameAddr,eax
              .BREAK
         .ENDIF
         inc   ecx
         add   edi,swblksize           ;next element in structure
    .ENDW
    .IF  NameHitFlag == 0
         mov  TaskNameAddr,offset NoNameListed
    .ENDIF
    popa
    ret
GetNameFromHandle  Endp

CloseDown       Proc
    $Call WinMessageBox,HWND_DESKTOP,HWND_DESKTOP,offset ExitMsg,offset ExitTitle,0,MB_OKCANCEL
    .IF eax != MBID_CANCEL
        $Call WinShutdownSystem,hab,hmq
        $Call DosFreeMem,memAddr
        $Call WinReleaseHook,hab,NULL,HK_INPUT,[DllProcAddr1],DllHandle
        $Call DosFreeModule,DllHandle
        $Call WinDestroyWindow,hwndMainFrame
        Call  ExitWin
    .ENDIF
    ret
CloseDown       Endp

UnloadKBHook   Proc
    $Alarm0
    $Call WinMessageBox,HWND_DESKTOP,HWND_DESKTOP,offset RemoveMsg,offset RemoveTitle,0,MB_OKCANCEL
    .IF eax != MBID_CANCEL
        $Call DosFreeMem,memAddr
        .IF eax != 0
            $WinErrMsg " : DosFreeRegularMem"
        .ENDIF                                 ;got here OK
        $Call WinReleaseHook,hab,NULL,HK_INPUT,[DllProcAddr1],DllHandle
        .IF eax != 1
           $WinErrMsg " : WinReleastHook"
        .ENDIF
        $Call DosFreeModule,DllHandle
        .IF  eax != 0
            $WinErrMsg "  : DosFreeModule-DLL"
        .ENDIF
        $Call WinDestroyWindow,hwndMainFrame
        .IF  eax != 1
            $WinErrMsg " : WinDestroyWindow"
        .ENDIF
        Call  ExitWin
    .ENDIF
    mov  eax,TRUE
    ret
UnloadKBHook   Endp

SetShiftInsWinSize   Proc        ;Set size of Alt-Shift-Ins(w) window
   pushad
   mov   esi,offset StartData0   ;DosStart Structure
   $Call WinQuerySysValue,HWND_DESKTOP,SV_CXSCREEN   ;width in pels
   mov   Scr_Width_Pels,eax
   xor   edx,edx     ;required for divide
   mov   ecx,3       ;one third of screen width
   div   ecx
   mov   word ptr[esi+42],ax     ;x offset 1/3 of window  width
   mov   word ptr[esi+46],ax     ;x window size also 1/3 full width
   $Call WinQuerySysValue,HWND_DESKTOP,SV_CYSCREEN   ;height in pels
   mov   Scr_Height_Pels,eax
   xor   edx,edx
   mov   ecx,8
   div   ecx
   mov   word ptr[esi+48],ax     ;y window size 1/8 full height
   mov   edx,eax
   add   eax,edx
   add   eax,edx
   mov   word ptr[esi+44],ax     ;offset 3/8 of window height up from 0
   popad
   ret
SetShiftInsWinSize   Endp

;----- Fills RECT structure for window size ---
DefineWindowSize  Proc
    xor   edx,edx
    mov   eax,Scr_Width_Pels
    mov   ecx,7                ;1/7 of screen width
    div   ecx
    mov   Rightx,eax

    xor   edx,edx
    mov   eax,Scr_Height_Pels
    mov   ecx,15                ;1/15 of screen height
    div   ecx
    mov   UpperY,eax

    mov   esi,offset rect
    mov   eax,LeftX             ;defined 0
    mov   [esi],eax
    mov   eax,LowerY            ;defined 0
    mov   [esi+4],eax
    mov   eax,RightX
    mov   [esi +8],eax
    mov   eax,UpperY
    mov   [esi+12],eax
    ret
DefineWindowSize  Endp

;------ sets window position ---
SetWindow   Proc
    mov   edx,0                      ;y-origin
    .IF posorigin == 0               ;default Lower Left Corner
        mov   eax,0
    .ENDIF
    .IF posorigin == 1               ;lower right corner
       mov   eax,Scr_Width_Pels      ;ScreenWidth
       sub   eax,Rightx
    .ENDIF

;    .IF SetOrigin == 1               ;origin location passed
;        mov  eax,0                   ;getting errors here I do not understand
;        mov  edx,0
;        $AsciiToDWord   yorigin
;        mov edx,eax
;        $AsciiToDWord   xorigin     ;result in eax
;    .ENDIF
    mov   ebx,SWP_SIZE
    or    ebx,SWP_MOVE
    .IF invflag == 1
       or ebx,SWP_MINIMIZE
    .ENDIF
    $Call WinSetWindowPos,hwndMainFrame,0,eax,edx,RightX,UpperY,ebx
    .IF eax == 0
        $WinErrMsg " WinSetWindowsPos"
    .ENDIF
    ret
SetWindow   Endp

RecordMacroON Proc   ;esp checks before and after call
    .IF  RecordOn == 0
        mov    RecordOn,1
        mov    JR_Count,0        ;as is done in call
        mov    JR_Counter,0      ;as is done in call
        mov    AddrCtr,0
        $Call WinSetWindowPos,hwndMainFrame,0,0,0,0,0,SWP_ACTIVATE
        $Call WinInvalidateRect,hwndMain,offset rect,TRUE
        $WinInfoMsg  "After Pressing Enter Your First Action Should be to Move to the Desired Starting Location by Hot-Keys or Mouse Actions"
        mov    eax,1             ;in DLL JR_Counter->0,RecordOn->1
        call    DllProcAddr2
    .ENDIF
    ret
RecordMacroON  Endp

; When turning OFF the Shift-Ctrl-Ins key strokes are recorded. They
; contribute 6 counts tothe records. A single key stroke (down and up)
; contributes 2 counts to the record.
RecordMacroOFF   Proc   ;esp checks before and after calls
    pusha
    .IF  RecordOn == 1
        mov    norecs,1
        mov    RecordOn,0
        mov    eax,2             ;JR_Counter,JR_Count,RecordON->0
        call    DllProcAddr2      ;Returns JR_Count in eax
        mov    JR_Count,eax      ;JR_Counter returned from DLL
        $Call WinInvalidateRect,hwndMain,offset rect,TRUE
    .ELSE
        mov    norecs,0          ;no records
    .ENDIF
    popa
    ret
RecordMacroOFF       Endp
;
PlaybackMacro  Proc
    pusha
    .IF  RecordOn == 0 && JR_Count > 8 ;edi saved across calls
        mov  eax,JR_Count
        sub  eax,8             ;Omit 3 start and 5 terminating messages
;        $WinInfMsg   " Messages to Play back !!"
        mov   RecordOn,2
        $Call WinInvalidateRect,hwndMain,offset rect,TRUE
;----  Now Playback the Macro
        mov   esi,msgParms           ;block holding playback records
        add   esi,RecdLnth_x_3       ;no include 1st 3 msgs which are KeyUp of Shift-Ctrl-LeftArrow StartUp Sequence
        mov   ecx,9                  ;Omit 3 start 5 ending messages
        mov   ebx,0
        mov   edx,0                  ;value for first time around
        .WHILE  ecx <= JR_Count
            .IF edx > 0  ;&& dword ptr[esi+ebx+4] != WM_TIMER
                 mov  Delta_t,50
                 Call TimeDelay
            .ENDIF
            pusha
            Call UseCurWindows
            popa
;            mov   eax,[esi+ebx+16] ;time of this just played
            inc   ecx
            add   ebx,RecdLnth
;            mov   edx,[esi+ebx+16] ;time of message coming up
;            sub   edx,eax          ;time diff between messages
        .ENDW
;        mov   eax,ecx
;        dec   eax
;        $WinInfMsg "       Records Played Back"
        ;---- Restore to non Playback
        mov   RecordOn,0      ;reset to no recording
        $Call WinInvalidateRect,hwndMain,offset rect,TRUE
    .ENDIF
    popa
    ret
PlaybackMacro  Endp

;---- Called by PlayBack to use Current Windows which are either
;---- ACtive Windows (mouse related) or windows with focus (KBoard related)
UseCurWindows   Proc
;---- WM_CHAR ----
     ;--- Code here ensures that window with focus gets WM_CHAR messages
     ;--- Using only those on the Down Stroke
    ;Test for Shift-Alt-Ins(white)     -
     .IF  [esi+4+ebx] ==  WM_CHAR  && byte ptr[esi+8+ebx] > 40H   ;Up stroke
         mov    eax,TRUE
         ret
     .ENDIF
     .IF  [esi+4+ebx] ==  WM_CHAR  && byte ptr[esi+8+ebx] <= 40H  ;down stroke
         ;---  Code below ensures that no messages called by Alt/Ctrl -Key
         ;---- Are Called with Shift Alt/Ctrl-Key sequence in playback
         ;---  If Alt/Ctrl down lowest byte of param2=0
         ;---  AND next lowest byte is Scan Code of Key Struck
         ;---  If Shift Down Test Lowest Word of param1 for KC_SHIFT
         mov     edx,[esi+12+ebx] ;param2
         .IF     dh != 0 && dl == 0 ;Alt/Ctrl down and ScanCode valid
             test   [esi+8+ebx],KC_SHIFT   ;is ShiftKey Down
             jz     NoShft
             mov   eax,TRUE
             ret
         .ENDIF
NoShft:  $Call WinQueryFocus,HWND_DESKTOP    ;window handle returned in EAX
         $Call WinSendMsg,eax,WM_CHAR,[esi+8+ebx],[esi+12+ebx]  ;this works
         mov   eax,TRUE
         ret
     .ENDIF

;---- WM_MOUSEMOVE ----
;---- The parms here are x,y coordinates relative to Screen
;---- x = 0, y = 0 is lower left corner
     .IF   dword ptr[esi+4+ebx] == WM_MOUSEMOVE || dword ptr[esi+4+ebx] == WM_MOUSELAST
          $Call  WinSetPointerPos,HWND_DESKTOP,dword ptr[esi+20+ebx],dword ptr[esi+24+ebx]
          mov   eax,TRUE
          ret
     .ENDIF

;---- WM_BUTTON1DOWN=WM_BUTTON1CLICK WM_SINGLESELECT WM_BUTTON1DBLCLK WM_BUTTON1UP  WM_BUTTON1MOTIONSTART || [esi+4+ebx] == WM_BUTTON1MOTIONEND----
     .IF  [esi+4+ebx] == WM_BUTTON1DOWN || [esi+4+ebx] == WM_BUTTON1UP || [esi+4+ebx] == WM_BUTTON1DBLCLK || [esi+4+ebx] == WM_BUTTON1MOTIONSTART || [esi+4+ebx] == WM_BUTTON1MOTIONEND || [esi+4+ebx] == WM_BUTTON1CLICK ;| [esi+4+ebx] == WM_SINGLESELECT
          ;--- This gets handle of active window from DeskTop
          mov   eax,[esi+20+ebx]        ;X Screen Coordinate
          mov   WinPosX,eax
          mov   eax,[esi+24+ebx]        ;Y Screen Coordinate
          mov   WinPosY,eax
          $Call WinWindowFromPoint,HWND_DESKTOP,offset WinPosX,TRUE
          mov   hwndActive,eax
          $Call WinSetFocus,HWND_DESKTOP,eax
          $Call WinSendMsg,hwndActive,[esi+4+ebx],[esi+8+ebx],[esi+12+ebx]  ;this works
          mov   eax,TRUE
          ret
     .ENDIF

;---- WM_BUTTON2DOWN  WM_BUTTON2UP WM_BUTTON2DBLCLK  WM_BUTTON2MOTIONSTART  WM_BUTTON2MOTIONEND WM_BUTTON2CLICK ----
     .IF  [esi+4+ebx] == WM_BUTTON2DOWN || [esi+4+ebx] == WM_BUTTON2UP || [esi+4+ebx] == WM_BUTTON2DBLCLK || [esi+4+ebx] == WM_BUTTON2MOTIONSTART || [esi+4+ebx] == WM_BUTTON2CLICK
          ;--- This gets handle of active window from DeskTop
          mov   eax,[esi+20+ebx]        ;X Screen Coordinate
          mov   WinPosX,eax
          mov   eax,[esi+24+ebx]        ;Y Screen Coordinate
          mov   WinPosY,eax
          $Call WinWindowFromPoint,HWND_DESKTOP,offset WinPosX,TRUE
          mov   hwndActive,eax
          $Call WinSetFocus,HWND_DESKTOP,eax
          $Call WinSendMsg,hwndActive,[esi+4+ebx],[esi+8+ebx],[esi+12+ebx]  ;this works
         mov   eax,TRUE
         ret
     .ENDIF

;---- WM_ related to mouse drag
     .IF   dword ptr[esi+4+ebx] == WM_BEGINDRAG || dword ptr[esi+4+ebx] == WM_ENDDRAG || [esi+4+ebx] == WM_BUTTON2MOTIONEND
          mov   eax,[esi+20+ebx]        ;X Screen Coordinate
          mov   WinPosX,eax
          mov   eax,[esi+24+ebx]        ;Y Screen Coordinate
          mov   WinPosY,eax
          $Call WinWindowFromPoint,HWND_DESKTOP,offset WinPosX,TRUE
          mov   hwndActive,eax
          $Call WinSetFocus,HWND_DESKTOP,hwndActive
          $Call WinSendMsg,hwndActive,[esi+4+ebx],[esi+8+ebx],[esi+12+ebx]  ;this works
          ret
     .ENDIF

;---- WM_TASKLIST 082H----
;---- Task List -- TaskList Handle is Unique,TaskListHandle equ 004001CCh -< 2.0
;---- TaskList Handle = 004001D8H in vs. 2.1
;---- Though there are other messages associated with the Task List
;---- 80H = SH_TASKLIST 81h = SH_TASKMANAGER 82H = SH_TASKACTIVATE
;---- ALso 02f43h and 02F42h seem associated
;---- If this not included Ctrl-Esc not recognized on playback
;---- Inclusion of 2F43H below meakes Macro Playback involving Ctrl-Esc work incorrectly
;---- Inclusion of 81h makes no difference
;---- Inclusion of 80h makes no difference
;---- Inclusion of 1003H makes no difference but does display TaskLIst at End
     .IF dword ptr[esi+ebx+4] == 82h || dword ptr[esi+ebx+4] == 2F42h || dword ptr[esi+ebx+4] ==1003h
         $Call WinSetFocus,HWND_DESKTOP,TaskListHandle
         $Call WinSendMsg,TaskListHandle,[esi+4+ebx],[esi+8+ebx],[esi+12+ebx]  ;this works
         mov   eax,TRUE
         ret
     .ENDIF


;---- WM_OPEN WM_CLOSE WM_SYSCOMMAND WM_COMMAND
;---- WM_SYSCOMMAND controls window size etc.  examine parms passed
;---- and pass to FRAME WINDOW obtained by call to WinQueryWindow passing focus to it
;---- Inclusion of WM_CONTROL seems to make no difference
     .IF [esi+4+ebx] == WM_OPEN || [esi+4+ebx] == WM_CLOSE || [esi+4+ebx] == WM_SYSCOMMAND || [esi+4+ebx] == WM_COMMAND || [esi+4+ebx] == WM_CONTROL || dword ptr[esi+4+ebx] == 185h
          $Call WinQueryFocus,HWND_DESKTOP
          $Call WinQueryWindow,eax,QW_PARENT
          $Call WinSendMsG,eax,[esi+4+ebx],[esi+8+ebx],[esi+12+ebx]  ;this works
          mov   eax,TRUE
         ret
     .ENDIF

;---- WM_PAINT ----
     .IF   [esi+4+ebx] == WM_PAINT
         $Call WinQueryFocus,HWND_DESKTOP
         $Call WinSendMsg,eax,[esi+4+ebx],[esi+8+ebx],[esi+12+ebx]  ;this works
         mov   eax,TRUE
         ret
     .ENDIF

;---- WM_USER+300h --- Send message to this Program (= hwndMain) for action
     .IF   [esi+4+ebx] == WM_USER+300h
         $Call WinSendMsg,hwndMain,[esi+4+ebx],[esi+8+ebx],[esi+12+ebx]
         mov   eax,TRUE
         ret
     .ENDIF

;---- WM_ALL_THE_REST ----
;---- Since we do not know what window to send them to
     mov   eax,TRUE
     ret            ;for all those messages not explicitly handled
UseCurWindows   Endp

;------Write Macro to File  Format is in ASCII HEX in LF/CR separated records
;      hwnd msgID mp1 mp2 Time Coord
;      Activated by Shift-Ctrl-PgDn(White)
;      Format 8 DWords into HEX using $DWordtoHex, copy from DW_Buff to
;      fmBuffer, space separating each Dword then write out to file
;      The handle at offset 8 in switch structure is handle of parent
;      frame of window identified by hwnd in quemsg structure
;      The files are written to directory and name selected by
;      user in GetUserFile call. This writes both hex and ascii to same directory
;      The user selected file name is in fdFileDlg.fildlg_szFullFile with
;      extension hex. Copy to fmName and change extension.
WriteMacroAsciiHex   Proc      ;Write Macro to File
    pusha
    ;--- first copy name to fmName from fdFileDlg.fildlg_szFullFile and
    ;    change extension to "mac"
    $StrCpy fmName,fdFileDlg.fildlg_szFullFile
    mov  edi,offset fmName
    xor  ecx,ecx
    .WHILE byte ptr [edi+ecx] != 0   ;go to end of string
        inc   ecx
    .ENDW
    sub  ecx,3
    mov  byte ptr[edi+ecx],'m'
    mov  byte ptr[edi+ecx+1],'a'
    mov  byte ptr[edi+ecx+2],'c'
    ;--- next set file size to correspond to number of messages
    ;fsize = #records x 84 + header
    mov   eax,JR_Count
    mov   ecx,84
    mul   ecx
    add   eax,84            ;header size
    mov   fmsize,eax
    $Call DosOpen,offset fmName,offset fmhandle,offset fmActionTaken,fmsize,fmAttribute,fmOpenFlag,fmOpenMode,fmExtaBuf
    .IF   eax != 0
         $WinInfMsg " : DosOpenMacroFile "
         popa
         ret
    .ENDIF
    ;----- first write header line
    $Call DosWrite,fmhandle,offset fmHeader,84,offset fmWritten
    ;----- then actual data records
    mov    ebx,msgParms           ;Address of Source
    mov    edx,JR_Count
    .WHILE edx > 0
        mov   ecx,1
        mov   esi,offset fmBuffer
        .WHILE ecx <= 7
            mov  eax,[ebx]
            .IF  ecx == 1     ;handle from msgparms
                mov   HandFromMsg,eax   ;value to be passed
                pusha
                Call GetNameFromHandle   ;value of handle passed in HandFromMsg
                mov  edi,TaskNameAddr    ;address of TaskListName returned
                mov  edx,1
                add  esi,70
                .WHILE  edx <= 12        ;copy to fmBuffer
                    mov   al,byte ptr[edi]
                    .IF   al == 13 || al == 10  ;CR or LF
                        .BREAK
                    .ENDIF
                    mov   [esi],al
                    inc   edx
                    inc   esi
                    inc   edi
                .ENDW
                .IF edx != 13             ;need to fill out with spaces
                    dec   edx
                    dec   esi
                   .WHILE  edx <= 12
                       mov  byte ptr [esi]," "
                       inc  esi
                       inc  edx
                   .ENDW
                .ENDIF
                popa
            .ENDIF
             mov    eax,[ebx]
             Call   DwordToHex
             inc    ecx
             add    ebx,4                 ;get next parm
             add    esi,10
        .ENDW
        dec   edx

        $Call DosWrite,fmhandle,offset fmBuffer,84,offset fmWritten
        .IF   eax != 0
             $WinInfMsg " : DosWrite "
             popa
             ret
        .ENDIF
    .ENDW
    $Call DosSetFileSize,fmHandle,fmSize
    $Call DosClose,fmHandle
    .IF   eax != 0
         $WinInfMsg " : DosCloseMacroFile "
         popa
         ret
    .ENDIF
    popa
    ret
WriteMacroAsciiHex   Endp

;------Write Macro to File  Format  in binary
;      Activated by Shift-Ctrl-PgDn(White)
;      File Name selected by call to GetUserFile and is stored in
;      fdFileDlg.fildlg_szFullFile
WriteMacroBin   Proc      ;Write Macro to File in binary
    pushad
    ;--- first set file size to correspond to number of messages
    mov   eax,JR_Count
    mov   ecx,28      ; 4 bytes x 7 parms\byte
    mul   ecx
    mov   fmsize,eax
    $Call DosOpen,offset fdFileDlg.fildlg_szFullFile,offset fmhandle,offset fmActionTaken,fmsize,fmAttribute,fmOpenFlag,fmOpenMode,fmExtaBuf
    .IF   eax != 0
         $WinInfMsg " : DosOpenMacroHexFile "
         popad
         ret
    .ENDIF
    $Call DosWrite,fmhandle,msgParms,fmsize,offset fmWritten
    .IF   eax != 0
         $WinInfMsg " : DosWrite Hex"
         popad
         ret
    .ENDIF
    $Call DosSetFileSize,fmHandle,fmSize
    $Call DosClose,fmHandle
    .IF   eax != 0
         $WinInfMsg " : DosCloseMacroFile "
         popad
         ret
    .ENDIF
    popad
    ret
WriteMacroBin   Endp

; does a time dealy of milli seconds value passed in Delta_T
TimeDelay  Proc
    pusha
    $Call WinGetCurrentTime,hab   ;returns in eax
     mov  nwritten,eax
    .WHILE 1          ;
        $Call WinGetCurrentTime,hab
        sub eax,nwritten            ;difference in time
        .BREAK .IF eax > Delta_T   ;
    .ENDW
    popa
    ret
TimeDelay Endp

ReadDatFile   Proc
;----------  IS Data File AVAILABLE AND VALID ? ------------
;---------- First see if  hookkbsm.dat exists in proper location ------
     mov   EOFFlag,0       ;initial value
     $Call DosOpen,offset fName,offset fhandle,offset fActionTaken,fsize,fAttribute,fOpenFlag,fOpenMode,fExtaBuf
     .IF   eax != 0
          $WinErrMsg " : DosOpen "
          Call   ExitWin
     .ENDIF
;------- get file size
     $Call DosSetFilePtr,fhandle,0,FILE_END,offset fpointer1
     .IF    eax != 0
          $WinErrMsg " : DosSetFilePtr1"
          Call   ExitWin
     .ENDIF
     $Call DosSetFilePtr,fhandle,0,FILE_BEGIN,offset fpointer0
     mov    eax,fpointer1
     sub    eax,fpointer0
     mov    fsize,eax        ;fsize now has file size
     add    eax,16           ;allow a little leeway in buffer
     push   eax
;;------- now allocate memory for file buffers
     .IF memAddr != 0      ;not first time around
          $Call DosFreeMem,memAddr
          .IF eax != 0
              $WinErrMsg " : DosFreeRegularMem"
          .ENDIF
     .ENDIF
     pop    eax            ;get back size needed
     $Call DosAllocMem,offset memAddr,eax,memFlags
     .IF    eax != 0
          $WinErrMsg " : DosAllocMem FileBuf"
          Call   ExitWin
     .ENDIF
;------Read File Into buffer and Close file -------
;reposition to start of file
;     $Call DosSetFilePtr,fhandle,0,FILE_BEGIN,offset fpointer0
     $Call DosRead,fHandle,memAddr,fsize,offset nwritten
     $Call DosClose,fHandle
     mov   eax,fsize
;------ Reset SessT of ExecONKB arrays to 9
     mov   edi,offset AltX
     mov   esi,offset CtrlX
     mov   ecx,1
     mov   ebx,10
     .WHILE  ecx <= 36
          mov  word ptr[edi+ebx],9
          mov  word ptr[esi+ebx],9
          inc  ecx
          add  ebx,10
     .ENDW
;------ Read Buffer and Initialize Arrays ALtX and CtrlX ----
     mov    esi,memAddr
     mov    ecx,0               ;Index and Counter for memAddr
     .WHILE ecx <=  fsize && byte ptr [esi+ecx] != 26   ;Ctrl-Z  Fri  04-30-1993
         call   SkipSpaces        ;skip over any initial spaces
         .BREAK .IF EOFflag == 1
         call   SkipCommentsToEOL ;skip over comments and spaces to first valid entry
         .BREAK .IF EOFflag == 1
         call SkipSpaces          ;skip over initial spaces
;         .IF EOFflag == 1
;             .BREAK
;         .ENDIF
         .BREAK .IF EOFflag == 1
         .IF (byte ptr [esi+ecx] == 'A' || byte ptr [esi+ecx] == 'a' || byte ptr [esi+ecx] == 'C' || byte ptr [esi+ecx] == 'c')
              inc   ecx           ;point to number or letter
              xor   eax,eax
              xor   edx,edx
              mov  al,byte ptr [esi+ecx]  ;get digit or letter ID
             .IF  (al >= '0' && al <= '9')
                  sub  al,'0'         ;convert to decimal
             .ENDIF
             .IF  al  >= 'a'
                  sub  al,32          ;convert to UpperCase
             .ENDIF
             .IF  (al >= 'A' && al <= 'Z')
                  sub  al,37h          ;convert to decimal 10 +
             .ENDIF
              mov      dl,LenExec ;Length of Structure    10
              mul      dl         ;ax has offset into array
              inc      ecx        ;right after digit/letter id A/C number
         .ELSE
              .CONTINUE           ;go around again
         .ENDIF
         .IF byte ptr[esi+ecx - 2] == 'A' || byte ptr[esi+ecx - 2] == 'a'
               mov     edi,offset AltX      ;this is Alt Keys
         .ENDIF
         .IF byte ptr[esi+ecx - 2] == 'C' || byte ptr[esi+ecx - 2] ==  'c'
               mov     edi,offset CtrlX     ;this is a Ctrl Key
         .ENDIF
         .IF edi == offset AltX || edi == offset CtrlX
               mov     edx,eax              ;edx is offset into array
               call    SkipSpaces           ;go to SessID
               .BREAK .IF EOFflag == 1
               xor     eax,eax
               mov     al,byte ptr [esi+ecx] ;get sess type
               sub     al,'0'                ;convert to  number
               mov     word ptr [edi + edx+8],ax
               inc     ecx
               call    SkipSpaces            ;get to Exec string
               .BREAK .IF EOFflag == 1
               mov     eax,esi
               add     eax,ecx               ;offset of exec
               mov     [edi+edx],eax         ;store its address
               ; have to go to end of Exec string and place a numeric 0 there
               .WHILE  byte ptr [esi+ecx] != ' '
                    inc  ecx
               .ENDW   ;exits    pointing to end of exec command
               .BREAK .IF byte ptr[esi+ecx] != ' '
                  mov     byte ptr [esi+ecx],0
               inc     ecx
               call    SkipSpaces            ;get next parameter
               .BREAK .IF EOFflag == 1
               xor     eax,eax
               .IF     byte ptr [esi+ecx]== '0'  ;no command line
                   mov     al,byte ptr [esi+ecx]
                   sub     al,'0'
                   mov     [edi+edx+4],eax
               .ELSE                         ;its a string - copy its address
                   mov eax,esi
                   add eax,ecx               ;offset of command line
                   .IF   byte ptr [esi+ecx] != 22h  ;not a "
                      mov     [edi+edx+4],eax   ;store command line address
                      .WHILE  byte ptr [esi+ecx] != ' ' && ecx < fsize  ;skip until a space
                          .IF byte ptr[esi+ecx] == lf || byte ptr[esi+ecx] == cr  ; LF but no ";"
                               Call DataFormatErr
                          .ENDIF
                           inc  ecx
                      .ENDW                  ;exits  pointing to end of command line
                     .BREAK .IF ecx >= fsize
                      mov    byte ptr [esi+ecx],0 ;put 0 at end
                   .ELSE                     ;first char is a quote
                      inc  ecx               ;move beyond it
                      inc  eax
                      mov     [edi+edx+4],eax   ;store command line address
                      .WHILE byte ptr [esi+ecx] != 22h && ecx < fsize ; skip until a "
                           inc  ecx
                      .ENDW                  ;exits pointing to final quote
                      mov    byte ptr [esi+ecx],0 ;put 0 at end
                      .BREAK .IF ecx >= fsize
                      inc    ecx
                      .BREAK .IF byte ptr[esi+ecx] != ' '
                   .ENDIF
               .ENDIF
               .BREAK .IF ecx >= fsize || byte ptr[esi+ecx] == 26    ;Ctrl-Z
               xor    edi,edi                ;reset to 0 so test can be made
               .WHILE byte ptr[esi+ecx] != ';' && ecx < fsize  ;go to next comment ;
                   .IF byte ptr[esi+ecx] == lf || byte ptr[esi+ecx] == cr  ; LF but no ";"
                        Call DataFormatErr
                   .ENDIF
                   inc   ecx
               .ENDW
               .BREAK .IF ecx >= fsize || byte ptr[esi+ecx] == 26 ;Ctrl-Z
               .CONTINUE
         .ENDIF
     .ENDW
; See if Dat File properly read in
     .IF byte ptr [esi+ecx] == 26   ;Ctrl-Z
;         $WinErrMsg " : Ctrl-Z here"
     .ELSEIF ecx < fsize
          Call DataFormatErr
     .ENDIF
     ret
ReadDatFile   Endp

;------------ ReadMacroFile ------------
;Read in File *.hex  as selected from GetUserFile call
;by GetUserFile Call.
;The macro was saved to name selected by GetUserFile when Shift-Ctrl-PgDn
;option was selected.
;using Shift-Ctrl-PgDn - the user will then rename it and store it
ReadMacroBin  Proc
;----------  IS MAC File AVAILABLE AND VALID ? ------------
;---------- First see if  *.hex exists in proper location ------
;---------- name is in FILEDLG structure in fdFileDlg.fildlg_szFullFile
     pushad
     $Call DosOpen,offset fdFileDlg.fildlg_szFullFile,offset fmhandle,offset fmActionTaken,fmsize,fmAttribute,fOpenFlag,fmOpenMode,fmExtaBuf
     .IF   eax != 0
          $WinErrMsg " : DosOpen KBHex "
          popad
          ret
     .ENDIF
;------- do not need file size since created from this program
     $Call DosSetFilePtr,fmhandle,0,FILE_END,offset fpointer1
     .IF    eax != 0
          $WinErrMsg " : DosSetFilePtr1 KBHex"
          popad
          ret
     .ENDIF
     $Call DosSetFilePtr,fmhandle,0,FILE_BEGIN,offset fpointer0
     .IF    eax != 0
          $WinErrMsg " : DosSetFilePtr0 KBHex"
          popad
          ret
     .ENDIF
     mov    eax,fpointer1
     sub    eax,fpointer0
     mov    fmsize,eax
;     $WinDebugMessage  TextMsgPlay   ;correct number here
;     $Call DosSetFilePtr,fmhandle,0,FILE_BEGIN,offset fpointer0 ;reset to start
     $Call DosRead,fmhandle,msgParms,fmsize,offset fmWritten
     .IF   eax != 0
          $WinErrMsg " : DosRead KBHex "
          popad
          ret
     .ENDIF
     $Call DosClose,fmhandle
     mov    ecx,28
     xor    edx,edx           ;if not get divide by 0 error
     mov    eax,fmsize
     div    ecx               ;eax now has JR_Count
     mov    JR_CounT,eax
     mov    eax,fmwritten
;     $WinDebugMessage  TextMsgPlay   ; 0 = fmwritten
     popad
     ret
ReadMacroBin Endp

;if there are spaces this exits pointing to next non-space else points to non-space
SkipSpaces   proc    ;just skips over spaces
   .WHILE ecx < fsize && byte ptr [esi+ecx] == ' '   ;spaces
        inc ecx
   .ENDW
   .IF ecx >= fsize || byte ptr [esi+ecx] == 26  ; Ctrl-Z  Sat  05-01-1993
        mov    EOFflag,1
   .ENDIF
    ret
SkipSpaces   endp

SkipCommentsToEOL proc    ;skip from ';' to beginning of next line
    .IF byte ptr[esi+ecx] == ';' && ecx < fsize  ;if a comment
        inc    ecx
        .WHILE byte ptr [esi+ecx] != 0ah && ecx < fsize  ;Line feed end of line
            inc ecx
        .ENDW                       ;points to 0ah if it exists if not EOF
        .IF byte ptr[esi+ecx] == 26 ; Ctrl-Z
            mov EOFflag,1
        .ENDIF
    .ELSE
        mov    eax,ecx              ;bytes processed appears in message
        call DataFormatErr
    .ENDIF
    .IF  byte ptr[esi+ecx] != 0ah   ;must be EOF
         mov    EOFflag,1
    .ELSE                           ;it is end of line
         inc    ecx                 ;goto next line
         .IF    ecx >= fsize || byte ptr[esi+ecx] == 26  ; Ctrl-Z
             mov    EOFflag,1
         .ENDIF
    .ENDIF
    ret
SkipCommentsToEOL endp

DataFormatErr   Proc
    mov     eax,ecx            ;bytes processed appears in message
    mov     ecx,fsize
    sub     ecx,eax
    .IF     ecx >= 4           ;Sat  05-01-1993
        $WinDebugMessage msgFileErr
        call ExitWin           ;Fri  04-30-1993
    .ENDIF
    ret
DataFormatErr   EndP

SetJump   Proc           ;set HOOK to be not jumpable
   pushad
   $NumSwitchListEntries
   mov  numitems,eax      ;number of switch list entries
   dec numitems
   Call GetSwitchList     ;activate structure
   mov  edi,baseaddr      ;address of switch list
   mov  ecx,0
   mov  bl,'H'
   mov  bh,'o'
   mov  dl,'o'
   mov  dh,'K'
   .WHILE  ecx < numitems           ;starts at offset 0
       .IF bl == [edi+36] && bh == [edi+37] && dl == [edi+38]  && dh ==[edi+39]
            ;Mark this is as not jumpable
            mov  dword ptr[edi+32],SWL_NOTJUMPABLE     ;jumpable ?
            mov  esi,edi
            add  esi,8
            $Call WinChangeSwitchEntry,dword ptr[edi+4],esi
            .BREAK
       .ENDIF
       inc   ecx
       add   edi,swblksize           ;next element in structure
   .ENDW
   popad
   ret
SetJump   Endp

GetTaskList   Proc              ;GEt Handle of Task List
;   $NumSwitchListEntries
;   mov  numitems,eax            ;number of switch list entries
   Call GetSwitchList           ;activate structure
   mov  edi,baseaddr            ;address of switch list
   mov  eax,dword ptr[edi+8]    ;handle of first one in list which is TaskList
   mov  TaskListHandle,eax
   ret
GetTaskList   Endp

;----Handles setting things to reflect  Invisible flag options selected
InvFlagAction    Proc
   .IF InvFlag == 1
      mov   eax,SWP_RESTORE
      or    eax,SWP_ACTIVATE
      or    eax,SWP_SHOW
   .ELSE
      mov   eax,SWP_ACTIVATE
   .ENDIF
   $Call WinSetWindowPos,hwndMainFrame,0,0,0,0,0,EAX
   ret
InvFlagAction  Endp

;------ Thu  09-02-1993  This procedure handles  the saving and loading of
;------ macro  files. It is called just before Shift_Ctrl-PgUp to get a file
;------ to load if not playing back macro in meory and it is called just
;------ before Shift-Ctrl-PgDn to get name to save file to.
GetUserFile   Proc
    ;-----initializations
    mov    fdFileDlg.fildlg_cbsize,sizeof(FILEDLG)
    mov    fdFileDlg.fildlg_fl,0                           ;start fresh
    or     fdFileDlg.fildlg_fl,FDS_CENTER
    .IF  dlgOpt == 0
        or     fdFileDlg.fildlg_fl,FDS_OPEN_DIALOG
        mov    fdFileDlg.fildlg_pszTitle,offset fdTitle0   ;Title Bar
    .ELSE
        or     fdFileDlg.fildlg_fl,FDS_SAVEAS_DIALOG
        mov    fdFileDlg.fildlg_pszTitle,offset fdTitle1   ;Title Bar
    .ENDIF
    $strcpy fdFileDlg.fildlg_szFullFile,fdFileName ;- copy filter string
    $Call WinFileDlg,HWND_DESKTOP,hwndMainFrame,offset fdFileDlg
    mov      fdlghwnd,eax
    mov      ebx,fdFileDlg.fildlg_lReturn
    .IF eax > 0 && ebx == DID_OK   ;$WinErrMsg "  : WinFileDlg OK"
        mov   eax,1
    .ELSE
        mov   eax,0
    .ENDIF
    ret
GetUserFile    Endp

GetFocusWindow  Proc
    pushad
    $Call WinQueryfocus,HWND_DESKTOP   ;returned in eax
    mov  Mparm2,eax
    $Call WinPostMsg,WinTarget,WM_USER+301h,Mparm1,Mparm2
    popad
    ret
GetFocusWindow  Endp

;This gets the Handle of the Program whose name was passed on command line
GetTargetHandle  Proc
    pushad  ; Tue  07-20-1993   pusha -> pushad
    $NumSwitchListEntries
    mov  numitems,eax      ;number of switch list entries
    dec  numitems
    Call GetSwitchList     ;activate structure
    mov  edi,baseaddr      ;address of switch list
    mov  ecx,0
    mov  esi,offset PG_Entry
    mov  edx,PG_Len
    .WHILE  ecx < numitems           ;starts at offset 0
        Call MatchStrings            ;see if in task list
        .IF ebx == PG_Len                 ;Match with task list name
             mov  ebx,[edi+8]        ;Mon  08-09-1993  window handle
             mov  WinTarget,ebx
             jmp   tl0               ;exit
        .ENDIF
        inc   ecx
        add   edi,swblksize           ;next element in structure
    .ENDW
    ;if got here Target Not loaded
    $Call WinQueryFocus,HWND_DESKTOP
    push   eax                        ;save focus
    $WinInfoMsg  'Target Program Not loaded'
    pop    eax
    $Call WinSetFocus,HWND_DESKTOP,eax      ;reset
tl0:popad            ;Tue  07-20-1993 popa ->popad
    ret
GetTargetHandle  Endp

; Program is passed offsets of strings to match in esi and edi
; edi is offset of base address of Task List and esi is Offset of string
; passed on Command Line in task list, edx has length of esi string
; Returns in ebx length of match
MatchStrings  Proc
    push   esi
    push   edi
    push   ecx
    mov    ebx,0
    add    edi,36
    .WHILE  ebx < edx   ; byte ptr[esi+ebx] != 0       ;while passed string is valid
         mov  al,byte ptr[esi+ebx]
         .IF al == byte ptr[edi+ebx] ;36 is offset of Task List Title
              inc    ebx
         .ELSE
              .BREAK
         .ENDIF
    .ENDW
ms0:pop    ecx
    pop    edi
    pop    esi
    ret
MatchStrings  Endp

; This is called only if ClassName is WC_FRAME (#1 returned by WinQueryClassName)
CheckTitle   Proc
    pushad
    Call GetSwitchList     ;activate structure
    mov  esi,baseaddr      ;address of switch list
    add  esi,swblksize     ;newest one just added
    mov  eax,[esi+4]       ;switch list handle
    mov  edx,eax           ;saved here
    mov  dword ptr [esi+28],SWL_VISIBLE
    mov  ebx,dword ptr [StartData0+8] ;title desired
    mov  al,[esi+36]   ;A/C  ;From Switch List title
    mov  ah,[esi+36+3] ;'-'
    mov  cl,[ebx]            ;From Data Structure StartData0
    mov  ch,[ebx+3]
    .IF al == cl && ah == ch
       ;$WinInfMsg  " Match"    MATCH
    .ELSE
        mov   ecx,0          ;Copy desired string in
        .WHILE ecx <= 20 && byte ptr[ebx+ecx] != 0
            mov al,byte ptr[ebx+ecx]
            mov byte ptr[esi+36+ecx],al
            inc  ecx
        .ENDW
        add   esi,8           ;address of control block for this change
        $Call WinChangeSwitchEntry,edx,esi
    .ENDIF
    popad
    ret
CheckTitle    Endp

END   startup                       ;required


;    ;Test for Shift-Ctrl-5(white)    - ProgramTestCtrl
;         .IF  edx == 76 && Alt_Ctrl == 1      ;Shift-Ctrl-5(White)
;            Call  ProgramTestCtrl
;            jmp   wm0
;         .ENDIF
;    ;Test for Shift-Alt-5(white)    - ProgramTestAlt
;         .IF  edx == 76 && Alt_Ctrl == 0      ;Shift-Alt-5(White)
;            Call  ProgramTestAlt
;            jmp   wm0
;         .ENDIF

;--- Will Display handle of Window Under Mouse and WindowClass and
;--- Then whether 16/32 bit
;ProgramTestAlt  Proc      ;Use for testing things  Shift-Alt-5(white)
;    pusha
;    $Call WinQueryFocus,HWND_DESKTOP    ;get current focus to save
;    push   eax
;    $Call WinQueryPointerPos,HWND_DESKTOP,offset WinPosX
;    ;--- IF FALSE is chosen returns Handle of Frame Window under HWND_DESKTOP
;    ;--- IF  TRUE is chosen returns Handle of Actual Window
;    $Call WinWindowFromPoint,HWND_DESKTOP,offset WinPosX,TRUE
;    mov   hwndNext0,eax
;    $WinInfMsg  " is Handle of Window Under Mouse"
;    $Call WinQueryClassName,hwndNext0,16,offset ClassNameBuf
;    mov   eax,hwndNext0
;    $WinDebugMessage   ClassNameBuf
;    $Call WinQueryWindowModel,eax        ;0 = 16 bit, 1 = 32 bit
;    .IF  eax == 0
;         mov   eax,16
;    .ELSEIF  eax == 1
;         mov   eax,32
;    .ENDIF
;    $WinInfMsg  "   Bit Window"
;    $Call WinQueryWindow,hwndNext0,QW_OWNER
;    $WinInfMsg  " is Owner of window under mouse"
;    $Call WinQueryWindow,hwndNext0,QW_PARENT
;    $WinInfMsg  " is Parent of window under mouse"
;    pop   eax
;    $Call WinSetFocus,HWND_DESKTOP,eax
;    popa
;    ret
;ProgramTestAlt  Endp
;
;ProgramTestCtrl  Proc      ;Use for testing things  Shift-Ctrl-5(white)
;    pusha
;    $Call WinQueryPointerPos,HWND_DESKTOP,offset WinPosX
;    ;--- IF FALSE is chosen returns Handle of Frame Window under HWND_DESKTOP
;    ;--- IF  TRUE is chosen returns Handle of Actual Window
;    $Call WinWindowFromPoint,HWND_DESKTOP,offset WinPosX,FALSE
;    mov   hwndNext0,eax
;    $WinInfMsg  "      Handle of Frame of Window Under Mouse"
;    $Call WinBeginEnumWindows,hwndNext0      ;HWND_DESKTOP
;    .IF  eax == PMERR_INVALID_HWND
;         $WinInfMsg   "  Error Calling WinBeginEnumWindows"
;         jmp   xptc
;    .ENDIF
;    mov   henum,eax           ;enum handle
;    mov   ecx,0
;    .WHILE TRUE
;         push   ecx
;         $Call WinGetNextWindow,henum
;         pop    ecx
;         .BREAK .IF eax == 0
;         .IF  ecx == 0
;              mov   hwndNext0,eax
;         .ENDIF
;         .IF  ecx == 1
;              mov   hwndNext1,eax
;         .ENDIF
;         .IF  ecx == 2
;              mov   hwndNext2,eax
;         .ENDIF
;         push   ecx
;         $WinInfMsg  "     Window Handle Value"
;         pop    ecx
;         inc   ecx
;    .ENDW
;    mov  eax,ecx
;    $WinInfMsg   "     Number of Windows below Frame Window"
;    $Call WinEndEnumWindows,henum
;
;    mov   eax,hwndNext0
;    $Call WinQueryClassName,hwndNext0,7,offset ClassNameBuf
;    mov   eax,hwndNext0
;    $WinDebugMessage   ClassNameBuf
;
;    $WinInfMsg   "   Enumerating Children of Window to Left"
;    $Call WinBeginEnumWindows,hwndNext0
;    .IF  eax == PMERR_INVALID_HWND
;         $WinInfMsg   "  Error Calling WinBeginEnumWindowsNext0"
;         jmp   xptc
;    .ENDIF
;    mov   henum,eax           ;enum handle
;    .WHILE TRUE
;         $Call WinGetNextWindow,henum
;         .BREAK .IF eax == 0
;         push  eax
;         $Call WinQueryClassName,eax,20,offset ClassNameBuf
;         pop   eax            ;handle back
;         $WinDebugMessage   ClassNameBuf
;    .ENDW
;    $Call WinEndEnumWindows,henum
;    .IF eax == 0
;        $WinInfMsg  "  WinEndEnumWindows"
;    .ENDIF
;xptc: popa
;    ret
;ProgramTestCtrl  Endp
;
