#! perl -w

use lib './lib','../lib'; # can run from here or distribution base

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test?.t'
# `perl test?.t time' pauses `time' seconds (1..5) between pages

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..357\n"; }
END {print "not ok 1\n" unless $loaded;}
use AltPort 0.13;		# check inheritance & export
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

#### 3 - 24: Check Port Capabilities Match Save

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

print "Defaults for stty and lookfor\n";

@opts = $ob->are_match;
is_ok ($#opts == 0);				# 27
is_ok ($opts[0] eq "\n");			# 28
is_ok ($ob->lookclear == 1);			# 29
is_ok ($ob->is_prompt eq "");			# 30
is_ok ($ob->lookfor eq "");			# 31

($in, $out) = $ob->lastlook;
is_ok ($in eq "");				# 32
is_ok ($out eq "");				# 33

is_ok ($ob->stty_intr eq "\cC");		# 34
is_ok ($ob->stty_quit eq "\cD");		# 35
is_ok ($ob->stty_eof eq "\cZ");			# 36
is_ok ($ob->stty_eol eq "\cJ");			# 37
is_ok ($ob->stty_erase eq "\cH");		# 38
is_ok ($ob->stty_kill eq "\cU");		# 39

my $space76 = " "x76;
my $cstring = "\r$space76\r";
is_ok ($ob->stty_clear eq $cstring);		# 40
is_ok ($ob->stty_bsdel eq "\cH \cH");		# 41

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->is_stty_intr == 3);			# 42
is_ok ($ob->is_stty_quit == 4);			# 43
is_ok ($ob->is_stty_eof == 26);			# 44
is_ok ($ob->is_stty_eol == 10);			# 45
is_ok ($ob->is_stty_erase == 8);		# 46
is_ok ($ob->is_stty_kill == 21);		# 47

is_ok ($ob->stty_echo == 1);			# 48
is_ok ($ob->stty_echoe == 1);			# 49
is_ok ($ob->stty_echok == 1);			# 50
is_ok ($ob->stty_echonl == 0);			# 51
is_ok ($ob->stty_echoke == 1);			# 52
is_ok ($ob->stty_echoctl == 0);			# 53
is_ok ($ob->stty_istrip == 0);			# 54
is_ok ($ob->stty_icrnl == 1);			# 55
is_ok ($ob->stty_ocrnl == 0);			# 56
is_ok ($ob->stty_igncr == 0);			# 57
is_ok ($ob->stty_inlcr == 0);			# 58
is_ok ($ob->stty_onlcr == 1);			# 59
is_ok ($ob->stty_isig == 0);			# 60
is_ok ($ob->stty_icanon == 1);			# 61

print "Change all the parameters\n";

#### 62 - 120: Modify All Port Capabilities

is_ok ($ob->is_xon_char(1) == 0x01);		# 62

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->is_xoff_char(2) == 0x02);		# 63

$pass = $ob->can_spec_char;			# generic port can't set
if ($pass) {
    is_ok ($ob->is_eof_char(4) == 0x04);	# 64
    is_ok ($ob->is_event_char(3) == 0x03);	# 65
    is_ok ($ob->is_error_char(5) == 5);		# 66
}
else {
    is_ok ($ob->is_eof_char(4) == 0);		# 64
    is_ok ($ob->is_event_char(3) == 0);		# 65
    is_ok ($ob->is_error_char(5) == 0);		# 66
}

is_ok ($ob->is_baudrate(1200) == 1200);		# 67
is_ok ($ob->is_parity("odd") eq "odd");		# 68
is_ok ($ob->is_databits(7) == 7);		# 69
is_ok ($ob->is_stopbits(2) == 2);		# 70
is_ok ($ob->is_handshake("xoff") eq "xoff");	# 71
is_ok ($ob->is_read_interval(0) == 0x0);	# 72
is_ok ($ob->is_read_const_time(1000) == 1000);	# 73
is_ok ($ob->is_read_char_time(50) == 50);	# 74
is_ok ($ob->is_write_const_time(2000) == 2000);	# 75
is_ok ($ob->is_write_char_time(75) == 75);	# 76

