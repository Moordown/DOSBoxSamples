
{*******************************************************}
{                                                       }
{       Turbo Pascal Runtime Library                    }
{       DOS Protected-mode Interface Unit               }
{                                                       }
{       Copyright (c) 1991,92 Borland International     }
{                                                       }
{*******************************************************}

unit WinAPI;

{$S-}

interface

{ Generic types }

type
  Bool     = WordBool;          { Windows compatible boolean }
  THandle  = Word;              { Global memory handle }
  TFarProc = Pointer;           { Procedure address }

{ Flags returned by GetWinFlags }

const
  wf_PMode      = $00000001;    { Running in protected mode }
  wf_CPU286     = $00000002;    { System CPU is an 80286 }
  wf_CPU386     = $00000004;    { System CPU is an 80386 }
  wf_CPU486     = $00000008;    { System CPU is an 80486 }
  wf_Standard   = $00000010;    { Running in standard mode }
  wf_Enhanced   = $00000020;    { Running in enhanced mode }
  wf_CPU086     = $00000040;    { System CPU is an 8086 }
  wf_CPU186     = $00000080;    { System CPU is an 80186 }
  wf_LargeFrame = $00000100;    { Windows EMS large-frame configuration }
  wf_SmallFrame = $00000200;    { Windows EMS small-frame configuration }
  wf_80x87      = $00000400;    { System contains a math coprocessor }
  wf_DPMI       = $80000000;    { Running in DOS protected mode }

{ GlobalAlloc and GlobalReAlloc flags }

