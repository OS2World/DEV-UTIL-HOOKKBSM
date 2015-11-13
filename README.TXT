        Tue  11-16-93
 From : Morton F. Kaplon
   To : ALL


 CONTENTS

 I   Contents of HOOK05.ZIP

 II  What HOOKKBSM does

 III Installing HOOKKBSM

 IV  Using HOOKKBSM



 I   Contents of HOOK05.ZIP

 - FileName -   --------------------- Description of File ---------------------
 dll-w386.cmd   CMD file to create hookdlsm.dll from hookdlsm.asm
 doswin32.mac   Macros used in the two ASM files
 hookdlsm.asm   Source code for hookdlsm.dll
 hookdlsm.def   DEF file required for Assembling hookdlsm
 hookdlsm.dll   Dynamic Load Module - intercepts message queue
 hookkbsm.asm   Source Code for hookkbsm.exe
 hookkbsm.dat   Sample data file for hot-key assignments - read by hookkbsm.exe
 hookkbsm.doc   Documentation for HOOKKBSM
 hookkbsm.exe   Executable File - Executes According to Key Combinations Struck
 hot-keys.prg   ASCII file Listing Hard Coded Key Assignments
 hot-keys.usr   Sample ASCII file listing hot-key assignments in hookkbsm.dat
 install.cmd    CMD file to Copy required files to assigned directories
 mlc-w386.cmd   CMD file to assemble hookkbsm.exe from hookkbsm.asm
 readme.1st     This file - What HOOKKBSM does and How to Use it
 target.exe     A file used for testing purposes for receiving messages

 NB To assemble file(s) with mlc-w386.cmd or dll-w386.cmd requires the
    OS/2 2.0 or 2.1 Toolkit  and MASM (>=6.0 and < 6.1). The CMD file assumes
    that the executables in each case are in the defined PATH.

    If you use the 2.0 Toolkit, you will need to edit the dll-w386.cmd
    to reflect that usage (it is coded for 2.1)

    MASM (>=6.1) is not usable as it does not run under OS/2.


 II What HOOKKBSM does

    HOOKKBSM was designed to alleviate the need to clear up the Desktop
    of OS/2 in order to obtain access to Icons to load programs and to
    facilitate switching from one active program to another.

    I found myself all too frequently having to to minimize some of my
    active programs in order to access the Desktop to load another
    program that was required. Additionally I wanted a quicker way of
    switching to another program than using Alt-Esc to move through
    active programs until I came to the desired one or by accessing the
    Task List to select the program.

    Conceptually then, HOOKKBSM is akin to a DOS TSR. Whereas a DOS TSR
    is resident in Memory, HOOKKBSM works through a DLL, HOOKDLSM.DLL
    which is loaded into memory when HOOKKBSM is loaded. HOOKDLSM
    monitors the message queue for WM_CHAR messages, the equivalent of a
    TSR hooking the KB interrupt. WM_CHAR messages contain information
    on Keyboard activity and HOOKDLSM, depending on the Keyboard
    Activity sends messages to HOOKKBSM which executes according to the
    key combinations struck.

    OS/2 itself by default assigns a variety of actions to Keystrokes.
    For instance F1 brings up HELP, Alt-F4 closes an active program,
    Ctrl-Esc brings up the Task List,Alt-Esc and Tab-Esc switch to the
    next program in the Task List, Alt-F7  moves a Window, Alt-F8
    resizes, Alt-F10 maximizes, Alt-F5 restores and so on. In addition
    each program as a rule has its own set of dedicated Keystrokes to
    accomplish certain actions. Editors and Word Processors are very
    rich in such keystroke assignments.

    If a Hot-Key type program is to be useful, it should be as
    unobtrusive as possible and not interfere with programmatic
    hot-keys. I originally chose the triple key combination of
    Shift-Alt-X, Shift-Ctrl-X, where X can be 0,....9,A,B,.....Y,Z (case
    insensitive) for the Hot-Keys since in my experience to date, they
    had been almost unused. I also used those combinations with X being
    keys on the White(numeric) Cursor_Pad for Hard Coded actions
    relating to tasks involving HOOKKBSM itself.

    I have recently discovered that some editors, the E.exe OS/2 Editor
    for instance as well as the Editors built into many Compiler
    programs use the Shift-Ctrl-Cursor_Pad keys very heavily for Block
    activities and thus I have added a Toggle key to HOOKKBSM that
    allows the user to temporarily toggle its trapping actions OFF so
    that the total Keyboard is available to the user. That same Toggle
    key then activates HOOKKBSM so that Hot-Key switching is back ON.

    HOOKKBSM has an additional feature. It can (with some limitations)
    save a sequence of Keyboard and Mouse Actions so that they may be
    replayed. I have found this useful for establishing certain DESKTOP
    environments that I use repeatedly. These "Macros" may be saved to
    Disk and restored From disk to memory for replay. When saved to
    disk, the user is prompted for the name under which to save the
    macro and two files are saved in c:\os2\hook - one with the
    extension HEX which is the file that can be played back when loaded
    into memory and the other a Text file with extension MAC. The latter
    contains the information in the Message queue for the sequence of
    commands that are in the Macro.


 III Installing HOOKKBSM

    The INSTALL.CMD file installs HOOKKBSM. If you are a current user of
    HOOKKBSM note that the format of HOOKKBSM.DAT is basically the same
    as before, but that HOOKDLSM.DLL has been modified as has of course
    HOOKKBSM.EXE.

    If HOOKBSM is active, UNLOAD it before installing this version. In some
    cases HOOKDLSM.DLL does not uninstall and the INSTALL.CMD will not
    copy the new HOOKDLSM.DLL to c:\os2\dll . In that case you should
    reboot, ensuring that HOOKKBSM is not automatically loaded, and then
    run the INSTALL program.

    To use the Install.CMD program, be sure it is in the same directory
    as the rest of the files included in HOOK05.ZIP and type Install.

    The files will be copied to the appropriate subdirectories and if
    those do not exist they will be created.

    FOR CURRENT USERS of HOOKKBSM
       If you were using a previous version of HOOKKBSM that installed
       into c:\os2\hook, then the program will rename those HOOKKBSM.DAT
       and HOT-KEYS.USR files with extensions of OLD before installing
       the new files. The renamed files will remain the in c:\os2\hook
       directory. If you want to use the old HOOKKBSM.DAT and
       HOT_KEYS.USR with the new version, then you should rename them
       with the extensions of DAT and USR respectively after the install
       program is complete and ONLY after renaming the newly installed
       HOOKKBSM.DAT and HOT_KEYS.USR with extensions of NEW. You should
       inspect the new files as the header is now more informative.

       If you were using a version of HOOKKBSM that installed into c:\os2,
       the the current HOOKKBSM.DAT and HOT-KEYS.USR will not be renamed.
       If you want to use them, you should copy them to c:\os2\hook, but
       again rename the newly installed HOOKKBSM.DAT and HOT_KEYS.USR with
       extensions of NEW.

    What Install.CMD does

    IF c:\os2\hook does not exist, it will be created.

    IF c:\os2\hook\hookkbsm.dat exists it will be renamed to
       c:\os2\hook\hookkbsm.old

    IF c:\os2\hook\hot-keys.usr exists it will be renamed to
       c:\os2\hook\hot-keys.old

    HOOKDLSM.DLL will be copied to c:\os2\dll (if it has been unloaded)

    HOOKKBSM.DAT, HOOKKBSM.EXE, HOT-KEYS.USR, HOT-KEYS.PRG will be copied
    to c:\os2\hook .


 IV Using HOOKKBSM

    THE HOT-KEY ASSIGNMENTS

    There are two classes of hot-key assignments in HOOKKBSM. One class
    is hard coded and cannot be changed by the user. The other is under
    the user's control and allows the user to assign specific actions
    to a given key combination. That assignment is done in the text file
    HOOKKBSM.DAT, which is read by HOOKKBSM.

    THE FIXED HOT-KEY ASSIGNMENTS

    The fixed key assignments are all related to the functioning of HOOKKBSM
    and with one exception use the Shift-Alt / Shift-Ctrl in combination
    with the numerical(White) cursor pad. The assignments are:

    Shft-Alt-Del(W)       Unload Hookkbsm
    Shft-Alt-End(W)       ShutDown System

    Shft-Alt-5(W)         Toggle Hot-Keys Off/On

    Shift-Alt-UpArrow(W)  Re-Read HOOKKBSM.DAT into Memory
    Shift-Alt-Ins(W)      Open Small OS/2 Window

    Shft-Ctl-LeftArrow(W) Start Macro Recording
    Shft-Ctl-RghtArrow(W) End Macro Recording & optionally Save to Disk File
    Shft-Ctl-Ins(W)       PlayBack Macro Currently in Memory
    Shft-Ctl-PgDn(W)      Save Current Loaded Macro to DiskFile
    Shft-Ctl-PgUp(W)      Load Selected Macro from Disk to Memory

    Shft-Ctl-?            Display User Defined HotKeys (hot-keys.usr)
    Shft-Alt-?            Display Prog Defined HotKeys (hot-keys.prg)


    USER DEFINED HOT-KEY ASSIGNMENTS

    The user defined hot-key assignments are made in the text file
    HOOKKBSM.DAT which is in the directory c:\os2\hook. The default
    file loaded by INSTALL has a series of comments in it that describe
    the format of making key assignments and there are a number of
    assignments made in that file as examples. The user can delete them,
    reassign them or whatever. That file is reproduced below.

    Please Note that when HOOKKBSM is active, any changes to HOOKKBSM.DAT
    may be made active by pressing Shift-Alt-UpArrow which re-reads
    this file into memory making the current contents the active set of
    user defined Hot-Keys. It is thus easy to test out your key assignments
    by editing HOOKKBSM.DAT in an OS/2 window, re-reading it into memory
    and trying out the edited key assignments.