($in, $out)= $ob->buffers(8092, 1024);
is_ok (8092 == $ob->is_read_buf);		# 77
is_ok (1024 == $ob->is_write_buf);		# 78

is_ok ($ob->alias("oddPort") eq "oddPort");	# 79
is_ok ($ob->is_xoff_limit(45) == 45);		# 80

$pass = $ob->can_parity_enable;
if ($pass) {
    is_ok (scalar $ob->is_parity_enable(1));	# 81
}
else {
    is_zero (scalar $ob->is_parity_enable);	# 81
}

is_ok ($ob->is_xon_limit(90) == 90);		# 82
is_zero ($ob->user_msg(0));			# 83
is_zero ($ob->error_msg(0));			# 84

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

@opts = $ob->are_match ("END","Bye");
is_ok ($#opts == 1);				# 85
is_ok ($opts[0] eq "END");			# 86
is_ok ($opts[1] eq "Bye");			# 87
is_ok ($ob->stty_echo(0) == 0);			# 88
is_ok ($ob->lookclear("Good Bye, Hello") == 1);	# 89
is_ok ($ob->is_prompt("Hi:") eq "Hi:");		# 90
is_ok ($ob->lookfor eq "Good ");		# 91

($in, $out) = $ob->lastlook;
is_ok ($in eq "Bye");				# 92
is_ok ($out eq ", Hello");			# 93

is_ok ($ob->stty_intr("a") eq "a");		# 94
is_ok ($ob->stty_quit("b") eq "b");		# 95
is_ok ($ob->stty_eof("c") eq "c");		# 96
is_ok ($ob->stty_eol("d") eq "d");		# 97
is_ok ($ob->stty_erase("e") eq "e");		# 98
is_ok ($ob->stty_kill("f") eq "f");		# 99

is_ok ($ob->is_stty_intr == 97);		# 100
is_ok ($ob->is_stty_quit == 98);		# 101
is_ok ($ob->is_stty_eof == 99);			# 102

is_ok ($ob->is_stty_eol == 100);		# 103
is_ok ($ob->is_stty_erase == 101);		# 104
is_ok ($ob->is_stty_kill == 102);		# 105

is_ok ($ob->stty_clear("g") eq "g");		# 106
is_ok ($ob->stty_bsdel("h") eq "h");		# 107

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty_echoe(0) == 0);		# 108
is_ok ($ob->stty_echok(0) == 0);		# 109
is_ok ($ob->stty_echonl(1) == 1);		# 110
is_ok ($ob->stty_echoke(0) == 0);		# 111
is_ok ($ob->stty_echoctl(1) == 1);		# 112
is_ok ($ob->stty_istrip(1) == 1);		# 113
is_ok ($ob->stty_icrnl(0) == 0);		# 114
is_ok ($ob->stty_ocrnl(1) == 1);		# 115
is_ok ($ob->stty_igncr(1) == 1);		# 116
is_ok ($ob->stty_inlcr(1) == 1);		# 117
is_ok ($ob->stty_onlcr(0) == 0);		# 118
is_ok ($ob->stty_isig(1) == 1);			# 119
is_ok ($ob->stty_icanon(0) == 0);		# 120

is_ok ($ob->lookclear == 1);			# 121
is_ok ($ob->is_prompt eq "Hi:");		# 122
is_ok ($ob->is_prompt("") eq "");		# 123
is_ok ($ob->lookfor eq "");			# 124

($in, $out) = $ob->lastlook;
is_ok ($in eq "");				# 125
is_ok ($out eq "");				# 126

#### 127 - 180: Check Port Capabilities Match Changes

is_ok ($ob->is_xon_char == 0x01);		# 127
is_ok ($ob->is_xoff_char == 0x02);		# 128

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

