{$I CetusOptions.inc}

unit ctsPointerHeader;

interface

uses
  ctsPointerInterface,
  ctsPointerStructure;

type
  //interface
  PctsPtrArray = ctsPointerInterface.PctsArray;
  TctsPtrArray = ctsPointerInterface.TctsArray;
  PctsPtrNode = ctsPointerInterface.PctsNode;
  TctsPtrNode = ctsPointerInterface.TctsNode;
  IctsPtrObserver = ctsPointerInterface.IctsObserver;
  IctsPtrObserverGenerator = ctsPointerInterface.IctsObserverGenerator;
  IctsPtrIterator = ctsPointerInterface.IctsIterator;
  IctsPtrCollection = ctsPointerInterface.IctsCollection;
  IctsPtrVector = ctsPointerInterface.IctsVector;
  IctsPtrList = ctsPointerInterface.IctsList;
  IctsPtrOrderOperator = ctsPointerInterface.IctsOrderOperator;
  IctsPtrStack = ctsPointerInterface.IctsStack;
  IctsPtrQueue = ctsPointerInterface.IctsQueue;
  //classes
  PctsPtrNotifyEntry = ctsPointerStructure.PctsNotifyEntry;
  TctsPtrNotifyEntry = ctsPointerStructure.TctsNotifyEntry;
  TctsPtrBaseNotifier = ctsPointerStructure.TctsBaseNotifier;
  TctsPtrNotifier = ctsPointerStructure.TctsNotifier;
  TctsPtrNotifierWithObserver = ctsPointerStructure.TctsNotifierWithObserver;
  TctsPtrObserver = ctsPointerStructure.TctsObserver;
  TctsPtrCustomVector = ctsPointerStructure.TctsCustomVector;
  TctsPtrVector = ctsPointerStructure.TctsVector;
  TctsPtrVectorWithObserver = ctsPointerStructure.TctsVectorWithObserver;
  TctsPtrThreadSafeVector = ctsPointerStructure.TctsThreadSafeVector;
  TctsPtrCustomLinkedList = ctsPointerStructure.TctsCustomLinkedList;
  TctsPtrLinkedList = ctsPointerStructure.TctsLinkedList;
  TctsPtrLinkedListWithObserver = ctsPointerStructure.TctsLinkedListWithObserver;
  TctsPtrThreadSafeLinkedList = ctsPointerStructure.TctsThreadSafeLinkedList;
  TctsPtrOrderOperator = ctsPointerStructure.TctsOrderOperator;
  TctsPtrStack = ctsPointerStructure.TctsStack;
  TctsPtrStackVector = ctsPointerStructure.TctsStackVector;
  TctsPtrStackLinked = ctsPointerStructure.TctsStackLinked;
  TctsPtrQueue = ctsPointerStructure.TctsQueue;
  TctsPtrQueueVector = ctsPointerStructure.TctsQueueVector;
  TctsPtrQueueLinked = ctsPointerStructure.TctsQueueLinked;
  TctsPtrSortFunctions = ctsPointerStructure.TctsSortFunctions;

implementation

end.
