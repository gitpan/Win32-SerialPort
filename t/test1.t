#! perl -w

use lib './lib','../lib'; # can run from here or distribution base
require 5.003;

# Before installation is performed this script should be runnable with
# `perl test1.t time' which pauses `time' seconds (1..5) between pages

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..198\n"; }
END {print "not ok 1\n" unless $loaded;}
use Win32::SerialPort 0.14;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# assume a "vanilla" port on "COM1"

use strict;

## verifies the (0, 1) list returned by binary functions
sub test_bin_list {
    return undef unless (@_ == 2);
    return undef unless (0 == shift);
    return undef unless (1 == shift);
    return 1;
}

## verifies the (0, 255) list returned by byte functions
sub test_byte_list {
    return undef unless (@_ == 2);
    return undef unless (0 == shift);
    return undef unless (255 == shift);
    return 1;
}

## verifies the (0, 0xffff) list returned by short functions
sub test_short_list {
    return undef unless (@_ == 2);
    return undef unless (0 == shift);
    return undef unless (0xffff == shift);
    return 1;
}

## verifies the (0, 0xffffffff) list returned by long functions
sub test_long_list {
    return undef unless (@_ == 2);
    return undef unless (0 == shift);
    return undef unless (0xffffffff == shift);
    return 1;
}

## verifies the value returned by byte functions
sub test_byte_value {
    my $v = shift;
    return undef if (($v < 0) or ($v > 255));
    return 1;
}

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

my $fault = 0;
my $ob;
my $pass;
my $fail;
my $in;
my $in2;
my @opts;
my $out;
my $err;
my $blk;
my $e;
my $tick;
my $tock;
my %required_param;
my @necessary_param = Win32::SerialPort->set_test_mode_active(1);

unlink $cfgfile;
foreach $e (@necessary_param) { $required_param{$e} = 0; }

## 2 - 5 SerialPort Global variable ($Babble);

is_bad(scalar Win32::SerialPort->debug);	# 2: start out false

is_ok(scalar Win32::SerialPort->debug(1));	# 3: set it

is_bad(scalar Win32::SerialPort->debug(2));	# 4: invalid binary=false

# 5: yes_true subroutine, no need to SHOUT if it works

$e="not ok $tc:";
unless (Win32::SerialPort->debug("T"))   { print "$e \"T\"\n"; $fault++; }
if     (Win32::SerialPort->debug("F"))   { print "$e \"F\"\n"; $fault++; }

no strict 'subs';
unless (Win32::SerialPort->debug(T))     { print "$e T\n";     $fault++; }
if     (Win32::SerialPort->debug(F))     { print "$e F\n";     $fault++; }
unless (Win32::SerialPort->debug(Y))     { print "$e Y\n";     $fault++; }
if     (Win32::SerialPort->debug(N))     { print "$e N\n";     $fault++; }
unless (Win32::SerialPort->debug(ON))    { print "$e ON\n";    $fault++; }
if     (Win32::SerialPort->debug(OFF))   { print "$e OFF\n";   $fault++; }
unless (Win32::SerialPort->debug(TRUE))  { print "$e TRUE\n";  $fault++; }
if     (Win32::SerialPort->debug(FALSE)) { print "$e FALSE\n"; $fault++; }
unless (Win32::SerialPort->debug(Yes))   { print "$e Yes\n";   $fault++; }
if     (Win32::SerialPort->debug(No))    { print "$e No\n";    $fault++; }
unless (Win32::SerialPort->debug("yes")) { print "$e \"yes\"\n"; $fault++; }
if     (Win32::SerialPort->debug("f"))   { print "$e \"f\"\n";   $fault++; }
use strict 'subs';

print "ok $tc\n" unless ($fault);
$tc++;

@opts = Win32::SerialPort->debug;		# 6: binary_opt array
is_ok(test_bin_list(@opts));

# 7: Constructor

unless (is_ok ($ob = Win32::SerialPort->new ($file))) {
    printf "could not open port $file\n";
    exit 1;
    # next test would die at runtime without $ob
}

#### 8 - 99: Check Port Capabilities 

## 8 - 35: Binary Capabilities

is_ok(scalar $ob->can_baud);			# 8
@opts = $ob->can_baud;
is_ok(test_bin_list(@opts));			# 9

