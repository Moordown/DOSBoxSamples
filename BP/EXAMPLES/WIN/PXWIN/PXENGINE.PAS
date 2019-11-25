{************************************************}
{                                                }
{   Paradox Engine demo interface unit           }
{   Copyright (c) 1991 by Borland International  }
{                                                }
{************************************************}

unit PXEngine;

interface

uses WinProcs,WinTypes;

const
 internalVersion  = $02000002;    { version number, same }
                                  { as found in .lib files }
{ Type definitions  }
type
  TableHandle = word;             { table handle }
  RecordHandle = word;            { record handle }
  FieldHandle = word;             { field number 1.. }
  LockHandle = Integer;           { lock handle }
  RecordNumber = LongInt;         { record number 1.. }
  Date = LongInt;                 { representation of date }

{ Maximum and default values for dynamic configuration. }
{ The default values are used if not overwritten in PXSetDefaults (DOS) }
{ or in WIN.INI (Windows) }
const
  PXDefault =   0;                { use internal default value }

  MaxTableHandles =  64;          { maximum number of open }
                                  { tables allowed at a time }
  DefTableHandles =   5;          { default number of open }
                                  { tables allowed at a time }
  MaxRecordHandles = 128;         { maximum number of record }
                                  { buffers available }
  DefRecordHandles =  10;         { default number of record }
                                  { buffers available }
  MaxLockHandles = 128;           { maximum number of lock }
                                  { handles per table }
  DefLockHandles =  32;           { default number of lock }
                                  { handles per table }
  MaxFileHandles = 255;           { maximum number of DOS file }
                                  { handles to use }
  MinFileHandles =   2;           { minimum number of DOS file }
                                  { handles to use }
  DefFileHandles =  10;           { default number of DOS file }
                                  { handles to use }
const
  DefSortOrder = #255;            { default sort order (ASCII) }

{ Swap buffer size }
const
  MaxSwapSize = 256;              { maximum buffer size allowed (k)}
  MinSwapSize =   8;              { minimum buffer size allowed (k)}
  DefSwapSize =  32;              { default buffer size (k) }

{ Network codes }
{ used in PXNetInit }
const
  NotOnNet = 1;                   { Not on a net }
  NovellNet = 2;                  { Novell }
  ThreeComNet = 3;                { 3Com }
  ThreeOpenNet = 4;               { 3Com 3+Open }
  OtherNet = 5;                   { other: unknown DOS 3.1 compatible }
  StarLanNet = 7;                 { Starlan }
  BanyanNet = 8;                  { Banyan }
  IBMPCNet = 9;                   { IBM PC }

const
  LocalShare = 32;                { enables sharing on local drives with }
                                  { any net type }
                                  { (i.e. OTHERNET | LOCALSHARE) }
const
  DefUserName = nil;              { use default username in PXNetInit() }


{ used in PXKeyAdd }
const
  Primary =  0;                   { primary index (key) }
  Secondary =  1;                 { not maintained secondary index }
  IncSecondary =  2;              { maintained secondary index }

{ used in PXSrchFld, PXSrchKey }
const
  SearchFirst = 0;                { search from beginning of table }
  SearchNext = 1;                 { search from next record in table }
  ClosestRecord = 2;              { (modifier) goto 'nearest' record if }
                                  { no match found (ordered fields only) }

{ Lock types }
{ used in PXNetFileLock, PXNetFileUnlock, PXNetTblLock, PXNetTblUnlock }
const
  FL = 1;                         { full lock, no concurrency }
  WL = 2;                         { write lock }
  PWL = 3;                        { prevent write lock }
  PFL = 4;                        { prevent full lock, full concurrency }

{ macros for checking blank values }
const
  BlankDate = $80000000;
  BlankLong = $80000000;
  BlankShort = $8000;

function IsBlankAlpha(x: PChar): Boolean;
inline(
  $58/       { POP AX       }
  $5A/       { POP DX       }
  $1E/       { PUSH DS      }
  $DA8E/     { MOV DS,DX    }
  $C689/     { MOV SI,AX    }
  $C031/     { XOR AX,AX    }
  $AC/       { LODSB        }
  $1F        { POP DS       }
);

