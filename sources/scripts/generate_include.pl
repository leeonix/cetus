#!/usr/bin/perl -w
use strict;

my @interfaces = qw
{   PctsArray
    TctsArray
    PctsNode
    TctsNode
    IctsObserver
    IctsObserverGenerator
    IctsIterator
    IctsCollection
    IctsVector
    IctsList
    IctsOrderOperator
    IctsStack
    IctsQueue
};

my @classes = qw
{
    PctsNotifyEntry
    TctsNotifyEntry
    TctsBaseNotifier
    TctsNotifier
    TctsNotifierWithObserver
    TctsObserver
    TctsCustomVector
    TctsVector
    TctsVectorWithObserver
    TctsThreadSafeVector
    TctsCustomLinkedList
    TctsLinkedList
    TctsLinkedListWithObserver
    TctsThreadSafeLinkedList
    TctsOrderOperator
    TctsStack
    TctsStackVector
    TctsStackLinked
    TctsQueue
    TctsQueueVector
    TctsQueueLinked
    TctsSortFunctions
};

my @all_types;
my $filename;
my $line_format = "  %s = %s.%s;";

sub save_alltype
{
    push(@all_types, sprintf $line_format, $_[0], $filename, $_[0]);
}

sub gen_value
{
    my $_file = pop(@_);
    my $_type = pop(@_);
    my @_save = @_;
    my @_values;
    foreach my $_src (@_save)
    {
        my $dest = $_src;
        $dest =~ s/(.)cts(.*)/$1cts$_type$2/g;
        save_alltype($dest);
        push(@_values, sprintf $line_format, $dest, $_file, $_src);
    };
    return join "\n", @_values;
};

sub gen_file
{
    my ($type, $file) = @_;
    push(@all_types, "  //$file");
    $filename = sprintf "cts%sHeader", $file;
    my $Intf_file = sprintf "cts%sInterface", $file;
    my $Imp_file = sprintf "cts%sStructure", $file;
    my $uses_files = "$Intf_file,\n  $Imp_file;";
    my $save_interfaces = gen_value(@interfaces, $type, $Intf_file);
    my $save_classes = gen_value(@classes, $type, $Imp_file);
    open _out, ">", "../$filename.pas";
    format _out =
{$I CetusOptions.inc}

unit ^*;
     $filename

interface

uses
  @*
  $uses_files
  
type
  //interface
@*
$save_interfaces
  //classes
@*
$save_classes
  
implementation

end.
.
    write _out;
    close _out;
    push(@all_types, "");
}

gen_file("Ptr", "Pointer");
gen_file("Obj", "Object");
gen_file("Intf", "IInterface");
gen_file("Str", "String");
my $all_type = join "\n", @all_types;

open _Header, ">", "../ctsHeader.pas";
format _Header =
{$I CetusOptions.inc}

unit ctsHeader;

interface

uses
  ctsPointerHeader,
  ctsObjectHeader,
  ctsIInterfaceHeader,
  ctsStringHeader;
  
type
@*
$all_type

implementation

end.
.

write _Header;
close _Header;