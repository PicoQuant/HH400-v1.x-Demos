Unit HHLib;
{                                                               }
{ Functions exported by the HydraHarp programming library HHLib }
{                                                               }
{ Ver. 1.2    August 2009                                       }
{                                                               }

interface

const
  LIB_VERSION    =      '1.2';
  LIB            =      'libhh400.so';  //the only difference from Windows

  MAXDEVNUM      =          8;               // max num of USB devices
  HHMAXCHAN      =          8;               // max num of logical channels

  MAXBINSTEPS    =         12;
  MAXHISTLEN     =      65536;   // max number of histogram bins
  MAXLENCODE     =          6;   // max length code

  TTREADMAX      =     131072;   // 128K event records can be read in one chunk

  MODE_HIST      =          0;
  MODE_T2        =          2;
  MODE_T3        =          3;

  FLAG_OVERFLOW  =      $0001;   // histo mode only
  FLAG_FIFOFULL  =      $0002;
  FLAG_SYNC_LOST =      $0004;
  FLAG_REF_LOST  =      $0008;
  FLAG_SYSERROR  =      $0010;

  SYNCDIVMIN     =          1;
  SYNCDIVMAX     =         16;

  ZCMIN          =          0;   // mV
  ZCMAX          =         40;   // mV
  DISCRMIN       =          0;   // mV
  DISCRMAX       =       1000;   // mV

  CHANOFFSMIN    =     -99999;   // ps
  CHANOFFSMAX    =      99999;   // ps

  OFFSETMIN      =          0;   // ps
  OFFSETMAX      =     500000;   // ps
  ACQTMIN        =          1;   // ms
  ACQTMAX        =  360000000;   // ms  (100*60*60*1000ms = 100h)

  STOPCNTMIN     =          1;
  STOPCNTMAX     = 4294967295;   // 32 bit is mem max


var
  pcLibVers      : pchar;
  strLibVers     : array [0.. 7] of char;
  pcErrText      : pchar;
  strErrText     : array [0..40] of char;
  pcHWSerNr      : pchar;
  strHWSerNr     : array [0.. 7] of char;
  pcHWModel      : pchar;
  strHWModel     : array [0..15] of char;
  pcHWPartNo     : pchar;
  strHWPartNo    : array [0.. 8] of char;
  pcWtext        : pchar;
  strWtext       : array [0.. 16384] of char;
  
  iDevIdx        : array [0..MAXDEVNUM-1] of longint;


function  HH_GetLibraryVersion     (vers : pchar) : longint;
  stdcall; external LIB;
function  HH_GetErrorString        (errstring : pchar; errcode : longint) : longint;
  stdcall; external LIB;

function  HH_OpenDevice            (devidx : longint; serial : pchar) : longint;
  stdcall; external LIB;
function  HH_CloseDevice           (devidx : longint) : longint;
  stdcall; external LIB;
function  HH_Initialize            (devidx : longint; mode : longint; refsource : longint) : longint;
  stdcall; external LIB;

// all functions below can only be used after HH_Initialize

function  HH_GetHardwareInfo       (devidx : longint; model : pchar; partno : pchar) : longint;
  stdcall; external LIB;
function  HH_GetSerialNumber       (devidx : longint; serial : pchar) : longint;
  stdcall; external LIB;
function  HH_GetBaseResolution     (devidx : longint; var resolution : double; var binsteps : longint) : longint;
  stdcall; external LIB;

function  HH_GetNumOfInputChannels (devidx : longint; var nchannels : longint) : longint;
  stdcall; external LIB;
function  HH_GetNumOfModules       (devidx : longint; var nummod : longint) : longint;
  stdcall; external LIB;
function  HH_GetModuleInfo         (devidx : longint; modidx : longint; var modelcode : longint; var versioncode : longint) : longint;
  stdcall; external LIB;
function  HH_GetModuleIndex        (devidx : longint; channel : longint; var modidx : longint) : longint;
  stdcall; external LIB;

function  HH_Calibrate             (devidx : longint) : longint;
  stdcall; external LIB;

function  HH_SetSyncDiv            (devidx : longint; syncdiv : longint) : longint;
  stdcall; external LIB;