is_ok(scalar $ob->can_databits);		# 10
@opts = $ob->can_databits;
is_ok(test_bin_list(@opts));			# 11

is_ok(scalar $ob->can_stopbits);		# 12
@opts = $ob->can_stopbits;
is_ok(test_bin_list(@opts));			# 13

is_ok(scalar $ob->can_dtrdsr);			# 14
@opts = $ob->can_dtrdsr;
is_ok(test_bin_list(@opts));			# 15

is_ok(scalar $ob->can_handshake);		# 16
@opts = $ob->can_handshake;
is_ok(test_bin_list(@opts));			# 17

is_ok(scalar $ob->can_parity_check);		# 18
@opts = $ob->can_parity_check;
is_ok(test_bin_list(@opts));			# 19

is_ok(scalar $ob->can_parity_config);		# 20
@opts = $ob->can_parity_config;
is_ok(test_bin_list(@opts));			# 21

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(scalar $ob->can_parity_enable);		# 22
@opts = $ob->can_parity_enable;
is_ok(test_bin_list(@opts));			# 23

is_ok(scalar $ob->can_rlsd);			# 24
@opts = $ob->can_rlsd;
is_ok(test_bin_list(@opts));			# 25

is_ok(scalar $ob->can_rtscts);			# 26
@opts = $ob->can_rtscts;
is_ok(test_bin_list(@opts));			# 27

is_ok(scalar $ob->can_xonxoff);			# 28
@opts = $ob->can_xonxoff;
is_ok(test_bin_list(@opts));			# 29

is_ok(scalar $ob->can_interval_timeout);	# 30
@opts = $ob->can_interval_timeout;
is_ok(test_bin_list(@opts));			# 31

is_ok(scalar $ob->can_total_timeout);		# 32
@opts = $ob->can_total_timeout;
is_ok(test_bin_list(@opts));			# 33

is_ok(scalar $ob->can_xon_char);		# 34
@opts = $ob->can_xon_char;
is_ok(test_bin_list(@opts));			# 35


## 36 - 42: Unusual Parameters (for generic port)

$fail=$ob->can_spec_char;			# 36
printf (($fail ? "spec_char not generic but\n" : "")."ok %d\n",$tc++);
@opts = $ob->can_spec_char;
is_ok(test_bin_list(@opts));			# 37

$fail=$ob->can_16bitmode;			# 38
printf (($fail ? "16bitmode not generic but\n" : "")."ok %d\n",$tc++);
@opts = $ob->can_16bitmode;
is_ok(test_bin_list(@opts));			# 39

$pass=$ob->is_rs232;				# 40
$in = $ob->is_modem;				# 40 alternate
if ($pass)	{ printf ("ok %d\n", $tc++); }
elsif ($in)	{ printf ("modem is\nok %d\n", $tc++); }
else	 	{ printf ("not ok %d\n", $tc++); }

@opts = $ob->is_rs232;
is_ok(test_bin_list(@opts));			# 41

@opts = $ob->is_modem;
is_ok(test_bin_list(@opts));			# 42


## 43 - 62: Byte Capabilities

$in = $ob->xon_char;
is_ok(test_byte_value($in));			# 43

is_bad(scalar $ob->xon_char(500));		# 44

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

@opts = $ob->xon_char;
is_ok(test_byte_list(@opts));			# 45

is_ok(scalar $ob->xon_char(0x11));		# 46


$in = $ob->xoff_char;
is_ok(test_byte_value($in));			# 47

is_bad(scalar $ob->xoff_char(-1));		# 48

@opts = $ob->xoff_char;
is_ok(test_byte_list(@opts));			# 49

is_ok(scalar $ob->xoff_char(0x13));		# 50


$in = $ob->eof_char;
is_ok(test_byte_value($in));			# 51

is_bad(scalar $ob->eof_char(500));		# 52

@opts = $ob->eof_char;
is_ok(test_byte_list(@opts));			# 53

is_zero(scalar $ob->eof_char(0));		# 54


$in = $ob->event_char;
is_ok(test_byte_value($in));			# 55

is_bad(scalar $ob->event_char(5000));		# 56

@opts = $ob->event_char;
is_ok(test_byte_list(@opts));			# 57

is_zero(scalar $ob->event_char(0x0));		# 58


