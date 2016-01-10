use <tapeholder.scad>;

height = 42;
outer_radius = 58/2;
inner_radius = 24/2;

outlet_angle = 90;

tape_base = 3;
tape_thickness = 0.25;

connector_snap_number = 2;
connector_snap_size = 2.5;
connector_snap_angle = 150;

closing_snap_height = 1;
closing_snap_offset_share = 1;

thickness = 1.2;

offset = 0.5;

resolution = 100;

$fn = resolution;

inner_part(height, outer_radius, inner_radius, outlet_angle, tape_base, closing_snap_height, closing_snap_offset_share, thickness, offset);

//inner_part(height, outer_radius, inner_radius, outlet_angle, tape_base, thickness, offset);
//outer_part(height, outer_radius, inner_radius, tape_thickness, connector_snap_angle, connector_snap_size, connector_snap_number, thickness, offset);
