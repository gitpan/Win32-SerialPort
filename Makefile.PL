####    use ExtUtils::MakeMaker;
####    # See lib/ExtUtils/MakeMaker.pm for details of how to influence
####    # the contents of the Makefile that is written.
####    WriteMakefile(
####        'NAME'	=> 'SerialPort',
####        'VERSION_FROM' => 'SerialPort.pm', # finds $VERSION
####    );

print "\n\n            Win32::SerialPort and Win32API::CommPort\n";
print "                      Beta 3, VERSION 0.13\n";
print "                  No 'Makefile' will be created\n";
print "         so skip customary 'make', 'dmake', 'nmake' step\n\n";
print "              Test with nothing connected to COM1\n\n";
print "             The test suite will run automatically\n";
print "It will generate summary results on perl 5.004 and above (1+ minute)\n\n";
print "To run individual tests, type:\n";
print "    C:\\> perl t/test1.t Page_Pause_Time (1..5)\n";
print "Continue with 'perl t/test2.t' through 'perl t/test5.t'\n";
print "See README and other documentation for additional information.\n\n";

if ( $] < 5.004 ) {
    print "On ActiveState Build 3xx, test results will print to 'test.txt'\n";
    print "The Warnings about 'VERSION' and 'pack' are normal\n\n";

    open(TXT, ">test.txt") || die "Can't open 'test.txt': $!\n";
    print "....t/test1\n";
    print TXT "....t/test1\n";
    $result = `perl t/test1.t`;
        # assumes the perl 5.003 executable is in your path as "perl"
    print TXT $result;

    print "....t/test2\n";
    print TXT "....t/test2\n";
    $result = `perl t/test2.t`;
    print TXT $result;

    print "....t/test3\n";
    print TXT "....t/test3\n";
    $result = `perl t/test3.t`;
    print TXT $result;

    print "....t/test4\n";
    print TXT "....t/test4\n";
    $result = `perl t/test4.t`;
    print TXT $result;

    print "....t/test5\n";
    print TXT "....t/test5\n";
    $result = `perl t/test5.t`;
    print TXT $result;

    close TXT;
}
else {
    use Test::Harness;
    runtests ("t/test1.t", "t/test2.t", "t/test3.t", "t/test4.t", "t/test5.t");

    print "\nRun 'perl Install.PL' to install into proper locations.\n\n";
}
