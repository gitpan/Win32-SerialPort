#! perl -w

use lib '..','./lib','../lib'; # can run from here or distribution base
require 5.003;

# Before installation is performed this script should be runnable with
# `perl test4.t time' which pauses `time' seconds (0..5) between pages

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..488\n"; }
END {print "not ok 1\n" unless $loaded;}
use AltPort 0.15;		# check inheritance & export
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
if (exists $ENV{Makefile_Test_Port}) {
    $file = $ENV{Makefile_Test_Port};
}

my $naptime = 0;	# pause between output pages
if (@ARGV) {
    $naptime = shift @ARGV;
    unless ($naptime =~ /^[0-5]$/) {
	die "Usage: perl test?.t [ page_delay (0..5) ] [ COMx ]";
    }
}
if (@ARGV) {
    $file = shift @ARGV;
}
my $cfgfile = $file."_test.cfg";

my $fault = 0;
my $tc = 2;		# next test number
my $ob;
my $pass;
my $fail;
my $in;
my $in2;
my $instead;
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
is_zero (scalar $ob->is_parity_enable);		# 22

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->is_xoff_limit == 200);		# 23
is_ok ($ob->is_xon_limit == 100);		# 24
is_ok ($ob->user_msg == 1);			# 25
is_ok ($ob->error_msg == 1);			# 26

### 27 - 65: Defaults for stty and lookfor

@opts = $ob->are_match;
is_ok ($#opts == 0);				# 27
is_ok ($opts[0] eq "\n");			# 28
is_ok ($ob->lookclear == 1);			# 29
is_ok ($ob->is_prompt eq "");			# 30
is_ok ($ob->lookfor eq "");			# 31
is_ok ($ob->streamline eq "");			# 32

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 33
is_ok ($out eq "");				# 34
is_ok ($patt eq "");				# 35
is_ok ($instead eq "");				# 36
is_ok ($ob->matchclear eq "");			# 37

is_ok ($ob->stty_intr eq "\cC");		# 38
is_ok ($ob->stty_quit eq "\cD");		# 39
is_ok ($ob->stty_eof eq "\cZ");			# 40
is_ok ($ob->stty_eol eq "\cJ");			# 41
is_ok ($ob->stty_erase eq "\cH");		# 42
is_ok ($ob->stty_kill eq "\cU");		# 43
is_ok ($ob->stty_bsdel eq "\cH \cH");		# 44

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

my $space76 = " "x76;
my $cstring = "\r$space76\r";
is_ok ($ob->stty_clear eq $cstring);		# 45

is_ok ($ob->is_stty_intr == 3);			# 46
is_ok ($ob->is_stty_quit == 4);			# 47
is_ok ($ob->is_stty_eof == 26);			# 48
is_ok ($ob->is_stty_eol == 10);			# 49
is_ok ($ob->is_stty_erase == 8);		# 50
is_ok ($ob->is_stty_kill == 21);		# 51

is_ok ($ob->stty_echo == 0);			# 52
is_ok ($ob->stty_echoe == 1);			# 53
is_ok ($ob->stty_echok == 1);			# 54
is_ok ($ob->stty_echonl == 0);			# 55
is_ok ($ob->stty_echoke == 1);			# 56
is_ok ($ob->stty_echoctl == 0);			# 57
is_ok ($ob->stty_istrip == 0);			# 58
is_ok ($ob->stty_icrnl == 0);			# 59
is_ok ($ob->stty_ocrnl == 0);			# 60
is_ok ($ob->stty_igncr == 0);			# 61
is_ok ($ob->stty_inlcr == 0);			# 62
is_ok ($ob->stty_onlcr == 1);			# 63
is_ok ($ob->stty_opost == 0);			# 64
is_ok ($ob->stty_isig == 0);			# 65
is_ok ($ob->stty_icanon == 0);			# 66

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

print "Change all the parameters\n";

#### 67 - 213: Modify All Port Capabilities

is_ok ($ob->is_xon_char(1) == 0x01);		# 67

is_ok ($ob->is_xoff_char(2) == 0x02);		# 68

$pass = $ob->can_spec_char;			# generic port can't set
if ($pass) {
    is_ok ($ob->is_eof_char(4) == 0x04);	# 69
    is_ok ($ob->is_event_char(3) == 0x03);	# 70
    is_ok ($ob->is_error_char(5) == 5);		# 71
}
else {
    is_ok ($ob->is_eof_char(4) == 0);		# 69
    is_ok ($ob->is_event_char(3) == 0);		# 70
    is_ok ($ob->is_error_char(5) == 0);		# 71
}

is_ok ($ob->is_baudrate(1200) == 1200);		# 72
is_ok ($ob->is_parity("odd") eq "odd");		# 73
is_ok ($ob->is_databits(7) == 7);		# 74
is_ok ($ob->is_stopbits(2) == 2);		# 75
is_ok ($ob->is_handshake("xoff") eq "xoff");	# 76
is_ok ($ob->is_read_interval(0) == 0x0);	# 77
is_ok ($ob->is_read_const_time(1000) == 1000);	# 78
is_ok ($ob->is_read_char_time(50) == 50);	# 79
is_ok ($ob->is_write_const_time(2000) == 2000);	# 80
is_ok ($ob->is_write_char_time(75) == 75);	# 81

($in, $out)= $ob->buffers(8092, 1024);
is_ok (8092 == $ob->is_read_buf);		# 82
is_ok (1024 == $ob->is_write_buf);		# 83

is_ok ($ob->alias("oddPort") eq "oddPort");	# 84
is_ok ($ob->is_xoff_limit(45) == 45);		# 85

$pass = $ob->can_parity_enable;
if ($pass) {
    is_ok (scalar $ob->is_parity_enable(1));	# 86
}
else {
    is_zero (scalar $ob->is_parity_enable);	# 86
}

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->is_xon_limit(90) == 90);		# 87
is_zero ($ob->user_msg(0));			# 88
is_zero ($ob->error_msg(0));			# 89

