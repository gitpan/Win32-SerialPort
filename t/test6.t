#! perl -w

use lib './lib','../lib'; # can run from here or distribution base
require 5.004;

# Before installation is performed this script should be runnable with
# `perl test6.t time' which pauses `time' seconds (1..5) between pages

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..36\n"; }
END {print "not ok 1\n" unless $loaded;}
use Win32::SerialPort 0.14;
use Win32;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# assume a "vanilla" port on "COM1"

use strict;

my $tc = 2;		# next test number

sub is_ok {
    my $result = shift;
    printf (($result ? "" : "not ")."ok %d\n",$tc++);
    return $result;
}

sub is_zero {
    my $result = shift;
    if (defined $result) {
        return is_ok ($result == 0);
    }
    else {
        printf ("not ok %d\n",$tc++);
    }
}

sub is_bad {
    my $result = shift;
    printf (($result ? "not " : "")."ok %d\n",$tc++);
    return (not $result);
}

my $file = "COM1";
my $cfgfile = $file."_test.cfg";

my $naptime = 0;	# pause between output pages
if (@ARGV) {
    $naptime = shift @ARGV;
    unless ($naptime =~ /^[1-5]$/) {
	die "Usage: perl test?.t [ page_delay (1..5) ]";
    }
}

my $e="testing is a wonderful thing - this is a 60 byte long string";
#      123456789012345678901234567890123456789012345678901234567890
my $line = $e.$e.$e;		# about 185 MS at 9600 baud

my $fault = 0;
my $ob;
my $pass;
my $fail;
my $match;
my $left;
my @opts;
my $patt;
my $err;
my $blk;
my $tick;
my $tock;

## 2: Open as Tie using File 

    # constructor = TIEHANDLE method		# 2
unless (is_ok ($ob = tie(*PORT,'Win32::SerialPort', $cfgfile))) {
    printf "could not reopen port from $cfgfile\n";
    exit 1;
    # next test would die at runtime without $ob
}

### 2 - xx: Defaults for stty and lookfor

@opts = $ob->are_match("\n");
is_ok ($#opts == 0);				# 3
is_ok ($opts[0] eq "\n");			# 4
is_ok ($ob->lookclear == 1);			# 5
is_ok ($ob->is_prompt("") eq "");		# 6
is_ok ($ob->lookfor eq "");			# 7

($match, $left, $patt) = $ob->lastlook;
is_ok ($match eq "");				# 8
is_ok ($left eq "");				# 9
is_ok ($patt eq "");				# 10

is_ok("none" eq $ob->handshake("none"));	# 11
is_ok(0 == $ob->stty_onlcr(0));			# 12

is_ok(0 == $ob->read_char_time(0));		# 13
is_ok(1000 == $ob->read_const_time(1000));	# 14
is_ok(0 == $ob->read_interval(0));		# 15
is_ok(0 == $ob->write_char_time(0));		# 16
is_ok(2000 == $ob->write_const_time(2000));	# 17

    # tie to PRINT method
$tick=Win32::GetTickCount();
$pass=print PORT $line;
is_zero($);					# 18
$tock=Win32::GetTickCount();

is_ok($pass == 1);				# 19
$err=$tock - $tick;
is_bad (($err < 160) or ($err > 210));		# 20
print "<185> elapsed time=$err\n";

    # tie to READLINE method
$tick=Win32::GetTickCount();
$fail = <PORT>;
is_ok($);					# 21
$tock=Win32::GetTickCount();

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_bad(defined $fail);				# 22
$err=$tock - $tick;
is_bad (($err < 800) or ($err > 1200));		# 23
print "<1000> elapsed time=$err\n";

    # tie to PRINTF method
$tick=Win32::GetTickCount();
$pass=printf PORT "123456789_%s_987654321", $line;
is_zero($);					# 24
$tock=Win32::GetTickCount();

is_ok($pass == 1);				# 25
$err=$tock - $tick;
is_bad (($err < 180) or ($err > 235));		# 26
print "<205> elapsed time=$err\n";

    # tie to GETC method
$tick=Win32::GetTickCount();
$fail = getc PORT;
is_ok($);					# 27
$tock=Win32::GetTickCount();

is_bad(defined $fail);				# 28
$err=$tock - $tick;
is_bad (($err < 800) or ($err > 1200));		# 29
print "<1000> elapsed time=$err\n";

    # tie to WRITE method
$tick=Win32::GetTickCount();
if ( $] < 5.005 ) {
    $pass=print PORT $line;
    is_ok($pass == 1);				# 30
}
else {
    $pass=syswrite PORT, $line, length($line), 0;
    is_ok($pass == 180);			# 30
}
is_zero($);					# 31
$tock=Win32::GetTickCount();

$err=$tock - $tick;
is_bad (($err < 160) or ($err > 210));		# 32
print "<185> elapsed time=$err\n";

    # tie to READ method
my $in = "1234567890";
$tick=Win32::GetTickCount();
$fail = sysread (PORT, $in, 5, 0);
is_ok($);					# 33
$tock=Win32::GetTickCount();

is_bad(defined $fail);				# 34
$err=$tock - $tick;
is_bad (($err < 800) or ($err > 1200));		# 35
print "<1000> elapsed time=$err\n";

    # destructor = CLOSE method
if ( $] < 5.005 ) {
    is_ok($ob->close);				# 36
}
else {
    is_ok(close PORT);				# 36
}

    # destructor = DESTROY method
undef $ob;					# Don't forget this one!!
untie *PORT;
