#!/usr/bin/perl -w
use strict;

undef $/;
for my $file(glob("../*.pas"))
{
    open IP, "$file";
    my $content = <IP>;
    close IP;
    if ( $content !~ /^{\$I CetusOptions.inc}/m )
    {
        open OP, ">$file";
        $content =~ s/^(?)/{\$I CetusOptions.inc}\n\n/m;
        print OP $content;
        close OP;
        print "Updated $file\n";
    }
    else
    {
        print "$file already include CetusOptions.inc \n";
    }
}

#END:body