@opts = $ob->are_match ("END","Bye");
is_ok ($#opts == 1);				# 90
is_ok ($opts[0] eq "END");			# 91
is_ok ($opts[1] eq "Bye");			# 92
is_ok ($ob->stty_echo(0) == 0);			# 93
is_ok ($ob->lookclear("Good Bye, Hello") == 1);	# 94
is_ok ($ob->is_prompt("Hi:") eq "Hi:");		# 95
is_ok ($ob->lookfor eq "Good ");		# 96

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 97
is_ok ($out eq ", Hello");			# 98
is_ok ($patt eq "Bye");				# 99
is_ok ($instead eq "");				# 100
is_ok ($ob->matchclear eq "Bye");		# 101
is_ok ($ob->matchclear eq "");			# 102

is_ok ($ob->lookclear("Bye, Bye, Love. The END has come") == 1);	# 103
is_ok ($ob->lookfor eq "");			# 104

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 105
is_ok ($out eq ", Bye, Love. The END has come");# 106

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($patt eq "Bye");				# 107
is_ok ($instead eq "");				# 108
is_ok ($ob->matchclear eq "Bye");		# 109

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 110
is_ok ($out eq ", Bye, Love. The END has come");# 111
is_ok ($patt eq "Bye");				# 112
is_ok ($instead eq "");				# 113

is_ok ($ob->lookfor eq ", ");			# 114
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 115
is_ok ($out eq ", Love. The END has come");	# 116
is_ok ($patt eq "Bye");				# 117
is_ok ($instead eq "");				# 118
is_ok ($ob->matchclear eq "Bye");		# 119

is_ok ($ob->lookfor eq ", Love. The ");		# 120
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 121
is_ok ($out eq " has come");			# 122
is_ok ($patt eq "END");				# 123
is_ok ($instead eq "");				# 124
is_ok ($ob->matchclear eq "END");		# 125
is_ok ($ob->lookfor eq "");			# 126
is_ok ($ob->matchclear eq "");			# 127

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 128
is_ok ($patt eq "");				# 129
is_ok ($instead eq " has come");		# 130

is_ok ($ob->lookclear("First\nSecond\nThe END") == 1);	# 131
is_ok ($ob->lookfor eq "First\nSecond\nThe ");	# 132
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 133
is_ok ($out eq "");				# 134
is_ok ($patt eq "END");				# 135
is_ok ($instead eq "");				# 136

is_ok ($ob->lookclear("Good Bye, Hello") == 1);	# 137
is_ok ($ob->streamline eq "Good ");		# 138

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 139
is_ok ($out eq ", Hello");			# 140
is_ok ($patt eq "Bye");				# 141
is_ok ($instead eq "");				# 142

is_ok ($ob->lookclear("Bye, Bye, Love. The END has come") == 1);	# 143
is_ok ($ob->streamline eq "");			# 144

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 145
is_ok ($out eq ", Bye, Love. The END has come");# 146

is_ok ($patt eq "Bye");				# 147
is_ok ($instead eq "");				# 148
is_ok ($ob->matchclear eq "Bye");		# 149

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 150
is_ok ($out eq ", Bye, Love. The END has come");# 151
is_ok ($patt eq "Bye");				# 152
is_ok ($instead eq "");				# 153

is_ok ($ob->streamline eq ", ");		# 154
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 155
is_ok ($out eq ", Love. The END has come");	# 156
is_ok ($patt eq "Bye");				# 157
is_ok ($instead eq "");				# 158
is_ok ($ob->matchclear eq "Bye");		# 159

is_ok ($ob->streamline eq ", Love. The ");	# 160
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 161
is_ok ($out eq " has come");			# 162
is_ok ($patt eq "END");				# 163
is_ok ($instead eq "");				# 164
is_ok ($ob->matchclear eq "END");		# 165
is_ok ($ob->streamline eq "");			# 166
is_ok ($ob->matchclear eq "");			# 167

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 168
is_ok ($patt eq "");				# 169
is_ok ($instead eq " has come");		# 170

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->lookclear("First\nSecond\nThe END") == 1);	# 171
is_ok ($ob->streamline eq "First\nSecond\nThe ");	# 172
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 173
is_ok ($out eq "");				# 174
is_ok ($patt eq "END");				# 175
is_ok ($instead eq "");				# 176

