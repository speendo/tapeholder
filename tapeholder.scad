/* [Basic Properties] */

// Part to be computed
part = 3; // [1:Inner Part, 2:Outer Part, 3:Both Parts, 4:Animated Preview]

// Preview mode (no round corners - computes faster)
debug = true;

// Resolution (start low, raise before compilation)
resolution = 50; // [5:1:200]

/* [Basic Features] */

// Height (in mm)
height = 42; // [0:0.01:100]
// Outer Radius (in mm)
outer_radius = 29; // [0:0.01:100]
// Inner Radius (in mm)
inner_radius = 12; // [0:0.01:100]
// Default Thickness (in mm)
default_thickness = 1.2; // [0:0.005:50]
// Default Offset (in mm)
default_offset = 0.2; // [0:0.002:20]

/* [Wall and Plate Features] */

// Wall Thickness (in mm, -1 for default)
wall_thickness = 1.2; // [-1:0.005:50]
// Offset between outer Side Walls (in mm, -1 for default)
wall_offset = 0.5; // [-1:0.002:20]
// Base and Top Plate Thickness (in mm, -1 for default)
plate_thickness = 1.2; // [-1:0.005:50]

/* [Opening Features] */

// Opening Angle (in Deg)
outlet_angle = 120; //[0:0.5:360]
// Length of the Opening Notch e.g. to stick the tape on (in mm)
tape_base = 5; // [0:0.01:100]

/* [Connector Snap Features] */

// Number of Snaps
connector_snap_number = 2; // [1:1:36]
// Clip Size (in mm)
connector_snap_size = 2.5; // [0:0.005:50]
// Snap Angle (in Deg)
connector_snap_angle = 140; // [0:0.01:360]
// Connector Snap Pillar Thickness (in mm, -1 for default)
connector_snap_pillar_thickness = 2; // [-1:0.005:50]
// Connector Snap Height (in mm, -1 for default)
connector_snap_thickness = 1.5; // [0:0.005:50]
// Offset between Inner Part and Outer Part Snaps (in mm, -1 for default)
connector_snap_horizontal_offset = 1; // [-1:0.002:20]
// Offset between inner Side Walls (in mm, -1 for default)
connector_snap_vertical_offset = 0.2; // [-1:0.002:20]

/* [Opening and Closing Snaps] */

// Do you want closing snaps?
add_closing_snaps = true;
// Snap Height on the inner part (in mm, -1 for wall height)
closing_snap_height = -1.0; // [-1:0.01:100]

// Snap Radius (in mm, -1 for wall thickness)
closing_snap_radius = -1.0; // [-1:0.002:20]

// Snap Overlap (as a share of wall_offset)
closing_snap_overlap = 0.66; // [0:0.01:2]

// Tape Thickness - determines the position of the snaps in the outer part (in mm)
tape_thickness = 0.1;// [0:0.001:2]

/* [Inscription] */

// Do you want an inscription?
add_inscription = false;

// Number of Lines
text_lines = 1; // [1, 2, 3]

// Content of Line 1
text_content_line_1 = "";

// Content of Line 2
text_content_line_2 = "";

// Content of Line 3
text_content_line_3 = "";

// Text Size Line 1
text_size_line_1 = 10; // [0.1:0.01:100]

// Text Size Line 2
text_size_line_2 = 10; // [0.1:0.01:100]

// Text Size Line 3
text_size_line_3 = 10; // [0.1:0.01:100]

// Font Line 1 (depends on which fonts are installed)
text_font_line_1 = "Latin Modern Sans:style=Bold";

// Font Line 2 (depends on which fonts are installed)
text_font_line_2 = "Liberation Mono";

// Font Line 3 (depends on which fonts are installed)
text_font_line_3 = "Liberation Mono";

// Inscription Depth (as share of Wall thickness)
inscription_depth = 0.4; // [0:0.01:1]

/* [Advanced Features] */

// Convexity used in rotate_extrude() - only change if you know what you are doing
convexity = 3;

/* [Hidden] */

$fn = resolution;

