{$I CetusOptions.inc}

unit ctsObjectInterface;

interface

{$DEFINE USE_Object}

uses
  ctsTypesDef,
  ctsBaseInterfaces;

type
  TctsDataType = TObject;

{$I template\ctsStructIntf.inc}

end.
