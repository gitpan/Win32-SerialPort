#! perl -w

use lib '..','./lib','../lib'; # can run from here or distribution base
require 5.003;

# Before installation is performed this script should be runnable with
# `perl test4.t time' which pauses `time' seconds (1..5) between pages

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..374\n"; }
END {print "not ok 1\n" unless $loaded;}
use AltPort 0.14;		# check inheritance & export
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# tests start using file created by test1.pl

use strict;
use Win32;

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
my $tc = 2;		# next test number
my $ob;
my $pass;
my $fail;
my $in;
my $in2;
my @opts;
my $out;
my $blk;
my $err;
my $e;
my $tick;
my $tock;
my $patt;
my @necessary_param = Win32::SerialPort->set_test_mode_active(1);

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

# 2: Constructor

unless (is_ok ($ob = Win32::SerialPort->start ($cfgfile))) {
    printf "could not open port from $cfgfile\n";
    exit 1;
    # next test would die at runtime without $ob
}

#### 3 - 26: Check Port Capabilities Match Save

is_ok ($ob->is_xon_char == 0x11);		# 3
is_ok ($ob->is_xoff_char == 0x13);		# 4
is_ok ($ob->is_eof_char == 0);			# 5
is_ok ($ob->is_event_char == 0);		# 6
is_ok ($ob->is_error_char == 0);		# 7
is_ok ($ob->is_baudrate == 9600);		# 8
is_ok ($ob->is_parity eq "none");		# 9
is_ok ($ob->is_databits == 8);			# 10
is_ok ($ob->is_stopbits == 1);			# 11
is_ok ($ob->is_handshake eq "none");		# 12
is_ok ($ob->is_read_interval == 0xffffffff);	# 13
is_ok ($ob->is_read_const_time == 0);		# 14
is_ok ($ob->is_read_char_time == 0);		# 15
is_ok ($ob->is_write_const_time == 200);	# 16
is_ok ($ob->is_write_char_time == 10);		# 17

($in, $out)= $ob->are_buffers;
is_ok (4096 == $in);				# 18
is_ok (4096 == $out);				# 19

is_ok ($ob->alias eq "AltPort");		# 20
is_ok ($ob->is_binary == 1);			# 21

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_zero (scalar $ob->is_parity_enable);		# 22
is_ok ($ob->is_xoff_limit == 200);		# 23
is_ok ($ob->is_xon_limit == 100);		# 24
is_ok ($ob->user_msg == 1);			# 25
is_ok ($ob->error_msg == 1);			# 26

### 27 - 62: Defaults for stty and lookfor

@opts = $ob->are_match;
is_ok ($#opts == 0);				# 27
is_ok ($opts[0] eq "\n");			# 28
is_ok ($ob->lookclear == 1);			# 29
is_ok ($ob->is_prompt eq "");			# 30
is_ok ($ob->lookfor eq "");			# 31

($in, $out, $patt) = $ob->lastlook;
is_ok ($in eq "");				# 32
is_ok ($out eq "");				# 33
is_ok ($patt eq "");				# 34

is_ok ($ob->stty_intr eq "\cC");		# 35
is_ok ($ob->stty_quit eq "\cD");		# 36
is_ok ($ob->stty_eof eq "\cZ");			# 37
is_ok ($ob->stty_eol eq "\cJ");			# 38
is_ok ($ob->stty_erase eq "\cH");		# 39
is_ok ($ob->stty_kill eq "\cU");		# 40

my $space76 = " "x76;
my $cstring = "\r$space76\r";
is_ok ($ob->stty_clear eq $cstring);		# 41
is_ok ($ob->stty_bsdel eq "\cH \cH");		# 42

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->is_stty_intr == 3);			# 43
is_ok ($ob->is_stty_quit == 4);			# 44
is_ok ($ob->is_stty_eof == 26);			# 45
is_ok ($ob->is_stty_eol == 10);			# 46
is_ok ($ob->is_stty_erase == 8);		# 47
is_ok ($ob->is_stty_kill == 21);		# 48