module inner_part(
		height,
		outer_radius,
		inner_radius,
		outlet_angle,
		tape_base,
		wall_thickness,
		plate_thickness,
		wall_offset,
		add_closing_snaps=true,
		closing_snap_height,
		closing_snap_radius,
		closing_snap_overlap,
		debug
) {
	total_outer_radius = outer_radius + wall_thickness;
	total_height = height + plate_thickness;
	tape_base = max(tape_base, (wall_thickness + wall_offset));
	tape_base_angle = tape_base_angle(wall_thickness, total_outer_radius);
	closing_snap_height = closing_snap_height < 0 ? height : closing_snap_height;

	union() {
		difference() {
			union() {
				union() {
					// outer part
					difference() {
						cylinder(h = total_height, r = total_outer_radius);
						if (!debug) {
							round_outer_cut(total_outer_radius, max(plate_thickness, wall_thickness), resolution);
						}

						translate([0,0,plate_thickness]) {
							union() {
								cylinder(h = height + 1, r = total_outer_radius - wall_thickness);
								pie(total_outer_radius + 1, outlet_angle, total_height, tape_base_angle);
								if (!debug) {
									rotate([0,0,outlet_angle + ( 1.5 * tape_base_angle)]) {
										round_wall_cut(height, total_outer_radius, wall_thickness);
									}
								}
							}
						}
					}
					// tape_base
					difference() {
						// opening
						difference() {
							pie(total_outer_radius + tape_base, tape_base_angle, total_height);
							if (!debug) {
								round_outer_cuts(total_height, total_outer_radius + tape_base, wall_thickness, resolution);
								pillar_cut(total_height, total_outer_radius + tape_base, wall_thickness);
								radius_cuts(total_height, total_outer_radius + tape_base, wall_thickness);
							}
						}
						translate([0,0,plate_thickness]) {
							cylinder(h = height + 1, r = total_outer_radius - wall_thickness);
						}
					}
				}
				// inner part
				cylinder(h = total_height, r = inner_radius);
			}
			// inner hole
			translate([0, 0, -1]) {
				cylinder(h = total_height + 2, r = inner_radius - wall_thickness);
			}
		}
		// closing_snap
		if (add_closing_snaps) {
			translate([0,0, plate_thickness]) {
				closing_snap(closing_snap_height, closing_snap_radius, total_outer_radius + wall_offset/2, outer_radius, 180, closing_snap_overlap, outer=false, closing=true, debug = debug);
			}
		}
	}
}