const
  gmem_Fixed       = $0000;     { Allocate fixed memory }
  gmem_Moveable    = $0002;     { Allocate moveable memory }
  gmem_NoCompact   = $0010;     { Don't compact when allocating }
  gmem_NoDiscard   = $0020;     { Don't discard when allocating }
  gmem_ZeroInit    = $0040;     { Initialize memory contents to zero }
  gmem_Modify      = $0080;     { Modify memory flags }
  gmem_Discardable = $0100;     { Allocate discardable memory }
  gmem_Not_Banked  = $1000;     { Allocate non-banked memory }
  gmem_DDEShare    = $2000;     { Allocate sharable memory }
  gmem_Notify      = $4000;     { Notify upon discarding }

{ Flags returned by GlobalFlags (in addition to gmem_Discardable) }

const
  gmem_Discarded = $4000;
  gmem_LockCount = $00FF;

{ MessageBox Flags }

const
  mb_Ok               = $0000;
  mb_OkCancel         = $0001;
  mb_AbortRetryIgnore = $0002;
  mb_YesNoCancel      = $0003;
  mb_YesNo            = $0004;
  mb_RetryCancel      = $0005;

  mb_IconHand         = $0010;
  mb_IconStop         = $0010;
  mb_IconQuestion     = $0020;
  mb_IconExclamation  = $0030;
  mb_IconAsterisk     = $0040;
  mb_IconInformation  = $0040;

  mb_DefButton1       = $0000;
  mb_DefButton2       = $0100;
  mb_DefButton3       = $0200;

  mb_ApplModal        = $0000;
  mb_SystemModal      = $1000;
  mb_TaskModal        = $2000;

  mb_NoFocus          = $8000;

  mb_TypeMask         = $000F;
  mb_IconMask         = $00F0;
  mb_DefMask          = $0F00;
  mb_ModeMask         = $3000;
  mb_MiscMask         = $C000;

{ MessageBox return values }

const
  id_Ok     = 1;
  id_Cancel = 2;
  id_Abort  = 3;
  id_Retry  = 4;
  id_Ignore = 5;
  id_Yes    = 6;
  id_No     = 7;

{ Windows API routines }

function AccessResource(Instance, ResInfo: THandle): Integer;
function AllocDStoCSAlias(Selector: Word): Word;
function AllocSelector(Selector: Word): Word;
function ChangeSelector(SourceSelector, DestSelector: Word): Word;
procedure DOS3Call;
procedure FatalExit(Code: Integer);
function FindResource(Instance: THandle; Name, ResType: PChar): THandle;
procedure FreeLibrary(LibModule: THandle);
function FreeResource(ResData: THandle): Bool;
function FreeSelector(Selector: Word): Word;
function GetDOSEnvironment: PChar;
function GetFreeSpace(Flag: Word): Longint;
function GetModuleFileName(Module: THandle; Filename: PChar; Size: Integer): Integer;
function GetModuleHandle(ModuleName: PChar): THandle;
function GetModuleUsage(Module: THandle): Integer;
function GetProcAddress(Module: THandle; ProcName: PChar): TFarProc;
function GetSelectorBase(Selector: Word): Longint;
function GetSelectorLimit(Selector: Word): Longint;
function GetVersion: Longint;
function GetWinFlags: Longint;
function GlobalAlloc(Flags: Word; Bytes: Longint): THandle;
function GlobalAllocPtr(Flags: Word; Bytes: Longint): Pointer; 
function GlobalCompact(MinFree: Longint): Longint;
function GlobalDiscard(Mem: THandle): THandle;
function GlobalDosAlloc(Bytes: Longint): Longint;
function GlobalDosFree(Selector: Word): Word;
procedure GlobalFix(Mem: THandle);
function GlobalFlags(Mem: THandle): Word;
function GlobalFree(Mem: THandle): THandle;
function GlobalFreePtr(P: Pointer): THandle;
function GlobalHandle(Mem: Word): Longint;
function GlobalLock(Mem: THandle): Pointer;
function GlobalLRUNewest(Mem: THandle): THandle;
function GlobalLRUOldest(Mem: THandle): THandle;
procedure GlobalNotify(NotifyProc: TFarProc);
function GlobalPageLock(Selector: THandle): Word;
function GlobalPageUnlock(Selector: THandle): Word;
function GlobalPtrHandle(P: Pointer): THandle; 
function GlobalReAlloc(Mem: THandle; Bytes: Longint; Flags: Word): THandle;
function GlobalReAllocPtr(P: Pointer; Bytes: Longint; Flags: Word): Pointer;
function GlobalSize(Mem: THandle): Longint;
function GlobalUnfix(Mem: THandle): Bool;
function GlobalUnlock(Mem: THandle): Bool;
function LoadLibrary(LibFileName: PChar): THandle;
function LoadResource(Instance: THandle; ResInfo: THandle): THandle;
function LoadString(Instance: THandle; ID: Word; Buffer: PChar;
  BufferMax: Integer): Integer;
function LockResource(ResData: THandle): Pointer;
function LockSegment(Segment: Word): THandle;
function MessageBox(WndParent: THandle; Text, Caption: PChar;
  TextType: Word): Integer;
function PrestoChangoSelector(SourceSelector, DestSelector: Word): Word;
function SetSelectorBase(Selector: Word; Base: Longint): Word;
function SetSelectorLimit(Selector: Word; Limit: Longint): Word;
function SizeOfResource(Instance, ResInfo: THandle): Longint;
function UnlockResource(ResData: THandle): Bool;
function UnlockSegment(Segment: Word): THandle;

{ Inline routines }

function MakeLong(A, B: Word): Longint;
inline(
  $5A/    { POP DX }
  $58);   { POP AX }

function LoWord(A: Longint): Word;
inline(
  $58/    { POP AX }
  $5A);   { POP DX }

function HiWord(A: Longint): Word;
inline(
  $5A/    { POP DX }
  $58);   { POP AX }

function LoByte(A: Word): Byte;
inline(
  $58/       { POP AX    }
  $32/$E4);  { XOR AH,AH }

function HiByte(A: Word): Byte;
inline(
  $58/       { POP AX    }
  $8A/$C4/   { MOV AL,AH }
  $32/$E4);  { XOR AH,AH }

implementation

{ KERNEL routines }

procedure FatalExit;			external 'KERNEL' index 1;
function GetVersion;			external 'KERNEL' index 3;
function GlobalAlloc;			external 'KERNEL' index 15;
function GlobalReAlloc;			external 'KERNEL' index 16;
function GlobalFree;			external 'KERNEL' index 17;
function GlobalLock;			external 'KERNEL' index 18;
function GlobalUnlock;			external 'KERNEL' index 19;
function UnlockResource;		external 'KERNEL' index 19;
function GlobalSize;			external 'KERNEL' index 20;
function GlobalHandle;			external 'KERNEL' index 21;
function GlobalFlags;			external 'KERNEL' index 22;
function LockSegment;			external 'KERNEL' index 23;
function UnlockSegment;			external 'KERNEL' index 24;
function GlobalCompact;			external 'KERNEL' index 25;
function GetModuleHandle;		external 'KERNEL' index 47;
function GetModuleUsage;		external 'KERNEL' index 48;
function GetModuleFileName;		external 'KERNEL' index 49;
function GetProcAddress;		external 'KERNEL' index 50;
function FindResource;			external 'KERNEL' index 60;
function LoadResource;			external 'KERNEL' index 61;
function LockResource;			external 'KERNEL' index 62;
function FreeResource;			external 'KERNEL' index 63;
function AccessResource;		external 'KERNEL' index 64;
function SizeOfResource;		external 'KERNEL' index 65;
function LoadLibrary;			external 'KERNEL' index 95;
procedure FreeLibrary;			external 'KERNEL' index 96;
procedure DOS3Call;			external 'KERNEL' index 102;
function GetDOSEnvironment;             external 'KERNEL' index 131;
function GetWinFlags;			external 'KERNEL' index 132;
procedure GlobalNotify;			external 'KERNEL' index 154;
function GlobalLRUOldest;		external 'KERNEL' index 163;
function GlobalLRUNewest;		external 'KERNEL' index 164;
function GetFreeSpace;			external 'KERNEL' index 169;
function AllocDStoCSAlias;              external 'KERNEL' index 171;
function AllocSelector;                 external 'KERNEL' index 175;
function FreeSelector;                  external 'KERNEL' index 176;
function ChangeSelector;		external 'KERNEL' index 177;
function PrestoChangoSelector;		external 'KERNEL' index 177;
function GlobalDosAlloc;		external 'KERNEL' index 184;
function GlobalDosFree;			external 'KERNEL' index 185;
function GetSelectorBase;		external 'KERNEL' index 186;
function SetSelectorBase;		external 'KERNEL' index 187;
function GetSelectorLimit;		external 'KERNEL' index 188;
function SetSelectorLimit;		external 'KERNEL' index 189;
function GlobalPageLock;                external 'KERNEL' index 191;
function GlobalPageUnlock;              external 'KERNEL' index 192;
procedure GlobalFix;                    external 'KERNEL' index 197;
function GlobalUnfix;                   external 'KERNEL' index 198;

{ USER routines }

function MessageBox;			external 'USER' index 1;
function LoadString;			external 'USER' index 176;

{ Wrapper routines }

function GlobalDiscard(Mem: THandle): THandle; assembler;
asm
	PUSH	Mem
	XOR	AX,AX
	PUSH	AX
	PUSH	AX
	MOV	AX,gmem_Moveable
	PUSH	AX
	CALL	GlobalReAlloc
end;

function GlobalPtrHandle(P: Pointer): THandle; assembler;
asm
	PUSH	P.Word[2]
	CALL	GlobalHandle
end;

function GlobalAllocPtr(Flags: Word; Bytes: Longint): Pointer; assembler;
asm
	PUSH	Flags
	PUSH	Bytes.Word[2]
	PUSH	Bytes.Word[0]
	CALL	GlobalAlloc
	PUSH	AX
	CALL	GlobalLock
end;

function GlobalReAllocPtr(P: Pointer; Bytes: Longint;
  Flags: Word): Pointer; assembler;
asm
	PUSH	P.Word[2]
	CALL	GlobalHandle
	PUSH	AX
	PUSH	AX
	CALL	GlobalUnlock
	PUSH	Bytes.Word[2]
	PUSH	Bytes.Word[0]
	PUSH	Flags
	CALL	GlobalReAlloc
	PUSH	AX
	CALL	GlobalLock
end;

function GlobalFreePtr(P: Pointer): THandle; assembler;
asm
	PUSH	P.Word[2]
	CALL	GlobalHandle
	PUSH	AX
	PUSH	AX
	CALL	GlobalUnlock
	CALL	GlobalFree
end;

end.
