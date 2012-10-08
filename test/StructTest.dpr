program StructTest;

{$APPTYPE CONSOLE}

uses
  FastMM4,
  Windows,
  Classes,
  SysUtils,
  Math,
  Contnrs,
  ctsTypesDef,
  ctsInclude,
  ctsAlgorithm,
  Test_data;

procedure TestPtr();
var
  I, Num: LongInt;

  Vector: IctsPtrVector;
  List: IctsPtrList;
//  P: Pointer;
  Iter: IctsPtrIterator;
  
//  ObjVector: IctsObjectList;
//  Obj: TObject;
//  ObjIter: IctsObjectIterator;

  Test: TTestObj;
  Test1: TTestObj;


    IOb: IctsPtrObserver;
    Gen: IctsPtrObserverGenerator;


begin
//  Pool := TctsMiniMemoryPool.Create(16);
  AssignFile(Output, 'OutPut.txt');
  Rewrite(Output);

  Test := TTestObj.Create;
  Test.Name := 'Test';

  Test1 := TTestObj.Create;
  Test1.Name := 'Test1';

  Vector := TctsPtrVectorWithObserver.Create;
  Vector.Compare := Test.CompareI;

  List := TctsPtrLinkedListWithObserver.Create;
  List.Compare := Test.CompareI;
  Gen := Vector as IctsPtrObserverGenerator;
//  Supports(Vector, IctsPtrObserverGenerator, Gen);

  IOb := Gen.GenerateObserver;
  IOb.OnChanged := Test.Observer;
  Gen.Register(IOb);

  IOb := Gen.GenerateObserver;
  IOb.OnChanged := Test1.Observer;
  Gen.Register(IOb);

  Randomize;

  Writeln(Output, '-----------------Vector Add----------------------');

  for I := 0 to $200 do
  begin
//    P := Pool.New;
    Num := RandomRange(1000000, 5000000);
    Writeln(Output, Num);
    Vector.Insert(0, Pointer(Num));
//    Vector.Add(Pointer(Num));
  end;

  Writeln(Output, '-----------------Vector Sorted----------------------');

  Vector.Sort;

  Iter := Vector.First;
  while Iter.HasNext do
  begin
    Writeln(Output, IntToStr(Integer(Iter.Data)));
    Iter.Next;
  end;


//  Vector.Free;
  IOb := nil;
  Gen := nil;
  Iter := nil;
  Vector := nil;

//  Supports(List, IctsPointerObserverGenerator, Gen);
  Gen := List as IctsPtrObserverGenerator;
  IOb := Gen.GenerateObserver();
  IOb.OnChanged := Test.Observer;
  Gen.Register(IOb);

  IOb := Gen.GenerateObserver();
  IOb.OnChanged := Test1.Observer;
  Gen.Register(IOb);

  Writeln(Output, '-----------------List Add----------------------');

  for I := 0 to $300 do
  begin
    Num := RandomRange(100000, 50000000);
    Writeln(Output, Num);
    List.Add(Pointer(Num));
  end;


  Writeln(Output, '-----------------List Sorted----------------------');
  List.Sort;
  Iter := List.Last;
  while Iter.HasPrior do
  begin
    Writeln(Output, IntToStr(Integer(Iter.Data)));
    Iter.Prior;
  end;
  
  Gen := nil;
  Iter := nil;
  List := nil;
  
//  Pool := nil;

//  Writeln(Output, '-----------------TObject Add----------------------');
//
//  Supports(TctsObjectVectorWithObserver.Create, IctsObjectList, ObjVector);
//  ObjVector.Dispose := ctsDefaultDisposeObj;
//  ObjVector.Compare := CompareII;
//
//  for I := 0 to $100 do
//  begin
//    Obj := TObject.Create;
//    Writeln(Output, IntToStr(Integer(Obj)));
//    ObjVector.Add(Obj);
//  end;
//
//  Writeln(Output, '-----------------TObject Sorted----------------------');
//
//  ObjVector.Sort;
//  ObjVector.First(ObjIter);
////  Iter := Vector.First;
//
//  while ObjIter.HasNext do
//  begin
//    Writeln(Output, IntToStr(Integer(ObjIter.Value)));
//    ObjIter.Next;
//  end;
//
//  ObjIter := nil;
//  ObjVector := nil;


  Test.Free;
  Test1.Free;

  CloseFile(Output);
end;