is_ok ($ob->stty_echo == 1);			# 49
is_ok ($ob->stty_echoe == 1);			# 50
is_ok ($ob->stty_echok == 1);			# 51
is_ok ($ob->stty_echonl == 0);			# 52
is_ok ($ob->stty_echoke == 1);			# 53
is_ok ($ob->stty_echoctl == 0);			# 54
is_ok ($ob->stty_istrip == 0);			# 55
is_ok ($ob->stty_icrnl == 1);			# 56
is_ok ($ob->stty_ocrnl == 0);			# 57
is_ok ($ob->stty_igncr == 0);			# 58
is_ok ($ob->stty_inlcr == 0);			# 59
is_ok ($ob->stty_onlcr == 1);			# 60
is_ok ($ob->stty_isig == 0);			# 61
is_ok ($ob->stty_icanon == 1);			# 62

print "Change all the parameters\n";

#### 63 - 129: Modify All Port Capabilities

is_ok ($ob->is_xon_char(1) == 0x01);		# 63

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->is_xoff_char(2) == 0x02);		# 64

$pass = $ob->can_spec_char;			# generic port can't set
if ($pass) {
    is_ok ($ob->is_eof_char(4) == 0x04);	# 65
    is_ok ($ob->is_event_char(3) == 0x03);	# 66
    is_ok ($ob->is_error_char(5) == 5);		# 67
}
else {
    is_ok ($ob->is_eof_char(4) == 0);		# 65
    is_ok ($ob->is_event_char(3) == 0);		# 66
    is_ok ($ob->is_error_char(5) == 0);		# 67
}

is_ok ($ob->is_baudrate(1200) == 1200);		# 68
is_ok ($ob->is_parity("odd") eq "odd");		# 69
is_ok ($ob->is_databits(7) == 7);		# 70
is_ok ($ob->is_stopbits(2) == 2);		# 71
is_ok ($ob->is_handshake("xoff") eq "xoff");	# 72
is_ok ($ob->is_read_interval(0) == 0x0);	# 73
is_ok ($ob->is_read_const_time(1000) == 1000);	# 74
is_ok ($ob->is_read_char_time(50) == 50);	# 75
is_ok ($ob->is_write_const_time(2000) == 2000);	# 76
is_ok ($ob->is_write_char_time(75) == 75);	# 77

($in, $out)= $ob->buffers(8092, 1024);
is_ok (8092 == $ob->is_read_buf);		# 78
is_ok (1024 == $ob->is_write_buf);		# 79

is_ok ($ob->alias("oddPort") eq "oddPort");	# 80
is_ok ($ob->is_xoff_limit(45) == 45);		# 81

$pass = $ob->can_parity_enable;
if ($pass) {
    is_ok (scalar $ob->is_parity_enable(1));	# 82
}
else {
    is_zero (scalar $ob->is_parity_enable);	# 82
}

is_ok ($ob->is_xon_limit(90) == 90);		# 83
is_zero ($ob->user_msg(0));			# 84
is_zero ($ob->error_msg(0));			# 85

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

@opts = $ob->are_match ("END","Bye");
is_ok ($#opts == 1);				# 86
is_ok ($opts[0] eq "END");			# 87
is_ok ($opts[1] eq "Bye");			# 88
is_ok ($ob->stty_echo(0) == 0);			# 89
is_ok ($ob->lookclear("Good Bye, Hello") == 1);	# 90
is_ok ($ob->is_prompt("Hi:") eq "Hi:");		# 91
is_ok ($ob->lookfor eq "Good ");		# 92

($in, $out, $patt) = $ob->lastlook;
is_ok ($in eq "Bye");				# 93
is_ok ($out eq ", Hello");			# 94
is_ok ($patt eq "Bye");				# 95

is_ok ($ob->stty_intr("a") eq "a");		# 96
is_ok ($ob->stty_quit("b") eq "b");		# 97
is_ok ($ob->stty_eof("c") eq "c");		# 98
is_ok ($ob->stty_eol("d") eq "d");		# 99
is_ok ($ob->stty_erase("e") eq "e");		# 100
is_ok ($ob->stty_kill("f") eq "f");		# 101

is_ok ($ob->is_stty_intr == 97);		# 102
is_ok ($ob->is_stty_quit == 98);		# 103
is_ok ($ob->is_stty_eof == 99);			# 104

is_ok ($ob->is_stty_eol == 100);		# 105
is_ok ($ob->is_stty_erase == 101);		# 106
is_ok ($ob->is_stty_kill == 102);		# 107

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty_clear("g") eq "g");		# 108
is_ok ($ob->stty_bsdel("h") eq "h");		# 109

