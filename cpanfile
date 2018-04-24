requires "Dancer2"                            => "0.203001";
requires "Dancer2::Plugin::Auth::Extensible"  => '0.704';
requires "Dancer2::Session::Cookie"           => '0.008';
requires "Dancer2::Plugin::Flash"             => '0.03';
requires "Dancer2::Plugin::DBIC"              => '0.0100';
requires "Dancer2::Plugin::Ajax"              => '0.300000';
requires "Digest::SHA1"                       => '2.13';
requires "Digest::MD5"                        => '2.55';
requires "PathTools"                          => '3.62';
requires "Time::Duration"                     => '1.20';
requires "HTML::Escape"                       => '1.10';
requires "Parse::BBCode"                      => '0.15';
requires "Regexp::Common"                     => '2017060201';
requires "Regexp::Common::profanity_us"       => '4.112150';
requires "URL::Encode"                        => '0.03';
requires "Gravatar::URL"                      => '1.07';

recommends "YAML"             => "0";
recommends "URL::Encode::XS"  => "0";
recommends "CGI::Deurl::XS"   => "0";
recommends "HTTP::Parser::XS" => "0";

on "test" => sub {
    requires "Test::More"            => "0";
    requires "HTTP::Request::Common" => "0";
};
