unit ctsAlgorithm;

interface

uses
  Classes,
  ctsStringInclude;

function GetTextStr(const aStrCol: IctsStrCollection): string;
procedure LoadFromFile(const aFileName: string; const aStrCol: IctsStrCollection);
procedure LoadFromStream(const aStream: TStream; const aStrCol: IctsStrCollection);
procedure SaveToFile(const aFileName: string; const aStrCol: IctsStrCollection);
procedure SaveToStream(Stream: TStream; const aStrCol: IctsStrCollection);
procedure SetTextStr(const aValue: string; const aStrCol: IctsStrCollection);

implementation

uses
  SysUtils;

function GetTextStr(const aStrCol: IctsStrCollection): string;
var
  L, Size: Integer;
  P: PChar;
  S, LB: string;
  Itr: IctsStrIterator;
begin
  Size := 0;
  LB := sLineBreak;

  Itr := aStrCol.First;
  while Itr.HasNext do
  begin
    Inc(Size, Length(Itr.Data) + Length(LB));
    Itr.Next;
  end;
  SetString(Result, nil, Size);
  P := Pointer(Result);

  Itr := aStrCol.First;
  while Itr.HasNext do
  begin
    S := Itr.Data;
    L := Length(S);
    if L <> 0 then
    begin
      Move(Pointer(S)^, P^, L);
      Inc(P, L);
    end;
    L := Length(LB);
    if L <> 0 then
    begin
      Move(Pointer(LB)^, P^, L);
      Inc(P, L);
    end;
    Itr.Next;
  end;
end;

procedure LoadFromFile(const aFileName: string; const aStrCol: IctsStrCollection);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(aFileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream, aStrCol);
  finally
    Stream.Free;
  end;
end;

procedure LoadFromStream(const aStream: TStream; const aStrCol: IctsStrCollection);
var
  Size: Integer;
  S: string;
begin
  Size := aStream.Size - aStream.Position;
  SetString(S, nil, Size);
  aStream.Read(Pointer(S)^, Size);
  SetTextStr(S, aStrCol);
end;

procedure SaveToFile(const aFileName: string; const aStrCol: IctsStrCollection);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(aFileName, fmCreate);
  try
    SaveToStream(Stream, aStrCol);
  finally
    Stream.Free;
  end;
end;

procedure SaveToStream(Stream: TStream; const aStrCol: IctsStrCollection);
var
  S: string;
begin
  S := GetTextStr(aStrCol);
  Stream.WriteBuffer(Pointer(S)^, Length(S));
end;

procedure SetTextStr(const aValue: string; const aStrCol: IctsStrCollection);
var
  P, Start: PChar;
  S: string;
begin
  P := Pointer(aValue);
  if P <> nil then
    while P^ <> #0 do
    begin
      Start := P;
      while not (P^ in [#0, #10, #13]) do
        Inc(P);
      SetString(S, Start, P - Start);
      aStrCol.Add(S);
      if P^ = #13 then
        Inc(P);
      if P^ = #10 then
        Inc(P);
    end;
end;

end.