is_ok ($ob->stty_echoe(0) == 0);		# 110
is_ok ($ob->stty_echok(0) == 0);		# 111
is_ok ($ob->stty_echonl(1) == 1);		# 112
is_ok ($ob->stty_echoke(0) == 0);		# 113
is_ok ($ob->stty_echoctl(1) == 1);		# 114
is_ok ($ob->stty_istrip(1) == 1);		# 115
is_ok ($ob->stty_icrnl(0) == 0);		# 116
is_ok ($ob->stty_ocrnl(1) == 1);		# 117
is_ok ($ob->stty_igncr(1) == 1);		# 118
is_ok ($ob->stty_inlcr(1) == 1);		# 119
is_ok ($ob->stty_onlcr(0) == 0);		# 120
is_ok ($ob->stty_isig(1) == 1);			# 121
is_ok ($ob->stty_icanon(0) == 0);		# 122

is_ok ($ob->lookclear == 1);			# 123
is_ok ($ob->is_prompt eq "Hi:");		# 124
is_ok ($ob->is_prompt("") eq "");		# 125
is_ok ($ob->lookfor eq "");			# 126

($in, $out, $patt) = $ob->lastlook;
is_ok ($in eq "");				# 127
is_ok ($out eq "");				# 128
is_ok ($patt eq "");				# 129

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

#### 130 - 183: Check Port Capabilities Match Changes

is_ok ($ob->is_xon_char == 0x01);		# 130
is_ok ($ob->is_xoff_char == 0x02);		# 131

$pass = $ob->can_spec_char;			# generic port can't set
if ($pass) {
    is_ok ($ob->is_eof_char == 0x04);		# 132
    is_ok ($ob->is_event_char == 0x03);		# 133
    is_ok ($ob->is_error_char == 5);		# 134
}
else {
    is_ok ($ob->is_eof_char == 0);		# 132
    is_ok ($ob->is_event_char == 0);		# 133
    is_ok ($ob->is_error_char == 0);		# 134
}
is_ok ($ob->is_baudrate == 1200);		# 135
is_ok ($ob->is_parity eq "odd");		# 136
is_ok ($ob->is_databits == 7);			# 137
is_ok ($ob->is_stopbits == 2);			# 138
is_ok ($ob->is_handshake eq "xoff");		# 139
is_ok ($ob->is_read_interval == 0x0);		# 140
is_ok ($ob->is_read_const_time == 1000);	# 141
is_ok ($ob->is_read_char_time == 50);		# 142
is_ok ($ob->is_write_const_time == 2000);	# 143
is_ok ($ob->is_write_char_time == 75);		# 144

($in, $out)= $ob->are_buffers;
is_ok (8092 == $in);				# 145
is_ok (1024 == $out);				# 146
is_ok ($ob->alias eq "oddPort");		# 147

$pass = $ob->can_parity_enable;
if ($pass) {
    is_ok (scalar $ob->is_parity_enable);	# 148
}
else {
    is_zero (scalar $ob->is_parity_enable);	# 148
}

is_ok ($ob->is_xoff_limit == 45);		# 149
is_ok ($ob->is_xon_limit == 90);		# 150

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_zero ($ob->user_msg);			# 151
is_zero ($ob->error_msg);			# 152

