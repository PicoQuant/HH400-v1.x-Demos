Attribute VB_Name = "Module1"
'+==========================================================
'
'  TTTRMODE.bas
'
'  A simple demo how to use the HydraHarp 400 programming library
'  HHLIB.DLL v.1.2 from Visual Basic.
'
'  The program uses a text console for user input/output
'
'  Michael Wahl, PicoQuant GmbH, August 2009
'
'===========================================================

Option Explicit

'''''D E C L A R A T I O N S for Console access etc ''''''''''

Private Declare Function AllocConsole Lib "kernel32" () As Long
Private Declare Function FreeConsole Lib "kernel32" () As Long
Private Declare Function GetStdHandle Lib "kernel32" _
(ByVal nStdHandle As Long) As Long

Private Declare Function ReadConsole Lib "kernel32" Alias _
"ReadConsoleA" (ByVal hConsoleInput As Long, _
ByVal lpBuffer As String, ByVal nNumberOfCharsToRead As Long, _
lpNumberOfCharsRead As Long, lpReserved As Integer) As Long

Private Declare Function WriteConsole Lib "kernel32" Alias _
"WriteConsoleA" (ByVal hConsoleOutput As Long, _
ByVal lpBuffer As String, ByVal nNumberOfCharsToWrite As Long, _
lpNumberOfCharsWritten As Long, lpReserved As Integer) As Long


Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)


