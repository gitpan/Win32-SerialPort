#   ActiveState Build 3xx Install script for Win32::SerialPort
#   Adapted from Win32::API version 0.011 Install Program
#   by Aldo Calpini <dada@divinf.it>

BEGIN { die "wrong version" unless ($] =~ /^5\.003/); }

use Win32::Registry;
use File::Copy;

sub CheckDir {
    my($dir) = @_;
    if(! -d $dir) {
        print "Creating directory $dir...\n";
        mkdir($dir, 0) or die "ERROR: ($!)\n";
    }
}    

$MODULE  = "Win32::SerialPort";
$VERSION = "0.13";

print "\n   $MODULE version $VERSION Install Program for Build 3xx\n";
print   "   Adapted from Win32::API Install Program\n";
print   "   by Aldo Calpini <dada\@divinf.it>\n\n";

$KEY = "SOFTWARE\\ActiveWare\\Perl5";

$HKEY_LOCAL_MACHINE->Open($KEY, $hkey)
  or die "ERROR: Can't open Perl registry key: $KEY\n";

$hkey->GetValues($values);
$hkey->Close();

$PRIVLIB = $values->{'PRIVLIB'}->[2];

die "ERROR: Can't get PRIVLIB registry value!\n" unless $PRIVLIB;

CheckDir($PRIVLIB."\\Win32");
CheckDir($PRIVLIB."\\Win32API");

if (copy "lib\\Win32\\SerialPort.pm","$PRIVLIB\\Win32\\SerialPort.pm") {
    print "Copied Win32::SerialPort.pm to $PRIVLIB\\Win32...\n";
}
else {
    die "Could not copy Win32::SerialPort.pm to $PRIVLIB\\Win32...\n";
}

if (copy "lib\\Win32API\\CommPort.pm","$PRIVLIB\\Win32API\\CommPort.pm") {
    print "Copied Win32API::CommPort.pm to $PRIVLIB\\Win32API...\n";
}
else {
    die "Could not copy Win32API::CommPort.pm to $PRIVLIB\\Win32API...\n";
}

print "Installation done\n";
