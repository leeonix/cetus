{$I CetusOptions.inc}

unit ctsStringHeader;

interface

uses
  ctsStringInterface,
  ctsStringStructure;

type
  //interface
  PctsStrArray = ctsStringInterface.PctsArray;
  TctsStrArray = ctsStringInterface.TctsArray;
  PctsStrNode = ctsStringInterface.PctsNode;
  TctsStrNode = ctsStringInterface.TctsNode;
  IctsStrObserver = ctsStringInterface.IctsObserver;
  IctsStrObserverGenerator = ctsStringInterface.IctsObserverGenerator;
  IctsStrIterator = ctsStringInterface.IctsIterator;
  IctsStrCollection = ctsStringInterface.IctsCollection;
  IctsStrVector = ctsStringInterface.IctsVector;
  IctsStrList = ctsStringInterface.IctsList;
  IctsStrOrderOperator = ctsStringInterface.IctsOrderOperator;
  IctsStrStack = ctsStringInterface.IctsStack;
  IctsStrQueue = ctsStringInterface.IctsQueue;
  //classes
  PctsStrNotifyEntry = ctsStringStructure.PctsNotifyEntry;
  TctsStrNotifyEntry = ctsStringStructure.TctsNotifyEntry;
  TctsStrBaseNotifier = ctsStringStructure.TctsBaseNotifier;
  TctsStrNotifier = ctsStringStructure.TctsNotifier;
  TctsStrNotifierWithObserver = ctsStringStructure.TctsNotifierWithObserver;
  TctsStrObserver = ctsStringStructure.TctsObserver;
  TctsStrCustomVector = ctsStringStructure.TctsCustomVector;
  TctsStrVector = ctsStringStructure.TctsVector;
  TctsStrVectorWithObserver = ctsStringStructure.TctsVectorWithObserver;
  TctsStrThreadSafeVector = ctsStringStructure.TctsThreadSafeVector;
  TctsStrCustomLinkedList = ctsStringStructure.TctsCustomLinkedList;
  TctsStrLinkedList = ctsStringStructure.TctsLinkedList;
  TctsStrLinkedListWithObserver = ctsStringStructure.TctsLinkedListWithObserver;
  TctsStrThreadSafeLinkedList = ctsStringStructure.TctsThreadSafeLinkedList;
  TctsStrOrderOperator = ctsStringStructure.TctsOrderOperator;
  TctsStrStack = ctsStringStructure.TctsStack;
  TctsStrStackVector = ctsStringStructure.TctsStackVector;
  TctsStrStackLinked = ctsStringStructure.TctsStackLinked;
  TctsStrQueue = ctsStringStructure.TctsQueue;
  TctsStrQueueVector = ctsStringStructure.TctsQueueVector;
  TctsStrQueueLinked = ctsStringStructure.TctsQueueLinked;
  TctsStrSortFunctions = ctsStringStructure.TctsSortFunctions;

implementation

end.