@opts = $ob->are_match;
is_ok ($#opts == 1);				# 153
is_ok ($opts[0] eq "END");			# 154
is_ok ($opts[1] eq "Bye");			# 155

is_ok ($ob->stty_intr eq "a");			# 156
is_ok ($ob->stty_quit eq "b");			# 157
is_ok ($ob->stty_eof eq "c");			# 158
is_ok ($ob->stty_eol eq "d");			# 159
is_ok ($ob->stty_erase eq "e");			# 160
is_ok ($ob->stty_kill eq "f");			# 161

is_ok ($ob->is_stty_intr == 97);		# 162
is_ok ($ob->is_stty_quit == 98);		# 163
is_ok ($ob->is_stty_eof == 99);			# 164

is_ok ($ob->is_stty_eol == 100);		# 165
is_ok ($ob->is_stty_erase == 101);		# 166
is_ok ($ob->is_stty_kill == 102);		# 167

is_ok ($ob->stty_clear eq "g");			# 168
is_ok ($ob->stty_bsdel eq "h");			# 169

is_ok ($ob->stty_echo == 0);			# 170
is_ok ($ob->stty_echoe == 0);			# 171
is_ok ($ob->stty_echok == 0);			# 172

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty_echonl == 1);			# 173
is_ok ($ob->stty_echoke == 0);			# 174
is_ok ($ob->stty_echoctl == 1);			# 175

is_ok ($ob->stty_istrip == 1);			# 176
is_ok ($ob->stty_icrnl == 0);			# 177
is_ok ($ob->stty_ocrnl == 1);			# 178
is_ok ($ob->stty_igncr == 1);			# 179
is_ok ($ob->stty_inlcr == 1);			# 180
is_ok ($ob->stty_onlcr == 0);			# 181
is_ok ($ob->stty_isig == 1);			# 182
is_ok ($ob->stty_icanon == 0);			# 183

print "Restore all the parameters\n";

is_ok ($ob->restart($cfgfile));			# 184

#### 185 - 244: Check Port Capabilities Match Original

is_ok ($ob->is_xon_char == 0x11);		# 185
is_ok ($ob->is_xoff_char == 0x13);		# 186
is_ok ($ob->is_eof_char == 0);			# 187
is_ok ($ob->is_event_char == 0);		# 188
is_ok ($ob->is_error_char == 0);		# 189
is_ok ($ob->is_baudrate == 9600);		# 190
is_ok ($ob->is_parity eq "none");		# 191
is_ok ($ob->is_databits == 8);			# 192

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->is_stopbits == 1);			# 193
is_ok ($ob->is_handshake eq "none");		# 194
is_ok ($ob->is_read_interval == 0xffffffff);	# 195
is_ok ($ob->is_read_const_time == 0);		# 196

is_ok ($ob->is_read_char_time == 0);		# 197
is_ok ($ob->is_write_const_time == 200);	# 198
is_ok ($ob->is_write_char_time == 10);		# 199

($in, $out)= $ob->are_buffers;
is_ok (4096 == $in);				# 200
is_ok (4096 == $out);				# 201

is_ok ($ob->alias eq "AltPort");		# 202
is_ok ($ob->is_binary == 1);			# 203
is_zero (scalar $ob->is_parity_enable);		# 204
is_ok ($ob->is_xoff_limit == 200);		# 205
is_ok ($ob->is_xon_limit == 100);		# 206
is_ok ($ob->user_msg == 1);			# 207
is_ok ($ob->error_msg == 1);			# 208

