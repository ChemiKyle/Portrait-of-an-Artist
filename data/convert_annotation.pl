#!/usr/bin/perl

use 5.12.0;

open(INPUT, "<$ARGV[0]") || die "Couldn't open $!";
open(OUTPUT, ">parsed_annotation.jsonl") || die "Couldn't create output file, $!";

# Use regex to convert
while (<INPUT>) {
    $_ =~ s/^(-?.*)=\{(.+}$)/{"id":"\1",\2/;
    print OUTPUT $_;
}

close(INPUT);
close(OUTPUT) || die "Couldn't close output file";