;; HOOKKBSM.DAT Key Assignment file for HOOKKBSM.EXE Thu  10-21-1993
;;
;; This file  MUST be located in the directory c:\os2\hook
;;
;; NB the actuating Key strokes are Shift-Alt-X or Shift-Ctrl-X
;;
;; The Shift is not required in the text below
;;
;; <<<<<<<<<<<<<<<<<<<<<<< The format is as follows >>>>>>>>>>>>>>>>>>>>>>
;;
;; A ";"indicates a comment and any text from ";" to end of line is ignored
;;
;; Blank Lines are not allowed - place at least one ";" on any line
;;
;; There must be at least 1 space between each field and the next field.
;;
;; The first field in a line is either A# or C# indicating an assignment to
;; the Shift-Alt-# or Shift-Ctrl-# key where #  is  0,1,2,3,4,5,6,7,8,9 or
;; either Ax or Cx indicating an assignment to Shift-Alt-x or to Shift-Ctrl-x
;; where x is any letter from a .. z.
;; No distinction exists between LowerCase or UpperCase.
;;
;; The next field has the following options.
;;
;; 9 means that the key will not be recognized. This can be accomplished
;;   as well by commenting that assignment out with ";
;; ;Ad        means that Shift-Alt-D is not assigned
;; Ad 9 a 0   means that Shift-Alt-D is not assigned
;;            the 9 must be followed by a space any letter a space and "0"
;;
;; OR just omitting Ad from the text also means it is not assigned
;;
;; 8 means that the key will be recognized as a hot key that sends a
;;   message to the program name passed on the command line
;;
;; Ad 8 b 0   assigns Shift-Alt-D as a message sending Key
;;            the 8 must be followed by a space any letter a space and "0"
;;
;; Otherwise the field has the following meaning
;;
;; 0   Allows the Shell to establish the session type - best as a rule
;; 1   Starts program as Full Screen OS/2
;; 2   Start Program in Windowed Session for programs using Base Video System
;; 3   Start Program in Windowed Session for programs using PM services
;; 4   Start Program in Full Screen DOS session
;; 7   Start Program in Windowed DOS session
;;
;; The next field is the file spec of the program to be executed and the
;; field after that is either a "0" indicating no  command line parameters
;; or the command line parameters. If the command line parameters contain
;; any spaces the command line parameters must be contained within "".
;;
;; Ae 0 c:\os2\e.exe c:config.sys ; loads the system editor included in OS/2
;;                                  to edit c:config.sys and assigns  this
;;                                  command to Shift-Alt-e
;;
;; Generically speaking the format below assigns programfilespec to Shift-Alt-x
;;
;; Ax 0 programfilespec "program command line" ;if there are command line parms
;;
;; Ax 0 programfilespec  0                     ;if no command line parms
;;
;; The  programfilespec must contain the extension .COM / .EXE / .BAT
;; BAT files can be loaded just like EXE files
;;
;; HOOKKBSM uses the DosStartSession Function of the OS/2 API to load programs.
;; It is documented on page 2-345 of the Control Program Functions Manual.
;;
;; DosStartSession does not like to load a CMD file directly so they must be
;; loaded with a command processor as
;;
;; A1 0 c:\os2\cmd.exe abcdef.cmd ; abcdef.CMD loaded by OS/2 command processor
;;
;; To assign a program to a key follow the examples/rules above
;;
;; If you edit this file while HOOKKBSM is Active, press Shft-Alt-UpArrow(W)
;; to re-read this file in and redefine the Active Set of Keys
;;
;; This file contains some assignments using programs that come with OS/2
;; as well as assigning several key combinations to both OS/2 and DOS
;; Windowed and Full Screen Sessions. You may of course change any or all
;; of these but they are included as a "starter" so to speak.
;;
;; The following keys are pre-assigned for your convenience and testing
;;
;; A1,A2,A3 to OS/2 Command Processors, Ae to OS/2 Editor e.exe
;; As to OS/2 pmseek program, At to target.exe
;; C1,C2,C3 to DOS Command Processors,Cb to Qbasic,Cw to Windows 3.1
;; Ab,Ce and Cx are assigned to send messages to TARGET.EXE
;; EVERYTHING IS CHANGEABLE
;;
A1 0 c:\os2\cmd.exe 0            ;OS/2 window using OS/2 Command Processor
A2 0 c:\os2\cmd.exe 0            ;OS/2 window using OS2 Command Processor
A3 1 c:\os2\cmd.exe 0            ;OS/2 Full Screen using OS/2 Command Processor
A4 9 x 0                         ;Key not assigned
A5 9 x 0                         ;Key not assigned
A6 9 a 0                         ;Key not assigned
A7 9 x 0                         ;Key not assigned
A8 9 a 0                         ;Key not assigned
A9 9 a 0                         ;Key not assigned
A0 9 x 0                         ;Key not assigned
Aa 9 a 0                         ;Key not assigned
Ab 8 x 0                         ;sends message to program named on command line
Ac 9 x 0                         ;Key not assigned
Ad 9 a 0                         ;Key not assigned
Ae 0 c:\os2\e.exe 0              ;OS/2 e.exe  system editor
Af 9 x 0                         ;Key not assigned
Ag 9 x 0                         ;Key not assigned
Ah 9 x 0                         ;Key not assigned
Ai 9 x 0                         ;Key not assigned
Aj 9 x 0                         ;Key not assigned
Ak 9 x 0                         ;Key not assigned
Al 9 x 0                         ;Key not assigned
Am 9 x 0                         ;Key not assigned
An 9 x 0                         ;Key not assigned
Ap 9 z 0                         ;Key not assigned
Aq 9 x 0                         ;Key not assigned
Ar 9 z 0                         ;Key not assigned
As 0 c:\os2\apps\pmseek.exe 0    ;OS/2 Search & Scan Applet
At 0 c:target.exe 0              ;target.exe program used as target of 8 option programs
Au 9 z 0                         ;Key not assigned
Av 9 x 0                         ;Key not assigned
Aw 9 z 0                         ;Key not assigned
Ax 9 z 0                         ;Key not assigned
Ay 9 z 0                         ;Key not assigned
Az 9 z 0                         ;Key not assigned
C1 7 c:\os2\mdos\command.com  0  ;DOS window using built in DOS
C2 7 c:\os2\mdos\command.com  0  ;DOS window using built in DOS
C3 4 c:\os2\mdos\command.com  0  ;Full Screen using built in DOS
C4 9 a 0                         ;Key not assigned
C5 9 a 0                         ;Key not assigned
C6 9 a 0                         ;Key not assigned
C7 9 a 0                         ;Key not assigned
C8 9 a 0                         ;Key not assigned
C9 9 a 0                         ;Key not assigned
C0 9 a 0                         ;Key not assigned
Ca 9 a 0                         ;Key not assigned
Cb 7 c:\os2\mdos\qbasic.exe 0    ;QBasic from dos in DOS window
Cc 9 a 0                         ;Key not assigned
Cd 9 a 0                         ;Key not assigned
Ce 8 a 0                         ;sends message to program named on command line
Cf 9 c 0                         ;Key not assigned
Cg 9 b 0                         ;Key not assigned
Ch 9 c 0                         ;Key not assigned
Ci 9 c 0                         ;Key not assigned
Cj 9 d 0                         ;Key not assigned
Ck 9 e 0                         ;Key not assigned
Cl 9 f 0                         ;Key not assigned
Cm 9 c 0                         ;Key not assigned
Cn 9 g 0                         ;Key not assigned
Co 9 h 0                         ;Key not assigned
Cp 9 c 0                         ;Key not assigned
Cq 9 c 0                         ;Key not assigned
Cr 9 i 0                         ;Key not assigned
Cs 9 j 0                         ;Key not assigned
Ct 9 k 0                         ;Key not assigned
Cu 9 l 0                         ;Key not assigned
Cv 9 m 0                         ;Key not assigned
Cw 4 c:\os2\mdos\winos2\win.com 0;OS/2 DOS Win 3.1 Full Screen
Cx 8 o 0                         ;sends message to program named on command line
Cy 9 p 0                         ;Key not assigned
Cz 9 q 0                         ;Key not assigned

    When programs are loaded by a Hot-Key their title appears in the
    Task List (actuated by Ctrl-Esc) according to the following rules.

    If assigned to a Shift-Alt key combination it appears as
        Alt-X name_as_assigned_in_field_3     where X is key assigned

    If assigned to a Shift-Ctrl key combination it appears as
        Ctl-X name_as_assigned_in_field_3     where X is key assigned

    In each case the string "name_as_assigned_in_field_3" contains up to
    a total of 24 characters from the filespec of the program to be
    loaded appended to "Alt-X " or to "Ctl-X "

    The reason for this is two fold. Most importantly it is because the
    program uses the Task List titles to determine if a program is
    currently active when that hot-key combination is struck and it
    switches to the running program. Secondly in the Task List it
    serves as a convenient reminder of the current hot-key assignments.

    The examples below reflect the Task List Title  for some of the
    assignments above in the sample HOOKKBSM.DAT

    Alt-E c:\os2\e.exe                  ;OS/2 e.exe  system editor
    Alt-S c:\os2\apps\pmseek.exe        ;the pmseek program
    Ctl-W c:\os2\mdos\winos2\win.c      ;Win 3.1 (note the "om" missing)
    Ctl-3 c:\os2\mdos\command.com       ;DOS window

    Please note that if the Alt-E assignment had been made as
    Ae 0 C:\OS2\e.exe 0                 ;OS/2 e.exe  system editor
    then its Task List title would appear as
    Alt-E C:\OS2\e.exe 0

    Programs not loaded by HOOKKBSM hot-keys will have their Task List
    titles reflect how the program is written. PM programs may have
    their Task List title reflect either the Program Name or the
    title that appears in their Window when loaded.

    The two text files, hot-keys.prg and hot-keys.usr are meant to serve
    as a reminder for the user of the hot-key assignments that are
    fixed into the system (hot-keys.prg) and those that have been created
    by the user (hot-keys.usr).

    The user should modify hot-keys.usr to reflect the current set hot-key
    assignments made in HOOKKBSM.DAT.


    COMMAND LINE OPTIONS WHEN STARTING HOOKKBSM

    HOOKKBSM has a variety of options in how it functions and these options
    are exercised by passing their parameters on the Command Line.

    The option switches are passed on the command line as /x /y ... where
    the switch variable is case insensitive.

    /i  makes the hookkbsm Information window INVISIBLE

    /j  makes the program responsive to the Alt-Esc / Alt-Tab keystrokes

    /l  places the Information window in the lower  left hand corner

    /r  places the Information window in the lower right hand corner

    Defaults are : Information Window Visible
                   HOOKKBSM not responsive to Alt-Esc or Alt-Tab key strokes
                   Information Window in Lower Left hand corner

    /sfilespec     loads the command processor specified in filespec
                   as the command processor used to open OS/2 windows.
                   The default is the command processor defined by
                   the OS/2 COMSPEC variable in the environment. If you
                   use another (e.g. 4os2.exe, you must pass its complete
                   file specification including the extension).

    /pTskLstTtl}   if the program whose listing in the Task List (the
                   list of loaded programs) is TskLstTtl ("}" is the string
                   terminator on the Command Line) then Hot-Keys assigned
                   as Message Hot-Keys when struck will send a Message to
                   that Program containing the following:
                          PARM1
                            Lowest Byte      = Scan Code of Key Struck
                            Next Lowest Byte = 0/1 if Alt/Ctrl Key Struck

                          PARM2
                            Handle of Window with Focus when Key Struck

                   The program TskLstTtl is a user written program that
                   must respond to the messages. The  Message ID used
                   is WM_USER+301H

                   The comparison of TskLstTtl with the listings in the
                   Task List is Case Sensitive.

    The program is written, so that even if the /i or /I option is
    chosen, when any messages are to be displayed in the window, it is
    made visible to display them and restored to its invisible state
    after the display. A 500 MS delay is inserted to ensure readability.

    If you have started hookkbsm with the /i or /I option and you
    inadvertently make it visible, by selecting it from the Task List
    or some other method, you can restore it to Invisible status by
    the key sequence Shift-Alt-UpArrow(w).

    HOOKKBSM may be started by placing the appropriate command in a
    STARTUP.CMD file or by entering it from an OS/2 Window.

    Examples: Assumes c:\os2\hook is in the PATH defined in config.sys.
              If not hookkbsm -> c:\os2\hook\hookkbsm

    Load hookkbsm as Invisible using the 4os2 command processor - in the
    example 4os2 is in d:\4os2

        Start hookkbsm /i /sd:\4os2\4os2.exe

    Load hookkbsm as Invisible with target.exe as the program that is the
    target of messages. It is assumed that target.exe is assigned to
    the Shift-Alt-Y hot-key

        Start /i hookkbsm /pAlt-Y c:target.exe}

    N.B. When target.exe, in the c:root directory is loaded by the hot-key
         Alt-Y and assigned in HOOKKBSM.DAT as
         AY 0 c:target.exe 0 ;
         Its task list title will be "Alt-Y c:target.exe"

    Load hookkbsm as Visible, Information window in Lower right hand
    corner with target.exe as the program that is the target of
    messages. It is assumed that target.exe is not loaded by a HOOKKBSM
    Hot-key.

         Start hookkbsm /r /pMessage Target}
         In this case the Task List Title is the same as that in the
         Title Window of Target.exe.

    Load hookkbsm accepting all defaults.

         Start Hookkbsm


    RECORDING AND PLAYING BACK MACROS

      To begin the recording of KeyStrokes and/or Mouse Actions press
      Shift-Ctrl-LeftArrow(white). The program window will display a
      Window Message Prompting you with respect to your first recording
      action and will then display "Recording" as long as the recording
      is on. To conclude the recording press Shift-Ctrl-RightArrow(W)
      and the window will be closed indicating recording is ended. You
      will also at this point be presented a file dialog box to select a
      name under which to save the Macro. To abort Saving the Macro just
      enter Esc.

      To PlayBack the Macro just recorded press the Shift_Ctrl-Ins(W)
      key and the window will display the message "Playback" while it is
      playing back the events recorded.

      A Macro may also be saved after it has been recorded (if the
      original prompt for saving was ignored) by pressing
      Shift-Ctrl-PgDn(W). A dialogue box will be presented prompting you
      for the name of the macro file to be stored. The macro is written
      to c:\os2\hook with the assigned name in two forms. One form is
      the binary form that is playable back and has the extension HEX.
      The other form is in ASCII with the same name but extension MAC
      and is a listing of the following parameters recorded in the
      Macro; the values of all except TaskListName are given in HEX.