procedure TestInterface;
var
  List: IctsIntfVector;
//  List: IctsIntfList;
  MyObject: IIntfMyObject;
  It: IctsIntfIterator;
  It1: IctsIntfIterator;
//  I: Integer;
begin
  List := TctsIntfVector.Create;
//  List := TctsIntfLinkedList.Create;

  It1 := List.First();

  MyObject := TIntfMyObject.Create;
  MyObject.Int := 42;
  MyObject.Str := 'MyString';
  List.Add(MyObject);

//  MyObject := IIntfMyObject(List.Items[0]);
//  MyObject := TIntfMyObject.Create;
//  MyObject.Int := 41;
//  MyObject.Str := 'InsertString';

  MyObject := TIntfMyObject.Create;
  MyObject.Int := 88;
  MyObject.Str := 'InsertString';
//  It1.Insert(MyObject);
  List.Insert(1, MyObject);


  MyObject := TIntfMyObject.Create;
  MyObject.Int := 43;
  MyObject.Str := 'AnotherString';
  List.Add(MyObject);

  MyObject := TIntfMyObject.Create;
  MyObject.Int := 41;
  MyObject.Str := 'InsertString';
  It1.Next;
  It1.Insert(MyObject);
//  List.Insert(2, MyObject);

  MyObject := TIntfMyObject.Create;
  MyObject.Int := 44;
  MyObject.Str := 'AnotherString';
  List.Add(MyObject);

//  MyObject := TIntfMyObject.Create;
//  MyObject.Int := 41;
//  MyObject.Str := 'InsertString';
//  List.Insert(3, MyObject);

  MyObject := TIntfMyObject.Create;
  MyObject.Int := 45;
  MyObject.Str := 'AnotherString';
  List.Add(MyObject);

  MyObject := TIntfMyObject.Create;
  MyObject.Int := 46;
  MyObject.Str := 'AnotherString';
  List.Add(MyObject);

  MyObject := TIntfMyObject.Create;
  MyObject.Int := 47;
  MyObject.Str := 'AnotherString';
  List.Add(MyObject);

  MyObject := TIntfMyObject.Create;
  MyObject.Int := 100;
  MyObject.Str := '';
  It1.Insert(MyObject);

  It1.Insert(nil);
  It1.Insert(nil);

//  List.Pack;

//  List.Delete(2);

  It := List.First();
  while It.HasNext do
  begin
    if It.GetData = nil then
      Writeln('Data is nil......')
    else
      with IIntfMyObject(It.GetData) do
         Writeln(IntToStr(Int) + ' ' + Str);
    It.Next;
  end;
end;

procedure TestString;
var
//  List: IctsStrList;
  Vector: IctsStrVector;
//  It: IctsStrIterator;
  I: Integer;
//  S: string;
  Test: TTestObj;
  Tick: LongWord;
begin
  Test := TTestObj.Create;

  Vector := TctsStrVector.Create;
  Vector.Compare := Test.CompareII;
  Vector.Add('MyString');
  LoadFromFile('Test3.txt', Vector);
  Tick := GetTickCount;  
  Vector.Sort;
  Tick := GetTickCount - Tick;
  Vector.Add(IntToStr(Tick));

  for I := 1 to 5 do
    Vector[I] := '';

  for I := 11 to 15 do
    Vector[I] := '';

  SaveToFile('Out_put_vector.txt', Vector);

  Vector.Pack;

  SaveToFile('Out_put_vector_packed.txt', Vector);

  Vector := nil;

//  List := TctsStrLinkedList.Create;
//  List.Compare := Test.CompareII;
//  LoadFromFile('Test3.txt', List);
//  Tick := GetTickCount;
//  List.Sort;
//  Tick := GetTickCount - Tick;
//  List.Add(IntToStr(Tick));
//  SaveToFile('Out_put_list.txt', List);
////  List.Add('MyString');
//
//  S := Vector[0];
//  Writeln(S);
////  List.Add('AnotherString');
//  Vector.Insert(1, 'AnotherString1');
//  Vector.Insert(2, 'AnotherString2');
//  Vector.Insert(1, 'AnotherString3');
//
//  // Iteration
//  //List.First(It);
//  It := Vector.First;
//  while It.HasNext do
//  begin
//    S := It.Next;
//    Writeln(S);
//  end;
//
//  Vector.Clear;
//  Vector.Add('MyString');
//  Vector.Insert(1, 'AnotherString1');
//  Vector.Insert(2, 'AnotherString2');
//  Vector.Insert(1, 'AnotherString3');
//
//  Vector.Delete(2);
//
//  Vector.Insert(1, 'AnotherString1');
//  Vector.Insert(2, 'AnotherString2');
//  Vector.Insert(1, 'AnotherString3');