is_ok ($ob->stty_intr("a") eq "a");		# 177
is_ok ($ob->stty_quit("b") eq "b");		# 178
is_ok ($ob->stty_eof("c") eq "c");		# 179
is_ok ($ob->stty_eol("d") eq "d");		# 180
is_ok ($ob->stty_erase("e") eq "e");		# 181
is_ok ($ob->stty_kill("f") eq "f");		# 182

is_ok ($ob->is_stty_intr == 97);		# 183
is_ok ($ob->is_stty_quit == 98);		# 184
is_ok ($ob->is_stty_eof == 99);			# 185

is_ok ($ob->is_stty_eol == 100);		# 186
is_ok ($ob->is_stty_erase == 101);		# 187
is_ok ($ob->is_stty_kill == 102);		# 188

is_ok ($ob->stty_clear("g") eq "g");		# 189
is_ok ($ob->stty_bsdel("h") eq "h");		# 190
is_ok ($ob->stty_echoe(0) == 0);		# 191

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty_echok(0) == 0);		# 192
is_ok ($ob->stty_echonl(1) == 1);		# 193
is_ok ($ob->stty_echoke(0) == 0);		# 194
is_ok ($ob->stty_echoctl(1) == 1);		# 195
is_ok ($ob->stty_istrip(1) == 1);		# 196
is_ok ($ob->stty_icrnl(1) == 1);		# 197
is_ok ($ob->stty_ocrnl(1) == 1);		# 198
is_ok ($ob->stty_igncr(1) == 1);		# 199
is_ok ($ob->stty_inlcr(1) == 1);		# 200
is_ok ($ob->stty_onlcr(0) == 0);		# 201
is_ok ($ob->stty_opost(1) == 1);		# 202
is_ok ($ob->stty_isig(1) == 1);			# 203
is_ok ($ob->stty_icanon(1) == 1);		# 204

