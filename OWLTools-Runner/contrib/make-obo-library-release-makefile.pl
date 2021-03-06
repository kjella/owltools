#!/usr/bin/perl
use strict;
my $ns;
my %d = ();
my %nsh = ();
my %fmth = ();

my $md_url = 'http://obo-registry.googlecode.com/svn/trunk/metadata/ontologies.txt';

my @mdfiles=();

if (!@ARGV) {
    @ARGV = ('--fetch-metadata');
}

while (@ARGV && $ARGV[0] =~ /^\-/) {
    my $opt = shift @ARGV;
    print STDERR "O: $opt\n";
    if ($opt eq '--fetch-metadata') {
        cmd("wget $md_url -O ontologies.txt");
        push(@mdfiles, 'ontologies.txt');
    }
    else {
        die $opt;
    }
}
push(@mdfiles, @ARGV);
die unless @mdfiles;

foreach my $mdf (@mdfiles) {
    open(F,$mdf);
    while(<F>) {
        chomp;
        if (/^(\S+)\t+(.*)/) {
            my ($t,$v) = ($1,$2);
            if ($t eq 'namespace') {
                $ns = $v;
                print STDERR "NS: $ns\n";
                $nsh{$ns}++;
                if ($nsh{$ns} > 1) {
                    print STDERR "NS PRESENT TWICE: $ns\n";
                }
            }
            elsif ($t eq 'download') {
                if ($v && !$d{$ns}) {
                    $d{$ns} = $v;
                }
            }
            elsif ($t eq 'source') {
                if ($v && !$d{$ns}) {
                    $v =~ s/.*\|//;
                    $d{$ns} = $v;
                }
            }
            elsif ($t eq 'prerelease_download') {
                # always takes priority..
                ##$d{$ns} = $v;
            }
            elsif ($t eq 'format') {
                $fmth{$ns} = $v;
                print STDERR "NS: $ns FMT: $v\n";
            }
        }
        elsif (/^\S+$/) {
            print STDERR "TYPO: no tab in line: $_\n";
        }
        else {
            if ($ns && /\S/) {
                print STDERR "Possible typo, no tab in line: $_\n";
            }
            $ns = '';
        }
    }
    close(F);
}

foreach my $ns (keys %nsh) {
    if (!$d{$ns}) {
        print STDERR "NO DOWNLOAD: $ns\n";
    }
}

my @targets = ();
my @rules = ();
foreach my $ns (keys %d)  {
    next unless $ns;
    my $ont = lc($ns);
    my $fmt = $fmth{$ns};
    print STDERR "ONT: $ont FMT: '$fmt'\n";
    next if $ont eq 'lipro'; # hermit does not complete
    next unless $fmt eq 'obo' || $fmt eq 'owl';

    my $srcf = "$ont/src/$ont.$fmt";

    push(@targets, "release-$ont");

    # first fetch; depends on 'stamp' file, which can be touched
    my $localf = $d{$ns};
    $localf =~ s@.*/@@g;
    push(@rules, "$srcf: stamp\n\twget --no-check-certificate '$d{$ns}' -O \$@.tmp && ( cmp \$@.tmp \$@ && echo identical || cp \$@.tmp \$@)");

    # then build
    push(@rules, "$ont/$ont.owl: $srcf\n\tontology-release-runner --skip-release-folder --no-subsets --skip-format owx --allow-overwrite --outdir $ont --no-reasoner --asserted --simple \$< > \$@.fail 2>&1  && mv \$@.fail \$@.log");
    push(@rules, "$ont/$ont.obo: $ont/$ont.owl");
    push(@rules, "$ont/$ont-obo-diff.html: $ont/$ont.obo\n".
        "\t(test -f \$<.LAST || cp \$< \$<.LAST ) ;compare-obo-files.pl -f1 \$<.LAST -f2 \$< -m html txt rss --rss-path . -o $ont/$ont-obo-diff --config html/ontology_name=$ont && cp \$<.LAST \$<");

    # then release
    #push(@rules, "../$ont.%: $ont/$ont.%\n\tcp \$< \$@");
    push(@rules, "\$(TDIR)/$ont.obo: $ont/$ont.obo\n\tcp \$< \$@");
    push(@rules, "\$(TDIR)/$ont.owl: $ont/$ont.owl\n\tcp \$< \$@");
    push(@rules, "release-$ont: \$(TDIR)/$ont.obo \$(TDIR)/$ont.owl $ont/$ont-obo-diff.html\n\ttouch \$@");
    #push(@rules, "release-$ont: $ont/$ont.owl\n\tcp $ont/$ont.owl ..; cp $ont/$ont.obo ..");

    cmd("mkdir $ont");
    cmd("mkdir $ont/src");

}
unshift(@rules, "all: @targets");
push(@rules, "stamp:\n\ttouch \$@");

print "TDIR=..\n\n";
foreach (@rules) {
    print "$_\n";
    if (/^(\S+):/) {
        print ".PRECIOUS: $1\n";
    }
    print "\n";
}

exit 0;    

sub cmd {
    my $cmd = "@_";
    print STDERR "CMD:$cmd\n";
    system($cmd) && print STDERR "PROBLEM: $cmd\n";
}