'''''D E C L A R A T I O N S for HHLIB.DLL-access '''''''''''''

'extern int _stdcall HH_GetLibraryVersion(char* vers);
Private Declare Function HH_GetLibraryVersion Lib "hhlib.dll" (ByVal vers As String) As Long

'extern int _stdcall HH_GetErrorString(char* errstring, int errcode);
Private Declare Function HH_GetErrorString Lib "hhlib.dll" (ByVal errstring As String, ByVal errcode As Long) As Long

'extern int _stdcall HH_OpenDevice(int devidx, char* serial);
Private Declare Function HH_OpenDevice Lib "hhlib.dll" (ByVal devidx As Long, ByVal serial As String) As Long

'extern int _stdcall HH_CloseDevice(int devidx);
Private Declare Function HH_CloseDevice Lib "hhlib.dll" (ByVal devidx As Long) As Long

'extern int _stdcall HH_Initialize(int devidx, int mode, int refsource);
Private Declare Function HH_Initialize Lib "hhlib.dll" (ByVal devidx As Long, ByVal mode As Long, ByVal refsource As Long) As Long

'--- functions below can only be used after Initialize ------

'extern int _stdcall HH_GetHardwareInfo(int devidx, char* model, char* partno);
Private Declare Function HH_GetHardwareInfo Lib "hhlib.dll" (ByVal devidx As Long, ByVal model As String, ByVal partno As String) As Long

'extern int _stdcall HH_GetSerialNumber(int devidx, char* serial);
Private Declare Function HH_GetSerialNumber Lib "hhlib.dll" (ByVal devidx As Long, ByVal serial As String) As Long

'extern int _stdcall HH_GetBaseResolution(int devidx, double* resolution, int* binsteps);
Private Declare Function HH_GetBaseResolution Lib "hhlib.dll" (ByVal devidx As Long, Resolution As Double, Binsteps As Long) As Long


'extern int _stdcall HH_GetNumOfInputChannels(int devidx, int* nchannels);
Private Declare Function HH_GetNumOfInputChannels Lib "hhlib.dll" (ByVal devidx As Long, nchannels As Long) As Long

'extern int _stdcall HH_GetNumOfModules(int devidx, int* nummod);
Private Declare Function HH_GetNumOfModules Lib "hhlib.dll" (ByVal devidx As Long, nummod As Long) As Long

'extern int _stdcall HH_GetModuleInfo(int devidx, int modidx, int* modelcode, int* versioncode);
Private Declare Function HH_GetModuleInfo Lib "hhlib.dll" (ByVal devidx As Long, modidx As Long, modelcode As Long, versioncode As Long) As Long

'extern int _stdcall HH_GetModuleIndex(int devidx, int channel, int* modidx);
Private Declare Function HH_GetModuleIndex Lib "hhlib.dll" (ByVal devidx As Long, channel As Long, modidx As Long) As Long

'extern int _stdcall HH_Calibrate(int devidx);
Private Declare Function HH_Calibrate Lib "hhlib.dll" (ByVal devidx As Long) As Long

'extern int _stdcall HH_SetSyncDiv(int devidx, int div);
Private Declare Function HH_SetSyncDiv Lib "hhlib.dll" (ByVal devidx As Long, ByVal div As Long) As Long

'extern int _stdcall HH_SetSyncCFDLevel(int devidx, int value);
Private Declare Function HH_SetSyncCFDLevel Lib "hhlib.dll" (ByVal devidx As Long, ByVal value As Long) As Long

'extern int _stdcall HH_SetSyncCFDZeroCross(int devidx, int value);
Private Declare Function HH_SetSyncCFDZeroCross Lib "hhlib.dll" (ByVal devidx As Long, ByVal value As Long) As Long

'extern int _stdcall HH_SetSyncChannelOffset(int devidx, int value);
Private Declare Function HH_SetSyncChannelOffset Lib "hhlib.dll" (ByVal devidx As Long, ByVal value As Long) As Long

'extern int _stdcall HH_SetInputCFDLevel(int devidx, int channel, int value);
Private Declare Function HH_SetInputCFDLevel Lib "hhlib.dll" (ByVal devidx As Long, ByVal channel As Long, ByVal value As Long) As Long

'extern int _stdcall HH_SetInputCFDZeroCross(int devidx, int channel, int value);
Private Declare Function HH_SetInputCFDZeroCross Lib "hhlib.dll" (ByVal devidx As Long, ByVal channel As Long, ByVal value As Long) As Long

'extern int _stdcall HH_SetInputChannelOffset(int devidx, int channel, int value);
Private Declare Function HH_SetInputChannelOffset Lib "hhlib.dll" (ByVal devidx As Long, ByVal channel As Long, ByVal value As Long) As Long

'extern int _stdcall HH_SetStopOverflow(int devidx, int stop_ovfl, unsigned int stopcount);
'note: stopcount is actually unsigned int, VB does not have this type, you must convert
Private Declare Function HH_SetStopOverflow Lib "hhlib.dll" (ByVal devidx As Long, ByVal stop_ovfl As Long, ByVal stopcount As Long) As Long

'extern int _stdcall HH_SetHistoLen(int devidx, int lencode, int* actuallen);
Private Declare Function HH_SetHistoLen Lib "hhlib.dll" (ByVal devidx As Long, ByVal Binning As Long, actuallen As Long) As Long

'extern int _stdcall HH_SetBinning(int devidx, int binning);
Private Declare Function HH_SetBinning Lib "hhlib.dll" (ByVal devidx As Long, ByVal Binning As Long) As Long

'extern int _stdcall HH_SetOffset(int devidx, int offset);
Private Declare Function HH_SetOffset Lib "hhlib.dll" (ByVal devidx As Long, ByVal Offset As Long) As Long

'extern int _stdcall HH_ClearHistMem(int devidx);
Private Declare Function HH_ClearHistMem Lib "hhlib.dll" (ByVal devidx As Long) As Long

'extern int _stdcall HH_StartMeas(int devidx, int tacq);
Private Declare Function HH_StartMeas Lib "hhlib.dll" (ByVal devidx As Long, ByVal tacq As Long) As Long

'extern int _stdcall HH_StopMeas(int devidx);
Private Declare Function HH_StopMeas Lib "hhlib.dll" (ByVal devidx As Long) As Long

'extern int _stdcall HH_CTCStatus(int devidx, int* ctcstatus);
Private Declare Function HH_CTCStatus Lib "hhlib.dll" (ByVal devidx As Long, Ctcstatus As Long) As Long

'extern int _stdcall HH_GetHistogram(int devidx, unsigned int *chcount, int channel, int clear);
Private Declare Function HH_GetHistogram Lib "hhlib.dll" (ByVal devidx As Long, chcount As Long, ByVal channel As Long, ByVal clear As Long) As Long

'extern int _stdcall HH_GetResolution(int devidx, double* resolution);
Private Declare Function HH_GetResolution Lib "hhlib.dll" (ByVal devidx As Long, Resolution As Double) As Long

'extern int _stdcall HH_GetSyncRate(int devidx, int* syncrate);
Private Declare Function HH_GetSyncRate Lib "hhlib.dll" (ByVal devidx As Long, Syncrate As Long) As Long

'extern int _stdcall HH_GetCountRate(int devidx, int channel, int* cntrate);
Private Declare Function HH_GetCountRate Lib "hhlib.dll" (ByVal devidx As Long, ByVal channel As Long, cntrate As Long) As Long

'extern int _stdcall HH_GetFlags(int devidx, int* flags);
Private Declare Function HH_GetFlags Lib "hhlib.dll" (ByVal devidx As Long, Flags As Long) As Long

'extern int _stdcall HH_GetElapsedMeasTime(int devidx, double* elapsed);
Private Declare Function HH_GetElapsedMeasTime Lib "hhlib.dll" (ByVal devidx As Long, elapsed As Double) As Long

'extern int _stdcall HH_GetWarnings(int devidx, int* Warnings);
Private Declare Function HH_GetWarnings Lib "hhlib.dll" (ByVal devidx As Long, Warnings As Long) As Long

'extern int _stdcall HH_GetWarningsText(int devidx, char* text, int warnings);
Private Declare Function HH_GetWarningsText Lib "hhlib.dll" (ByVal devidx As Long, ByVal Warningstext As String, ByVal Warnings As Long) As Long


'for TT modes only

'extern int _stdcall HH_SetMarkerEdges(int devidx, int me1, int me2, int me3, int me4);
Private Declare Function HH_TTSetMarkerEdges Lib "hhlib.dll" (ByVal devidx As Long, ByVal me0 As Long, ByVal me1 As Long, ByVal me2 As Long, ByVal me3 As Long, ByVal me4 As Long) As Long

'extern int _stdcall HH_SetMarkerEnable(int devidx, int en1, int en2, int en3, int en4);
Private Declare Function HH_SetMarkerEnable Lib "hhlib.dll" (ByVal devidx As Long, ByVal en0 As Long, ByVal en1 As Long, ByVal en2 As Long, ByVal en3 As Long, ByVal en4 As Long) As Long

'extern int _stdcall HH_ReadFiFo(int devidx, unsigned int* buffer, int count, int* nactual);
Private Declare Function HH_ReadFiFo Lib "hhlib.dll" (ByVal devidx As Long, buffer As Long, ByVal count As Long, Nactual As Long) As Long


''''C O N S T A N T S'''''''''''''''''''''''''''''''''''''