$in = $ob->error_char;
is_ok(test_byte_value($in));			# 59

is_bad(scalar $ob->error_char(65600));		# 60

@opts = $ob->error_char;
is_ok(test_byte_list(@opts));			# 61

is_zero(scalar $ob->error_char(0x0));		# 62


#### 63 - 93: Set Basic Port Parameters 

## 63 - 68: Baud (Valid/Invalid/Current)

@opts=$ob->baudrate;		# list of allowed values
is_ok(1 == grep(/^9600$/, @opts));		# 63
is_zero(scalar grep(/^9601/, @opts));		# 64

is_ok($in = $ob->baudrate);			# 65
is_ok(1 == grep(/^$in$/, @opts));		# 66

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_bad(scalar $ob->baudrate(9601));		# 67
is_ok($in == $ob->baudrate(9600));		# 68
    # leaves 9600 pending


## 69 - 74: Parity (Valid/Invalid/Current)

@opts=$ob->parity;		# list of allowed values
is_ok(1 == grep(/none/, @opts));		# 69
is_zero(scalar grep(/any/, @opts));		# 70

is_ok($in = $ob->parity);			# 71
is_ok(1 == grep(/^$in$/, @opts));		# 72

is_bad(scalar $ob->parity("any"));		# 73
is_ok($in eq $ob->parity("none"));		# 74
    # leaves "none" pending

## 75: Missing Param test

is_bad($ob->write_settings);			# 75


## 76 - 81: Databits (Valid/Invalid/Current)

@opts=$ob->databits;		# list of allowed values
is_ok(1 == grep(/8/, @opts));			# 76
is_zero(scalar grep(/4/, @opts));		# 77

is_ok($in = $ob->databits);			# 78
is_ok(1 == grep(/^$in$/, @opts));		# 79

is_bad(scalar $ob->databits(3));		# 80
is_ok($in == $ob->databits(8));			# 81
    # leaves 8 pending


## 82 - 87: Stopbits (Valid/Invalid/Current)

@opts=$ob->stopbits;		# list of allowed values
is_ok(1 == grep(/1.5/, @opts));			# 82
is_zero(scalar grep(/3/, @opts));		# 83

is_ok($in = $ob->stopbits);			# 84
is_ok(1 == grep(/^$in$/, @opts));		# 85

is_bad(scalar $ob->stopbits(3));		# 86
is_ok($in == $ob->stopbits(1));			# 87
    # leaves 1 pending


## 88 - 93: Handshake (Valid/Invalid/Current)

@opts=$ob->handshake;		# list of allowed values
is_ok(1 == grep(/none/, @opts));		# 88
is_zero(scalar grep(/moo/, @opts));		# 89

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok($in = $ob->handshake);			# 90
is_ok(1 == grep(/^$in$/, @opts));		# 91

is_bad(scalar $ob->handshake("moo"));		# 92
is_ok($in = $ob->handshake("rts"));		# 93
    # leaves "rts" pending for status


## 94 - 99: Buffer Size

($in, $out) = $ob->buffer_max(512);
is_bad(defined $in);				# 94
($in, $out) = $ob->buffer_max;
is_ok(defined $in);				# 95

if (($in > 0) and ($in < 4096))		{ $in2 = $in; } 
else					{ $in2 = 4096; }

if (($out > 0) and ($out < 4096))	{ $err = $out; } 
else					{ $err = 4096; }

is_ok(scalar $ob->buffers($in2, $err));		# 96

@opts = $ob->buffers(4096, 4096, 4096);
is_bad(defined $opts[0]);			# 97
($in, $out)= $ob->buffers;
is_ok($in2 == $in);				# 98
is_ok($out == $err);				# 99

## 100: Alias

is_ok("TestPort" eq $ob->alias("TestPort"));	# 100


## 101 - 106: Read Timeouts

@opts = $ob->read_interval;
is_ok(test_long_list(@opts));			# 101
is_ok(0xffffffff == $ob->read_interval(0xffffffff));	# 102

@opts = $ob->read_const_time;
is_ok(test_long_list(@opts));			# 103
is_zero($ob->read_const_time(0));		# 104

@opts = $ob->read_char_time;
is_ok(test_long_list(@opts));			# 105
is_zero($ob->read_char_time(0));		# 106


## 107 - 110: Write Timeouts