module outer_part(
		height,
		outer_radius,
		inner_radius,
		outlet_angle,
		tape_thickness,
		wall_thickness,
		plate_thickness,
		wall_offset,
		add_closing_snaps=true,
		closing_snap_height,
		closing_snap_radius,
		closing_snap_overlap,
		connector_snap_number,
		connector_snap_angle,
		connector_snap_size,
		connector_snap_pillar_thickness,
		connector_snap_thickness,
		connector_snap_horizontal_offset,
		connector_snap_vertical_offset,
		debug=false
) {
	total_outer_radius = total_outer_radius_outer_part(outer_radius, wall_thickness, wall_offset);
	total_outer_radius_inner = outer_radius + wall_thickness;
	
	total_inner_radius = inner_radius - wall_thickness - connector_snap_vertical_offset;

	tape_base_angle = tape_base_angle(wall_thickness, total_outer_radius_inner);
	
	total_height = height + 2 * plate_thickness;

	closing_snap_height = closing_snap_height < 0 ? height : closing_snap_height;
	
	difference() {
		union() {
			// outer part
			difference() {
				cylinder(h = total_height, r = total_outer_radius);
				translate([0,0,plate_thickness]) {
					union() {
						cylinder(h = total_height - plate_thickness + 1, r = total_outer_radius - wall_thickness);
						// opening
						pie(total_outer_radius + 1, outlet_angle + tape_base_angle, total_height - plate_thickness + 1);
						// round pillars
						if (!debug) {
							rotate([0,0,outlet_angle + ( 2 * tape_base_angle)]) {
								half_wall_cut(total_height - plate_thickness, total_outer_radius, wall_thickness);
							}
							rotate([0,0,180 - tape_base_angle]) {
								mirror([1,0,0]) {
									half_wall_cut(total_height - plate_thickness, total_outer_radius, wall_thickness);
								}
							}
						}
					}
				}
			}
			difference() {
				// inner part
				union() {
					cylinder(h = total_height + connector_snap_horizontal_offset, r = total_inner_radius);
					translate([0,0,total_height + connector_snap_horizontal_offset]) {
						cylinder(h = connector_snap_thickness, r1 = inner_radius + connector_snap_size - wall_thickness, r2= total_inner_radius);
					}
				}
				// cut connector_snaps
				translate([0, 0, -1]) {
					union() {
						for (i = [1 : connector_snap_number]) {
							pie(total_outer_radius, 360 / connector_snap_number - connector_snap_angle, total_height + plate_thickness + connector_snap_thickness + connector_snap_horizontal_offset + 2, i * 360 / connector_snap_number);
						}
					}
				}
			}
			// closing_snaps
			if (add_closing_snaps) {
				translate([0,0,plate_thickness]) {
					closing_snap(closing_snap_height, closing_snap_radius, total_outer_radius_inner + wall_offset/2, total_outer_radius, 180 + tape_base_angle(tape_thickness + wall_thickness, total_outer_radius_inner + wall_offset), closing_snap_overlap, outer=true, closing=true, debug = debug);
					closing_snap(closing_snap_height, closing_snap_radius, total_outer_radius_inner + wall_offset/2, total_outer_radius, 180 + outlet_angle + tape_base_angle(tape_thickness + wall_thickness, total_outer_radius_inner + wall_offset), closing_snap_overlap, outer=true, closing=false, debug = debug);
				}
			}
		}
		union() {
			// inner hole
			translate([0, 0, -1]) {
				union() {
					cylinder(h = height + 2 * plate_thickness + connector_snap_thickness + connector_snap_horizontal_offset + 2, r = total_inner_radius - connector_snap_pillar_thickness);
					// cut another part of the base
					for (i = [1 : connector_snap_number]) {
						pie(total_inner_radius, 360 / connector_snap_number - connector_snap_angle, connector_snap_pillar_thickness + 2, i * 360 / connector_snap_number);
					}
				}
			}
			if (!debug) {
				round_inner_cuts(total_height + plate_thickness + connector_snap_thickness + connector_snap_horizontal_offset, total_inner_radius - connector_snap_pillar_thickness, connector_snap_pillar_thickness, resolution);
			}
		}
		if (!debug) {
			round_outer_cut(total_outer_radius, max(plate_thickness, wall_thickness), resolution);
			translate([0,0,total_height]) {
				rotate([180,0,0]) {
					round_outer_cut(total_outer_radius, wall_thickness, resolution);
				}
			}
		}
	}
}

// Helper module from https://github.com/brodykenrick/text_on_OpenSCAD
use <text_on_OpenSCAD/text_on.scad>;

module outer_part_with_text (
		height,
		outer_radius,
		inner_radius,
		outlet_angle,
		tape_thickness,
		wall_thickness,
		plate_thickness,
		wall_offset,
		add_closing_snaps=true,
		closing_snap_height,
		closing_snap_radius,
		closing_snap_overlap,
		connector_snap_number,
		connector_snap_angle,
		connector_snap_size,
		connector_snap_pillar_thickness,
		connector_snap_thickness,
		connector_snap_horizontal_offset,
		connector_snap_vertical_offset,
		debug=false,
		text_lines,
		text_content_line_1,
		text_size_line_1,
		text_font_line_1,
		text_content_line_2,
		text_size_line_2,
		text_font_line_2,
		text_content_line_3,
		text_size_line_3,
		text_font_line_3
) {
	difference() {
		outer_part(
				height,
				outer_radius,
				inner_radius,
				outlet_angle,
				tape_thickness,
				wall_thickness,
				plate_thickness,
				wall_offset,
				add_closing_snaps,
				closing_snap_height,
				closing_snap_radius,
				closing_snap_overlap,
				connector_snap_number,
				connector_snap_angle,
				connector_snap_size,
				connector_snap_pillar_thickness,
				connector_snap_thickness,
				connector_snap_horizontal_offset,
				connector_snap_vertical_offset,
				debug
		);
		translate([0,0,plate_thickness]) {
			rotate([0, 0, 270+(outlet_angle/2)]) {
				cylinderHeight = (height) / text_lines;
				// Line 1
				if (text_content_line_1 != "") {
					translate([0,0,cylinderHeight * (text_lines - 1)]) {
						text_on_cylinder(t=text_content_line_1,r=total_outer_radius_outer_part(outer_radius, wall_thickness, wall_offset), h=cylinderHeight, font=text_font_line_1, direction="ltr", size=text_size_line_1, extrusion_height=2*wall_thickness*inscription_depth);
					}
				}
				// Line 2
				if (text_lines >= 2 && text_content_line_2 != "") {
					translate([0,0,cylinderHeight * (text_lines - 2)]) {
						text_on_cylinder(t=text_content_line_2,r=total_outer_radius_outer_part(outer_radius, wall_thickness, wall_offset), h=cylinderHeight, font=text_font_line_2, direction="ltr", size=text_size_line_2, extrusion_height=2*wall_thickness*inscription_depth);
					}
				}
				// Line 3
				if (text_lines >= 3 && text_content_line_3 != "") {
					translate([0,0,cylinderHeight * (text_lines - 3)]) {
						text_on_cylinder(t=text_content_line_3,r=total_outer_radius_outer_part(outer_radius, wall_thickness, wall_offset), h=cylinderHeight, font=text_font_line_3, direction="ltr", size=text_size_line_3, extrusion_height=2*wall_thickness*inscription_depth);
					}
				}
			}
		}
	}
}