'HHlib constants from hhdefin.h and errorcodes.h
'please also use the other constants from hhdefin.h to perform
'range checking on your function parameters!

Private Const LIB_VERSION = "1.2"

Private Const MAXDEVNUM = 8

Private Const MAXHISTLEN = 65536     ' number of histogram channels
Private Const TTREADMAX = 131072     ' 128K event records (TT modes)
Private Const HHMAXCHAN = 8

Private Const MODE_HIST = 0
Private Const MODE_T2 = 2
Private Const MODE_T3 = 3

Private Const FLAG_OVERFLOW = &H1
Private Const FLAG_FIFOFULL = &H2

Private Const ZCMIN = 0                'mV
Private Const ZCMAX = 20               'mV
Private Const DISCRMIN = 0             'mV
Private Const DISCRMAX = 800           'mV

Private Const OFFSETMIN = 0            'ps
Private Const OFFSETMAX = 1000000000   'ps
Private Const ACQTMIN = 1              'ms
Private Const ACQTMAX = 360000000      'ms  (100*60*60*1000ms = 100h)


Private Const ERROR_DEVICE_OPEN_FAIL = -1

'I/O handlers for the console window.

Private Const STD_INPUT_HANDLE = -10&
Private Const STD_OUTPUT_HANDLE = -11&
Private Const STD_ERROR_HANDLE = -12&


'''''G L O B A L S'''''''''''''''''''''''''''''''''''

Private hConsoleIn As Long 'The console's input handle
Private hConsoleOut As Long 'The console's output handle
Private hConsoleErr As Long 'The console's error handle


'''''M A I N'''''''''''''''''''''''''''''''''''''''''

Private Sub Main()