@opts = $ob->write_const_time;
is_ok(test_long_list(@opts));			# 107
is_ok(200 == $ob->write_const_time(200));	# 108

@opts = $ob->write_char_time;
is_ok(test_long_list(@opts));			# 109
is_ok(10 == $ob->write_char_time(10));		# 110

## 111 - 118: Other Parameters (Defaults)

@opts = $ob->binary;
is_ok(test_bin_list(@opts));			# 111
is_ok(1 == $ob->binary(1));			# 112

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

@opts = $ob->parity_enable;
is_ok(test_bin_list(@opts));			# 113
is_zero(scalar $ob->parity_enable(0));		# 114

@opts = $ob->xon_limit;
is_ok(test_short_list(@opts));			# 115

@opts = $ob->xoff_limit;
is_ok(test_short_list(@opts));			# 116

## 117 - 119: Finish Initialize

is_ok(scalar $ob->write_settings);		# 117

is_ok(100 == $ob->xon_limit(100));		# 118
is_ok(200 == $ob->xoff_limit(200));		# 119


## 120 - 130: Constants from Package

is_ok(1 == $ob->BM_fCtsHold);			# 120
is_ok(2 == $ob->BM_fDsrHold);			# 121
is_ok(4 == $ob->BM_fRlsdHold);			# 122
is_ok(8 == $ob->BM_fXoffHold);			# 123
is_ok(0x10 == $ob->BM_fXoffSent);		# 124
is_ok(0x20 == $ob->BM_fEof);			# 125
is_ok(0x40 == $ob->BM_fTxim);			# 126

is_ok(0x10 == $ob->MS_CTS_ON);			# 127
is_ok(0x20 == $ob->MS_DSR_ON);			# 128
is_ok(0x40 == $ob->MS_RING_ON);			# 129
is_ok(0x80 == $ob->MS_RLSD_ON);			# 130

is_ok(0x1 == $ob->CE_RXOVER);			# 131
is_ok(0x2 == $ob->CE_OVERRUN);			# 132

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(0x4 == $ob->CE_RXPARITY);			# 133
is_ok(0x8 == $ob->CE_FRAME);			# 134
is_ok(0x10 == $ob->CE_BREAK);			# 135
is_ok(0x100 == $ob->CE_TXFULL);			# 136
is_ok(0x8000 == $ob->CE_MODE);			# 137

## 138 - 143: Status

@opts = $ob->status;
is_ok(defined @opts);				# 138

# for an unconnected port, should be $in=0, $out=0, $blk=1 (no CTS), $err=0

($blk, $in, $out, $err)=@opts;
is_ok(defined $blk);				# 139
is_zero($in);					# 140
is_zero($out);					# 141

is_ok($blk == $ob->BM_fCtsHold);		# 142
is_zero($err);					# 143

## 144 - 103: No Handshake, Polled Write

is_ok("none" eq $ob->handshake("none"));	# 144

$e="testing is a wonderful thing - this is a 60 byte long string";
#   123456789012345678901234567890123456789012345678901234567890
my $line = $e.$e.$e;		# about 185 MS at 9600 baud

$tick=Win32::GetTickCount();
$pass=$ob->write($line);
$tock=Win32::GetTickCount();

is_ok($pass == 180);				# 145
$err=$tock - $tick;
is_bad (($err < 160) or ($err > 210));		# 146
print "<185> elapsed time=$err\n";

($blk, $in, $out, $err)=$ob->status;
is_zero($blk);					# 147
if ($blk) { printf "status: blk=%lx\n", $blk; }
is_zero($in);					# 148
is_zero($out);					# 149
is_zero($err);					# 150

## 151 - 156: Block by DSR without Output

is_ok(scalar $ob->purge_tx);			# 151
is_ok("dtr" eq $ob->handshake("dtr"));		# 152

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

($blk, $in, $out, $err)=$ob->status;
is_ok($blk == $ob->BM_fDsrHold);		# 153
is_zero($in);					# 154
is_zero($out);					# 155
is_zero($err);					# 156

## 157 - 161: Unsent XOFF without Output

is_ok("xoff" eq $ob->handshake("xoff"));	# 157

($blk, $in, $out, $err)=$ob->status;
is_zero($blk);					# 158
if ($blk) { printf "status: blk=%lx\n", $blk; }
is_zero($in);					# 159
is_zero($out);					# 160
is_zero($err);					# 161