function  HH_SetSyncCFDLevel       (devidx : longint; value : longint) : longint;
  stdcall; external LIB;
function  HH_SetSyncCFDZeroCross   (devidx : longint; value : longint) : longint;
  stdcall; external LIB;
function  HH_SetSyncChannelOffset  (devidx : longint; value : longint) : longint;
  stdcall; external LIB;

function  HH_SetInputCFDLevel      (devidx : longint; channel : longint; value : longint) : longint;
  stdcall; external LIB;
function  HH_SetInputCFDZeroCross  (devidx : longint; channel : longint; value : longint) : longint;
  stdcall; external LIB;
function  HH_SetInputChannelOffset (devidx : longint; channel : longint; value : longint) : longint;
  stdcall; external LIB;

function  HH_SetStopOverflow       (devidx : longint; stop_ovfl : longint; stopcount : longword) : longint;
  stdcall; external LIB;
function  HH_SetBinning            (devidx : longint; binning : longint) : longint;
  stdcall; external LIB;
function  HH_SetOffset             (devidx : longint; offset : longint) : longint;
  stdcall; external LIB;
function  HH_SetHistoLen           (devidx : longint; lencode : longint; var actuallen : longint) : longint;
  stdcall; external LIB;

function  HH_ClearHistMem          (devidx : longint) : longint;
  stdcall; external LIB;
function  HH_StartMeas             (devidx : longint; tacq : longint) : longint;
  stdcall; external LIB;
function  HH_StopMeas              (devidx : longint) : longint;
  stdcall; external LIB;
function  HH_CTCStatus             (devidx : longint; var ctcstatus : longint) : longint;
  stdcall; external LIB;

function  HH_GetHistogram          (devidx : longint; var chcount : longword; channel : longint; clear : longint) : longint;
  stdcall; external LIB;
function  HH_GetResolution         (devidx : longint; var resolution : double) : longint;
  stdcall; external LIB;
function  HH_GetSyncRate           (devidx : longint; var syncrate : longint) : longint;
  stdcall; external LIB;
function  HH_GetCountRate          (devidx : longint; channel : longint; var cntrate : longint) : longint;
  stdcall; external LIB;
function  HH_GetFlags              (devidx : longint; var flags : longint) : longint;
  stdcall; external LIB;
function  HH_GetElapsedMeasTime    (devidx : longint; var elapsed : double) : longint;
  stdcall; external LIB;
function  HH_GetWarnings           (devidx : longint; var warnings : longint) : longint;
  stdcall; external LIB;
function  HH_GetWarningsText       (devidx : longint; model : pchar; warnings : longint) : longint;
  stdcall; external LIB;

// for TT modes

function  HH_SetMarkerEdges      (devidx : longint; me1 : longint; me2 : longint; me3 : longint; me4 : longint) : longint;
  stdcall; external LIB;
function  HH_SetMarkerEnable     (devidx : longint; en1 : longint; en2 : longint; en3 : longint; en4 : longint) : longint;
  stdcall; external LIB;
function  HH_ReadFiFo            (devidx : longint; var buffer : longword; count : longint; var nactual : longint) : longint;
  stdcall; external LIB;

procedure HH_CloseAllDevices;

