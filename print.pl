#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

use File::Spec;
use GD;

my %posline;

printMap();

sub printMap {
	my $wid = 20;
	my $hei = 20;
	my $im = new GD::Image($wid, $hei);
	
	my $white = $im->colorAllocate(255,255,255);
	my $black = $im->colorAllocate(0,0,0);
	my $red = $im->colorAllocate(255,0,0);
	
	my $startx;
	my $endx;
	my $starty;
	my $endy;
	
	$startx = 2;
	$starty = 2;
	
	$endx = 11;
	$endy = 17;
	check_line($startx,$starty,$endx,$endy);
	foreach my $y (0..($hei - 1)) {
		foreach my $x (0..($wid - 1)) {
			
			if (($x == $startx && $y == $starty) || ($x == $endx && $y == $endy)) {
				$im->setPixel($x,$y,$red);
				
			} elsif (exists $posline{$x} && exists $posline{$x}{$y}) {
				$im->setPixel($x,$y,$black);
				
			} else {
				$im->setPixel($x,$y,$white);
			}
		}
	}
	
	my $png_data = $im->png;
	
	open IMG, ">:raw", "prob1.png";
	binmode IMG;
	print IMG $png_data;
	close IMG;
}

sub check_line {
	my ($X0, $Y0, $X1, $Y1) = @_;
	
	undef %posline;


	my $steep;
	my $posX = 1;
	my $posY = 1;
	if ($X1 - $X0 < 0) {
		$posX = -1;
	}
	if ($Y1 - $Y0 < 0) {
		$posY = -1;
	}
	if (abs($Y0 - $Y1) < abs($X0 - $X1)) {
		$steep = 0;
	} else {
		$steep = 1;
	}
	if ($steep == 1) {
		my $Yt = $Y0;
		$Y0 = $X0;
		$X0 = $Yt;

		$Yt = $Y1;
		$Y1 = $X1;
		$X1 = $Yt;
	}
	if ($X0 > $X1) {
		my $Xt = $X0;
		$X0 = $X1;
		$X1 = $Xt;

		my $Yt = $Y0;
		$Y0 = $Y1;
		$Y1 = $Yt;
	}
	my $dX = $X1 - $X0;
	my $dY = abs($Y1 - $Y0);
	my $E = 0;
	my $dE;
	if ($dX) {
		$dE = $dY / $dX;
	} else {
		# Delta X is 0, it only occures when $from is equal to $to
		return 1;
	}
	my $stepY;
	if ($Y0 < $Y1) {
		$stepY = 1;
	} else {
		$stepY = -1;
	}
	my $Y = $Y0;
	my $Erate = 0.99;
	if (($posY == -1 && $posX == 1) || ($posY == 1 && $posX == -1)) {
		$Erate = 0.01;
	}
	for (my $X=$X0;$X<=$X1;$X++) {
		$E += $dE;
		if ($steep == 1) {
			$posline{$Y}{$X} = 1;
		} else {
			$posline{$X}{$Y} = 1;
		}
		if ($E >= $Erate) {
			$Y += $stepY;
			$E -= 1;
		}
	}
}


1;