is_ok ($ob->lookclear == 1);			# 205
is_ok ($ob->is_prompt eq "Hi:");		# 206
is_ok ($ob->is_prompt("") eq "");		# 207
is_ok ($ob->lookfor eq "");			# 208

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 209
is_ok ($out eq "");				# 210
is_ok ($patt eq "");				# 211
is_ok ($instead eq "");				# 212
is_ok ($ob->stty_echo(1) == 1);			# 213

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

#### 214 - 269: Check Port Capabilities Match Changes

is_ok ($ob->is_xon_char == 0x01);		# 214
is_ok ($ob->is_xoff_char == 0x02);		# 215

$pass = $ob->can_spec_char;			# generic port can't set
if ($pass) {
    is_ok ($ob->is_eof_char == 0x04);		# 216
    is_ok ($ob->is_event_char == 0x03);		# 217
    is_ok ($ob->is_error_char == 5);		# 218
}
else {
    is_ok ($ob->is_eof_char == 0);		# 216
    is_ok ($ob->is_event_char == 0);		# 217
    is_ok ($ob->is_error_char == 0);		# 218
}
is_ok ($ob->is_baudrate == 1200);		# 219
is_ok ($ob->is_parity eq "odd");		# 220
is_ok ($ob->is_databits == 7);			# 221
is_ok ($ob->is_stopbits == 2);			# 222
is_ok ($ob->is_handshake eq "xoff");		# 223
is_ok ($ob->is_read_interval == 0x0);		# 224
is_ok ($ob->is_read_const_time == 1000);	# 225
is_ok ($ob->is_read_char_time == 50);		# 226
is_ok ($ob->is_write_const_time == 2000);	# 227
is_ok ($ob->is_write_char_time == 75);		# 228

($in, $out)= $ob->are_buffers;
is_ok (8092 == $in);				# 229
is_ok (1024 == $out);				# 230
is_ok ($ob->alias eq "oddPort");		# 231

$pass = $ob->can_parity_enable;
if ($pass) {
    is_ok (scalar $ob->is_parity_enable);	# 232
}
else {
    is_zero (scalar $ob->is_parity_enable);	# 232
}

is_ok ($ob->is_xoff_limit == 45);		# 233
is_ok ($ob->is_xon_limit == 90);		# 234

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_zero ($ob->user_msg);			# 235
is_zero ($ob->error_msg);			# 236

@opts = $ob->are_match;
is_ok ($#opts == 1);				# 237
is_ok ($opts[0] eq "END");			# 238
is_ok ($opts[1] eq "Bye");			# 239

is_ok ($ob->stty_intr eq "a");			# 240
is_ok ($ob->stty_quit eq "b");			# 241
is_ok ($ob->stty_eof eq "c");			# 242
is_ok ($ob->stty_eol eq "d");			# 243
is_ok ($ob->stty_erase eq "e");			# 244
is_ok ($ob->stty_kill eq "f");			# 245

is_ok ($ob->is_stty_intr == 97);		# 246
is_ok ($ob->is_stty_quit == 98);		# 247
is_ok ($ob->is_stty_eof == 99);			# 248

is_ok ($ob->is_stty_eol == 100);		# 249
is_ok ($ob->is_stty_erase == 101);		# 250
is_ok ($ob->is_stty_kill == 102);		# 251

is_ok ($ob->stty_clear eq "g");			# 252
is_ok ($ob->stty_bsdel eq "h");			# 253

is_ok ($ob->stty_echo == 1);			# 254
is_ok ($ob->stty_echoe == 0);			# 255
is_ok ($ob->stty_echok == 0);			# 256

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty_echonl == 1);			# 257
is_ok ($ob->stty_echoke == 0);			# 258
is_ok ($ob->stty_echoctl == 1);			# 259

