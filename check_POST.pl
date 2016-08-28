#!/usr/bin/env perl
use common::sense;
use Mojo::UserAgent;
use Data::Dumper;
use utf8;	

my $ua = Mojo::UserAgent->new;



my $hash->{foo} = 'bar';

# my %hash = (
# 	message => (
# 		'text' => 'hi',
# 		'chat' => { 'id' => '218718957'}, 
# 		'from' => {'id' => '218718957'} 
# 	)
# );

warn Dumper $ua->post('http://127.0.0.1:3000/' => json => $hash)->res->json;