@opts = $ob->are_match("\n");
is_ok ($#opts == 0);				# 209
is_ok ($opts[0] eq "\n");			# 210
is_ok ($ob->lookclear == 1);			# 211
is_ok ($ob->is_prompt eq "");			# 212
is_ok ($ob->lookfor eq "");			# 213

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

($in, $out, $patt) = $ob->lastlook;
is_ok ($in eq "");				# 214
is_ok ($out eq "");				# 215
is_ok ($patt eq "");				# 216

is_ok ($ob->stty_intr eq "\cC");		# 217
is_ok ($ob->stty_quit eq "\cD");		# 218
is_ok ($ob->stty_eof eq "\cZ");			# 219
is_ok ($ob->stty_eol eq "\cJ");			# 220
is_ok ($ob->stty_erase eq "\cH");		# 221
is_ok ($ob->stty_kill eq "\cU");		# 222
is_ok ($ob->stty_clear eq $cstring);		# 223
is_ok ($ob->stty_bsdel eq "\cH \cH");		# 224

is_ok ($ob->is_stty_intr == 3);			# 225
is_ok ($ob->is_stty_quit == 4);			# 226
is_ok ($ob->is_stty_eof == 26);			# 227
is_ok ($ob->is_stty_eol == 10);			# 228
is_ok ($ob->is_stty_erase == 8);		# 229
is_ok ($ob->is_stty_kill == 21);		# 230

is_ok ($ob->stty_echo == 1);			# 231
is_ok ($ob->stty_echoe == 1);			# 232
is_ok ($ob->stty_echok == 1);			# 233
is_ok ($ob->stty_echonl == 0);			# 234

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty_echoke == 1);			# 235
is_ok ($ob->stty_echoctl == 0);			# 236
is_ok ($ob->stty_istrip == 0);			# 237

is_ok ($ob->stty_icrnl == 1);			# 238
is_ok ($ob->stty_ocrnl == 0);			# 239
is_ok ($ob->stty_igncr == 0);			# 240
is_ok ($ob->stty_inlcr == 0);			# 241
is_ok ($ob->stty_onlcr == 1);			# 242
is_ok ($ob->stty_isig == 0);			# 243
is_ok ($ob->stty_icanon == 1);			# 244


## 245 - 255: Status

is_ok (4 == scalar (@opts = $ob->is_status));	# 245

# for an unconnected port, should be $in=0, $out=0, $blk=0, $err=0

($blk, $in, $out, $err)=@opts;
is_ok (defined $blk);				# 246
is_zero ($in);					# 247
is_zero ($out);					# 248
is_zero ($blk);					# 249
if ($blk) { printf "status: blk=%lx\n", $blk; }
is_zero ($err);					# 250

($blk, $in, $out, $err)=$ob->is_status(0x150);	# test only
is_ok ($err == 0x150);				# 251
### printf "error: err=%lx\n", $err;

($blk, $in, $out, $err)=$ob->is_status(0x0f);	# test only
is_ok ($err == 0x15f);				# 252

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

print "=== Force all Status Errors\n";

($blk, $in, $out, $err)=$ob->status;
is_ok ($err == 0x15f);				# 253

is_ok ($ob->reset_error == 0x15f);		# 254

($blk, $in, $out, $err)=$ob->is_status;
is_zero ($err);					# 255

# 256 - 258: "Instant" return for read_interval=0xffffffff

$tick=Win32::GetTickCount();
($in, $in2) = $ob->read(10);
$tock=Win32::GetTickCount();

is_zero ($in);					# 256
is_bad ($in2);					# 257
$out=$tock - $tick;
is_ok ($out < 100);				# 258
print "<0> elapsed time=$out\n";

# 259 - 267: 1 Second Constant Timeout

is_ok (2000 == $ob->is_read_const_time(2000));	# 259
is_zero ($ob->is_read_interval(0));		# 260
is_ok (100 == $ob->is_read_char_time(100));	# 261
is_zero ($ob->is_read_const_time(0));		# 262
is_zero ($ob->is_read_char_time(0));		# 263

is_ok (0xffffffff == $ob->is_read_interval(0xffffffff));	#264
is_ok (1000 == $ob->is_write_const_time(1000));	# 265
is_zero ($ob->is_write_char_time(0));		# 266
is_ok ("rts" eq $ob->is_handshake("rts"));	# 267 ; so it blocks

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

# 268 - 269

$e="12345678901234567890";