Dim Dev(0 To MAXDEVNUM - 1) As Long
Dim Found As Long
Dim SyncDivider As Long
Dim Binning As Long
Dim AcquisitionTime As Long
Dim SyncCFDLevel As Long
Dim SyncCFDZeroCross As Long
Dim InputCFDLevel As Long
Dim InputCFDZeroCross As Long
Dim Retcode As Long
Dim LibVersion As String * 8
Dim ErrorString As String * 40
Dim HardwareSerial As String * 8
Dim HardwareModel As String * 16
Dim HardwarePartno As String * 8
Dim Baseres As Double
Dim Binsteps As Long
Dim InpChannels As Long
Dim Resolution As Double
Dim Syncrate As Long
Dim Countrate As Long
Dim Flags As Long
Dim Ctcstatus As Long
Dim Nactual As Long
Dim Progress As Long
Dim buffer(1 To TTREADMAX) As Long
Dim i As Long
Dim Blocksz As Long
Dim Warnings As Long
Dim Warningstext As String * 16384

AllocConsole 'Create a console instance

'Get the console I/O handles

hConsoleIn = GetStdHandle(STD_INPUT_HANDLE)
hConsoleOut = GetStdHandle(STD_OUTPUT_HANDLE)
hConsoleErr = GetStdHandle(STD_ERROR_HANDLE)

Open "TTTRMODE.OUT" For Binary As #1


ConsolePrint "HydraHarp 400  TTTR mode demo" & vbCrLf

Retcode = HH_GetLibraryVersion(LibVersion)
ConsolePrint "Library version = " & LibVersion & vbCrLf
If Left$(LibVersion, 3) <> LIB_VERSION Then
    ConsolePrint "Tis program version requires hhlib.dll version " & LIB_VERSION & vbCrLf
    GoTo Ex
End If

ConsolePrint "Searching for HydraHarp devices..." & vbCrLf
ConsolePrint "Devidx    Status" & vbCrLf

Found = 0
For i = 0 To MAXDEVNUM - 1
    Retcode = HH_OpenDevice(i, HardwareSerial)
    If Retcode = 0 Then ' Grab any HydraHarp we can open
        ConsolePrint "  " & i & "     S/N " & HardwareSerial & vbCrLf
        Dev(Found) = i  'keep index to devices we want to use
        Found = Found + 1
     Else
         If Retcode = ERROR_DEVICE_OPEN_FAIL Then
         ConsolePrint "  " & i & "     no device " & vbCrLf
         Else
             Retcode = HH_GetErrorString(ErrorString, Retcode)
             ConsolePrint "  " & i & "     " & ErrorString & vbCrLf
         End If
    End If
 Next i

'in this demo we will use the first HydraHarp device we found, i.e. dev(0)
'you could also check for a specific serial number, so that you always know
'which physical device you are talking to.

If Found < 1 Then
    ConsolePrint "No device available." & vbCrLf
    GoTo Ex
End If
ConsolePrint "Using device " & CStr(Dev(0)) & vbCrLf
ConsolePrint "Initializing the device " & vbCrLf

Retcode = HH_Initialize(Dev(0), MODE_T2, 0) 'T2 mode, internal clock
If Retcode < 0 Then
    ConsolePrint "HH_Initialize error " & CStr(Retcode) & vbCrLf
    GoTo Ex
End If

Retcode = HH_GetHardwareInfo(Dev(0), HardwareModel, HardwarePartno)
If Retcode < 0 Then
    ConsolePrint "HH_GetHardwareVersion error " & CStr(Retcode) & vbCrLf
    GoTo Ex
End If
ConsolePrint "Found Hardware Model " & HardwareModel & " Partnumber " & HardwarePartno & vbCrLf

Retcode = HH_GetBaseResolution(Dev(0), Baseres, Binsteps)
If Retcode < 0 Then
    ConsolePrint "HH_GetBaseResolution error " & CStr(Retcode) & vbCrLf
    GoTo Ex
End If
ConsolePrint "Base Resolution = " & CStr(Baseres) & " ps" & vbCrLf

Retcode = HH_GetNumOfInputChannels(Dev(0), InpChannels)
If Retcode < 0 Then
    ConsolePrint "HH_GetNumOfInputChannels error " & CStr(Retcode) & vbCrLf
    GoTo Ex
End If
ConsolePrint "Input Channels = " & CStr(InpChannels) & vbCrLf

'everything up to here doesn't need to be done again

ConsolePrint "Calibrating..." & vbCrLf
Retcode = HH_Calibrate(Dev(0))
If Retcode < 0 Then
    ConsolePrint "HH_Calibrate error " & CStr(Retcode) & vbCrLf
    GoTo Ex
End If


'Set the measurement parameters (can be done again later)
'Change these numbers as you need

