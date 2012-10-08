{$I CetusOptions.inc}

unit ctsUtils;

interface

function OutRange(const aIndex, aLow, aHight: LongInt): Boolean;

implementation

function OutRange(const aIndex, aLow, aHight: LongInt): Boolean;
begin
  Result := (aIndex < 0) or (aIndex >= aHight);
end;

end.