$pass = $ob->can_spec_char;			# generic port can't set
if ($pass) {
    is_ok ($ob->is_eof_char == 0x04);		# 129
    is_ok ($ob->is_event_char == 0x03);		# 130
    is_ok ($ob->is_error_char == 5);		# 131
}
else {
    is_ok ($ob->is_eof_char == 0);		# 129
    is_ok ($ob->is_event_char == 0);		# 130
    is_ok ($ob->is_error_char == 0);		# 131
}
is_ok ($ob->is_baudrate == 1200);		# 132
is_ok ($ob->is_parity eq "odd");		# 133
is_ok ($ob->is_databits == 7);			# 134
is_ok ($ob->is_stopbits == 2);			# 135
is_ok ($ob->is_handshake eq "xoff");		# 136
is_ok ($ob->is_read_interval == 0x0);		# 137
is_ok ($ob->is_read_const_time == 1000);	# 138
is_ok ($ob->is_read_char_time == 50);		# 139
is_ok ($ob->is_write_const_time == 2000);	# 140
is_ok ($ob->is_write_char_time == 75);		# 141

($in, $out)= $ob->are_buffers;
is_ok (8092 == $in);				# 142
is_ok (1024 == $out);				# 143
is_ok ($ob->alias eq "oddPort");		# 144

$pass = $ob->can_parity_enable;
if ($pass) {
    is_ok (scalar $ob->is_parity_enable);	# 145
}
else {
    is_zero (scalar $ob->is_parity_enable);	# 145
}

is_ok ($ob->is_xoff_limit == 45);		# 146
is_ok ($ob->is_xon_limit == 90);		# 147
is_zero ($ob->user_msg);			# 148
is_zero ($ob->error_msg);			# 149

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

@opts = $ob->are_match;
is_ok ($#opts == 1);				# 150
is_ok ($opts[0] eq "END");			# 151
is_ok ($opts[1] eq "Bye");			# 152

is_ok ($ob->stty_intr eq "a");			# 153
is_ok ($ob->stty_quit eq "b");			# 154
is_ok ($ob->stty_eof eq "c");			# 155
is_ok ($ob->stty_eol eq "d");			# 156
is_ok ($ob->stty_erase eq "e");			# 157
is_ok ($ob->stty_kill eq "f");			# 158

is_ok ($ob->is_stty_intr == 97);		# 159
is_ok ($ob->is_stty_quit == 98);		# 160
is_ok ($ob->is_stty_eof == 99);			# 161

is_ok ($ob->is_stty_eol == 100);		# 162
is_ok ($ob->is_stty_erase == 101);		# 163
is_ok ($ob->is_stty_kill == 102);		# 164

is_ok ($ob->stty_clear eq "g");			# 165
is_ok ($ob->stty_bsdel eq "h");			# 166

is_ok ($ob->stty_echo == 0);			# 167
is_ok ($ob->stty_echoe == 0);			# 168
is_ok ($ob->stty_echok == 0);			# 169
is_ok ($ob->stty_echonl == 1);			# 170
is_ok ($ob->stty_echoke == 0);			# 171
is_ok ($ob->stty_echoctl == 1);			# 172

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty_istrip == 1);			# 173
is_ok ($ob->stty_icrnl == 0);			# 174
is_ok ($ob->stty_ocrnl == 1);			# 175
is_ok ($ob->stty_igncr == 1);			# 176
is_ok ($ob->stty_inlcr == 1);			# 177
is_ok ($ob->stty_onlcr == 0);			# 178
is_ok ($ob->stty_isig == 1);			# 179
is_ok ($ob->stty_icanon == 0);			# 180

print "Restore all the parameters\n";

is_ok ($ob->restart($cfgfile));			# 181

#### 182 - xx: Check Port Capabilities Match Original

