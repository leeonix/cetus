{$I CetusOptions.inc}

unit ctsIInterfaceHeader;

interface

uses
  ctsIInterfaceInterface,
  ctsIInterfaceStructure;

type
  //interface
  PctsIntfArray = ctsIInterfaceInterface.PctsArray;
  TctsIntfArray = ctsIInterfaceInterface.TctsArray;
  PctsIntfNode = ctsIInterfaceInterface.PctsNode;
  TctsIntfNode = ctsIInterfaceInterface.TctsNode;
  IctsIntfObserver = ctsIInterfaceInterface.IctsObserver;
  IctsIntfObserverGenerator = ctsIInterfaceInterface.IctsObserverGenerator;
  IctsIntfIterator = ctsIInterfaceInterface.IctsIterator;
  IctsIntfCollection = ctsIInterfaceInterface.IctsCollection;
  IctsIntfVector = ctsIInterfaceInterface.IctsVector;
  IctsIntfList = ctsIInterfaceInterface.IctsList;
  IctsIntfOrderOperator = ctsIInterfaceInterface.IctsOrderOperator;
  IctsIntfStack = ctsIInterfaceInterface.IctsStack;
  IctsIntfQueue = ctsIInterfaceInterface.IctsQueue;
  //classes
  PctsIntfNotifyEntry = ctsIInterfaceStructure.PctsNotifyEntry;
  TctsIntfNotifyEntry = ctsIInterfaceStructure.TctsNotifyEntry;
  TctsIntfBaseNotifier = ctsIInterfaceStructure.TctsBaseNotifier;
  TctsIntfNotifier = ctsIInterfaceStructure.TctsNotifier;
  TctsIntfNotifierWithObserver = ctsIInterfaceStructure.TctsNotifierWithObserver;
  TctsIntfObserver = ctsIInterfaceStructure.TctsObserver;
  TctsIntfCustomVector = ctsIInterfaceStructure.TctsCustomVector;
  TctsIntfVector = ctsIInterfaceStructure.TctsVector;
  TctsIntfVectorWithObserver = ctsIInterfaceStructure.TctsVectorWithObserver;
  TctsIntfThreadSafeVector = ctsIInterfaceStructure.TctsThreadSafeVector;
  TctsIntfCustomLinkedList = ctsIInterfaceStructure.TctsCustomLinkedList;
  TctsIntfLinkedList = ctsIInterfaceStructure.TctsLinkedList;
  TctsIntfLinkedListWithObserver = ctsIInterfaceStructure.TctsLinkedListWithObserver;
  TctsIntfThreadSafeLinkedList = ctsIInterfaceStructure.TctsThreadSafeLinkedList;
  TctsIntfOrderOperator = ctsIInterfaceStructure.TctsOrderOperator;
  TctsIntfStack = ctsIInterfaceStructure.TctsStack;
  TctsIntfStackVector = ctsIInterfaceStructure.TctsStackVector;
  TctsIntfStackLinked = ctsIInterfaceStructure.TctsStackLinked;
  TctsIntfQueue = ctsIInterfaceStructure.TctsQueue;
  TctsIntfQueueVector = ctsIInterfaceStructure.TctsQueueVector;
  TctsIntfQueueLinked = ctsIInterfaceStructure.TctsQueueLinked;
  TctsIntfSortFunctions = ctsIInterfaceStructure.TctsSortFunctions;

implementation

end.
