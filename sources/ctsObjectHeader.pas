{$I CetusOptions.inc}

unit ctsObjectHeader;

interface

uses
  ctsObjectInterface,
  ctsObjectStructure;

type
  //interface
  PctsObjArray = ctsObjectInterface.PctsArray;
  TctsObjArray = ctsObjectInterface.TctsArray;
  PctsObjNode = ctsObjectInterface.PctsNode;
  TctsObjNode = ctsObjectInterface.TctsNode;
  IctsObjObserver = ctsObjectInterface.IctsObserver;
  IctsObjObserverGenerator = ctsObjectInterface.IctsObserverGenerator;
  IctsObjIterator = ctsObjectInterface.IctsIterator;
  IctsObjCollection = ctsObjectInterface.IctsCollection;
  IctsObjVector = ctsObjectInterface.IctsVector;
  IctsObjList = ctsObjectInterface.IctsList;
  IctsObjOrderOperator = ctsObjectInterface.IctsOrderOperator;
  IctsObjStack = ctsObjectInterface.IctsStack;
  IctsObjQueue = ctsObjectInterface.IctsQueue;
  //classes
  PctsObjNotifyEntry = ctsObjectStructure.PctsNotifyEntry;
  TctsObjNotifyEntry = ctsObjectStructure.TctsNotifyEntry;
  TctsObjBaseNotifier = ctsObjectStructure.TctsBaseNotifier;
  TctsObjNotifier = ctsObjectStructure.TctsNotifier;
  TctsObjNotifierWithObserver = ctsObjectStructure.TctsNotifierWithObserver;
  TctsObjObserver = ctsObjectStructure.TctsObserver;
  TctsObjCustomVector = ctsObjectStructure.TctsCustomVector;
  TctsObjVector = ctsObjectStructure.TctsVector;
  TctsObjVectorWithObserver = ctsObjectStructure.TctsVectorWithObserver;
  TctsObjThreadSafeVector = ctsObjectStructure.TctsThreadSafeVector;
  TctsObjCustomLinkedList = ctsObjectStructure.TctsCustomLinkedList;
  TctsObjLinkedList = ctsObjectStructure.TctsLinkedList;
  TctsObjLinkedListWithObserver = ctsObjectStructure.TctsLinkedListWithObserver;
  TctsObjThreadSafeLinkedList = ctsObjectStructure.TctsThreadSafeLinkedList;
  TctsObjOrderOperator = ctsObjectStructure.TctsOrderOperator;
  TctsObjStack = ctsObjectStructure.TctsStack;
  TctsObjStackVector = ctsObjectStructure.TctsStackVector;
  TctsObjStackLinked = ctsObjectStructure.TctsStackLinked;
  TctsObjQueue = ctsObjectStructure.TctsQueue;
  TctsObjQueueVector = ctsObjectStructure.TctsQueueVector;
  TctsObjQueueLinked = ctsObjectStructure.TctsQueueLinked;
  TctsObjSortFunctions = ctsObjectStructure.TctsSortFunctions;

implementation

end.
