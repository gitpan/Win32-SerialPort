#! perl -w

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "demo5.plx loaded "; }
END {print "not ok 1\n" unless $loaded;}
use lib './lib';
use Win32::SerialPort 0.13;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use Carp;
use Win32;
use strict;

my $ob;
my $pass;
my @wanted;
my $out;

sub nextline {
    my $delay = 0;
    my $prompt;
    $delay = shift if (@_);
    if (@_)	{ $prompt = shift; }
    else	{ $prompt = ""; }
    my $timeout=Win32::GetTickCount() + (1000 * $delay);
    my $gotit = "";
	# this count wraps every month or so

    $ob->is_prompt($prompt);
    $ob->write($prompt);

    for (;;) {
        return unless (defined ($gotit = $ob->lookfor));
        return $gotit if ($gotit ne "");
        return if ($ob->reset_error);
	if ( $] >= 5.005 ) {
	    select undef, undef, undef, 0.2; # traditional 5/sec.
	}
	elsif ( $] < 5.004 ) {
	    Win32::Sleep (200);	# AS 3xx builds
	}
	else {
	    sleep 1;	# no easy GSAR equivalent
	}
	return if (Win32::GetTickCount() > $timeout);
    }
}

sub waitfor {
    croak "parameter problem" unless (@_ == 1);
    $ob->lookclear;
    nextline ( shift );
}

sub cntl_char {
    my $n_char = shift;
    my $pos = ord $n_char;
    if ($pos < 32) {
        $n_char = "^".chr($pos + 64);
    }
    if ($pos == 127) {
        $n_char = "DEL";
    }
    return $n_char;
}

# starts configuration created by test1.pl

my $cfgfile = "COM1_test.cfg";

# =============== execution begins here =======================

# 2: Constructor

$ob = Win32::SerialPort->start ($cfgfile) or die "Can't start $cfgfile\n";
    # next test will die at runtime unless $ob

my $intr = cntl_char($ob->stty_intr);
my $quit = cntl_char($ob->stty_quit);
my $eof = cntl_char($ob->stty_eof);
my $eol = cntl_char($ob->stty_eol);
my $erase = cntl_char($ob->stty_erase);
my $kill = cntl_char($ob->stty_kill);
my $echo = ($ob->stty_echo ? "" : "-")."echo";
my $echoe = ($ob->stty_echoe ? "" : "-")."echoe";
my $echok = ($ob->stty_echok ? "" : "-")."echok";
my $echonl = ($ob->stty_echonl ? "" : "-")."echonl";
my $echoke = ($ob->stty_echoke ? "" : "-")."echoke";
my $echoctl = ($ob->stty_echoctl ? "" : "-")."echoctl";
my $istrip = ($ob->stty_istrip ? "" : "-")."istrip";
my $icrnl = ($ob->stty_icrnl ? "" : "-")."icrnl";
my $ocrnl = ($ob->stty_ocrnl ? "" : "-")."ocrnl";
my $igncr = ($ob->stty_igncr ? "" : "-")."igncr";
my $inlcr = ($ob->stty_inlcr ? "" : "-")."inlcr";
my $onlcr = ($ob->stty_onlcr ? "" : "-")."onlcr";
my $isig = $ob->stty_isig ? "enabled" : "disabled";
my $icanon = $ob->stty_icanon ? "enabled" : "disabled";


# 3: Prints Prompts to Port and Main Screen

my $head	= "\r\n\r\n++++++++++++++++++++++++++++++++++++++++++\r\n";
my $e="\r\n....Bye\r\n";

my $tock	= <<TOCK_END;
\rSimple Serial Terminal with lookfor\r

Terminal CONTROL Keys Supported:\r
    quit = $quit;  intr = $intr;  $isig\r
    erase = $erase;  kill = $kill;  $icanon\r
    eol = $eol;  eof = $eof;\r

Terminal FUNCTIONS Supported:\r
    $istrip  $igncr  $echoke  $echoctl\r
    $echo  $echoe  $echok  $echonl\r

Terminal Character Conversions Supported:\r
    $icrnl  $inlcr  $ocrnl  $onlcr\r
\r
TOCK_END
#

print $head, $tock;
$pass=$ob->write($head);
$pass=$ob->write($tock);

$ob->error_msg(1);		# use built-in error messages
$ob->user_msg(1);

my $match1 = "YES";
my $match2 = "NO";
my $prompt1 = "Type $match1 or $match2 or <ENTER> exactly to continue\r\n";

$pass=$ob->write($prompt1) if ($ob->stty_echo);

$ob->are_match($match1, $match2, "\n");
$out = waitfor (30);
if (defined $out) {
    print "\r\nout found: $out\n";
}
else {
    print "\r\nAborted or Timed Out\r\n";
}

print $head;
$pass=$ob->write($head);

$ob->lookclear;
$out = nextline (60, "\nPROMPT:");
if (defined $out) {
    print "\nPROMPT:$out...";
}
else {
    print "\r\nAborted or Timed Out\r\n";
}

sleep 2;
$out = nextline (60, "\nPROMPT2:");
if (defined $out) {
    print "\nPROMPT2:$out...";
}
else {
    print "\r\nAborted or Timed Out\r\n";
}

sleep 2;
@wanted = ("BYE");
$ob->are_match(@wanted);
$out = nextline (60, "\ntype 'BYE' to quit:");
if (defined $out) {
    my ($found, $end) = $ob->lastlook;
    print "\nout: $out...followed by: $found...";
}
else {
    print "\r\nAborted or Timed Out\r\n";
}
### example from the docs

$ob->are_match("pattern", "\n");	# possible end strings
$ob->lookclear;				# empty buffer
$ob->write("\r\nFeed Me:");		# initial prompt
$ob->is_prompt("More Food:");		# new prompt after "kill" char

my $gotit = "";
until ("" ne $gotit) {
    $gotit = $ob->lookfor;		# poll until data ready
    die "Aborted without match\n" unless (defined $gotit);
    sleep 1;				# polling sample time
}
printf "\ngotit = %s...", $gotit;		# input before the match
my ($match, $after) = $ob->lastlook;		# match and input after
printf "\nlastlook-match = %s  -after = %s...\n", $match, $after;

###
print $e;
$pass=$ob->write($e);

sleep 1;

undef $ob;
