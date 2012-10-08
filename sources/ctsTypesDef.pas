{$I CetusOptions.inc}

unit ctsTypesDef;

interface

uses
  SysUtils;

type
  TctsNotifyAction = (naAdded, naDeleting, naForEach);
  TctsNameString = string[31];
  EctsError = class(Exception);
  EctsListError = class(EctsError);
  EctsStackError = class(EctsError);
  EctsQueueError = class(EctsError);
  EctsTreeError = class(EctsError);

const
{$IFDEF DEBUG}
  ctsDebugSign = $CC;
{$ENDIF}
  ctsMaxBlockSize = MaxLongInt div 16;
  ctsDefaultNodeQuantity = $80;
  ctsDefaultCapacity = $10;

implementation

end.