is_ok ($ob->is_xon_char == 0x11);		# 182
is_ok ($ob->is_xoff_char == 0x13);		# 183
is_ok ($ob->is_eof_char == 0);			# 184
is_ok ($ob->is_event_char == 0);		# 185
is_ok ($ob->is_error_char == 0);		# 186
is_ok ($ob->is_baudrate == 9600);		# 187
is_ok ($ob->is_parity eq "none");		# 188
is_ok ($ob->is_databits == 8);			# 189
is_ok ($ob->is_stopbits == 1);			# 190
is_ok ($ob->is_handshake eq "none");		# 191
is_ok ($ob->is_read_interval == 0xffffffff);	# 192
is_ok ($ob->is_read_const_time == 0);		# 193

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->is_read_char_time == 0);		# 194
is_ok ($ob->is_write_const_time == 200);	# 195
is_ok ($ob->is_write_char_time == 10);		# 196

($in, $out)= $ob->are_buffers;
is_ok (4096 == $in);				# 197
is_ok (4096 == $out);				# 198

is_ok ($ob->alias eq "AltPort");		# 199
is_ok ($ob->is_binary == 1);			# 200
is_zero (scalar $ob->is_parity_enable);		# 201
is_ok ($ob->is_xoff_limit == 200);		# 202
is_ok ($ob->is_xon_limit == 100);		# 203
is_ok ($ob->user_msg == 1);			# 204
is_ok ($ob->error_msg == 1);			# 205

@opts = $ob->are_match("\n");
is_ok ($#opts == 0);				# 206
is_ok ($opts[0] eq "\n");			# 207
is_ok ($ob->lookclear == 1);			# 208
is_ok ($ob->is_prompt eq "");			# 209
is_ok ($ob->lookfor eq "");			# 210

($in, $out) = $ob->lastlook;
is_ok ($in eq "");				# 211
is_ok ($out eq "");				# 212

is_ok ($ob->stty_intr eq "\cC");		# 213
is_ok ($ob->stty_quit eq "\cD");		# 214
is_ok ($ob->stty_eof eq "\cZ");			# 215

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty_eol eq "\cJ");			# 216
is_ok ($ob->stty_erase eq "\cH");		# 217
is_ok ($ob->stty_kill eq "\cU");		# 218
is_ok ($ob->stty_clear eq $cstring);		# 219
is_ok ($ob->stty_bsdel eq "\cH \cH");		# 220

is_ok ($ob->is_stty_intr == 3);			# 221
is_ok ($ob->is_stty_quit == 4);			# 222
is_ok ($ob->is_stty_eof == 26);			# 223
is_ok ($ob->is_stty_eol == 10);			# 224
is_ok ($ob->is_stty_erase == 8);		# 225
is_ok ($ob->is_stty_kill == 21);		# 226

is_ok ($ob->stty_echo == 1);			# 227
is_ok ($ob->stty_echoe == 1);			# 228
is_ok ($ob->stty_echok == 1);			# 229
is_ok ($ob->stty_echonl == 0);			# 230
is_ok ($ob->stty_echoke == 1);			# 231
is_ok ($ob->stty_echoctl == 0);			# 232
is_ok ($ob->stty_istrip == 0);			# 233
is_ok ($ob->stty_icrnl == 1);			# 234
is_ok ($ob->stty_ocrnl == 0);			# 235
is_ok ($ob->stty_igncr == 0);			# 236
is_ok ($ob->stty_inlcr == 0);			# 237

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}
is_ok ($ob->stty_onlcr == 1);			# 238
is_ok ($ob->stty_isig == 0);			# 239
is_ok ($ob->stty_icanon == 1);			# 240


## 241 - 251: Status

is_ok (4 == scalar (@opts = $ob->is_status));	# 241

# for an unconnected port, should be $in=0, $out=0, $blk=0, $err=0

($blk, $in, $out, $err)=@opts;
is_ok (defined $blk);				# 242
is_zero ($in);					# 243
is_zero ($out);					# 244
is_zero ($blk);					# 245
if ($blk) { printf "status: blk=%lx\n", $blk; }
is_zero ($err);					# 246

($blk, $in, $out, $err)=$ob->is_status(0x150);	# test only
is_ok ($err == 0x150);				# 247
### printf "error: err=%lx\n", $err;