is_ok ($ob->stty_istrip == 1);			# 260
is_ok ($ob->stty_icrnl == 1);			# 261
is_ok ($ob->stty_ocrnl == 1);			# 262
is_ok ($ob->stty_igncr == 1);			# 263
is_ok ($ob->stty_inlcr == 1);			# 264
is_ok ($ob->stty_onlcr == 0);			# 265
is_ok ($ob->stty_opost == 1);			# 266
is_ok ($ob->stty_isig == 1);			# 267
is_ok ($ob->stty_icanon == 1);			# 268

print "Restore all the parameters\n";

is_ok ($ob->restart($cfgfile));			# 269

#### 270 - 333: Check Port Capabilities Match Original

is_ok ($ob->is_xon_char == 0x11);		# 270
is_ok ($ob->is_xoff_char == 0x13);		# 271
is_ok ($ob->is_eof_char == 0);			# 272
is_ok ($ob->is_event_char == 0);		# 273
is_ok ($ob->is_error_char == 0);		# 274
is_ok ($ob->is_baudrate == 9600);		# 275
is_ok ($ob->is_parity eq "none");		# 276
is_ok ($ob->is_databits == 8);			# 277

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->is_stopbits == 1);			# 278
is_ok ($ob->is_handshake eq "none");		# 279
is_ok ($ob->is_read_interval == 0xffffffff);	# 280
is_ok ($ob->is_read_const_time == 0);		# 281

is_ok ($ob->is_read_char_time == 0);		# 282
is_ok ($ob->is_write_const_time == 200);	# 283
is_ok ($ob->is_write_char_time == 10);		# 284

($in, $out)= $ob->are_buffers;
is_ok (4096 == $in);				# 285
is_ok (4096 == $out);				# 286

is_ok ($ob->alias eq "AltPort");		# 287
is_ok ($ob->is_binary == 1);			# 288
is_zero (scalar $ob->is_parity_enable);		# 289
is_ok ($ob->is_xoff_limit == 200);		# 290
is_ok ($ob->is_xon_limit == 100);		# 291
is_ok ($ob->user_msg == 1);			# 292
is_ok ($ob->error_msg == 1);			# 293

@opts = $ob->are_match("\n");
is_ok ($#opts == 0);				# 294
is_ok ($opts[0] eq "\n");			# 295
is_ok ($ob->lookclear == 1);			# 296
is_ok ($ob->is_prompt eq "");			# 297
is_ok ($ob->lookfor eq "");			# 298

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 299
is_ok ($out eq "");				# 300
is_ok ($patt eq "");				# 301
is_ok ($instead eq "");				# 302
is_ok ($ob->streamline eq "");			# 303
is_ok ($ob->matchclear eq "");			# 304

is_ok ($ob->stty_intr eq "\cC");		# 305
is_ok ($ob->stty_quit eq "\cD");		# 306
is_ok ($ob->stty_eof eq "\cZ");			# 307
is_ok ($ob->stty_eol eq "\cJ");			# 308
is_ok ($ob->stty_erase eq "\cH");		# 309
is_ok ($ob->stty_kill eq "\cU");		# 310
is_ok ($ob->stty_clear eq $cstring);		# 311
is_ok ($ob->stty_bsdel eq "\cH \cH");		# 312

is_ok ($ob->is_stty_intr == 3);			# 313
is_ok ($ob->is_stty_quit == 4);			# 314
is_ok ($ob->is_stty_eof == 26);			# 315
is_ok ($ob->is_stty_eol == 10);			# 316
is_ok ($ob->is_stty_erase == 8);		# 317
is_ok ($ob->is_stty_kill == 21);		# 318

is_ok ($ob->stty_echo == 0);			# 319
is_ok ($ob->stty_echoe == 1);			# 320

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty_echok == 1);			# 321
is_ok ($ob->stty_echonl == 0);			# 322
is_ok ($ob->stty_echoke == 1);			# 323
is_ok ($ob->stty_echoctl == 0);			# 324
is_ok ($ob->stty_istrip == 0);			# 325

