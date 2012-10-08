#!/usr/bin/perl -w
use strict;

sub copy_from
{
    my ($source_name, $template_name) = @_;
    undef $/;
    print "process file: $source_name from $template_name\n";

    open template_file, "<$template_name";
    my $temp = <template_file>;
    close template_file;

    rename $source_name, "$source_name.bak";
    open src_file, "<", "$source_name.bak";
    my $src = <src_file>;    
    $src =~ s/\$I template(.*)\n/\.\$I template$1\n$temp/g;
    close src_file;
    
    open out_file, ">", "$source_name";
    print out_file $src;
    close out_file;
}

copy_from("../ctsPointerInterface.pas", "../template/ctsStructIntf.inc");
copy_from("../ctsPointerStructure.pas", "../template/ctsStructImp.inc");