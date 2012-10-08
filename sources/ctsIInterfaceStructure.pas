{$I CetusOptions.inc}

unit ctsIInterfaceStructure;

interface

{$DEFINE USE_Reference}

{$IFDEF USE_Reference}
  {$DEFINE USE_Interface}
{$ENDIF USE_Reference}

uses
{$I ctsUseDeclare.inc}
  ctsIInterfaceInterface;

const
  cUnitName = 'ctsIInterfaceStructure.pas';

{$I template\ctsStructImp.inc}

end.
