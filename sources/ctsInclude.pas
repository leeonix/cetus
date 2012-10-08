{$I CetusOptions.inc}

unit ctsInclude;

interface

uses
  ctsPointerInclude,
  ctsObjectInclude,
  ctsIInterfaceInclude,
  ctsStringInclude;

type
  //Pointer
  PctsPtrArray = ctsPointerHeader.PctsPtrArray;
  TctsPtrArray = ctsPointerHeader.TctsPtrArray;
  PctsPtrNode = ctsPointerHeader.PctsPtrNode;
  TctsPtrNode = ctsPointerHeader.TctsPtrNode;
  IctsPtrObserver = ctsPointerHeader.IctsPtrObserver;
  IctsPtrObserverGenerator = ctsPointerHeader.IctsPtrObserverGenerator;
  IctsPtrIterator = ctsPointerHeader.IctsPtrIterator;
  IctsPtrCollection = ctsPointerHeader.IctsPtrCollection;
  IctsPtrVector = ctsPointerHeader.IctsPtrVector;
  IctsPtrList = ctsPointerHeader.IctsPtrList;
  IctsPtrOrderOperator = ctsPointerHeader.IctsPtrOrderOperator;
  IctsPtrStack = ctsPointerHeader.IctsPtrStack;
  IctsPtrQueue = ctsPointerHeader.IctsPtrQueue;
  PctsPtrNotifyEntry = ctsPointerHeader.PctsPtrNotifyEntry;
  TctsPtrNotifyEntry = ctsPointerHeader.TctsPtrNotifyEntry;
  TctsPtrBaseNotifier = ctsPointerHeader.TctsPtrBaseNotifier;
  TctsPtrNotifier = ctsPointerHeader.TctsPtrNotifier;
  TctsPtrNotifierWithObserver = ctsPointerHeader.TctsPtrNotifierWithObserver;
  TctsPtrObserver = ctsPointerHeader.TctsPtrObserver;
  TctsPtrCustomVector = ctsPointerHeader.TctsPtrCustomVector;
  TctsPtrVector = ctsPointerHeader.TctsPtrVector;
  TctsPtrVectorWithObserver = ctsPointerHeader.TctsPtrVectorWithObserver;
  TctsPtrThreadSafeVector = ctsPointerHeader.TctsPtrThreadSafeVector;
  TctsPtrCustomLinkedList = ctsPointerHeader.TctsPtrCustomLinkedList;
  TctsPtrLinkedList = ctsPointerHeader.TctsPtrLinkedList;
  TctsPtrLinkedListWithObserver = ctsPointerHeader.TctsPtrLinkedListWithObserver;
  TctsPtrThreadSafeLinkedList = ctsPointerHeader.TctsPtrThreadSafeLinkedList;
  TctsPtrOrderOperator = ctsPointerHeader.TctsPtrOrderOperator;
  TctsPtrStack = ctsPointerHeader.TctsPtrStack;
  TctsPtrStackVector = ctsPointerHeader.TctsPtrStackVector;
  TctsPtrStackLinked = ctsPointerHeader.TctsPtrStackLinked;
  TctsPtrQueue = ctsPointerHeader.TctsPtrQueue;
  TctsPtrQueueVector = ctsPointerHeader.TctsPtrQueueVector;
  TctsPtrQueueLinked = ctsPointerHeader.TctsPtrQueueLinked;
  TctsPtrSortFunctions = ctsPointerHeader.TctsPtrSortFunctions;

  //Object
  PctsObjArray = ctsObjectHeader.PctsObjArray;
  TctsObjArray = ctsObjectHeader.TctsObjArray;
  PctsObjNode = ctsObjectHeader.PctsObjNode;
  TctsObjNode = ctsObjectHeader.TctsObjNode;
  IctsObjObserver = ctsObjectHeader.IctsObjObserver;
  IctsObjObserverGenerator = ctsObjectHeader.IctsObjObserverGenerator;
  IctsObjIterator = ctsObjectHeader.IctsObjIterator;
  IctsObjCollection = ctsObjectHeader.IctsObjCollection;
  IctsObjVector = ctsObjectHeader.IctsObjVector;
  IctsObjList = ctsObjectHeader.IctsObjList;
  IctsObjOrderOperator = ctsObjectHeader.IctsObjOrderOperator;
  IctsObjStack = ctsObjectHeader.IctsObjStack;
  IctsObjQueue = ctsObjectHeader.IctsObjQueue;
  PctsObjNotifyEntry = ctsObjectHeader.PctsObjNotifyEntry;
  TctsObjNotifyEntry = ctsObjectHeader.TctsObjNotifyEntry;
  TctsObjBaseNotifier = ctsObjectHeader.TctsObjBaseNotifier;
  TctsObjNotifier = ctsObjectHeader.TctsObjNotifier;
  TctsObjNotifierWithObserver = ctsObjectHeader.TctsObjNotifierWithObserver;
  TctsObjObserver = ctsObjectHeader.TctsObjObserver;
  TctsObjCustomVector = ctsObjectHeader.TctsObjCustomVector;
  TctsObjVector = ctsObjectHeader.TctsObjVector;
  TctsObjVectorWithObserver = ctsObjectHeader.TctsObjVectorWithObserver;
  TctsObjThreadSafeVector = ctsObjectHeader.TctsObjThreadSafeVector;
  TctsObjCustomLinkedList = ctsObjectHeader.TctsObjCustomLinkedList;
  TctsObjLinkedList = ctsObjectHeader.TctsObjLinkedList;
  TctsObjLinkedListWithObserver = ctsObjectHeader.TctsObjLinkedListWithObserver;
  TctsObjThreadSafeLinkedList = ctsObjectHeader.TctsObjThreadSafeLinkedList;
  TctsObjOrderOperator = ctsObjectHeader.TctsObjOrderOperator;
  TctsObjStack = ctsObjectHeader.TctsObjStack;
  TctsObjStackVector = ctsObjectHeader.TctsObjStackVector;
  TctsObjStackLinked = ctsObjectHeader.TctsObjStackLinked;
  TctsObjQueue = ctsObjectHeader.TctsObjQueue;
  TctsObjQueueVector = ctsObjectHeader.TctsObjQueueVector;
  TctsObjQueueLinked = ctsObjectHeader.TctsObjQueueLinked;
  TctsObjSortFunctions = ctsObjectHeader.TctsObjSortFunctions;

  //IInterface
  PctsIntfArray = ctsIInterfaceHeader.PctsIntfArray;
  TctsIntfArray = ctsIInterfaceHeader.TctsIntfArray;
  PctsIntfNode = ctsIInterfaceHeader.PctsIntfNode;
  TctsIntfNode = ctsIInterfaceHeader.TctsIntfNode;
  IctsIntfObserver = ctsIInterfaceHeader.IctsIntfObserver;
  IctsIntfObserverGenerator = ctsIInterfaceHeader.IctsIntfObserverGenerator;
  IctsIntfIterator = ctsIInterfaceHeader.IctsIntfIterator;
  IctsIntfCollection = ctsIInterfaceHeader.IctsIntfCollection;
  IctsIntfVector = ctsIInterfaceHeader.IctsIntfVector;
  IctsIntfList = ctsIInterfaceHeader.IctsIntfList;
  IctsIntfOrderOperator = ctsIInterfaceHeader.IctsIntfOrderOperator;
  IctsIntfStack = ctsIInterfaceHeader.IctsIntfStack;
  IctsIntfQueue = ctsIInterfaceHeader.IctsIntfQueue;
  PctsIntfNotifyEntry = ctsIInterfaceHeader.PctsIntfNotifyEntry;
  TctsIntfNotifyEntry = ctsIInterfaceHeader.TctsIntfNotifyEntry;
  TctsIntfBaseNotifier = ctsIInterfaceHeader.TctsIntfBaseNotifier;
  TctsIntfNotifier = ctsIInterfaceHeader.TctsIntfNotifier;
  TctsIntfNotifierWithObserver = ctsIInterfaceHeader.TctsIntfNotifierWithObserver;
  TctsIntfObserver = ctsIInterfaceHeader.TctsIntfObserver;
  TctsIntfCustomVector = ctsIInterfaceHeader.TctsIntfCustomVector;
  TctsIntfVector = ctsIInterfaceHeader.TctsIntfVector;
  TctsIntfVectorWithObserver = ctsIInterfaceHeader.TctsIntfVectorWithObserver;
  TctsIntfThreadSafeVector = ctsIInterfaceHeader.TctsIntfThreadSafeVector;
  TctsIntfCustomLinkedList = ctsIInterfaceHeader.TctsIntfCustomLinkedList;
  TctsIntfLinkedList = ctsIInterfaceHeader.TctsIntfLinkedList;
  TctsIntfLinkedListWithObserver = ctsIInterfaceHeader.TctsIntfLinkedListWithObserver;
  TctsIntfThreadSafeLinkedList = ctsIInterfaceHeader.TctsIntfThreadSafeLinkedList;
  TctsIntfOrderOperator = ctsIInterfaceHeader.TctsIntfOrderOperator;
  TctsIntfStack = ctsIInterfaceHeader.TctsIntfStack;
  TctsIntfStackVector = ctsIInterfaceHeader.TctsIntfStackVector;
  TctsIntfStackLinked = ctsIInterfaceHeader.TctsIntfStackLinked;
  TctsIntfQueue = ctsIInterfaceHeader.TctsIntfQueue;
  TctsIntfQueueVector = ctsIInterfaceHeader.TctsIntfQueueVector;
  TctsIntfQueueLinked = ctsIInterfaceHeader.TctsIntfQueueLinked;
  TctsIntfSortFunctions = ctsIInterfaceHeader.TctsIntfSortFunctions;

  //String
  PctsStrArray = ctsStringHeader.PctsStrArray;
  TctsStrArray = ctsStringHeader.TctsStrArray;
  PctsStrNode = ctsStringHeader.PctsStrNode;
  TctsStrNode = ctsStringHeader.TctsStrNode;
  IctsStrObserver = ctsStringHeader.IctsStrObserver;
  IctsStrObserverGenerator = ctsStringHeader.IctsStrObserverGenerator;
  IctsStrIterator = ctsStringHeader.IctsStrIterator;
  IctsStrCollection = ctsStringHeader.IctsStrCollection;
  IctsStrVector = ctsStringHeader.IctsStrVector;
  IctsStrList = ctsStringHeader.IctsStrList;
  IctsStrOrderOperator = ctsStringHeader.IctsStrOrderOperator;
  IctsStrStack = ctsStringHeader.IctsStrStack;
  IctsStrQueue = ctsStringHeader.IctsStrQueue;
  PctsStrNotifyEntry = ctsStringHeader.PctsStrNotifyEntry;
  TctsStrNotifyEntry = ctsStringHeader.TctsStrNotifyEntry;
  TctsStrBaseNotifier = ctsStringHeader.TctsStrBaseNotifier;
  TctsStrNotifier = ctsStringHeader.TctsStrNotifier;
  TctsStrNotifierWithObserver = ctsStringHeader.TctsStrNotifierWithObserver;
  TctsStrObserver = ctsStringHeader.TctsStrObserver;
  TctsStrCustomVector = ctsStringHeader.TctsStrCustomVector;
  TctsStrVector = ctsStringHeader.TctsStrVector;
  TctsStrVectorWithObserver = ctsStringHeader.TctsStrVectorWithObserver;
  TctsStrThreadSafeVector = ctsStringHeader.TctsStrThreadSafeVector;
  TctsStrCustomLinkedList = ctsStringHeader.TctsStrCustomLinkedList;
  TctsStrLinkedList = ctsStringHeader.TctsStrLinkedList;
  TctsStrLinkedListWithObserver = ctsStringHeader.TctsStrLinkedListWithObserver;
  TctsStrThreadSafeLinkedList = ctsStringHeader.TctsStrThreadSafeLinkedList;
  TctsStrOrderOperator = ctsStringHeader.TctsStrOrderOperator;
  TctsStrStack = ctsStringHeader.TctsStrStack;
  TctsStrStackVector = ctsStringHeader.TctsStrStackVector;
  TctsStrStackLinked = ctsStringHeader.TctsStrStackLinked;
  TctsStrQueue = ctsStringHeader.TctsStrQueue;
  TctsStrQueueVector = ctsStringHeader.TctsStrQueueVector;
  TctsStrQueueLinked = ctsStringHeader.TctsStrQueueLinked;
  TctsStrSortFunctions = ctsStringHeader.TctsStrSortFunctions;

implementation

end.
