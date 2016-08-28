use Test::More;
use strict;
use warnings;

BEGIN {
    use FindBin;
    use lib "$FindBin::Bin/../lib";
}

use List::Util qw(first);
use Slic3r;
use Slic3r::Test;

plan tests => 2;

{
    my $config = Slic3r::Config->new_from_defaults;
    $config->set('layer_height', 0.2);
    $config->set('first_layer_height', 0.2);
    $config->set('nozzle_diameter', [0.5]);
    $config->set('infill_every_layers', 2);
    $config->set('infill_extruder', 2);
    $config->set('top_solid_layers', 0);
    $config->set('bottom_solid_layers', 0);
    my $print = Slic3r::Test::init_print('20mm_cube', config => $config);
    ok my $gcode = Slic3r::Test::gcode($print), "infill_every_layers does not crash";
    
    my $tool = undef;
    my %layer_infill = ();  # layer_z => has_infill
    Slic3r::GCode::Reader->new->parse($gcode, sub {
        my ($self, $cmd, $args, $info) = @_;
        
        if ($cmd =~ /^T(\d+)/) {
            $tool = $1;
        } elsif ($cmd eq 'G1' && $info->{extruding} && $info->{dist_XY} > 0) {
            $layer_infill{$self->Z} //= 0;
            if ($tool == $config->infill_extruder-1) {
                $layer_infill{$self->Z} = 1;
            }
        }
    });
    my $layers_with_infill = grep $_,  values %layer_infill;
    $layers_with_infill--; # first layer is never combined
    is $layers_with_infill, scalar(keys %layer_infill)/2, 'infill is only present in correct number of layers';
}

# the following needs to be adapted to the new API
if (0) {
    my $config = Slic3r::Config->new_from_defaults;
    $config->set('skirts', 0);
    $config->set('solid_layers', 0);
    $config->set('bottom_solid_layers', 0);
    $config->set('top_solid_layers', 0);
    $config->set('infill_every_layers', 6);
    $config->set('layer_height', 0.06);
    $config->set('perimeters', 1);
    
    my $test = sub {
        my ($shift) = @_;
        
        my $self = Slic3r::Test::init_print('20mm_cube', config => $config);
        
        $shift /= &Slic3r::SCALING_FACTOR;
        my $scale = 4; # make room for fat infill lines with low layer height

        # Put a slope on the box's sides by shifting x and y coords by $tilt * (z / boxheight).
        # The test here is to put such a slight slope on the walls that it should
        # not trigger any extra fill on fill layers that should be empty when 
        # combine infill is enabled.
        $_->[0] += $shift * ($_->[2] / (20 / &Slic3r::SCALING_FACTOR)) for @{$self->objects->[0]->meshes->[0]->vertices};
        $_->[1] += $shift * ($_->[2] / (20 / &Slic3r::SCALING_FACTOR)) for @{$self->objects->[0]->meshes->[0]->vertices};
        $_ = [$_->[0]*$scale, $_->[1]*$scale, $_->[2]] for @{$self->objects->[0]->meshes->[0]->vertices};
                
        # copy of Print::export_gcode() up to the point 
        # after fill surfaces are combined
        $self->init_extruders;
        $_->slice for @{$self->objects};
        $_->make_perimeters for @{$self->objects};
        $_->detect_surfaces_type for @{$self->objects};
        $_->prepare_fill_surfaces for map @{$_->regions}, map @{$_->layers}, @{$self->objects};
        $_->process_external_surfaces for map @{$_->regions}, map @{$_->layers}, @{$self->objects};
        $_->discover_horizontal_shells for @{$self->objects};
        $_->combine_infill for @{$self->objects};

        # Only layers with id % 6 == 0 should have fill.
        my $spurious_infill = 0;
        foreach my $layer (map @{$_->layers}, @{$self->objects}) {
            ++$spurious_infill if ($layer->id % 6 && grep @{$_->fill_surfaces} > 0, @{$layer->regions});
        }

        $spurious_infill -= scalar(@{$self->objects->[0]->layers} - 1) % 6;
        
        fail "spurious fill surfaces found on layers that should have none (walls " . sprintf("%.4f", Slic3r::Geometry::rad2deg(atan2($shift, 20/&Slic3r::SCALING_FACTOR))) . " degrees off vertical)"
            unless $spurious_infill == 0;
        1;
    };
    
    # Test with mm skew offsets for the top of the 20mm-high box
    for my $shift (0, 0.0001, 1) {
        ok $test->($shift), "no spurious fill surfaces with box walls " . sprintf("%.4f",Slic3r::Geometry::rad2deg(atan2($shift, 20))) . " degrees off of vertical";
    }
}

__END__