module outer_part_with_text_gate(
				height,
				outer_radius,
				inner_radius,
				outlet_angle,
				tape_thickness,
				wall_thickness,
				plate_thickness,
				wall_offset,
				add_closing_snaps=true,
				closing_snap_height,
				closing_snap_radius,
				closing_snap_overlap,
				connector_snap_number,
				connector_snap_angle,
				connector_snap_size,
				connector_snap_pillar_thickness,
				connector_snap_thickness,
				connector_snap_horizontal_offset,
				connector_snap_vertical_offset,
				debug=false,
				add_inscription=false,
				text_lines,
				text_content_line_1,
				text_size_line_1,
				text_font_line_1,
				text_content_line_2,
				text_size_line_2,
				text_font_line_2,
				text_content_line_3,
				text_size_line_3,
				text_font_line_3,
) {
	if (add_inscription) {
		outer_part_with_text(
				height,
				outer_radius,
				inner_radius,
				outlet_angle,
				tape_thickness,
				wall_thickness,
				plate_thickness,
				wall_offset,
				add_closing_snaps,
				closing_snap_height,
				closing_snap_radius,
				closing_snap_overlap,
				connector_snap_number,
				connector_snap_angle,
				connector_snap_size,
				connector_snap_pillar_thickness,
				connector_snap_thickness,
				connector_snap_horizontal_offset,
				connector_snap_vertical_offset,
				debug,
				text_lines,
				text_content_line_1,
				text_size_line_1,
				text_font_line_1,
				text_content_line_2,
				text_size_line_2,
				text_font_line_2,
				text_content_line_3,
				text_size_line_3,
				text_font_line_3
		);
	} else {
		outer_part(
				height,
				outer_radius,
				inner_radius,
				outlet_angle,
				tape_thickness,
				wall_thickness,
				plate_thickness,
				wall_offset,
				add_closing_snaps,
				closing_snap_height,
				closing_snap_radius,
				closing_snap_overlap,
				connector_snap_number,
				connector_snap_angle,
				connector_snap_size,
				connector_snap_pillar_thickness,
				connector_snap_thickness,
				connector_snap_horizontal_offset,
				connector_snap_vertical_offset,
				debug

		);
	}
}

// Functions
function tape_base_angle(thickness, total_outer_radius) = atan(thickness / (total_outer_radius));

function total_outer_radius_outer_part(outer_radius, thickness, offset) = outer_radius + 2 * thickness + offset;

// Ressources
module pie(radius, angle, height, spin=0) {
	// calculations
	ang = angle % 360;
	absAng = abs(ang);
	halfAng = absAng % 180;
	negAng = min(ang, 0);

	// submodules
	module pieCube() {
		translate([-radius - 1, 0, -1]) {
			cube([2*(radius + 1), radius + 1, height + 2]);
		}
	}