($blk, $in, $out, $err)=$ob->is_status(0x0f);	# test only
is_ok ($err == 0x15f);				# 248

print "    Force all Status Errors\n";

($blk, $in, $out, $err)=$ob->status;
is_ok ($err == 0x15f);				# 249

is_ok ($ob->reset_error == 0x15f);		# 250

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

($blk, $in, $out, $err)=$ob->is_status;
is_zero ($err);					# 251

# 252 - 254: "Instant" return for read_interval=0xffffffff

$tick=Win32::GetTickCount();
($in, $in2) = $ob->read(10);
$tock=Win32::GetTickCount();

is_zero ($in);					# 252
is_bad ($in2);					# 253
$out=$tock - $tick;
is_ok ($out < 100);				# 254
print "<0> elapsed time=$out\n";

# 255 - 263: 2 Second Constant Timeout

is_ok (2000 == $ob->is_read_const_time(2000));	# 255
is_zero ($ob->is_read_interval(0));		# 256
is_ok (100 == $ob->is_read_char_time(100));	# 257
is_zero ($ob->is_read_const_time(0));		# 258
is_zero ($ob->is_read_char_time(0));		# 259

is_ok (0xffffffff == $ob->is_read_interval(0xffffffff));	#260
is_ok (2000 == $ob->is_write_const_time(2000));	# 261
is_zero ($ob->is_write_char_time(0));		# 262
is_ok ("rts" eq $ob->is_handshake("rts"));	# 263 ; so it blocks

# 264 - 265

$e="12345678901234567890";

$tick=Win32::GetTickCount();
is_zero ($ob->write($e));			# 264
$tock=Win32::GetTickCount();

$out=$tock - $tick;
is_bad (($out < 1800) or ($out > 2400));	# 265
print "<2000> elapsed time=$out\n";

# 266 - 268: 3.5 Second Timeout Constant+Character

is_ok (75 ==$ob->is_write_char_time(75));	# 266

$tick=Win32::GetTickCount();
is_zero ($ob->write($e));			# 267
$tock=Win32::GetTickCount();

$out=$tock - $tick;
is_bad (($out < 3300) or ($out > 3900));	# 268
print "<3500> elapsed time=$out\n";


# 269 - 277: 2.5 Second Read Constant Timeout

is_ok (2500 == $ob->is_read_const_time(2500));	# 269
is_zero ($ob->is_read_interval(0));		# 270
is_ok (scalar $ob->purge_all);			# 271

$tick=Win32::GetTickCount();
$in = $ob->read_bg(10);
$tock=Win32::GetTickCount();

is_zero ($in);					# 272
$out=$tock - $tick;
is_ok ($out < 100);				# 273
print "<0> elapsed time=$out\n";

($pass, $in, $in2) = $ob->read_done(0);
$tock=Win32::GetTickCount();

is_zero ($pass);				# 274
is_zero ($in);					# 275
is_ok ($in2 eq "");				# 276
$out=$tock - $tick;
is_ok ($out < 100);				# 277

print "A Series of 1 Second Groups with Background I/O\n";

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 278
is_zero ($in);					# 279
is_ok ($in2 eq "");				# 280
is_zero ($ob->write_bg($e));			# 281
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 282
is_zero ($out);					# 283

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 284
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 285

($blk, $in, $out, $err)=$ob->is_status;
is_zero ($in);					# 286
is_ok ($out == 20);				# 287
is_ok ($blk == 1);				# 288
is_zero ($err);					# 289

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_ok ($pass);					# 290
is_zero ($in);					# 291
is_ok ($in2 eq "");				# 292
$tock=Win32::GetTickCount();			# expect about 3 seconds
$out=$tock - $tick;
is_bad (($out < 2800) or ($out > 3400));	# 293
print "<3000> elapsed time=$out\n";
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 294

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);		# double check ok?
is_ok ($pass);					# 295
is_zero ($in);					# 296
is_ok ($in2 eq "");				# 297
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 298