SyncDivider = 1             'must fit with chosen mode, see manual!
Binning = 0                 '0=BaseRes, 1=2*Baseres, 2=4*Baseres and so on
SyncCFDLevel = 50           'millivolts
SyncCFDZeroCross = 10       'millivolts
InputCFDLevel = 50          'millivolts
InputCFDZeroCross = 10      'millivolts
AcquisitionTime = 10000     'millisec
Blocksz = TTREADMAX

Retcode = HH_SetSyncDiv(Dev(0), SyncDivider)
If Retcode < 0 Then
    ConsolePrint "SetSyncDiv error " & CStr(Retcode) & vbCrLf
    GoTo Ex
End If

Retcode = HH_SetSyncCFDLevel(Dev(0), SyncCFDLevel)
If Retcode < 0 Then
    ConsolePrint "HH_SetSyncCFDLevel error " & CStr(Retcode) & vbCrLf
    GoTo Ex
End If

Retcode = HH_SetSyncCFDZeroCross(Dev(0), SyncCFDZeroCross)
If Retcode < 0 Then
    ConsolePrint "HH_SetSyncCFDZeroCross error " & CStr(Retcode) & vbCrLf
    GoTo Ex
End If

Retcode = HH_SetSyncChannelOffset(Dev(0), 0)
If Retcode < 0 Then
    ConsolePrint "HH_SetSyncChannelOffset error " & CStr(Retcode) & vbCrLf
    GoTo Ex
End If

For i = 0 To InpChannels - 1 'we set the same values for all channels

    Retcode = HH_SetInputCFDLevel(Dev(0), i, InputCFDLevel)
    If Retcode < 0 Then
        ConsolePrint "HH_SetInputCFDLevel error " & CStr(Retcode) & vbCrLf
        GoTo Ex
    End If
    
    Retcode = HH_SetInputCFDZeroCross(Dev(0), i, InputCFDZeroCross)
    If Retcode < 0 Then
        ConsolePrint "HH_SetInputCFDZeroCross error " & CStr(Retcode) & vbCrLf
        GoTo Ex
    End If
    
    Retcode = HH_SetInputChannelOffset(Dev(0), i, InputCFDZeroCross)
    If Retcode < 0 Then
        ConsolePrint "HH_SetInputChannelOffset error " & CStr(Retcode) & vbCrLf
        GoTo Ex
    End If

Next i

Retcode = HH_SetBinning(Dev(0), Binning) 'meaningless in T2 mode but harmless
If Retcode < 0 Then
    ConsolePrint "HH_SetBinning error " & CStr(Retcode) & vbCrLf
    GoTo Ex
End If

Retcode = HH_SetOffset(Dev(0), 0) 'meaningless in T2 mode but harmless
If Retcode < 0 Then
    ConsolePrint "HH_SetOffset error " & CStr(Retcode) & vbCrLf
    GoTo Ex
End If

Retcode = HH_GetResolution(Dev(0), Resolution) 'meaningless in T2 mode but harmless
If Retcode < 0 Then
    ConsolePrint "HH_GetResolution error " & CStr(Retcode) & vbCrLf
    GoTo Ex
End If
ConsolePrint "Resolution = " & CStr(Resolution) & " ps " & vbCrLf


'measure the input rates e.g. for a panel meter
'this can be done again later, e.g. on a timer that updates the display
'note: after Init or SetSyncDiv you must allow 400 ms for valid new count rate readings
'otherwise you get new readings every 100 ms
Sleep (400)

Retcode = HH_GetSyncRate(Dev(0), Syncrate)
If Retcode < 0 Then
    ConsolePrint "HH_GetSyncRate error " & CStr(Retcode) & vbCrLf
    GoTo Ex
End If
ConsolePrint "SyncRate = " & CStr(Syncrate) & vbCrLf

For i = 0 To InpChannels - 1
    Retcode = HH_GetCountRate(Dev(0), i, Countrate)
    If Retcode < 0 Then
        ConsolePrint "HH_GetCountRate error " & CStr(Retcode) & vbCrLf
        GoTo Ex
    End If
    ConsolePrint "CountRate" & CStr(i) & " = " & CStr(Countrate) & vbCrLf
Next i
    
'new from v1.2: after getting the count rates you can check for warnings
Retcode = HH_GetWarnings(Dev(0), Warnings)
If Retcode < 0 Then
    ConsolePrint "HH_GetWarnings error " & CStr(Retcode) & vbCrLf
    GoTo Ex