$tick=Win32::GetTickCount();
is_zero ($ob->write($e));			# 268
$tock=Win32::GetTickCount();

$out=$tock - $tick;
is_bad (($out < 800) or ($out > 1300));		# 269
print "<1000> elapsed time=$out\n";

# 270 - 272: 2.5 Second Timeout Constant+Character

is_ok (75 ==$ob->is_write_char_time(75));	# 270

$tick=Win32::GetTickCount();
is_zero ($ob->write($e));			# 271
$tock=Win32::GetTickCount();

$out=$tock - $tick;
is_bad (($out < 2300) or ($out > 2900));	# 272
print "<2500> elapsed time=$out\n";


# 273 - 281: 1.5 Second Read Constant Timeout

is_ok (1500 == $ob->is_read_const_time(1500));	# 273
is_zero ($ob->is_read_interval(0));		# 274
is_ok (scalar $ob->purge_all);			# 275

$tick=Win32::GetTickCount();
$in = $ob->read_bg(10);
$tock=Win32::GetTickCount();

is_zero ($in);					# 276
$out=$tock - $tick;
is_ok ($out < 100);				# 277
print "<0> elapsed time=$out\n";

($pass, $in, $in2) = $ob->read_done(0);
$tock=Win32::GetTickCount();

is_zero ($pass);				# 278
is_zero ($in);					# 279
is_ok ($in2 eq "");				# 280
$out=$tock - $tick;
is_ok ($out < 100);				# 281

if ($naptime) {
    print "++++ page break\n";
}

print "A Series of 1 Second Groups with Background I/O\n";

is_zero ($ob->write_bg($e));			# 282
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 283
is_zero ($out);					# 284

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 285
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 286

($blk, $in, $out, $err)=$ob->is_status;
is_zero ($in);					# 287
is_ok ($out == 20);				# 288
is_ok ($blk == 1);				# 289
is_zero ($err);					# 290

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_ok ($pass);					# 291
is_zero ($in);					# 292
is_ok ($in2 eq "");				# 293
$tock=Win32::GetTickCount();			# expect about 2 seconds
$out=$tock - $tick;
is_bad (($out < 1800) or ($out > 2400));	# 294
print "<2000> elapsed time=$out\n";
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 295

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);		# double check ok?
is_ok ($pass);					# 296
is_zero ($in);					# 297
is_ok ($in2 eq "");				# 298

sleep 1;
($pass, $out) = $ob->write_done(0);
is_ok ($pass);					# 299
is_zero ($out);					# 300
$tock=Win32::GetTickCount();			# expect about 4 seconds
$out=$tock - $tick;
is_bad (($out < 3800) or ($out > 4400));	# 301
print "<4000> elapsed time=$out\n";

$tick=Win32::GetTickCount();			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 302
($pass, $in, $in2) = $ob->read_done(0);

is_zero ($pass);				# 303 
is_zero ($in);					# 304
is_ok ($in2 eq "");				# 305

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 306
## print "testing fail message:\n";
$in = $ob->read_bg(10);
is_bad (defined $in);				# 307 - already reading

($pass, $in, $in2) = $ob->read_done(1);
is_ok ($pass);					# 308
is_zero ($in);					# 309 
is_ok ($in2 eq "");				# 310
$tock=Win32::GetTickCount();			# expect 1.5 seconds
$out=$tock - $tick;
is_bad (($out < 1300) or ($out > 1800));	# 311
print "<1500> elapsed time=$out\n";

$tick=Win32::GetTickCount();			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 312
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 313
is_zero ($in);					# 314
is_ok ($in2 eq "");				# 315

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 316 
is_ok (scalar $ob->purge_rx);			# 317 
($pass, $in, $in2) = $ob->read_done(1);
is_ok (scalar $ob->purge_rx);			# 318 
if (Win32::IsWinNT()) {
    is_zero ($pass);				# 319 
}
else {
    is_ok ($pass);				# 319 
}
is_zero ($in);					# 320 
is_ok ($in2 eq "");				# 321
$tock=Win32::GetTickCount();			# expect 1 second
$out=$tock - $tick;
is_bad (($out < 900) or ($out > 1200));		# 322
print "<1000> elapsed time=$out\n";