	module rotPieCube() {
		rotate([0, 0, halfAng]) {
			pieCube();
		}
	}

	if (angle != 0) {
		if (ang == 0) {
			cylinder(r=radius, h=height);
		} else {
			rotate([0, 0, spin + negAng]) {
				intersection() {
					cylinder(r=radius, h=height);
					if (absAng < 180) {
						difference() {
							pieCube();
							rotPieCube();
						}
					} else {
						union() {
							pieCube();
							rotPieCube();
						}
					}
				}
			}
		}
	}
}

module closing_snap(snapHeight, snapRadius, snapDistance, cutCylinderRadius, rotation, overlap, outer=true, closing=true, debug = false) {
	roundTip = abs(cutCylinderRadius - snapDistance) >= snapRadius && !debug;
	if (outer) {
		intersection() {
			make_snaps(snapHeight, snapRadius, snapDistance, rotation, overlap, outer, closing, roundTip);
			translate([0,0,-1]) {
				cylinder(h = snapHeight + 2, r = cutCylinderRadius);
			}
		}
	} else {
		difference() {
			make_snaps(snapHeight, snapRadius, snapDistance, rotation, overlap, outer, closing, roundTip);
			translate([0,0,-1]) {
				cylinder(h = snapHeight + 2, r = cutCylinderRadius);
			}
		}
	}

	module make_snaps(snapHeight, snapRadius, snapDistance, rotation, overlap, outer, closing, roundTip) {
		rotate([0,0,rotation]) {
			translate([snapDistance - snapRadius,0,0]) {
				// Overlap (Rotation)
				if (outer) {
					overlap = closing ? overlap : (-1) * overlap;
					rotate([0,0,asin(overlap/2)]) {
						// Outer
						translate([2 * snapRadius,0,0]) {
							make_snap(snapHeight, snapRadius, roundTip, outer);
						}
					}
				} else {
					// Inner
					make_snap(snapHeight, snapRadius, roundTip, outer);
				}
			}
		}
	}
	
	module make_snap(snapHeight, snapRadius, roundTip, outer) {
		if (roundTip) {
			if (outer) {
				cylinder(h = snapHeight - snapRadius, r = snapRadius);
				translate([0,0, snapHeight - snapRadius]) {
					sphere(r = snapRadius);
				}
			} else {
				translate([0,0, snapRadius]) {
					sphere(r = snapRadius);
					cylinder(h = snapHeight - 2 * snapRadius, r = snapRadius);
				}
				translate([0,0, snapHeight - snapRadius]) {
					sphere(r=snapRadius);
				}
			}
		} else {
			cylinder(h = snapHeight, r = snapRadius);
		}
	}
}

module round_outer_cuts(height, radius, thickness, resolution) {
	round_outer_cut(radius, thickness, resolution);
	translate([0, 0, height]) {
		rotate([180,0,0]) {
			round_outer_cut(radius, thickness, resolution);
		}
	}
}

module round_outer_cut(radius, thickness, resolution) {
	difference() {
		translate([0,0,-1]) {
			cylinder(h = thickness + 1, r = radius + 1);
		}
		rotate_extrude(convexity=convexity, $fn=resolution) {
			translate([0,-2,0]) {
				square([radius - thickness, 2 * thickness + 3]);
			}
			translate([radius - thickness, thickness, 0]) {
				circle(r=thickness, $fn=resolution);
			}
		}
	}
}

module round_inner_cuts(height, radius, thickness, resolution) {
	round_inner_cut(radius, thickness, resolution);

	translate([0, 0, height]) {
		rotate([180,0,0]) {
			round_inner_cut(radius, thickness, resolution);
		}
	}
}

module round_inner_cut(radius, thickness, resolution) {
	if (radius > 0) {
		difference() {
			union() {
				translate([0,0,-1]) {
					cylinder(h = thickness + 1, r = radius + thickness);
				}
				translate([0,0,-2]) {
					cylinder(h = (thickness + 1) + 2, r = radius);
				}
			}
			rotate_extrude(convexity=convexity, $fn=resolution) {
				translate([radius + thickness, thickness, 0]) {
					circle(r=thickness, $fn=resolution);
				}
			}
		}
	}
}

