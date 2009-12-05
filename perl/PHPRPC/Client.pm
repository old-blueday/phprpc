#/**********************************************************\
#|                                                          |
#| The implementation of PHPRPC Protocol 3.0                |
#|                                                          |
#| Client.pm                                                |
#|                                                          |
#| Release 3.0.0 beta                                       |
#| Copyright (c) 2005-2007 by Team-PHPRPC                   |
#|                                                          |
#| WebSite:  http://www.phprpc.org/                         |
#|           http://www.phprpc.net/                         |
#|           http://www.phprpc.com/                         |
#|           http://sourceforge.net/projects/php-rpc/       |
#|                                                          |
#| Author:   Ma Bingyao <andot@ujn.edu.cn>                  |
#|                                                          |
#| This file may be distributed and/or modified under the   |
#| terms of the GNU Lesser General Public License (LGPL)    |
#| version 3.0 as published by the Free Software Foundation |
#| and appearing in the included file LICENSE.              |
#|                                                          |
#\**********************************************************/
#
# PHPRPC Client for Perl.
#
# Copyright (C) 2006-2007 Ma Bingyao <andot@ujn.edu.cn>
# Version:      3.00
# LastModified: Nov 12, 2007
# This library is free.  You can redistribute it and/or modify it.
#

package PHPRPC::Client;

use bytes;
use strict;

$PHPRPC::Client::VERSION = '3.00';

use LWP::UserAgent;
use PHP::Serialization;
use MIME::Base64;
use Math::BigInt;
use Digest::MD5;
use Crypt::XXTEA;

sub new {
    my ($class, $url) = @_;
    my $this = bless {
        ua => LWP::UserAgent->new(
            agent             => 'PHPRPC Client ' . $PHPRPC::Client::VERSION . ' for Perl',
            protocols_allowed => ['http', 'https'],
            keep_alive        => 1,
            timeout           => 30,
        ),
        url => $url,
        output => '',
        warning => undef,
        key => undef,
        keylen => 128,
        encrypt_mode => 0,
        cookie => undef,
        charset => 'UTF-8',
        server_version => undef,
    }, $class;
}

sub AUTOLOAD {
    my $this   = shift;
    my $args   = \@_;
    my $method = $PHPRPC::Client::AUTOLOAD;
    $method =~ s/.*:://;

    return if ($method eq 'DESTROY');

    return $this->invoke($method, $args, 0);
}

sub useService {
    my ($this, $url, $username, $password) = @_;
    $this->{url} = $url;
    $this->{key} = undef;
    $this->{keylen} = 128;
    $this->{encrypt_mode} = 0;
    $this->{cookie} = undef;
    $this->{charset} = 'UTF-8';
    if (defined($username) & defined($password)) {
        $this->{ua}->default_headers->authorization_basic($username, $password);
    }
    return $this;
}

sub setProxy {
    my ($this, $host, $port, $username, $password) = @_;
    if (!defined($host)) {
        $this->{ua}->env_proxy();
    }
    else {
        if (!defined($port)) {
            $this->{ua}->proxy(['http', 'https'], $host);
        }
        else {
            $this->{ua}->proxy(['http', 'https'], "http://$host:$port/");
            if (defined($username) & defined($password)) {
                $this->{ua}->default_headers->proxy_authorization_basic($username, $password);
            }
        }
    }
}

sub setKeyLength {
    my ($this, $keylen) = @_;
    if (defined($this->{key})) {
        return 0;
    }
    else {
        $this->{keylen} = $keylen;
        return 1;
    }
}

sub getKeyLength {
    return $_[0]->{keylen};
}

sub setEncryptMode {
    my ($this, $encrypt_mode) = @_;
    if (($encrypt_mode >= 0) && ($encrypt_mode <= 3)) {
        $this->{encrypt_mode} = int($encrypt_mode);
        return 1;
    }
    else {
        $this->{encrypt_mode} = 0;
        return 0;
    }
}

sub getEncryptMode {
    return $_[0]->{encrypt_mode};
}

sub setCharset {
    my ($this, $charset) = @_;
    $this->{charset} = $charset;
}

sub getCharset {
    return $_[0]->{charset};
}

sub setTimeout {
    my ($this, $timeout) = @_;
    $this->{ua}->timeout($timeout);
}

sub getTimeout {
    return $_[0]->{ua}->timeout;
}