is_ok ($ob->stty_icrnl == 0);			# 326
is_ok ($ob->stty_ocrnl == 0);			# 327
is_ok ($ob->stty_igncr == 0);			# 328
is_ok ($ob->stty_inlcr == 0);			# 329
is_ok ($ob->stty_onlcr == 1);			# 330
is_ok ($ob->stty_opost == 0);			# 331
is_ok ($ob->stty_isig == 0);			# 332
is_ok ($ob->stty_icanon == 0);			# 333


## 334 - 344: Status

is_ok (4 == scalar (@opts = $ob->is_status));	# 334

# for an unconnected port, should be $in=0, $out=0, $blk=0, $err=0

($blk, $in, $out, $err)=@opts;
is_ok (defined $blk);				# 335
is_zero ($in);					# 336
is_zero ($out);					# 337
is_zero ($blk);					# 338
if ($blk) { printf "status: blk=%lx\n", $blk; }
is_zero ($err);					# 339

($blk, $in, $out, $err)=$ob->is_status(0x150);	# test only
is_ok ($err == 0x150);				# 340
### printf "error: err=%lx\n", $err;

($blk, $in, $out, $err)=$ob->is_status(0x0f);	# test only
is_ok ($err == 0x15f);				# 341

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

print "=== Force all Status Errors\n";

($blk, $in, $out, $err)=$ob->status;
is_ok ($err == 0x15f);				# 342

is_ok ($ob->reset_error == 0x15f);		# 343

($blk, $in, $out, $err)=$ob->is_status;
is_zero ($err);					# 344

# 345 - 347: "Instant" return for read_interval=0xffffffff

$tick=Win32::GetTickCount();
($in, $in2) = $ob->read(10);
$tock=Win32::GetTickCount();

is_zero ($in);					# 345
is_bad ($in2);					# 346
$out=$tock - $tick;
is_ok ($out < 100);				# 347
print "<0> elapsed time=$out\n";

# 348 - 356: 1 Second Constant Timeout

is_ok (2000 == $ob->is_read_const_time(2000));	# 348
is_zero ($ob->is_read_interval(0));		# 349
is_ok (100 == $ob->is_read_char_time(100));	# 350
is_zero ($ob->is_read_const_time(0));		# 351
is_zero ($ob->is_read_char_time(0));		# 352

is_ok (0xffffffff == $ob->is_read_interval(0xffffffff));	# 353
is_ok (1000 == $ob->is_write_const_time(1000));	# 354
is_zero ($ob->is_write_char_time(0));		# 355
is_ok ("rts" eq $ob->is_handshake("rts"));	# 356 ; so it blocks

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

# 357 - 358

$e="12345678901234567890";

$tick=Win32::GetTickCount();
is_zero ($ob->write($e));			# 357
$tock=Win32::GetTickCount();

$out=$tock - $tick;
is_bad (($out < 800) or ($out > 1300));		# 358
print "<1000> elapsed time=$out\n";

# 359 - 361: 2.5 Second Timeout Constant+Character

is_ok (75 ==$ob->is_write_char_time(75));	# 359

$tick=Win32::GetTickCount();
is_zero ($ob->write($e));			# 360
$tock=Win32::GetTickCount();

$out=$tock - $tick;
is_bad (($out < 2300) or ($out > 2900));	# 361
print "<2500> elapsed time=$out\n";


# 362 - 370: 1.5 Second Read Constant Timeout

is_ok (1500 == $ob->is_read_const_time(1500));	# 362
is_zero ($ob->is_read_interval(0));		# 263
is_ok (scalar $ob->purge_all);			# 364