function IsBlankShort(x: Integer): Boolean;
inline(
  $58/       { POP AX       }
  $35/$8000/ { XOR AX,$8000 }
  $D8F7/     { NEG AX       }
  $C01B/     { SBB AX,AX    }
  $40        { INC AX       }
);

function IsBlankLong(x: LongInt): Boolean;
inline(
  $5A/       { POP DX       }
  $58/       { POP AX       }
  $35/$8000/ { XOR AX,$8000 }
  $C20B/     { OR  AX,DX    }
  $D8F7/     { NEG AX       }
  $C01B/     { SBB AX,AX    }
  $40        { INC AX       }
);

function IsBlankDate(x: Date): Boolean;
inline(
  $5A/       { POP DX       }
  $58/       { POP AX       }
  $35/$8000/ { XOR AX,$8000 }
  $C20B/     { OR  AX,DX    }
  $D8F7/     { NEG AX       }
  $C01B/     { SBB AX,AX    }
  $40        { INC AX       }
);


{ successful Engine function operation returns }
const
  PXSuccess = 0;

{ Error codes from Engine functions }

{ initialization errors }
const
  PXErr_NotInitErr = 78;          { Engine not initialized }
  PXErr_AlreadyInit = 82;         { Engine already initialized }
  PXErr_NotLoggedIn = 98;         { Could not login on network }
                                  { (to PARADOX.NET) }
  PXErr_NoNetInit = 107;          { Engine not initialized }
                                  { with PXNetInit }
  PXErr_NetMultiple = 15;         { multiple PARADOX.NET files }

  PXErr_CantSharePDoxNet = 134;   { can't lock PARADOX.NET -- is }
                                  { SHARE.EXE loaded? }
  PXErr_WindowsRealMode = 135;    { can't run Engine in Windows  }
                                  { real mode }

{ hardware related errors }
const
  PXErr_DriveNotReady = 1;        { Drive not ready }
  PXErr_DiskWritePro = 124;       { Disk is write protected }
  PXErr_GeneralFailure = 126;     { General hardware error }

{ directory reg error codes }
const
  PXErr_DirNotFound = 2;          { Directory not found }
  PXErr_DirBusy = 10;             { Sharing violation }
  PXErr_DirLocked  = 11;          { Sharing violation }
  PXErr_DirNoAccess = 12;         { No access to directory }
  PXErr_DirNotPrivate = 14;       { Single user, but directory is }
                                  { shared }

{ file oriented errors }
const
  PXErr_FileBusy = 3;             { File is busy }
  PXErr_FileLocked = 4;           { File is locked }
  PXErr_FileNotFound = 5;         { Could not find file }

{ table oriented errors }
const
  PXErr_TableBusy = 118;          { Table is busy }
  PXErr_TableLocked = 119;        { Table is locked }
  PXErr_TableNotFound = 120;      { Table was not found }
  PXErr_TableOpen =  83;          { Unable to perform operation }
                                  { on open table }
  PXErr_TableIndexed =  94;       { Table is indexed }
  PXErr_TableNotIndexed =  95;    { Table is not indexed }
  PXErr_TableEmpty = 105;         { Operation on empty table }
  PXErr_TableWritePro =  22;      { Table is write protected }

  PXErr_TableCorrupted =   6;     { Table is corrupted }
  PXErr_TableFull = 128;          { Table is full }
  PXErr_TableSQL = 130;           { Table is SQL replica }
  PXErr_InsufRights =  21;        { Insufficient password rights }


{ index oriented errors }
const
  PXErr_XCorrupted = 7;           { Primary index is corrupted }
  PXErr_XOutOfDate = 8;           { Primary index is out of date }
  PXErr_XSortVersion = 13;        { Sort for index different }
                                  { from table }

  PXErr_SXCorrupted = 122;        { Secondary index is corrupted }
  PXErr_SXOutOfDate =  96;        { Secondary index is out of date }
  PXErr_SXNotFound = 121;         { Secondary index was not found }
  PXErr_SXOpen = 123;             { Secondary index is already open }
  PXErr_SXCantUpdate = 136;       { Can't update table open on non-maintained secondary }

  PXErr_RecTooBig = 125;          { Record too big for index }

{ record oriented errors }
const
  PXErr_RecDeleted = 50;          { Another user deleted record }
  PXErr_RecLocked = 9;            { Record is locked }
  PXErr_RecNotFound = 89;         { Record was not found }
  PXErr_KeyViol = 97;             { Key violation }

  PXErr_EndOfTable = 101;         { End of table }
  PXErr_StartOfTable = 102;       { Start of table }


{ errors specific for Windows Engine DLL }
const
  PXErr_TooManyClients = 131;
  PXErr_ExceedsConfigLimits = 132;
  PXErr_CantRemapFileHandle = 133;

{ resource errors }
const
  PXErr_OutOfMem = 40;            { Not enough memory to }
                                  { complete operation }
  PXErr_OutOfDisk = 41;           { Not enough disk space to }
                                  { complete operation }
  PXErr_OutOfStack = 127;         { Not enough stack space to }
                                  { complete operation }
  PXErr_OutOfSwapBuf = 129;       { Not enough swap buffer space to }
                                  { complete operation }

  PXErr_OutOfFileHandles = 70;    { No more file handles available }
  PXErr_OutOfTableHandles = 72;   { No more table handles available }
  PXErr_OutOfRecHandles = 103;    { No more record handles available }
  PXErr_OutOfLockHandles = 111;   { Too many locks on table }

  PXErr_NoMoreTmpNames = 86;      { No more temporary names }
                                  { available }
  PXErr_TooManyPassw = 115;       { Too many passwords specified }


{ invalid parameters to functions }
const
  PXErr_TypeMismatch = 30;        { Data type mismatch }
  PXErr_OutOfRange = 31;          { Argument out of range }
  PXErr_InvParameter = 33;        { Invalid argument }
  PXErr_InvDate = 73;             { Invalid date given }

  PXErr_InvFieldHandle = 75;      { Invalid field handle }
  PXErr_InvRecHandle = 104;       { Invalid record handle }
  PXErr_InvTableHandle = 76;      { Invalid table handle }
  PXErr_InvLockHandle = 110;      { Invalid lock handle }

  PXErr_InvDirName = 114;         { Invalid directory name }
  PXErr_InvFileName = 108;        { Invalid file name }
  PXErr_InvTableName = 99;        { Invalid table name }
  PXErr_InvFieldName = 74;        { Invalid field name }

  PXErr_InvLockCode = 106;        { Invalid lock code }
  PXErr_InvUnlock = 109;          { Invalid unlock }
  PXErr_InvSortOrder = 112;       { Invalid sort order table }
  PXErr_InvPassw = 116;           { Invalid password }
  PXErr_InvNetType = 113;         { Invalid net type (PXNetInit) }
  PXErr_BufTooSmall = 117;        { Buffer too small for result }

  PXErr_StructDiffer = 81;        { Table structures are different }

  PXErr_InvEngineState = 79;      { Previous fatal error; }
                                  { cannot proceed }

{ values for ShareMode argument to PXWinInit }
const
  PXSingleClient = 0;             { allow no other client access to Engine DLL }
  PXExclusive = 1;                { open all tables with FULL LOCK }
  PXShared = 2;                   { open all tables with PREVENT FULL LOCK }

{ prototypes for engine functions }

{ declarations of sort order tables, used in PXSetDefaults }
const
  SortOrderAscii = 'a';           { ASCII sort order }
  SortOrderInt = 'i';             { international sort order }
  SortOrderNorDan = 'n';          { Norwegian/Danish sort order }
  SortOrderSwedFin = 's';         { Swedish/Finnish sort order }

{ INITIALIZATION AND FINALIZATION FUNCTIONS }

{ initialize Engine connection in Windows environment }
function PXWinInit(
  clientName: PChar;              { string containing name of application }
  ShareMode: Integer              { Share mode: PXSingleClient, }
                                  { PXExclusive, or PXShared }
  ): Integer;

{ exit and deallocate }
function PXExit: Integer;

{ overwrites internal default values }
function PXSetDefaults(
  bufSize: Integer;               { internal swap buffer size }
                                  { MinSwapSize..MaxSwapSize (8..256), }
                                  { default DefSwapSize (32) }
                                  { allocated at initialization time }
  maxTables: Integer;             { max number of tables open at a time }
                                  { range 1..MaxTableHandles ,   (1..64) }
                                  { default  DefTableHandles     (5) }
  maxRecBufs: Integer;            { max number of record buffers at a time}
                                  { range 1..MaxRecordHandles ,  (1..128) }
                                  { default  DefRecordHandles    (10) }
  maxLocks: Integer;              { max number of locks per table }
                                  { range 1..MaxLockHandles  ,   (1..128) }
                                  { default DefLockHandles       (32) }
  maxFiles: Integer;              { max number of file handles to use }
                                  { range MinFileHandles..MaxFileHandles }
                                  { default DefFileHandles       (10) }
  sortOrder: Char                 { code for sort order table defined }
                                  { internally in the Engine : }
                                  { SortOrderAscii/SortOrderInt/ }
                                  { SortOrderNorDan/SortOrderSwedFin }
                                  { default : SortOrderAscii }
  ): Integer;


{ returns current default settings }
function PXGetDefaults(
  var swapSize: Integer;          { returns internal swap buffer size }
  var maxTables: Integer;         { returns max number of tables at a time }
  var maxRecBufs: Integer;        { returns max number of record buffers }
  var maxLocks: Integer;          { returns max number of locks per table }
  var maxFiles: Integer;          { returns max number of file handles to use }
  var sortTable: Char             { returns code indicating default sort table }
  ): Integer;

{ enables/disables internal hardware error handler }
function PXSetHWHandler(
  hwHandler: Bool                 { enable(True) / disable (False) }
  ): Integer;                     { default True }


{ UTILITY FUNCTIONS }

function IsBlankDouble(x: Double): Bool;
procedure BlankDouble(var x: Double);

{ TABLE FUNCTIONS }

{ open table for access, returning table handle }
function PXTblOpen(
  tblName: PChar;                 { name of table to open }
  var tblHandle: TableHandle;     { returns handle for opened table }
  indexID: Integer;               { =0 mastertable else indexnumber }
  saveEveryChange: Bool           { save each record as it is changed }
                                  { don't buffer changes }
  ): Integer;


{ close access to table }
function PXTblClose(
  tblHandle: TableHandle          { tblHandle of table to close }
  ): Integer;

{ create empty table }
function PXTblCreate(
  tblName: PChar;                 { name of table to create }
  nFields: Integer;               { number of fields in table }
  var fields;                     { field names }
  var types                       { field types (N, S..) }
  ): Integer;

{ clear table for records }
function PXTblEmpty(
  tblName: PChar                  { name of table to empty }
  ): Integer;

{ delete table and its family }
function PXTblDelete(
  tblName: PChar                  { name of table to delete }
  ): Integer;

{ copy table and its family }
function PXTblCopy(
  fromName: PChar;                { source table of copy }
  toName: PChar                   { destination table of copy }
  ): Integer;

{ rename table and its family }
function PXTblRename(
  fromName: PChar;                { source table of copy }
  toName: PChar                   { destination table of copy }
  ): Integer;

{ add records from one table to another table }
function PXTblAdd(
  srcName: PChar;                 { source table of add }
  destName: PChar                 { destination table of add }
  ): Integer;


{ RECORD FUNCTIONS }

{ insert record buffer in database (as last record if Heap) }
function PXRecAppend(
  tblHandle: TableHandle;         { table to append record to }
  recHandle: RecordHandle         { record to append }
  ): Integer;

{ insert record buffer in database (before current if Heap) }
function PXRecInsert(
  tblHandle: TableHandle;         { table to insert record into }
  recHandle: RecordHandle         { record to insert }
  ): Integer;

{ updates current record in database with contents of the record buffer }
function PXRecUpdate(
  tblHandle: TableHandle;         { table to update record into }
  recHandle: RecordHandle         { changed record to post }
  ): Integer;

{ delete current record in table }
function PXRecDelete(
  tblHandle: TableHandle          { table to delete record in }
  ): Integer;

{ creates a record buffer for a table }
function PXRecBufOpen(
  tblHandle: TableHandle;         { table to create buffer for }
  var recHandle: RecordHandle     { returns handle to record buffer }
  ): Integer;

{ deletes a record buffer for a table }
function PXRecBufClose(
  recHandle: RecordHandle         { record buffer to remove }
  ): Integer;

{ clears the record buffer (to blanks) }
function PXRecBufEmpty(
  recHandle: RecordHandle         { record buffer to clear }
  ): Integer;

{ copy record from a record buffer to another (compatible) record buffer }
function PXRecBufCopy(
  fromHandle: RecordHandle;       { record buffer to copy from }
  toHandle: RecordHandle          { record buffer to copy to   }
  ): Integer;

{ gets the current record from the database into the record buffer }
function PXRecGet(
  tblHandle: TableHandle;         { table to get record from }
  recHandle: RecordHandle         { record buffer to put record in }
  ): Integer;

{ FIELD FUNCTIONS }

{ put short value into N/$/S field in record buffer }
function PXPutShort(
  recHandle: RecordHandle;        { record buffer to put value in }
  fldHandle: FieldHandle;         { field in record }
  value: Integer                  { value to put }
  ): Integer;

{ put Double value into N/$/S field in record buffer }
function PXPutDoub(
  recHandle: RecordHandle;        { record buffer to put value in }
  fldHandle: FieldHandle;         { field in record }
  value: Double                   { value to put }
  ): Integer;

{ put LongInt value into N/$/S field in record buffer }
function PXPutlong(
  recHandle: RecordHandle;        { record buffer to put value in }
  fldHandle: FieldHandle;         { field in record }
  value: LongInt                  { value to put }
  ): Integer;

{ put string into Alpha field in record buffer }
function PXPutAlpha(
  recHandle: RecordHandle;        { record buffer to put value in }
  fldHandle: FieldHandle;         { field in record }
  value: PChar                    { value to put }
  ): Integer;

{ put LongInt value into date field (encoded value) in record buffer }
function PXPutDate(
  recHandle: RecordHandle;        { record buffer to put value in }
  fldHandle: FieldHandle;         { field in record }
  value: Date                     { value to put }
  ): Integer;

{ put blank value into field in record buffer }
function PXPutBlank(
  recHandle: RecordHandle;        { record buffer to put blank in }
  fldHandle: FieldHandle          { field in record }
  ): Integer;

{ get value from N/$/S field in record buffer, into short }
function PXGetShort(
  recHandle: RecordHandle;        { record buffer to get value from }
  fldHandle: FieldHandle;         { field to get value from }
  var value: Integer              { returns value }
  ): Integer;

{ get value from N/$/S field in record buffer, into Double }
function PXGetDoub(
  recHandle: RecordHandle;        { record buffer to get value from }
  fldHandle: FieldHandle;         { field to get value from }
  var value: Double               { returns value }
  ): Integer;

{ get value from N/$/S field in record buffer, into LongInt }
function PXGetlong(
  recHandle: RecordHandle;        { record buffer to get value from }
  fldHandle: FieldHandle;         { field to get value from }
  var value: LongInt              { returns value }
  ): Integer;

{ get string from alpha field in record buffer }
function PXGetAlpha(
  recHandle: RecordHandle;        { record buffer to get value from }
  fldHandle: FieldHandle;         { field to get value from }
  bufSize: Integer;               { size of return buffer }
  dest: PChar                     { return buffer }
  ): Integer;

{ get value from date field in record buffer, into LongInt  (encoded value) }
function PXGetDate(
  recHandle: RecordHandle;        { record buffer to get value from }
  fldHandle: FieldHandle;         { field to get value from }
  var value: Date                 { returns value }
  ): Integer;

{ is value in specified field in record buffer a blank? }
function PXFldBlank(
  recHandle: RecordHandle;        { record to test value in }
  fldHandle: FieldHandle;         { field to test }
  var Blank: Bool                 { returns True/False }
  ): Integer;

{ move to record with specified record number }
function PXRecGoto(
  tblHandle: TableHandle;         { tblHandle of table to move in }
  recNum: RecordNumber            { record number to move to }
  ): Integer;

{ move to first record in table }
function PXRecFirst(
  tblHandle: TableHandle          { table to move in }
  ): Integer;

{ move to last record in table }
function PXRecLast(
  tblHandle: TableHandle          { table to move in }
  ): Integer;

{ move to next record in table }
function PXRecNext(
  tblHandle: TableHandle          { table to move in }
  ): Integer;

{ move to previous record in table }
function PXRecPrev(
  tblHandle: TableHandle          { table to move in }
  ): Integer;

{ INDEX FUNCTIONS }

{ add a primary or secondary (maintained/nonmaintained) index }
function PXKeyAdd(
  tblName: PChar;                 { name of table to add index for  }
  nFlds: Integer;                 { number of fields in index }
  var fldHandles;                 { array of field numbers in index }
  mode: Integer                   { type of index to create }
                                  { PRIMARY/SECONDARY/INCSECONDARY }
  ): Integer;

{ delete an index for a table (primary/secondary) }
function PXKeyDrop(
  tblName: PChar;                 { name of table to delete index for }
  indexID: Integer                { 0 if primary key, else field number }
                                  { of secondary index }
  ): Integer;


{ DATE FUNCTIONS }

{ decodes a date value stored in the Paradox format }
function PXDateDecode(
  aDate: Date;                    { LongInt value to decode }
  var mo: Integer;                { decoded month value }
  var da: Integer;                { decoded date value }
  var yr: Integer                 { decoded year value }
  ): Integer;

{ encodes a date value to a LongInt value in Paradox format }
function PXDateEncode(
  mo,                             { month value to encode }
  da,                             { date value to encode }
  yr: Integer;                    { year value to encode }
  var aDate: Date                 { encoded date value }
  ): Integer;

{ SEARCH FUNCTIONS }

{ Searches a table for a given (sub) key }
function PXSrchKey(
  tblHandle: TableHandle;         { table to search in }
  recHandle: RecordHandle;        { record buffer containing key to find }
  nFlds,                          { number of fields in key }
  mode: Integer                   { searching from first/next record }
  ): Integer;

function PXSrchFld(
  tblHandle: TableHandle;         { table to search in }
  recHandle: RecordHandle;        { record buffer containing field to find }
  fldHandle: FieldHandle;         { field number to search on }
  mode: Integer                   { searching from first/next record }
  ): Integer;

{ PASSWORD FUNCTIONS }

{ checks if table is encrypted }
function PXTblProtected(
  tblName: PChar;                 { name of table to check }
  var Protected: Bool             { returns True/False }
  ): Integer;

{ enters a password to the Engine }
function PXPswAdd(
  password: PChar                 { password to enter into system }
  ): Integer;

{ deletes a password previously entered }
function PXPswDel(
  password: PChar                 { password to remove from system }
  ): Integer;

{ encrypt a table and make it password protected }
function PXTblEncrypt(
  tblName: PChar;                 { name of table to encrypt }
  password: PChar                 { password for encrypted table }
  ): Integer;

{ decrypt a table, password must already have been entered }
function PXTblDecrypt(
  tblName: PChar                  { name of table to decrypt }
  ): Integer;


{ INFORMATIONAL FUNCTIONS }

{ checks if table exists }
function PXTblExist(
  tblName: PChar;                 { name of table to check }
  var Exist: Bool                 { returns TRUE/FALSE }
  ) : Integer;

{ returns table name corresponding to a table handle }
function PXTblName(
  tblHandle: TableHandle;         { table to return name of }
  bufSize: Integer;               { size of return buffer }
  tblName: PChar                  { name of table, without extension }
  ): Integer;

{ returns record number of current record in table }
function PXRecNum(
  tblHandle: TableHandle;         { table to get record number from }
  var recNum: RecordNumber        { returns record number }
  ): Integer;

{ returns number of records in table }
function PXTblNRecs(
  tblHandle: TableHandle;         { table to get number of records from }
  var nRecs: RecordNumber         { returns number of records }
  ): Integer;

{ returns number of fields in a record }
function PXRecNFlds(
  tblHandle: TableHandle;         { table to get number of fields from }
  var nFlds: Integer              { returns number of fields in a record }
  ): Integer;

{ return number of fields in key for table }
function PXKeyNFlds(
  tblHandle: TableHandle;         { table to get key size for }
  var nKeyFlds: Integer           { returns number of fields in key }
  ): Integer;

{ returns field number of a given field name in a table }
function PXFldHandle(
  tblHandle: TableHandle;         { table to get field number from }
  fieldName: PChar;               { name of field in table }
  var fldHandle: FieldHandle      { returns field number }
  ): Integer;

{ returns field type of a given field in a table }
function PXFldType(
  tblHandle: TableHandle;         { table to get field type from }
  fldHandle: FieldHandle;         { field number of field in table }
  bufSize: Integer;               { size of return buffer }
  fldType: PChar                  { field type of field as string }
  ): Integer;

{ returns field name of a given field in a table }
function PXFldName(
  tblHandle: TableHandle;         { table to get field name from }
  fldHandle: FieldHandle;         { field number of field in table }
  bufSize: Integer;               { size of return buffer }
  fldName: PChar                  { returns name of field }
  ): Integer;


{ MISCELLANEOUS FUNCTIONS }
{ sets maximum size of tables created with PXTblCreat() }
function PXTblMaxSize(
  maxsize: Integer                { maximum size of table }
                                  { 64/128/256  (Megabytes) }
  ): Integer;

{ saves all buffered changes to disk }
function PXSave: Integer;

{ CONCURRENCY FUNCTIONS }
{ can be used only if PXNetInit() or PXWinInit() was successful }

{ returns name of user as known on network }
function PXNetUserName(
  bufSize: Integer;               { size of return buffer }
  userName: PChar                 { returns user name }
  ): Integer;

{ locks a file with specified lock (general function) }
function PXNetFileLock(
  fileName: PChar;                { name of file to lock }
  lockType: Integer               { type of lock to put on file }
                                  { (FL, WL, PFL, PWL) }
  ): Integer;


{ unlocks a file with specified lock (general function) }
function PXNetFileUnlock(
  fileName: PChar;                { name of file to unlock }
  lockType: Integer               { type of lock to remove from file }
                                  { (FL, WL, PFL, PWL) }
  ): Integer;


{ locks an open table with specified lock }
function PXNetTblLock(
  tblHandle: TableHandle;         { table to lock }
  lockType: Integer               { type of lock to put on table }
                                  { (FL, WL, PFL, PWL) }
  ): Integer;


{ unlocks an open table with specified lock }
function PXNetTblUnlock(
  tblHandle: TableHandle;         { table to unlock }
  lockType: Integer               { type of lock to remove from table }
                                  { (FL, WL, PFL, PWL) }
  ): Integer;

{ locks the current record in a table }
function PXNetRecLock(
  tblHandle: TableHandle;         { table to lock record in }
  var lckHandle: LockHandle       { returns handle to lock  }
  ): Integer;

{ unlocks record associated with lock handle in the table }
function PXNetRecUnlock(
  tblHandle: TableHandle;         { table to unlock record in }
  lckHandle: LockHandle           { lock handle of record to unlock }
  ): Integer;

{ checks if current record in table is locked (by any user) }
function PXNetRecLocked(
  tblHandle: TableHandle;         { table to check record in }
  var Locked: Bool                { returns True/False }
  ): Integer;

{ moves to the record in the table associated with the lock handle }
function PXNetRecGotoLock(
  tblHandle: TableHandle;         { table to move in }
  lckHandle: LockHandle           { lock handle to record }
  ): Integer;

{ checks if table was changed by other user since last refresh }
function PXNetTblChanged(
  tblHandle: TableHandle;         { table to test }
  var Changed: Bool               { returns True/False }
  ): Integer;

{ forces a refresh of a table if it was changed by another user }
function PXNetTblRefresh(
  tblHandle: TableHandle          { table to refresh }
  ): Integer;


{ ERROR FUNCTIONS }

{ returns error text associated with the error number }
function PXErrMsg(
  errCode: Integer                { errcode to return text for }
  ): PChar;

{ returns name of user causing a locking error }
function PXNetErrUser(
  bufSize: Integer;               { size of return buffer }
  userName: PChar                 { returns user name }
  ): Integer;

implementation

function PXExit;           external 'PXENGWIN' index  4;
function PXSetDefaults;    external 'PXENGWIN' index  5;
function PXGetDefaults;    external 'PXENGWIN' index  6;
function PXSetHWHandler;   external 'PXENGWIN' index  7;
function PXTblOpen;        external 'PXENGWIN' index  8;
function PXTblClose;       external 'PXENGWIN' index  9;
function PXTblCreate;      external 'PXENGWIN' index 10;
function PXTblEmpty;       external 'PXENGWIN' index 11;
function PXTblDelete;      external 'PXENGWIN' index 12;
function PXTblCopy;        external 'PXENGWIN' index 13;
function PXTblRename;      external 'PXENGWIN' index 14;
function PXTblAdd;         external 'PXENGWIN' index 15;
function PXRecAppend;      external 'PXENGWIN' index 16;
function PXRecInsert;      external 'PXENGWIN' index 17;
function PXRecUpdate;      external 'PXENGWIN' index 18;
function PXRecBufOpen;     external 'PXENGWIN' index 19;
function PXRecBufClose;    external 'PXENGWIN' index 20;
function PXRecBufEmpty;    external 'PXENGWIN' index 21;
function PXRecBufCopy;     external 'PXENGWIN' index 22;
function PXRecGet;         external 'PXENGWIN' index 23;
function PXPutShort;       external 'PXENGWIN' index 24;
function PXPutDoub;        external 'PXENGWIN' index 25;
function PXPutLong;        external 'PXENGWIN' index 26;
function PXPutAlpha;       external 'PXENGWIN' index 27;
function PXPutDate;        external 'PXENGWIN' index 28;
function PXPutBlank;       external 'PXENGWIN' index 29;
function PXGetShort;       external 'PXENGWIN' index 30;
function PXGetDoub;        external 'PXENGWIN' index 31;
function PXGetLong;        external 'PXENGWIN' index 32;
function PXGetAlpha;       external 'PXENGWIN' index 33;
function PXGetDate;        external 'PXENGWIN' index 34;
function PXFldBlank;       external 'PXENGWIN' index 35;
function PXRecGoto;        external 'PXENGWIN' index 36;
function PXRecFirst;       external 'PXENGWIN' index 37;
function PXRecLast;        external 'PXENGWIN' index 38;
function PXRecNext;        external 'PXENGWIN' index 39;
function PXRecPrev;        external 'PXENGWIN' index 40;
function PXRecDelete;      external 'PXENGWIN' index 41;
function PXKeyAdd;         external 'PXENGWIN' index 42;
function PXKeyDrop;        external 'PXENGWIN' index 43;
function PXDateDecode;     external 'PXENGWIN' index 44;
function PXDateEncode;     external 'PXENGWIN' index 45;
function PXSrchKey;        external 'PXENGWIN' index 46;
function PXSrchFld;        external 'PXENGWIN' index 47;
function PXTblProtected;   external 'PXENGWIN' index 48;
function PXPswAdd;         external 'PXENGWIN' index 49;
function PXPswDel;         external 'PXENGWIN' index 50;
function PXTblEncrypt;     external 'PXENGWIN' index 51;
function PXTblDecrypt;     external 'PXENGWIN' index 52;
function PXTblExist;       external 'PXENGWIN' index 53;
function PXTblName;        external 'PXENGWIN' index 54;
function PXRecNum;         external 'PXENGWIN' index 55;
function PXTblNRecs;       external 'PXENGWIN' index 56;
function PXRecNFlds;       external 'PXENGWIN' index 57;
function PXKeyNFlds;       external 'PXENGWIN' index 58;
function PXFldHandle;      external 'PXENGWIN' index 59;
function PXFldType;        external 'PXENGWIN' index 60;
function PXFldName;        external 'PXENGWIN' index 61;
function PXTblMaxSize;     external 'PXENGWIN' index 62;
function PXSave;           external 'PXENGWIN' index 63;
function PXNetUserName;    external 'PXENGWIN' index 64;
function PXNetFileLock;    external 'PXENGWIN' index 65;
function PXNetFileUnlock;  external 'PXENGWIN' index 66;
function PXNetTblLock;     external 'PXENGWIN' index 67;
function PXNetTblUnlock;   external 'PXENGWIN' index 68;
function PXNetRecLock;     external 'PXENGWIN' index 69;
function PXNetRecUnlock;   external 'PXENGWIN' index 70;
function PXNetRecLocked;   external 'PXENGWIN' index 71;
function PXNetRecGotoLock; external 'PXENGWIN' index 72;
function PXNetTblChanged;  external 'PXENGWIN' index 73;
function PXNetTblRefresh;  external 'PXENGWIN' index 74;
function PXErrMsg;         external 'PXENGWIN' index 75;
function PXNetErrUser;     external 'PXENGWIN' index 76;
function PXWinInit;        external 'PXENGWIN' index 84;
procedure BlankDouble;     external 'PXENGWIN' index 85;
function IsBlankDouble;    external 'PXENGWIN' index 86;

end.
