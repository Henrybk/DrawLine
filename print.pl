#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Time::HiRes qw(time);

use File::Spec;
use GD;

my $wid = 15;
my $hei = 15;
my $im = new GD::Image($wid, $hei);
	
my $white = $im->colorAllocate(255,255,255);
my $black = $im->colorAllocate(0,0,0);
my $red = $im->colorAllocate(255,0,0);

printMap();

#bench();

sub printMap {
	my $startx;
	my $endx;
	my $starty;
	my $endy;
	
	$startx = int rand $wid;
	$starty = int rand $hei;
	$endx = int rand $wid;
	$endy = int rand $hei;
	
	my $plot;
	$plot = Bresenham($startx,$starty,$endx,$endy);
	plot("kore_Bresenham.png", $startx, $starty, $endx, $endy, $plot);
	
	$plot = hercules_Bresenham($startx,$starty,$endx,$endy);
	plot("hercules_Bresenham.png", $startx, $starty, $endx, $endy, $plot);
}

sub bench {
	my $n = 100000;
	
	my @startx;
	my @endx;
	my @starty;
	my @endy;
	
	for(my $i = 0; $i < $n; $i++){
		$startx[$i] = int rand $wid;
		$starty[$i] = int rand $hei;
		$endx[$i] = int rand $wid;
		$endy[$i] = int rand $hei;
	}
	
	my $time_s;
	my $time_e;
	my $time_d;
	
	$time_s = time;
	for(my $i = 0; $i < $n; $i++){
		Bresenham($startx[$i],$starty[$i],$endx[$i],$endy[$i]);
	}
	$time_e = time;
	$time_d = $time_e - $time_s;
	print "Bresenham took $time_d\n";
	
	$time_s = time;
	for(my $i = 0; $i < $n; $i++){
		hercules_Bresenham($startx[$i],$starty[$i],$endx[$i],$endy[$i]);
	}
	$time_e = time;
	$time_d = $time_e - $time_s;
	print "hercules_Bresenham took $time_d\n";
}

sub plot {
	my ($name, $startx, $starty, $endx, $endy, $plot) = @_;
	foreach my $y (0..($hei - 1)) {
		foreach my $x (0..($wid - 1)) {
			
			if (($x == $startx && $y == $starty) || ($x == $endx && $y == $endy)) {
				$im->setPixel($x,$y,$red);
				
			} elsif (exists $plot->{$x} && exists $plot->{$x}{$y}) {
				$im->setPixel($x,$y,$black);
				
			} else {
				$im->setPixel($x,$y,$white);
			}
		}
	}
	my $png_data = $im->png;
	
	open IMG, ">:raw", $name;
	binmode IMG;
	print IMG $png_data;
	close IMG;
}

sub Bresenham {
	my ($X0, $Y0, $X1, $Y1) = @_;
	
	my %posline;

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
	
	return \%posline;
}

sub hercules_Bresenham {
	my ($start_x, $start_y, $end_x, $end_y) = @_;
	
	my %posline;
	
	my $dx;
	my $dy;
	my $wx = 0;
	my $wy = 0;
	my $weight;

	$dx = ($end_x - $start_x);
	if ($dx < 0) {
		($start_x, $end_x, $start_y, $end_y) = ($end_x, $start_x, $end_y, $start_y);
		$dx *= -1;
	}
	$dy = ($end_y - $start_y);

	if ($dx > abs($dy)) {
		$weight = $dx;
	} else {
		$weight = abs($end_y - $start_y);
	}

	while ($start_x != $end_x || $start_y != $end_y) {
		$wx += $dx;
		$wy += $dy;
		if ($wx >= $weight) {
			$wx -= $weight;
			$start_x++;
		}
		if ($wy >= $weight) {
			$wy -= $weight;
			$start_y++;
		} elsif ($wy < 0) {
			$wy += $weight;
			$start_y--;
		}
		$posline{$start_x}{$start_y} = 1;
	}

	return \%posline;
}

1;