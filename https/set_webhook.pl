#!/usr/bin/env perl
use common::sense;
use Mojo::UserAgent;
use Data::Dumper;
use utf8;	
my $ua = Mojo::UserAgent->new;

my %hash = (
	url => 'https://3d.fablab61.ru/',
	certificate => {file => "server.crt"},
);

# my %hash = (
# 	url => '',
# );

# 208769481:AAFAtahcqdHvk6OLrXzb7PvalI4w0n7rq_Q

#my $res = $ua->post('https://api.telegram.org/bot'.$token.'/setWebhook' => form => \%hash)->res;
my $res = $ua->post('https://api.telegram.org/bot237382088:AAE8edrqW4h02Zfj8vSNv3Hyoix49_3Dx94/setWebhook' => form => \%hash)->res;
warn Dumper $res->json;		

# say $ua->post('http://127.0.0.1:3000/')->res->code;


# my $res = $ua->get('https://bot.serikov.xyz/')->res;
# warn Dumper $res->json;	