is_zero ($ob->write_bg($e));			# 323
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 324

sleep 1;
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 325
is_ok (scalar $ob->purge_tx);			# 326 
($pass, $out) = $ob->write_done(1);
is_ok (scalar $ob->purge_tx);			# 327 
if (Win32::IsWinNT()) {
    is_zero ($pass);				# 328 
}
else {
    is_ok ($pass);				# 328 
}
$tock=Win32::GetTickCount();			# expect 2 seconds
$out=$tock - $tick;
is_bad (($out < 1900) or ($out > 2200));	# 329
print "<2000> elapsed time=$out\n";

$tick=Win32::GetTickCount();			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 330
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 331
is_zero ($ob->write_bg($e));			# 332
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 333

sleep 1;
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 334

($pass, $in, $in2) = $ob->read_done(1);
is_ok ($pass);					# 335 
is_zero ($in);					# 336
is_ok ($in2 eq "");				# 337
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 338
$tock=Win32::GetTickCount();			# expect 1.5 seconds
$out=$tock - $tick;
is_bad (($out < 1300) or ($out > 1800));	# 339
print "<1500> elapsed time=$out\n";

($pass, $out) = $ob->write_done(1);
is_ok ($pass);					# 340
$tock=Win32::GetTickCount();			# expect 2.5 seconds
$out=$tock - $tick;
is_bad (($out < 2300) or ($out > 2800));	# 341
print "<2500> elapsed time=$out\n";

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(1 == $ob->user_msg);			# 342
is_zero(scalar $ob->user_msg(0));		# 343
is_ok(1 == $ob->user_msg(1));			# 344
is_ok(1 == $ob->error_msg);			# 345
is_zero(scalar $ob->error_msg(0));		# 346
is_ok(1 == $ob->error_msg(1));			# 347

# 348 - 3xx Test and Normal "lookclear"

is_ok ($ob->stty_echo(0) == 0);			# 348
is_ok ($ob->lookclear("Before\nAfter") == 1);	# 349
is_ok ($ob->lookfor eq "Before");		# 350

($in, $out, $patt) = $ob->lastlook;
is_ok ($in eq "\n");				# 351
is_ok ($out eq "After");			# 352
is_ok ($patt eq "\n");				# 353

@opts = $ob->are_match ("B*e","ab..ef","-re","12..56","END");
is_ok ($#opts == 4);				# 354
is_ok ($opts[2] eq "-re");			# 355
is_ok ($ob->lookclear("Good Bye, the END, Hello") == 1);	# 356
is_ok ($ob->lookfor eq "Good Bye, the ");	# 357

($in, $out, $patt) = $ob->lastlook;
is_ok ($in eq "END");				# 358
is_ok ($out eq ", Hello");			# 359
is_ok ($patt eq "END");				# 360

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->lookclear("Good B*e, abcdef, 123456") == 1);	# 361
is_ok ($ob->lookfor eq "Good ");		# 362

($in, $out, $patt) = $ob->lastlook;
is_ok ($in eq "B*e");				# 363
is_ok ($out eq ", abcdef, 123456");		# 364
is_ok ($patt eq "B*e");				# 365

is_ok ($ob->lookfor eq ", abcdef, ");		# 366

($in, $out, $patt) = $ob->lastlook;
is_ok ($in eq "123456");			# 367
is_ok ($out eq "");				# 368
is_ok ($patt eq "12..56");			# 369

@necessary_param = Win32::SerialPort->set_test_mode_active(0);

is_bad ($ob->lookclear("Good\nBye"));		# 370
is_ok ($ob->lookfor eq "");			# 371
($in, $out, $patt) = $ob->lastlook;
is_ok ($in eq "");				# 372
is_ok ($out eq "");				# 373
is_ok ($patt eq "");				# 374

undef $ob;