$tick=Win32::GetTickCount();
$in = $ob->read_bg(10);
$tock=Win32::GetTickCount();

is_zero ($in);					# 365
$out=$tock - $tick;
is_ok ($out < 100);				# 366
print "<0> elapsed time=$out\n";

($pass, $in, $in2) = $ob->read_done(0);
$tock=Win32::GetTickCount();

is_zero ($pass);				# 367
is_zero ($in);					# 368
is_ok ($in2 eq "");				# 369
$out=$tock - $tick;
is_ok ($out < 100);				# 370

if ($naptime) {
    print "++++ page break\n";
}

print "A Series of 1 Second Groups with Background I/O\n";

is_zero ($ob->write_bg($e));			# 371
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 372
is_zero ($out);					# 373

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 374
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 375

($blk, $in, $out, $err)=$ob->is_status;
is_zero ($in);					# 376
is_ok ($out == 20);				# 377
is_ok ($blk == 1);				# 378
is_zero ($err);					# 379

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_ok ($pass);					# 380
is_zero ($in);					# 381
is_ok ($in2 eq "");				# 382
$tock=Win32::GetTickCount();			# expect about 2 seconds
$out=$tock - $tick;
is_bad (($out < 1800) or ($out > 2400));	# 383
print "<2000> elapsed time=$out\n";
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 384

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);		# double check ok?
is_ok ($pass);					# 385
is_zero ($in);					# 386
is_ok ($in2 eq "");				# 387

sleep 1;
($pass, $out) = $ob->write_done(0);
is_ok ($pass);					# 388
is_zero ($out);					# 389
$tock=Win32::GetTickCount();			# expect about 4 seconds
$out=$tock - $tick;
is_bad (($out < 3800) or ($out > 4400));	# 390
print "<4000> elapsed time=$out\n";

$tick=Win32::GetTickCount();			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 391
($pass, $in, $in2) = $ob->read_done(0);

is_zero ($pass);				# 392 
is_zero ($in);					# 393
is_ok ($in2 eq "");				# 394

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 395
## print "testing fail message:\n";
$in = $ob->read_bg(10);
is_bad (defined $in);				# 396 - already reading

($pass, $in, $in2) = $ob->read_done(1);
is_ok ($pass);					# 397
is_zero ($in);					# 398 
is_ok ($in2 eq "");				# 399
$tock=Win32::GetTickCount();			# expect 1.5 seconds
$out=$tock - $tick;
is_bad (($out < 1300) or ($out > 1800));	# 400
print "<1500> elapsed time=$out\n";

$tick=Win32::GetTickCount();			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 401
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 402
is_zero ($in);					# 403
is_ok ($in2 eq "");				# 404

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 405 
is_ok (scalar $ob->purge_rx);			# 406 
($pass, $in, $in2) = $ob->read_done(1);
is_ok (scalar $ob->purge_rx);			# 407 
if (Win32::IsWinNT()) {
    is_zero ($pass);				# 408 
}
else {
    is_ok ($pass);				# 408 
}
is_zero ($in);					# 409 
is_ok ($in2 eq "");				# 410
$tock=Win32::GetTickCount();			# expect 1 second
$out=$tock - $tick;
is_bad (($out < 900) or ($out > 1200));		# 411
print "<1000> elapsed time=$out\n";

is_zero ($ob->write_bg($e));			# 412
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 413

sleep 1;
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 414
is_ok (scalar $ob->purge_tx);			# 415 
($pass, $out) = $ob->write_done(1);
is_ok (scalar $ob->purge_tx);			# 416 
if (Win32::IsWinNT()) {
    is_zero ($pass);				# 417 
}
else {
    is_ok ($pass);				# 417 
}
$tock=Win32::GetTickCount();			# expect 2 seconds
$out=$tock - $tick;
is_bad (($out < 1900) or ($out > 2200));	# 418
print "<2000> elapsed time=$out\n";

$tick=Win32::GetTickCount();			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 419
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 420
is_zero ($ob->write_bg($e));			# 421
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 422