sleep 1;
($pass, $out) = $ob->write_done(0);
is_ok ($pass);					# 299
is_zero ($out);					# 300
$tock=Win32::GetTickCount();			# expect about 5 seconds
$out=$tock - $tick;
is_bad (($out < 4800) or ($out > 5400));	# 301
print "<5000> elapsed time=$out\n";

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

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 308
($pass, $in, $in2) = $ob->read_done(1);
is_ok ($pass);					# 309
is_zero ($in);					# 310 
is_ok ($in2 eq "");				# 311
$tock=Win32::GetTickCount();			# expect 2.5 seconds
$out=$tock - $tick;
is_bad (($out < 2300) or ($out > 2800));	# 312
print "<2500> elapsed time=$out\n";

$tick=Win32::GetTickCount();			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 313
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 314
is_zero ($in);					# 315
is_ok ($in2 eq "");				# 316

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 317 
is_ok (scalar $ob->purge_rx);			# 318 
($pass, $in, $in2) = $ob->read_done(1);
is_ok (scalar $ob->purge_rx);			# 319 
if (Win32::IsWinNT()) {
    is_zero ($pass);				# 320 
}
else {
    is_ok ($pass);				# 320 
}
is_zero ($in);					# 321 
is_ok ($in2 eq "");				# 322
$tock=Win32::GetTickCount();			# expect 1 second
$out=$tock - $tick;
is_bad (($out < 900) or ($out > 1200));		# 323
print "<1000> elapsed time=$out\n";

is_zero ($ob->write_bg($e));			# 324
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 325

sleep 1;
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 326
is_ok (scalar $ob->purge_tx);			# 327 
($pass, $out) = $ob->write_done(1);
is_ok (scalar $ob->purge_tx);			# 328 
if (Win32::IsWinNT()) {
    is_zero ($pass);				# 329 
}
else {
    is_ok ($pass);				# 329 
}
$tock=Win32::GetTickCount();			# expect 2 seconds
$out=$tock - $tick;
is_bad (($out < 1900) or ($out > 2200));	# 330
print "<2000> elapsed time=$out\n";

$tick=Win32::GetTickCount();			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 331
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 332
is_zero ($ob->write_bg($e));			# 333
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 334

sleep 1;
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 335

($pass, $in, $in2) = $ob->read_done(1);
is_ok ($pass);					# 336 
is_zero ($in);					# 337
is_ok ($in2 eq "");				# 338
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 339
$tock=Win32::GetTickCount();			# expect 2.5 seconds
$out=$tock - $tick;
is_bad (($out < 2300) or ($out > 2800));	# 340
print "<2500> elapsed time=$out\n";

($pass, $out) = $ob->write_done(1);
is_ok ($pass);					# 341
$tock=Win32::GetTickCount();			# expect 3.5 seconds
$out=$tock - $tick;
is_bad (($out < 3300) or ($out > 3800));	# 342
print "<3500> elapsed time=$out\n";

is_ok(1 == $ob->user_msg);			# 343
is_zero(scalar $ob->user_msg(0));		# 344
is_ok(1 == $ob->user_msg(1));			# 345
is_ok(1 == $ob->error_msg);			# 346
is_zero(scalar $ob->error_msg(0));		# 347
is_ok(1 == $ob->error_msg(1));			# 348

# 349 - 352 Test and Normal "lookclear"

is_ok ($ob->stty_echo(0) == 0);			# 349
is_ok ($ob->lookclear("Before\nAfter") == 1);	# 350
is_ok ($ob->lookfor eq "Before");		# 351

($in, $out) = $ob->lastlook;
is_ok ($in eq "\n");				# 352
is_ok ($out eq "After");			# 353

@necessary_param = Win32::SerialPort->set_test_mode_active(0);

is_bad ($ob->lookclear("Good\nBye"));		# 354
is_ok ($ob->lookfor eq "");			# 355
($in, $out) = $ob->lastlook;
is_ok ($in eq "");				# 356
is_ok ($out eq "");				# 357

undef $ob;
