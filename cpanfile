use strict;      # satisfy linter
use warnings;    # satisfy linter

requires 'Archive::Zip';
requires 'BSD::Resource';
requires 'BerkeleyDB';
requires 'Compress::Zlib';
requires 'DBI';
requires 'DB_File';
requires 'Devel::Cycle';
requires 'Digest::SHA';
requires 'Digest::SHA1';
requires 'Email::Address::XS';
requires 'Encode::Detect';
requires 'Encode::Detect::Detector';
requires 'Geo::IP';
requires 'GeoIP2';
requires 'GeoIP2::Database::Reader';
requires 'Geography::Countries';
requires 'HTML::Parser';
requires 'HTTP::Cookies';
requires 'HTTP::Daemon';
requires 'HTTP::Date';
requires 'HTTP::Negotiate';
requires 'IO::Socket::INET6';
requires 'IO::Socket::SSL';
requires 'IO::String';
requires 'IP::Country';
requires 'IP::Country::DB_File';
requires 'LWP::Protocol::https';
requires 'LWP::UserAgent';
requires 'Mail::DKIM';
requires 'Mail::DMARC::PurePerl';
requires 'Math::Int128';
requires 'MaxMind::DB::Reader::XS';
requires 'Net::CIDR::Lite';
requires 'Net::DNS';
requires 'Net::DNS::Nameserver';
requires 'Net::LibIDN';
requires 'Net::LibIDN2';
requires 'Net::Patricia';
requires 'Net::Works::Network';
requires 'NetAddr::IP';
requires 'Params::Validate';
requires 'Razor2::Client::Agent';
requires 'Sys::Hostname::Long';
requires 'Test::Perl::Critic';
requires 'Test::Pod';
requires 'Test::Pod::Coverage';
requires 'WWW::RobotRules';
requires 'Text::Diff';
requires 'Perl::Critic::Policy::Bangs::ProhibitBitwiseOperators';
requires 'Perl::Critic::Policy::Perlsecret';
requires 'Perl::Critic::Policy::Compatibility::ProhibitThreeArgumentOpen';
requires 'Perl::Critic::Policy::Lax::ProhibitStringyEval::ExceptForRequire';
requires 'Perl::Critic::Policy::ValuesAndExpressions::PreventSQLInjection';
requires 'Perl::Critic::Policy::ControlStructures::ProhibitReturnInDoBlock';

if ( "$]" < 5.017 ) {
    requires 'Devel::SawAmpersand';
}