//  It := Vector.First;
//  while It.HasNext do
//  begin
//    S := It.Next;
//    Writeln(S);
//  end;

//  Vector.Sort;

//  It := Vector.First;
//  while It.HasNext do
//  begin
//    S := It.Next;
//    Writeln(S);
//  end;



//  List.Sort;
//  SaveToFile('Out_put_list.txt', Vector);
  Test.Free;
end;
procedure TestObj;
var
//  List: IctsIInterfaceVector;
  List: IctsObjList;
  MyObject: TIntfMyObject;
  It: IctsObjIterator;
  It1: IctsObjIterator;
//  I: Integer;
begin
//  Supports(TctsIInterfaceVector.Create, IctsIInterfaceVector, List);
  List := TctsObjLinkedList.Create;
  List.OwnsObjects := True;
  It1 := List.First();

  MyObject := TIntfMyObject.Create;
  MyObject.Int := 42;
  MyObject.Str := 'MyString';
  List.Add(MyObject);

//  MyObject := IIntfMyObject(List.Items[0]);
//  MyObject := TIntfMyObject.Create;
//  MyObject.Int := 41;
//  MyObject.Str := 'InsertString';

  MyObject := TIntfMyObject.Create;
  MyObject.Int := 88;
  MyObject.Str := 'InsertString';
  It1.Insert(MyObject);
//  List.Insert(1, MyObject);


  MyObject := TIntfMyObject.Create;
  MyObject.Int := 43;
  MyObject.Str := 'AnotherString';
  List.Add(MyObject);

  MyObject := TIntfMyObject.Create;
  MyObject.Int := 41;
  MyObject.Str := 'InsertString';
  It1.Next;
  It1.Insert(MyObject);
//  List.Insert(2, MyObject);

  MyObject := TIntfMyObject.Create;
  MyObject.Int := 44;
  MyObject.Str := 'AnotherString';
  List.Add(MyObject);

//  MyObject := TIntfMyObject.Create;
//  MyObject.Int := 41;
//  MyObject.Str := 'InsertString';
//  List.Insert(3, MyObject);

  MyObject := TIntfMyObject.Create;
  MyObject.Int := 45;
  MyObject.Str := 'AnotherString';
  List.Add(MyObject);
  It1.Remove;


  MyObject := TIntfMyObject.Create;
  MyObject.Int := 46;
  MyObject.Str := 'AnotherString';
  List.Add(MyObject);

  MyObject := TIntfMyObject.Create;
  MyObject.Int := 47;
  MyObject.Str := 'AnotherString';
  List.Add(MyObject);

//  List.Delete(2);

  It := List.First();
  while It.HasNext do
  begin
    MyObject := TIntfMyObject(It.GetData);
    It.Next;
    Writeln(IntToStr(MyObject.Int) + ' ' + MyObject.Str);
  end;
end;

procedure TestStackANDQueue;
var
  Stack: IctsPtrStack;
  Queue: IctsPtrQueue;
  I: LongInt;
begin
  Stack := TctsPtrStackVector.Create();


  Writeln('Push Stack');

  for I := 0 to 20 do
  begin
    Stack.Push(Pointer(I * 10));
    Writeln(LongInt(Stack.Top));
  end;

  Writeln('Pop Stack');

  for I := 0 to Stack.GetCount - 1 do
  begin
    Writeln(LongInt(Stack.Top));
    Stack.Pop;
  end;

  Queue := TctsPtrQueueVector.Create;

  Writeln('Push Queue');

  for I := 0 to 20 do
  begin
    Queue.Push(Pointer(I * 10));
    Writeln(LongInt(Queue.Front));
  end;

  Writeln('Pop Queue');

  for I := 0 to Queue.GetCount - 1 do
  begin
    Writeln(LongInt(Queue.Back));
    Queue.Pop;
  end;  


end;

begin
//  TestPtr;
//  TestInterface;
  TestString;
//  TestObj;
//  TestStackANDQueue;
//  Writeln(sizeof(TctsPrtTreeNode));
end.