const

  HH_ERROR_NONE                     =   0;

  HH_ERROR_DEVICE_OPEN_FAIL         =  -1;
  HH_ERROR_DEVICE_BUSY              =  -2;
  HH_ERROR_DEVICE_HEVENT_FAIL       =  -3;
  HH_ERROR_DEVICE_CALLBSET_FAIL     =  -4;
  HH_ERROR_DEVICE_BARMAP_FAIL       =  -5;
  HH_ERROR_DEVICE_CLOSE_FAIL        =  -6;
  HH_ERROR_DEVICE_RESET_FAIL        =  -7;
  HH_ERROR_DEVICE_GETVERSION_FAIL   =  -8;
  HH_ERROR_DEVICE_VERSION_MISMATCH  =  -9;
  HH_ERROR_DEVICE_NOT_OPEN          = -10;

  HH_ERROR_INSTANCE_RUNNING         = -16;
  HH_ERROR_INVALID_ARGUMENT         = -17;
  HH_ERROR_INVALID_MODE             = -18;
  HH_ERROR_INVALID_OPTION           = -19;
  HH_ERROR_INVALID_MEMORY           = -20;
  HH_ERROR_INVALID_RDATA            = -21;
  HH_ERROR_NOT_INITIALIZED          = -22;
  HH_ERROR_NOT_CALIBRATED           = -23;
  HH_ERROR_DMA_FAIL                 = -24;
  HH_ERROR_XTDEVICE_FAIL            = -25;
  HH_ERROR_FPGACONF_FAIL            = -26;
  HH_ERROR_IFCONF_FAIL              = -27;
  HH_ERROR_FIFORESET_FAIL           = -28;

  HH_ERROR_USB_GETDRIVERVER_FAIL    = -32;
  HH_ERROR_USB_DRIVERVER_MISMATCH   = -33;
  HH_ERROR_USB_GETIFINFO_FAIL       = -34;
  HH_ERROR_USB_HISPEED_FAIL         = -35;
  HH_ERROR_USB_VCMD_FAIL            = -36;
  HH_ERROR_USB_BULKRD_FAIL          = -37;

  HH_ERROR_LANEUP_TIMEOUT           = -40;
  HH_ERROR_DONEALL_TIMEOUT          = -41;
  HH_ERROR_MODACK_TIMEOUT           = -42;
  HH_ERROR_MACTIVE_TIMEOUT          = -43;
  HH_ERROR_MEMCLEAR_FAIL            = -44;
  HH_ERROR_MEMTEST_FAIL             = -45;
  HH_ERROR_CALIB_FAIL               = -46;
  HH_ERROR_REFSEL_FAIL              = -47;
  HH_ERROR_STATUS_FAIL              = -48;
  HH_ERROR_MODNUM_FAIL              = -49;
  HH_ERROR_DIGMUX_FAIL              = -50;
  HH_ERROR_MODMUX_FAIL              = -51;
  HH_ERROR_MODFWPCB_MISMATCH        = -52;
  HH_ERROR_MODFWVER_MISMATCH        = -53;
  HH_ERROR_MODPROPERTY_MISMATCH     = -54;

  HH_ERROR_EEPROM_F01               = -64;
  HH_ERROR_EEPROM_F02               = -65;
  HH_ERROR_EEPROM_F03               = -66;
  HH_ERROR_EEPROM_F04               = -67;
  HH_ERROR_EEPROM_F05               = -68;
  HH_ERROR_EEPROM_F06               = -69;
  HH_ERROR_EEPROM_F07               = -70;
  HH_ERROR_EEPROM_F08               = -71;
  HH_ERROR_EEPROM_F09               = -72;
  HH_ERROR_EEPROM_F10               = -73;
  HH_ERROR_EEPROM_F11               = -74;

//The following are bitmasks for return values from HH_GetWarnings

  WARNING_SYNC_RATE_ZERO            = $0001;
  WARNING_SYNC_RATE_TOO_LOW         = $0002;
  WARNING_SYNC_RATE_TOO_HIGH        = $0004;

  WARNING_INPT_RATE_ZERO            = $0010;
  WARNING_INPT_RATE_TOO_HIGH        = $0040;

  WARNING_INPT_RATE_RATIO           = $0100;
  WARNING_DIVIDER_GREATER_ONE       = $0200;
  WARNING_TIME_SPAN_TOO_SMALL       = $0400;
  WARNING_OFFSET_UNNECESSARY        = $0800;

implementation

  procedure HH_CloseAllDevices;
  var
    iDev : integer;
  begin
    for iDev := 0 to MAXDEVNUM-1 // no harm closing all
    do HH_CloseDevice (iDev);
  end;

initialization
  pcLibVers  := PChar(@strLibVers[0]);
  pcErrText  := PChar(@strErrText[0]);
  pcHWSerNr  := PChar(@strHWSerNr[0]);
  pcHWModel  := PChar(@strHWModel[0]);
  pcHWPartNo := PChar(@strHWPartNo[0]);
  pcWtext    := PChar(@strWtext[0]);
finalization
  HH_CloseAllDevices;
end.