sub invoke {
    my ($this, $funcname, $args, $byRef) = @_;
    my $result = $this->_key_exchange();
    if (ref($result) eq 'PHPRPC::Error') {
        return $result;
    }
    my $request = "phprpc_func=$funcname";
    if (scalar(@{$args}) > 0) {
        $request .= "&phprpc_args=" . MIME::Base64::encode($this->_encrypt(PHP::Serialization::serialize($args), 1));
    }
    $request .= "&phprpc_encrypt=" . $this->{encrypt_mode};
    if (!$byRef) {
        $request .= "&phprpc_ref=false";
    }
    $request =~ s/([\+])/sprintf("%%%02X", ord($1))/seg;
    $result = $this->_post($request);
    if (ref($result) eq 'PHPRPC::Error') {
        return $result;
    }
    $this->{warning} = PHPRPC::Error->new(int($result->{phprpc_errno}), MIME::Base64::decode($result->{phprpc_errstr}));
    if (exists($result->{phprpc_output})) {
        $this->{output} = MIME::Base64::decode($result->{phprpc_output});
        if ($this->{server_version} >= 3) {
            $this->{output} = $this->_decrypt($this->{output}, 3);
        }
    }
    else {
        $this->{output} = '';
    }
    if (exists($result->{phprpc_result})) {
        if (exists($result->{phprpc_args})) {
            my $arguments = PHP::Serialization::unserialize($this->_decrypt(MIME::Base64::decode($result->{phprpc_args}), 1));
            for (my $i = 0; $i < scalar(@{$arguments}); $i++) {
                $args->[$i] = $arguments->[$i];
            }
        }
        $result = PHP::Serialization::unserialize($this->_decrypt(MIME::Base64::decode($result->{phprpc_result}), 2));
    }
    else {
        $result = $this->{warning};
    }
    return $result;
}

sub getOutput {
    return $_[0]->{output};
}

sub getWarning {
    return $_[0]->{warning};
}

sub _post {
    my ($this, $request) = @_;
    $this->{ua}->default_headers->header(Pragma => 'no-cache', Cache_Control => 'no-cache');
    $this->{ua}->default_headers->header(Content_Type => 'application/x-www-form-urlencoded; charset=' . $this->{charset});
    if (defined($this->{cookie})) {
        $this->{ua}->default_headers->header(Cookie => $this->{cookie});
    }
    my $response = $this->{ua}->post($this->{url},  Content => $request);
    return $this->_parse($response);
}

sub _parse {
    my ($this, $response) = @_;
    if ($response->is_success) {
        my $flag = 1;
        if ($response->header('X-Powered-By')) {
            my @values = $response->header('X-Powered-By');
            foreach my $value(@values) {
                $value =~ /^PHPRPC Server\/(.*)$/;
                if ($1) {
                    $this->{server_version} = $1;
                    $flag = 0;
                    last;
                }
            }
        }
        if ($flag) {
            return PHPRPC::Error->new(1, 'Illegal PHPRPC server.');
        }
        if ($response->header('Content-Type')) {
            my $value = $response->header('Content-Type');
            $value =~ /text\/plain\; charset\=(.*)$/i;
            if ($1) {
                $this->{charset} = $1;
            }
        }
        if ($response->header('Set-Cookie')) {
            my @cookies = split(/;/, $response->header('Set-Cookie'));
            my @newcookies = ();
            foreach my $cookie(@cookies) {
                $cookie =~ s/^\s+//;
                $cookie =~ s/\s+$//;
                if ((substr($cookie, 0, 5) ne 'path=') and
                    (substr($cookie, 0, 7) ne 'domain=') and
                    (substr($cookie, 0, 8) ne 'expires=')) {
                    push(@newcookies, $cookie);
                }
            }
            $this->{cookie} = join('; ', @newcookies);
        }
        my @values = split(/;\r\n/, $response->content);
        my $result = {};
        foreach my $value(@values) {
            $value=~/^(phprpc_[a-z]*)=\"([^\"]*)\"$/;
            $result->{$1}=$2;
        }
        return $result;
    }
    else {
        return PHPRPC::Error->new($response->code, $response->message);
    }
}

sub _key_exchange {
    my $this = shift;
    if (defined($this->{key}) || ($this->{encrypt_mode} == 0)) {
        return 1;
    }
    my $request = "phprpc_encrypt=true&phprpc_keylen=" . $this->{keylen};
    my $result = $this->_post($request);
    if (ref($result) eq 'PHPRPC::Error') {
        return $result;
    }
    if (exists($result->{phprpc_keylen})) {
        $this->{keylen} = int($result->{phprpc_keylen});
    }
    else {
        $this->{keylen} = 128;
    }
    if (exists($result->{phprpc_encrypt})) {
        my $encrypt = PHP::Serialization::unserialize(MIME::Base64::decode($result->{phprpc_encrypt}));
        my $x = Math::BigInt->bzero();
        for (my $i = 0; $i < $this->{keylen} - 1; $i++) {
            if (int(rand(2))) {
                $x->bior(Math::BigInt->bone()->blsft($i));
            }
        }
        $x->bior(Math::BigInt->bone()->blsft($this->{keylen} - 2));
        my $key = Math::BigInt->new($encrypt->{y})->bmodpow($x, Math::BigInt->new($encrypt->{p}));
        if ($this->{keylen} == 128) {
            $key = substr($key->as_hex(), 2);
            if (length($key) % 2 == 1) {
                $key = '0' . $key;
            }
            $key = pack("H*", $key);
            if (length($key) < 16) {
                $key = ("\0" x (16-length($key))) . $key;
            }
        }
        else {
            $key = Digest::MD5::md5($key->bstr());
        }
        $this->{key} = $key;
        my $y = Math::BigInt->new($encrypt->{g})->bmodpow($x, Math::BigInt->new($encrypt->{p}))->bstr();
        $result = $this->_post("phprpc_encrypt=$y");
        if (ref($result) eq 'PHPRPC::Error') {
            return $result;
        }
    }
    else {
        $this->{key} = undef;
        $this->{encrypt_mode} = 0;
    }
    return 1;
}

