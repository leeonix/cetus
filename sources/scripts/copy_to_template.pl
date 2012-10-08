#!/usr/bin/perl -w
use strict;

sub copy_to
{
    my ($source_name, $template_name) = @_;
    print "process file: $source_name to $template_name \n";
    
    undef $/;
    open src_file, "<$source_name";
    $_ = <src_file>;
    close src_file;
    
    my @content = split /{\.\$I template\\.*}\n/, $_;
    @content = split /\nend\.\n/, $content[1];
    
    open template_file, ">$template_name";
    print template_file $content[0];
    close template_file;    
}

copy_to("../ctsPointerInterface.pas", "../template/ctsStructIntf.inc");
copy_to("../ctsPointerStructure.pas", "../template/ctsStructImp.inc");