module pillar_cut(height, radius, thickness) {
	translate([-thickness + radius,thickness,0]) {
		difference() {
			translate([0,-thickness - 1,-1]) {
				cube([thickness + 1, thickness + 1, height + 2]);
			}
			union() {
				translate([0,0,thickness]) {
					cylinder(h = height - 2 * thickness, r = thickness);
				}
				translate([0,0,thickness]) {
					sphere(r = thickness);
				}
				translate([0,0,height - thickness]) {
					sphere(r = thickness);
				}
			}
		}
	}
}

module round_wall_cut(height, radius, thickness) {
	translate([(-thickness / 2) + radius,0,0]) {
		difference() {
			translate([(-thickness / 2) - 1,-thickness - 1,0]) {
				cube([thickness + 2, thickness + 1, height + 1]);
			}
			translate([0,0,-1]) {
				cylinder(h = height + 3, d = thickness);
			}
		}
	}
}

module half_wall_cut(height, radius, thickness) {
	translate([-thickness + radius,0,0]) {
		difference() {
			translate([(-thickness / 2) - 1,-thickness - 1,0]) {
				cube([thickness + 2, thickness + 1, height + 1]);
			}
			union() {
				translate([0,0,-1]) {
					cylinder(h = height - thickness + 1, r = thickness);
				}
				translate([0,0,height - thickness]) {
					sphere(r = thickness);
				}
			}
		}
	}
}

// currently not needed
/*
module double_pillar_cut(height, radius, thickness) {
	translate([(-thickness / 2) + radius,thickness + 1,0]) {
		difference() {
			translate([(-thickness / 2) - 1,-thickness - 1,-1]) {
				cube([thickness + 2, thickness + 1, height + 2]);
			}
			union() {
				translate([0,0,thickness]) {
					cylinder(h = height - 2 * thickness, d = thickness);
				}
				translate([0,0,thickness]) {
					sphere(d = thickness);
				}
				translate([0,0,height - thickness]) {
					sphere(d = thickness);
				}
			}
		}
	}
}
*/

module radius_cuts(height, radius, thickness) {
	radius_cut(radius, thickness);

	translate([0,0,height]) {
		rotate([-90,0,0]) {
			radius_cut(radius, thickness);
		}
	}
}

module radius_cut(radius, thickness) {
	translate([0,thickness,thickness]) {
		rotate([0,90,0]) {
			difference() {
				translate([0,-thickness - 1,0]) {
					cube([thickness + 1,thickness + 1,radius]);
				}
				cylinder(h = radius + 1, r = thickness);
			}
		}
	}
}

// Factory

module factory() {
// Thickness
	wall_thickness = wall_thickness < 0 ? default_thickness : wall_thickness;
	plate_thickness = plate_thickness < 0 ? default_thickness : plate_thickness;
	connector_snap_pillar_thickness = connector_snap_pillar_thickness < 0 ? default_thickness : connector_snap_pillar_thickness;
	connector_snap_thickness = connector_snap_thickness < 0 ? default_thickness : connector_snap_thickness;
	
	// Offset
	wall_offset = wall_offset < 0 ? default_offset : wall_offset;
	connector_snap_horizontal_offset = connector_snap_horizontal_offset < 0 ? default_offset : connector_snap_horizontal_offset;
	connector_snap_vertical_offset = connector_snap_vertical_offset < 0 ? default_offset : connector_snap_vertical_offset;
	
	// Closing Snaps
	closing_snap_radius = closing_snap_radius < 0 ? wall_thickness : closing_snap_radius;
	// Closing snap height is in the modules!