End If
    
If Warnings <> 0 Then
     Retcode = HH_GetWarningsText(Dev(0), Warningstext, Warnings)
     ConsolePrint vbCrLf & sTrim(Warningstext)
End If

'the measurement sequence starts here, the whole measurement sequence may be
'done again as often as you like

ConsolePrint "Measuring for " & CStr(AcquisitionTime) & " milliseconds" & vbCrLf
ConsolePrint "Press Enter to start measurement..." & vbCrLf
Call ConsoleRead


ConsolePrint "Progress:" & vbCrLf

'the actual measurement starts here
    
Retcode = HH_StartMeas(Dev(0), AcquisitionTime)
If Retcode < 0 Then
    ConsolePrint "HH_StartMeas error " & CStr(Retcode) & vbCrLf
    GoTo Ex
End If

Do
    Retcode = HH_GetFlags(Dev(0), Flags)
    If Retcode < 0 Then
        ConsolePrint "HH_GetFlags error " & CStr(Retcode) & vbCrLf
        GoTo Ex
    End If

    If (Flags And FLAG_FIFOFULL) Then
        ConsolePrint " FiFo overrun!" & vbCrLf
        GoTo stoptttr
    End If

    Retcode = HH_ReadFiFo(Dev(0), buffer(1), Blocksz, Nactual) 'may return less!
    If (Retcode < 0) Then
        ConsolePrint " HH_ReadFiFo error" & vbCrLf
        GoTo stoptttr
    End If

    If (Nactual > 0) Then
        For i = 1 To Nactual    ' save data in buffer to binary file
            Put #1, , buffer(i) ' doing this in a loop is terribly slow but VB
        Next i                  ' doesn't allow a block put with variable length
        Progress = Progress + Nactual
        ConsolePrint vbCr & CStr(Progress)
    Else
        Retcode = HH_CTCStatus(Dev(0), Ctcstatus)
        If (Retcode < 0) Then
            ConsolePrint " HH_CTCStatus error" & vbCrLf
            GoTo stoptttr
        End If
        If (Ctcstatus) Then
            ConsolePrint " Done" & vbCrLf
            GoTo stoptttr
        End If
    End If
                
    'count rates can be read here if needed
Loop

stoptttr:

ConsolePrint vbCrLf
Retcode = HH_StopMeas(Dev(0))
If Retcode < 0 Then
    ConsolePrint "HH_StopMeas error " & CStr(Retcode) & vbCrLf
End If

Close

Ex: 'End the program
For i = 0 To MAXDEVNUM - 1 'no harm to close all
    Retcode = HH_CloseDevice(i)
Next i
ConsolePrint "Press Enter to exit"
Call ConsoleRead
FreeConsole 'Destroy the console

End Sub



'''''F U N C T I O N S''''''''''''''''''''''''''''''''''
'F+F+++++++++++++++++++++++++++++++++++++++++++++++++++
'Function: ConsolePrint
'
'Summary: Prints the output of a string
'
'Args: String ConsolePrint
'The string to be printed to the console's ouput buffer.
'
'Returns: None
'
'-----------------------------------------------------

Private Sub ConsolePrint(szOut As String)

WriteConsole hConsoleOut, szOut, Len(szOut), vbNull, vbNull

End Sub


'F+F++++++++++++++++++++++++++++++++++++++++++++++++++++
'Function: ConsoleRead
'
'Summary: Gets a line of input from the user.
'
'Args: None
'
'Returns: String ConsoleRead
'The line of input from the user.
'---------------------------------------------------F-F

Private Function ConsoleRead() As String

Dim sUserInput As String * 256

Call ReadConsole(hConsoleIn, sUserInput, Len(sUserInput), vbNull, vbNull)

'Trim off the NULL charactors and the CRLF.

ConsoleRead = Left$(sUserInput, InStr(sUserInput, Chr$(0)) - 3)

End Function

' need this because VB cannot handle null terminated strings

Function sTrim(s As String) As String
    ' this function trims a string of right and left spaces
    ' it recognizes 0 as a string terminator
    Dim i As Integer
    i = InStr(s, Chr$(0))
    If (i > 0) Then
        sTrim = Trim(Left(s, i - 1))
    Else
        sTrim = Trim(s)
    End If
End Function

