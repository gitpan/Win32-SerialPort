####    use ExtUtils::MakeMaker;
####    # See lib/ExtUtils/MakeMaker.pm for details of how to influence
####    # the contents of the Makefile that is written.
####    WriteMakefile(
####        'NAME'	=> 'SerialPort',
####        'VERSION_FROM' => 'SerialPort.pm', # finds $VERSION
####    );

print "\n\n            Win32::SerialPort and Win32API::CommPort\n";
print "                           VERSION 0.17\n";
print "                  No 'Makefile' will be created\n";
print "         so skip customary 'make', 'dmake', 'nmake' steps\n\n";
print "              Test with nothing connected to COM1\n";
print "          or for different port: perl makefile.PL PORT\n\n";
print "             The test suite will run automatically\n";
print "         Timeout tests can take up to 30 seconds per test\n\n";

my $file = "COM1";
if (@ARGV) {
    $file = shift @ARGV;
}
$ENV{Makefile_Test_Port} = $file;

if ( $] < 5.004 ) {
    print "On ActiveState Build 3xx, test results will print to 'test.txt'\n\n";
    
    open(TXT, ">test.txt") || die "Can't open 'test.txt': $!\n";
    print TXT "\nWelcome to the Poor Man's Test::Harness\n\n";

    my $junk = $Win32::API::VERSION;
    $junk = $Win32::API::pack;

    sub summary {
	my $test = shift;
        print "....$test";
        print TXT "....$test";
	my $testout = `perl $test`;
            # assumes the perl 5.003 executable is in your path as "perl"
        if (index($testout, "not ok") > -1) {
	    print "....errors found\n";
	    print TXT "....errors found\n$testout\n";
	    return 1;
        }
	print "....ok\n";
	print TXT "....ok\n$testout\n";
	return 0;
    }

    my $fault = summary ("t/test1.t");
    $fault +=   summary ("t/test2.t");
    $fault +=   summary ("t/test3.t");
    $fault +=   summary ("t/test4.t");
    $fault +=   summary ("t/test5.t");
    $fault +=   summary ("t/test6.t");

    print "All tests OK\n" unless ($fault);
    close TXT;
    print "\nRun 'perl Inst_3xx.PL' to install into proper locations.\n\n";
}
else {
    use Test::Harness;
    runtests ("t/test1.t", "t/test2.t", "t/test3.t", "t/test4.t",
	      "t/test5.t", "t/test6.t", "t/test7.t");

    print "\nRun 'perl Install.PL' to install into proper locations.\n\n";
}
print "To run individual tests, type:\n";
print "    C:\\> perl t/test1.t Page_Pause_Time (0..5) [ COMx ]\n";
print "Continue with 'perl t/test2.t' through 'perl t/test7.t'\n";
print "See README and other documentation for additional information.\n\n";