sub _encrypt {
    my ($this, $str, $level) = @_;
    if (defined($this->{key}) && ($this->{encrypt_mode} >= $level)) {
        $str = Crypt::XXTEA::encrypt($str, $this->{key});
    }
    return $str;
}

sub _decrypt {
    my ($this, $str, $level) = @_;
    if (defined($this->{key}) && ($this->{encrypt_mode} >= $level)) {
        $str = Crypt::XXTEA::decrypt($str,$this->{key});
    }
    return $str;
}

##############################################################################

package PHPRPC::Error;

sub new {
    my ($class, $number, $message) = @_;

    my $self = bless {
        number => $number,
        message => $message,
    }, $class;
}

sub getNumber {
    $_[0]->{number};
}

sub getMessage {
    $_[0]->{message};
}

sub toString {
    $_[0]->{number} . ":" . $_[0]->{message};
}

1;

__END__

=head1 NAME

PHPRPC::Client - Perl implementation of PHPRPC Client 3.0.

=head1 SYNOPSIS

 use PHPRPC::Client;

 my $rpc = PHPRPC::Client->new("http://www.phprpc.org/server.php");
 $rpc->setKeyLength(256);
 $rpc->setEncryptMode(2);
 print $rpc->add(1, 2);       # add is a remote procedure.
 print $rpc->sub(3, 5);       # sub is a remote procedure.
 my $a = [1];
 $rpc->invoke('inc', $a, 1);  # inc is a remote procedure, and pass parameters by reference.
 print $a->[0];

=head1 PHPRPC::Client

=head2 METHODS

=over

=item new

 my $client = new PHPRPC::Client;
 my $client = PHPRPC::Client->new($url);

Creates new PHPRPC::Client object.

=item setProxy

 $client->setProxy();
 $client->setProxy($address);
 $client->setProxy($host, $port);
 $client->setProxy($host, $port, $username, $password);

Set the proxy server for the transfer. $username and $password is for the HTTP Basic Authorization. Without parameters, using env proxy.

=item useService

 $client->useService($url);
 $client->useService($url, $username, $password);

Set the $url of the PHPRPC Server. $username and $password is for the HTTP Basic Authorization.

=item setKeyLength

 $client->setKeyLength($keyLength);

Set the key length for the key exchange. This method will return 0 when the key exchange already to be done.

=item getKeyLength

 print $client->getKeyLength();

Get the key length. This method will return actual value when the key exchange being done. Otherwise, you will get the default length or which length you set.

=item setEncryptMode

 $client->setEncryptMode($encryptMode);

Set the encrypt mode. 0 denotes no encrypting any data. 1 denotes encrypting arguments in the transfer. 2 denotes encrypting arguments and result. 3 denotes encrypting arguments, result and output of the server console. Set other value, it would return false.

=item getEncryptMode

 print $client->getEncryptMode();

Get the encrypt mode.

=item setCharset

 $client->setCharset($charset);

Set the request charset. Use it before invoke the remote procedure. The default value is "UTF-8".

=item getCharset

 print $client->getCharset();

Get the response charset.

=item setTimeout

 $client->setTimeout($timeout);

Set the timeout of the invoking of the remote procedure. the $timeout is the number of seconds. Default value is 30 seconds.

=item getTimeout

 print $client->getTimeout();

Get the timeout of the invoking the remote procedure. the return value is the number of seconds.

=item invoke

 $client->invoke($funcname, \@args);
 $client->invoke($funcname, \@args, $byRef);

Invoke the remote procedure with the function name and arguments array. if you want to pass arguments by reference, set byRef to 1.

=item getOutput

 print $client->getOutput();

Get the output of the server console after invoke the remote procedure.

=item getWarning

 my $warning = $client->getWarning();

Get the warning of the remote procedure after invoke the remote procedure.

=back

=head1 PHPRPC::Error

=head2 METHODS

=over

=item getNumber

return error number

=item getMessage

return error message

=item toString

return a string which include the error number and error message

=back

=head1 AUTHOR

Ma Bingyao, E<lt>andot[at]ujn.edu.cnE<gt>

=head1 SEE ALSO

Crypt::XXTEA

=head1 COPYRIGHT

The implementation of the PHPRPC Client was developed by,
and is copyright of, Ma Bingyao (andot@ujn.edu.cn).

=cut
