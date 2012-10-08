{$I CetusOptions.inc}

unit ctsConsts;

interface

resourcestring
  SVectorCapacityError = 'Vecor capacity out of bounds'#13#10'([%s] [%s.%s] [objname: %s] [capacity: %d])';
  SVectorCountError = 'Vecor count out of bounds'#13#10'([%s] [%s.%s] [objname: %s] [count: %d])';
  SListIndexError = 'List index out of bounds'#13#10'([%s] [%s.%s] [objname: %s] [index: %d])';
  SListHaveNotCompareFunc = 'List have not the compare function'#13#10'([%s] [%s] [objname: %s])';
  SListNotSortError = 'List not sort'#13#10'(([%s] [%s] [objname: %s])';
  SLinkedListNodeError = 'Linked List range out of bounds'#13#10'([%s] [%s.%s] [objname: %s] [index: %d])';
  SLinkedListSetCountError = 'Linked List cannot set count value'#13#10'([%s] [%s.%s] [objname: %s] [index: %d])';
  SPopEmptyStackError = 'Pop from empty stack.'#13#10'([%s] [%s.%s] [objname: %s])';
  SEmptyStackError = 'empty stack.'#13#10'([%s] [%s.%s] [objname: %s])';
  SPopEmptyQueueError = 'Pop from empty queue.'#13#10'([%s] [%s.%s] [objname: %s])';
  SEmptyQueueError = 'empty queue.'#13#10'([%s] [%s.%s] [objname: %s])';
  STreeHasChild = 'Tree: Cannot insert here, this child node already exists.'#13#10'([%s] %s.%s Objname: %s)';
  STreeDupItem = 'Tree: Cannot have duplicate item, item being added already exists ([%s] %s.%s Objname: %s)';
  STreeItemMissing = 'Tree: Cannot find item to delete ([%s] %s.%s Objname: %s)';

const
  SDefaultLinkedListName = '-LinkedList-';
  SDefaultLinkedListMemoryPoolName = '-LinkedList_MemoryPool-';
  SDefaultQueueName = '-Queue-';
  SDefaultStackName = '-Stack-';
  SDefaultVectorName = '-Vector-';
  SDefaultTreeName = '-Tree-';
  SDefaultStrMapName = '-StrMap-';

  SAt = 'At';
  SBack = 'Back';
  SDelete = 'Delete';
  SFront = 'Front';
  SGetItems = 'GetItems';
  SGetValue = 'GetData';
  SInsert = 'Insert';
  SPop = 'Pop';
  SSetCapacity = 'SetCapacity';
  SSetCount = 'SetCount';
  SSetIndex = 'SetIndex';
  SSetItems = 'SetItems';
  SSetValue = 'SetData';
  SSort = 'Sort';
  STop = 'Top';
  SReadyDelete = 'ReadyDelete';

implementation

end.
