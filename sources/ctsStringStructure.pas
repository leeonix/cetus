{$I CetusOptions.inc}

unit ctsStringStructure;

interface

{$DEFINE USE_Reference}

{$IFDEF USE_Reference}
  {$DEFINE USE_String}
{$ENDIF USE_Reference}

uses
{$I ctsUseDeclare.inc}
  ctsStringInterface;

const
  cUnitName = 'ctsStringStructure';

{$I template\ctsStructImp.inc}

end.
