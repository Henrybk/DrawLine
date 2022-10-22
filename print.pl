#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

use File::Spec;
use GD;

my %posline;

printMap();

sub printMap {
	my $wid = 15;
	my $hei = 15;
	my $im = new GD::Image($wid, $hei);
	
	my $white = $im->colorAllocate(255,255,255);
	my $black = $im->colorAllocate(0,0,0);
	my $red = $im->colorAllocate(255,0,0);
	my $png_data;
	
	my $startx;
	my $endx;
	my $starty;
	my $endy;
	
	$startx = int rand $wid;
	$starty = int rand $hei;
	
	$endx = int rand $wid;
	$endy = int rand $hei;
	
	Bresenham($startx,$starty,$endx,$endy);
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
	
	$png_data = $im->png;
	
	open IMG, ">:raw", "kore_Bresenham.png";
	binmode IMG;
	print IMG $png_data;
	close IMG;
	
	hercules_Bresenham($startx,$starty,$endx,$endy);
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
	
	$png_data = $im->png;
	
	open IMG, ">:raw", "hercules_Bresenham.png";
	binmode IMG;
	print IMG $png_data;
	close IMG;
}

sub mod_Bresenham {
	my ($startx,$starty,$endx,$endy) = @_;
	
	undef %posline;
	
	my $x = $startx;
	my $y = $starty;
	#Grid cells are 1.0 X 1.0.
	my $diffX = $endx - $startx;
	my $diffY = $endy - $starty;
	my $stepX = $diffX < 0 ? -1 : 1;
	my $stepY = $diffY < 0 ? -1 : 1;
	
	#Ray/Slope related maths.
	#Straight distance to the first vertical grid boundary.
	my $xOffset = $endx > $startx ?
		($startx - $startx) :
		($startx - $startx);
	#Straight distance to the first horizontal grid boundary.
	my $yOffset = $endy > $starty ?
		($starty - $starty) :
		($starty - $starty);
		
	#Angle of ray/slope.
	my $angle = atan2(-$diffY, $diffX);
	#NOTE: These can be divide by 0's, but JS just yields Infinity! :)
	#How far to move along the ray to cross the first vertical grid cell boundary.
	my $tMaxX = $xOffset / cos($angle);
	#How far to move along the ray to cross the first horizontal grid cell boundary.
	my $tMaxY = $yOffset / sin($angle);
	#How far to move along the ray to move horizontally 1 grid cell.
	my $tDeltaX = 1.0 / cos($angle);
	#How far to move along the ray to move vertically 1 grid cell.
	my $tDeltaY = 1.0 / sin($angle);
	
	#Travel one grid cell at a time.
	my $manhattanDistance = abs($endx - $startx) +
		abs($endy - $starty);
	for (my $t = 0; $t <= $manhattanDistance; $t++) {
		$posline{$x}{$y} = 1;
		#Only move in either X or Y coordinates, not both.
		if (abs($tMaxX) < abs($tMaxY)) {
			$tMaxX += $tDeltaX;
			$x += $stepX;
		} else {
			$tMaxY += $tDeltaY;
			$y += $stepY;
		}
	}
}

sub Bresenham {
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
sub hercules_Bresenham {
	my ($start_x, $start_y, $end_x, $end_y) = @_;
	
	undef %posline;
	
	my $dx;
	my $dy;
	my $wx = 0;
	my $wy = 0;
	my $weight;

	$dx = ($end_x - $start_x);
	if ($dx < 0) {
		($start_x, $end_x) = ($end_x, $start_x);
		($start_y, $end_y) = ($end_y, $start_y);
		$dx = -$dx;
	}
	$dy = ($end_y - $start_y);

	my $spd;
	$spd->{rx} = 0;
	$spd->{ry} = 0;
	$spd->{len} = 1;
	$spd->{x}[0] = $start_x;
	$spd->{y}[0] = $start_y;

	if ($dx > abs($dy)) {
		$weight = $dx;
		$spd->{ry} = 1;
	} else {
		$weight = abs($end_y - $start_y);
		$spd->{rx} = 1;
	}

	while ($start_x != $end_x || $start_y != $end_y)
	{
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
		if( $spd->{len} < 32 )
		{
			$spd->{x}[$spd->{len}] = $start_x;
			$spd->{y}[$spd->{len}] = $start_y;
			$spd->{len}++;
		}
		$posline{$start_x}{$start_y} = 1;
	}

	return 1;
}

1;