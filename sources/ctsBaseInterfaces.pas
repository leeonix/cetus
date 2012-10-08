{$I CetusOptions.inc}

unit ctsBaseInterfaces;

interface

uses
  ctsTypesDef;

type
  IctsBaseInterface = IInterface;

  IctsIdentify = interface(IctsBaseInterface)
    ['{7FAF1691-1D3E-4369-8007-FB349BC6FB1D}']
    function GetName: TctsNameString;
  end;

  IctsNamed = interface(IctsIdentify)
    ['{9B008CDA-638F-419D-A958-B9ADA64246F7}']
    procedure SetName(const Value: TctsNameString);
    property Name: TctsNameString read GetName write SetName;
  end;

  IctsMemoryPool = interface(IctsNamed)
    ['{AE8FE9D6-9BB1-493F-9432-B9665359D876}']
    function New: Pointer;
    function NewClear: Pointer;
    procedure Delete(ANode: Pointer);
  end;

  IctsBaseObserver = interface(IInterface)
    ['{5DC5C2F3-71A8-4A83-BFCA-23B0A3DC2DCD}']
    procedure Changed(AParams: Pointer);
    function GetEnabled: Boolean;
    procedure SetEnabled(const AValue: Boolean);
    property Enabled: Boolean read GetEnabled write SetEnabled;
  end;

  IctsObserverRegister = interface(IInterface)
    ['{ACD63520-3714-4DD8-A3A7-DEE90F012917}']
    procedure Register(const AObserver: IctsBaseObserver);
    procedure UnRegister(const AObserver: IctsBaseObserver);
  end;

  IctsBaseContainer = interface(IctsNamed)
    ['{9E2312BF-7741-4120-8C5C-02878A49CCE6}']
    function GetCount: LongInt;
    function IsEmpty: Boolean;
    function GetReference: TObject;
  end;

  IctsContainer = interface(IctsBaseContainer)
    ['{EEC67BD4-214F-464F-94F0-B8A8CDDCE49C}']
    procedure SetCount(const AValue: LongInt);
    property Count: LongInt read GetCount write SetCount;
  end;

implementation

end.