sleep 1;
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 423

($pass, $in, $in2) = $ob->read_done(1);
is_ok ($pass);					# 424 
is_zero ($in);					# 425
is_ok ($in2 eq "");				# 426
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 427
$tock=Win32::GetTickCount();			# expect 1.5 seconds
$out=$tock - $tick;
is_bad (($out < 1300) or ($out > 1800));	# 428
print "<1500> elapsed time=$out\n";

($pass, $out) = $ob->write_done(1);
is_ok ($pass);					# 429
$tock=Win32::GetTickCount();			# expect 2.5 seconds
$out=$tock - $tick;
is_bad (($out < 2300) or ($out > 2800));	# 430
print "<2500> elapsed time=$out\n";

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(1 == $ob->user_msg);			# 431
is_zero(scalar $ob->user_msg(0));		# 432
is_ok(1 == $ob->user_msg(1));			# 433
is_ok(1 == $ob->error_msg);			# 434
is_zero(scalar $ob->error_msg(0));		# 435
is_ok(1 == $ob->error_msg(1));			# 436

# 437 - 488 Test and Normal "lookclear"

is_ok ($ob->stty_echo(0) == 0);			# 437
is_ok ($ob->lookclear("Before\nAfter") == 1);	# 438
is_ok ($ob->lookfor eq "Before");		# 439

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "\n");				# 440
is_ok ($out eq "After");			# 441
is_ok ($patt eq "\n");				# 442
is_ok ($instead eq "");				# 443

is_ok ($ob->lookfor eq "");			# 444
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 445
is_ok ($patt eq "");				# 446
is_ok ($instead eq "After");			# 447

@opts = $ob->are_match ("B*e","ab..ef","-re","12..56","END");
is_ok ($#opts == 4);				# 448
is_ok ($opts[2] eq "-re");			# 449
is_ok ($ob->lookclear("Good Bye, the END, Hello") == 1);	# 450
is_ok ($ob->lookfor eq "Good Bye, the ");	# 451

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 452
is_ok ($out eq ", Hello");			# 453
is_ok ($patt eq "END");				# 454
is_ok ($instead eq "");				# 455

is_ok ($ob->lookclear("Good Bye, the END, Hello") == 1);	# 456
is_ok ($ob->streamline eq "Good Bye, the ");	# 457

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 458
is_ok ($out eq ", Hello");			# 459
is_ok ($patt eq "END");				# 460
is_ok ($instead eq "");				# 461

is_ok ($ob->lookclear("Good B*e, abcdef, 123456") == 1);	# 462
is_ok ($ob->lookfor eq "Good ");		# 463

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "B*e");				# 464
is_ok ($out eq ", abcdef, 123456");		# 465
is_ok ($patt eq "B*e");				# 466
is_ok ($instead eq "");				# 467

is_ok ($ob->lookfor eq ", abcdef, ");		# 468

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "123456");			# 469
is_ok ($out eq "");				# 470
is_ok ($patt eq "12..56");			# 471
is_ok ($instead eq "");				# 472

is_ok ($ob->lookclear("Good B*e, abcdef, 123456") == 1);	# 473
is_ok ($ob->streamline eq "Good ");		# 474

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "B*e");				# 475
is_ok ($out eq ", abcdef, 123456");		# 476
is_ok ($patt eq "B*e");				# 477
is_ok ($instead eq "");				# 478

is_ok ($ob->streamline eq ", abcdef, ");	# 479

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "123456");			# 480
is_ok ($out eq "");				# 481
is_ok ($patt eq "12..56");			# 482
is_ok ($instead eq "");				# 483

@necessary_param = Win32::SerialPort->set_test_mode_active(0);

is_bad ($ob->lookclear("Good\nBye"));		# 484
is_ok ($ob->lookfor eq "");			# 485
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 486
is_ok ($out eq "");				# 487
is_ok ($patt eq "");				# 488

undef $ob;