## 162 - 170: Block by XOFF without Output

is_ok(scalar $ob->xoff_active);			# 162

is_ok(scalar $ob->transmit_char(0x33));		# 163

$in2=($ob->BM_fXoffHold | $ob->BM_fTxim);
($blk, $in, $out, $err)=$ob->status;
is_ok($blk & $in2);				# 164
is_zero($in);					# 165
is_zero($out);					# 166
is_zero($err);					# 167

is_ok(scalar $ob->xon_active);			# 168
($blk, $in, $out, $err)=$ob->status;
is_zero($blk);					# 169
if ($blk) { printf "status: blk=%lx\n", $blk; }
is_zero($err);					# 170

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

## 171 - 172: No Handshake

is_ok("none" eq $ob->handshake("none"));	# 171
is_ok(scalar $ob->purge_all);			# 172

## 173 - 178: Optional Messages

@opts = $ob->user_msg;
is_ok(test_bin_list(@opts));			# 173
is_zero(scalar $ob->user_msg);			# 174
is_ok(1 == $ob->user_msg(1));			# 175

@opts = $ob->error_msg;
is_ok(test_bin_list(@opts));			# 176
is_zero(scalar $ob->error_msg);			# 177
is_ok(1 == $ob->error_msg(1));			# 178

## 179 - 184: Save and Check Configuration

is_ok(scalar $ob->save($cfgfile));		# 179

is_ok(9600 == $ob->baudrate);			# 180
is_ok("none" eq $ob->parity);			# 181
is_ok(8 == $ob->databits);			# 182
is_ok(1 == $ob->stopbits);			# 183
is_ok(1 == $ob->close);				# 184
undef $ob;

## 185 - 187: Check File Headers

is_ok(open CF, "$cfgfile");			# 185
my ($signature, $name, @values) = <CF>;
close CF;

is_ok(1 == grep(/SerialPort_Configuration_File/, $signature));	# 186

chomp $name;
is_ok($name eq $file);				# 187

## 188 - 189: Check that Values listed exactly once

$fault = 0;
foreach $e (@values) {
    chomp $e;
    ($in, $out) = split(',',$e);
    $fault++ if ($out eq "");
    $required_param{$in}++;
    }
is_zero($fault);				# 188

$fault = 0;
foreach $e (@necessary_param) {
    $fault++ unless ($required_param{$e} ==1);
    }
is_zero($fault);				# 189

## 190 - 198: Reopen as (mostly 5.003 Compatible) Tie using File 

    # constructor = TIEHANDLE method		# 190
unless (is_ok ($ob = tie(*PORT,'Win32::SerialPort', $cfgfile))) {
    printf "could not reopen port from $cfgfile\n";
    exit 1;
    # next test would die at runtime without $ob
}

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

    # tie to PRINT method
$tick=Win32::GetTickCount();
$pass=print PORT $line;
$tock=Win32::GetTickCount();

is_ok($pass == 1);				# 191
$err=$tock - $tick;
is_bad (($err < 160) or ($err > 210));		# 192
print "<185> elapsed time=$err\n";

    # tie to PRINTF method
$tick=Win32::GetTickCount();
if ( $] < 5.004 ) {
    $out=sprintf "123456789_%s_987654321", $line;
    $pass=print PORT $out;
}
else {
    $pass=printf PORT "123456789_%s_987654321", $line;
}
$tock=Win32::GetTickCount();

is_ok($pass == 1);				# 193
$err=$tock - $tick;
is_bad (($err < 180) or ($err > 235));		# 194
print "<205> elapsed time=$err\n";

    # tie to READLINE method
is_ok (500 == $ob->read_const_time(500));	# 195
$tick=Win32::GetTickCount();
$fail = <PORT>;
$tock=Win32::GetTickCount();

is_bad(defined $fail);				# 196
$err=$tock - $tick;
is_bad (($err < 480) or ($err > 540));		# 197
print "<500> elapsed time=$err\n";

    # destructor = CLOSE method
if ( $] < 5.005 ) {
    is_ok($ob->close);				# 198
}
else {
    is_ok(close PORT);				# 198
}

    # destructor = DESTROY method
undef $ob;					# Don't forget this one!!
untie *PORT;

