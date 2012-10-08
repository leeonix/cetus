{$I CetusOptions.inc}

unit ctsCommons;

interface

{$IFDEF DEBUG}
type
  TLogWriteProc = procedure(const Str: string; const ID: LongInt);
var
  TraceLog: TLogWriteProc = nil;
{$ENDIF DEBUG}

type
  TDirect = Boolean;
const
  Left: TDirect = True;
  Right: TDirect = False;

implementation

uses
{$IFDEF USE_CODESITE}
  CodeSiteLogging,
{$ENDIF}  
  Windows,
  SysUtils;

{$IFDEF DEBUG}
procedure SimpleTrace(const Str: string; const ID: LongInt);
begin
  OutputDebugString(PChar(IntToStr(ID) + ':' + Str))
end;

{$IFDEF USE_CODESITE}
procedure CodeSiteTrace(const Str: string; const ID: LongInt);
begin
  CodeSite.Send(IntToStr(ID) + ':' + Str);
end;
{$ENDIF USE_CODESITE}

{$ENDIF DEBUG}

initialization
{$IFDEF DEBUG}

{$IFDEF USE_CODESITE}
  TraceLog := CodeSiteTrace;
{$ELSE}
  TraceLog := SimpleTrace;
{$ENDIF USE_CODESITE}

{$ENDIF DEBUG}

finalization

end.
