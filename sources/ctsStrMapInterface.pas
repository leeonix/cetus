{$I CetusOptions.inc}

unit ctsStrMapInterface;

interface

uses
  ctsPointerInterface;

type
  TctsKeyType = string;

  PPair = ^TPair;
  TPair = record
    Key: TctsKeyType;
    Data: TctsDataType;
  end;

  TctsDisposePairEvent = procedure(const APair: PPair) of object;
  TctsKeyCompareEvent = function(const AData1, AData2: TctsKeyType): LongInt;

implementation

end.