Handle MessageID msgParam1 msgParam2  msgTime  X_ScreenP Y_ScreenP TaskListName

      To play back a saved Macro, use Shift_Ctrl-PgUp(white) to activate
      a dialogue box that will present the list of saved macros. When
      one is selected it is read into memory and is activated by
      Shift_Ctrl-Ins(W) Any macro that is created or that is read into
      memory stays there until replaced by another and thus can be
      repeatedly used. If a macro is already in memory it can be played
      back(repeatedly) by Shift-Ctrl-Ins(W).

      LIMITATIONS OF MACRO RECORDING

      The Macro recorder does not record Alt-Esc or Alt-Tab key strokes.
      The messages for them are accessible(as I have just determined)
      but I have not yet made the effort to include them.

      It will record and play back messages for actions initiated by the
      Alt Key and then choosing options from the Control Frame Menu, such
      as Alt-x to maximize the window, Alt-r to restore the window, etc.
      If you record a macro that includes MOVING or RESIZING the window,
      when that aspect of the macro is entered, for reasons I do not yet
      understand, the system waits for you to move the cursor keys to
      either resize or move the window.

      It does record the Ctrl-Esc key sequence and its actions and other
      keyboard entries including the Shift-ALt|Ctrl-X keys assigned to
      this program and their actions and also mouse actions. It does not
      however faithfully play back everything recorded for reasons I
      also do not frankly understand. For instance if you assign to a
      Macro the sequence (from an OS/2 window) Help DownCursor
      DownCursor CR, it does not play back the DownCursor DownCursor CR
      sequence though it does open the Help Window.

      However if you save the sequence "Help Dir" from a command line it
      does play that back correctly.

      When you are recording anything from the Command Line, after using
      the Shift-Ctrl-LeftArrow(W) key strokes to start the macro, you
      must use the Mouse to activate the window you were in or else an
      assigned Shift-xxx-xxx action to get back into that window. This
      is because displaying the Message "Recording" in the Hook window
      makes that the active window. There is a Prompt reminding the user
      to make the shift to the desired active window.

      When activating a Macro you must be careful that your setup is
      similar to that used when recording it, particularly if writing
      text is a part of the scenario - you might get the text written
      back in a non-intended window.

      Since the macros when recorded, record positions in screen
      coordinates, which are absolute relative to the bottom left
      corner, any actions depending on a mouse action such as clicking
      on a minimize or maximize button will be sensitive to where that
      button is on the screen. If a window is not displayed at exactly
      the same position as it was when recording, those mouse actions
      will not be what is intended.

      I find the macros most useful for storing and setting up different
      groups of windows. For instance I have one mode of operations where
      I have my editor open in two different OS/2 windows, 2 DOS windows
      open with different versions of FoxPro in them and an OS/2 window
      for command line use. I have that set of keystrokes assigned to a
      macro I have named to FOXLOAD.HEX and  when I want to re-establish
      that set of windows I load it into memory using Shift_Ctrl-PgUp to
      select and load it and play it back with Shift-Ctrl-Ins.

      Finally the Buffer used to store the messages is of finite size. Each
      message is 28 bytes long and the buffer size is 56000 bytes and thus
      holds  2000 messages. If your recording exceeds the buffer size the
      program notifies you.

      The program macro PlayBack facility will now run under either OS/2
      version 2.0 or 2.1 as it determines the Handle of the Task List
      Window on the Fly, in this respect it should be immune to updates.
      The messageID of the Task List is not documented but it is 082H
      and it has a fixed handle value that changed from version 2.0 to
      2.1. The value is stored in the Task List Buffer at offset 8,
      which is where I get it on loading hookkbsm.

      Currently the macros are not played back at the speed at which
      they were recorded but somewhat faster. This is because it is
      presumed and certainly I do, that one uses Macros for convenience
      and speed. That sometimes gives a problem, especially if mouse
      movements are involved. For opening up icons on the screen I find
      it convenient to follow the procedure of going to the desktop, (or
      other window as the case may be) and clicking the left mouse
      button to establish the location, then press the Home key to bring
      you to the upper left icon of that window, and then use the cursor
      keys to bring you to the desired icon to open and then press enter
      to open it and so on.

      DOS WINDOWED SESSIONS and FULL SCREEN SESSIONS

      There are limitations to using the Macro Recorder from a DOS
      session. It will record and play back actions reflecting OS/2
      aspects, such as using the Alt key to activate a frame menu and
      select an options, such as Alt-x (maximize),etc or Ctrl-Esc to
      activate the Task List and make a selection but it will not record
      ordinary keyboard entry or any activity from within a DOS session
      relating to the DOS software program. That is because in DOS the
      PM message queue is not active and normal DOS KB TSR's are
      required if you need to intercept Keystrokes in DOS.

      A similar commend holds for OS/2 Full Screen. There monitors are
      required to read Keyboard Activity and the PM message queue does
      not apply.

      If I need to use an application in Full Screen, then I use
      Ctrl-Esc to bring up the TaskList window and from there the Hot
      Keys are valid since you are in PM.

      Notwithstanding the limitations above, I have found this most
      useful and it is worth playing around with to understand both its
      utility and its limitations.

      INCLUDING FULL SCREEN APPLICATIONS

        If you have an application that you want to run in Full Screen
        then in HOOKKBSM.DAT so define it by entering the number 1 / 4
        in the column following the key id, AltX 1  or CtrlX 4 if you
        want the session to be Full Screen OS/2 or Full Screen DOS
        respectively.

        Doing it this way assigns the Task List Title the name Alt-X or
        Ctl-X as when loaded with the 0 option or 7 option. This means
        that the program is loaded Full Screen with the assigned Key
        Combination and if the program is already loaded, it can be
        switched to from the desktop by hitting its Hot-Key and if you
        are in the full screen mode, then pressing Ctrl-Esc brings up
        the Task List, which is a PM and the hot keys are active from
        there. This means that switching to Full Screen applications
        from the Desktop is the same as if they are windowed and
        switching back from Full Screen applications takes only 1 more
        Key Combination to switch to a Windowed Application. Similarly
        switching between Full Screen applications also takes only one
        more Keyboard action, the Ctrl-Esc to the Task List and then the
        use of the appropriate Hot-Key.