	if (part == 1) {
		inner_part(
				height,
				outer_radius,
				inner_radius,
				outlet_angle,
				tape_base,
				wall_thickness,
				plate_thickness,
				wall_offset,
				add_closing_snaps,
				closing_snap_height,
				closing_snap_radius,
				closing_snap_overlap,
				debug
		);
	} else if (part == 2) {
		outer_part_with_text_gate(
				height,
				outer_radius,
				inner_radius,
				outlet_angle,
				tape_thickness,
				wall_thickness,
				plate_thickness,
				wall_offset,
				add_closing_snaps,
				closing_snap_height,
				closing_snap_radius,
				closing_snap_overlap,
				connector_snap_number,
				connector_snap_angle,
				connector_snap_size,
				connector_snap_pillar_thickness,
				connector_snap_thickness,
				connector_snap_horizontal_offset,
				connector_snap_vertical_offset,
				debug,
				add_inscription,
				text_lines,
				text_content_line_1,
				text_size_line_1,
				text_font_line_1,
				text_content_line_2,
				text_size_line_2,
				text_font_line_2,
				text_content_line_3,
				text_size_line_3,
				text_font_line_3
		);
	} else if (part == 3) {
		translate([(-1) * (total_outer_radius_outer_part(outer_radius, wall_thickness, wall_offset) + ((tape_base + wall_thickness)/2)), 0, 0]) {
			inner_part(
					height,
					outer_radius,
					inner_radius,
					outlet_angle,
					tape_base,
					wall_thickness,
					plate_thickness,
					wall_offset,
					add_closing_snaps,
					closing_snap_height,
					closing_snap_radius,
					closing_snap_overlap,
					debug
			);
		}
		translate([(total_outer_radius_outer_part(outer_radius, wall_thickness, wall_offset) + ((tape_base + wall_thickness)/2)), 0, 0]) {
			outer_part_with_text_gate(
					height,
					outer_radius,
					inner_radius,
					outlet_angle,
					tape_thickness,
					wall_thickness,
					plate_thickness,
					wall_offset,
					add_closing_snaps,
					closing_snap_height,
					closing_snap_radius,
					closing_snap_overlap,
					connector_snap_number,
					connector_snap_angle,
					connector_snap_size,
					connector_snap_pillar_thickness,
					connector_snap_thickness,
					connector_snap_horizontal_offset,
					connector_snap_vertical_offset,
					debug,
					add_inscription,
					text_lines,
					text_content_line_1,
					text_size_line_1,
					text_font_line_1,
					text_content_line_2,
					text_size_line_2,
					text_font_line_2,
					text_content_line_3,
					text_size_line_3,
					text_font_line_3
			);
		}
	} else if (part == 4) {
		start_angle = -(outlet_angle);
		end_angle = -(tape_base_angle(wall_thickness + tape_thickness, outer_radius + wall_thickness + wall_offset));
		move_range = end_angle - start_angle;

		step_angle = start_angle + abs(1 - 2 * $t) * move_range;
		echo($t);
		
		total_outer_radius_inner = outer_radius + wall_thickness;
		tape_base_angle = tape_base_angle(wall_thickness, total_outer_radius_inner);

		rotate([180,0,0]) {
			color("Brown", 1) {
				rotate([0, 0, step_angle]) {
	//			rotate([0, 0, -(tape_base_angle(thickness + tape_thickness, outer_radius + thickness + offset))]) {
	//			rotate([0, 0, -(outlet_angle + tape_base_angle)]) {
					inner_part(
							height,
							outer_radius,
							inner_radius,
							outlet_angle,
							tape_base,
							wall_thickness,
							plate_thickness,
							wall_offset,
							add_closing_snaps,
							closing_snap_height,
							closing_snap_radius,
							closing_snap_overlap,
							debug
					);
				}
			}
			color("Green", 1) {
				rotate([180, 0, 0]) {
					translate([0,0, -(height + 2* plate_thickness)]) {
						outer_part_with_text_gate(
								height,
								outer_radius,
								inner_radius,
								outlet_angle,
								tape_thickness,
								wall_thickness,
								plate_thickness,
								wall_offset,
								add_closing_snaps,
								closing_snap_height,
								closing_snap_radius,
								closing_snap_overlap,
								connector_snap_number,
								connector_snap_angle,
								connector_snap_size,
								connector_snap_pillar_thickness,
								connector_snap_thickness,
								connector_snap_horizontal_offset,
								connector_snap_vertical_offset,
								debug,
								add_inscription,
								text_lines,
								text_content_line_1,
								text_size_line_1,
								text_font_line_1,
								text_content_line_2,
								text_size_line_2,
								text_font_line_2,
								text_content_line_3,
								text_size_line_3,
								text_font_line_3
						);
					}
				}
			}
		}
	}
}
factory();

// Example
// tapeholder_show();
