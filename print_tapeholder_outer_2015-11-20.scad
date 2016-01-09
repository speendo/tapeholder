use <tapeholder.scad>;

height = 40;
outer_radius = 57;
inner_radius = 25;

outlet_angle = 90;

tape_base = 3;
tape_thickness = 0.25;

connector_snap_number = 3;
connector_snap_size = 1;
connector_snap_angle = 45;

closing_snap_height = 1.2;

thickness = 2;

offset = 1;

resolution = 200;

$fn = resolution;

//inner_part(height, outer_radius, inner_radius, outlet_angle, tape_base, thickness, offset);

outer_part(height, outer_radius, inner_radius, tape_thickness, connector_snap_angle, connector_snap_size, connector_snap_number, thickness, offset);