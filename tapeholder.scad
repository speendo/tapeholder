/* [Basic Properties] */

// Part to be computed
part = "Both Parts"; // [Inner Part, Outer Part, Both Parts, Animated Preview]

// Preview mode (no round corners - computes faster)
debug = true;

// Resolution (start low, raise before compilation)
resolution = 50;

/* [Basic Features] */

// Height (in mm)
height = 42;
// Outer Radius (in mm)
outer_radius = 29;
// Inner Radius (in mm)
inner_radius = 12;

/* [Thickness and Offset] */
// Wall Thickness (in mm)
thickness = 1.2;

// Offset between Inner and Outer Part (in mm)
offset = 0.2;

// Z-Offset should be higher

/* [Opening Features] */

// Opening Angle (in Deg)
outlet_angle = 90; //[0:0.5:360]

// Length of the Opening Notch e.g. to stick the tape on (in mm)
tape_base = 3;

/* [Connection Features] */

// Number of Snaps
connector_snap_number = 2;

// Clip Size (in mm)
connector_snap_size = 2.5;

// Snap Angle (in Deg)
connector_snap_angle = 140;

/* [Opening and Closing Snaps] */
// Snap Height on the inner part (in mm)
closing_snap_height = 1;

// Share of the Offset Value to be used for the Snaps (smaller values shifts Snaps down)
closing_snap_offset_share = 1; // [0:0.01:1]

// Tape Thickness - determines the position of the open/close openings in the outer part (in mm)
tape_thickness = 0.25;

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
text_size_line_1 = 10;

// Text Size Line 2
text_size_line_2 = 10;

// Text Size Line 3
text_size_line_3 = 10;

// Font Line 1 (depends on which fonts are installed)
text_font_line_1 = "Liberation Mono";

// Font Line 2 (depends on which fonts are installed)
text_font_line_2 = "Liberation Mono";

// Font Line 3 (depends on which fonts are installed)
text_font_line_3 = "Liberation Mono";

// Inscription Depth (as share of thickness)
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
		closing_snap_height,
		closing_snap_offset_share,
		thickness,
		offset,
		debug = false
) {
	total_outer_radius = outer_radius + thickness;
	tape_base = max(tape_base, (thickness + offset));
	tape_base_angle = tape_base_angle(thickness, total_outer_radius);

	union() {
		difference() {
//			render(convexity=convexity) { // this doesn't have any effect but makes preview much faster
				union() {
					union() {
						// outer part
						difference() {
							cylinder(h = height + thickness, r = total_outer_radius);
							if (!debug) {
								round_outer_cut(total_outer_radius, thickness, resolution);
							}
							translate([0,0,thickness]) {
								union() {
									cylinder(h = height + 1, r = total_outer_radius - thickness);
									pie(total_outer_radius + 1, outlet_angle, height + thickness, tape_base_angle);
								}
							}
						}
						// tape_base
						difference() {
							// opening
							difference() {
								pie(total_outer_radius + tape_base, tape_base_angle, height + thickness);
								if (!debug) {
									round_outer_cuts(height + thickness, total_outer_radius + tape_base, thickness, resolution);
									pillar_cut(height + thickness, total_outer_radius + tape_base, thickness);
									radius_cuts(height + thickness, total_outer_radius + tape_base, thickness);
								}
							}
							translate([0,0,-1]) {
								cylinder(h = height + thickness + 2, r = total_outer_radius - thickness);
							}
						}
					}
					// inner part
					cylinder(h = height + thickness, r = inner_radius);
				}
//			}
			// inner hole
			translate([0, 0, -1]) {
				cylinder(h = height + thickness + 2, r = inner_radius - thickness);
			}
		}
		// closing_snap
		translate([- (outer_radius + thickness / 2), 0, thickness]) { // moved up by thickness because of the rounded edge
			union() {
				cylinder(h = closing_snap_height + height + (offset * closing_snap_offset_share) - thickness / 2, d = thickness); // is offset right here?
				translate([0, 0, closing_snap_height + height + (offset * closing_snap_offset_share) - thickness / 2]) { // is offset right here?
					sphere(d = thickness);
				}
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
		closing_snap_height,
		connector_snap_angle,
		connector_snap_size,
		connector_snap_number,
		thickness,
		offset,
		debug=false
) {
	total_outer_radius = total_outer_radius_outer_part(outer_radius, thickness, offset);
	
	total_outer_radius_inner = outer_radius + thickness;
	tape_base_angle = tape_base_angle(thickness, total_outer_radius_inner);

	difference() {
//		render(convexity=convexity) { // this doesn't have any effect but makes preview much faster
			union() {
				// outer part
				difference() {
					cylinder(h = height + 2 * thickness, r = total_outer_radius);
					translate([0,0,thickness]) {
						union() {
							cylinder(h = height + thickness + 1, r = total_outer_radius - thickness);
							// opening
							pie(total_outer_radius + 1, outlet_angle + tape_base_angle, height + thickness + 1);
						}
					}
					if (!debug) {
						round_outer_cuts(height + 2 * thickness, total_outer_radius, thickness, resolution);
					}
				}
				difference() {
					// inner part
					union() {
						cylinder(h = height + 2 * thickness + offset, r = inner_radius - thickness - offset);
						translate([0,0,height + 2 * thickness + offset]) {
							cylinder(h = thickness, r1 = inner_radius + connector_snap_size - thickness, r2= inner_radius - 2 * thickness - offset);
						}
					}
					// cut connector_snaps
					translate([0, 0, -1]) {
						union() {
							for (i = [1 : connector_snap_number]) {
								pie(total_outer_radius, 360 / connector_snap_number - connector_snap_angle, height + 3 * thickness + offset + 2, i * 360 / connector_snap_number);
							}
						}
					}
				}
			}
//		}
//		render(convexity=convexity) { // this doesn't have any effect but makes preview much faster
			union() {
				// inner hole
				translate([0, 0, -1]) {
					union() {
						cylinder(h = height + 3 * thickness + offset + 2, r = inner_radius - 2 * thickness - offset);
						// cut another part of the base
						for (i = [1 : connector_snap_number]) {
							pie(inner_radius - thickness, 360 / connector_snap_number - connector_snap_angle, thickness + 2, i * 360 / connector_snap_number);
						}
					}
				}
				if (!debug) {
					round_inner_cuts(height + 3 * thickness + offset, inner_radius - 2 * thickness - offset, thickness, resolution);
				}
				// closing_snap
				rotate([180, 0, 0]) {
					rotate([0, 0, -tape_base_angle(tape_thickness + thickness, outer_radius + thickness + offset)]) {
						translate([- (outer_radius + thickness / 2), 0, - (height + 2 * thickness)]) {
							union() {
								cylinder(h = closing_snap_height + height + thickness - (thickness + offset) / 2, d = thickness + offset);
								translate([0, 0, closing_snap_height + height + thickness - (thickness + offset) / 2]) {
									sphere(d = thickness + offset);
								}
							}
						}
					}
					rotate([0, 0, -outlet_angle]) {
						translate([- (outer_radius + thickness / 2), 0, - (height + 2 * thickness)]) {
							union() {
								cylinder(h = closing_snap_height + height + thickness - (thickness + offset) / 2, d = thickness + offset);
								translate([0, 0, closing_snap_height + height + thickness - (thickness + offset) / 2]) {
									sphere(d = thickness + offset);
								}
							}
						}
					}
				}
			}
//		}
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
		closing_snap_height,
		connector_snap_angle,
		connector_snap_size,
		connector_snap_number,
		thickness,
		offset,
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
				closing_snap_height,
				connector_snap_angle,
				connector_snap_size,
				connector_snap_number,
				thickness,
				offset,
				debug
		);
		translate([0,0,thickness]) {
			rotate([0, 0, 270+(outlet_angle/2)]) {
				cylinderHeight = (height) / text_lines;
				// Line 1
				if (text_content_line_1 != "") {
					translate([0,0,cylinderHeight * (text_lines - 1)]) {
						text_on_cylinder(t=text_content_line_1,r=total_outer_radius_outer_part(outer_radius, thickness, offset), h=cylinderHeight, font=text_font_line_1, direction="ltr", size=text_size_line_1, extrusion_height=2*thickness*inscription_depth);
					}
				}
				// Line 2
				if (text_lines >= 2 && text_content_line_2 != "") {
					translate([0,0,cylinderHeight * (text_lines - 2)]) {
						text_on_cylinder(t=text_content_line_2,r=total_outer_radius_outer_part(outer_radius, thickness, offset), h=cylinderHeight, font=text_font_line_2, direction="ltr", size=text_size_line_2, extrusion_height=2*thickness*inscription_depth);
					}
				}
				// Line 3
				if (text_lines >= 3 && text_content_line_3 != "") {
					translate([0,0,cylinderHeight * (text_lines - 3)]) {
						text_on_cylinder(t=text_content_line_3,r=total_outer_radius_outer_part(outer_radius, thickness, offset), h=cylinderHeight, font=text_font_line_3, direction="ltr", size=text_size_line_3, extrusion_height=2*thickness*inscription_depth);
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
		closing_snap_height,
		connector_snap_angle,
		connector_snap_size,
		connector_snap_number,
		thickness,
		offset,
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
		text_font_line_3,
		add_inscription=false
) {
	if (add_inscription) {
		outer_part_with_text(
				height,
				outer_radius,
				inner_radius,
				outlet_angle,
				tape_thickness,
				closing_snap_height,
				connector_snap_angle,
				connector_snap_size,
				connector_snap_number,
				thickness,
				offset,
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
				closing_snap_height,
				connector_snap_angle,
				connector_snap_size,
				connector_snap_number,
				thickness,
				offset,
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
				circle(r=thickness, fn=resolution);
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
					circle(r=thickness, fn=resolution);
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
if (part == "Inner Part") {
	inner_part(
		height,
		outer_radius,
		inner_radius,
		outlet_angle,
		tape_base,
		closing_snap_height,
		closing_snap_offset_share,
		thickness,
		offset,
		debug
	);
} else if (part == "Outer Part") {
	outer_part_with_text_gate(
			height,
			outer_radius,
			inner_radius,
			outlet_angle,
			tape_thickness,
			closing_snap_height,
			connector_snap_angle,
			connector_snap_size,
			connector_snap_number,
			thickness,
			offset,
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
			text_font_line_3,
			add_inscription
	);
} else if (part == "Both Parts") {
	translate([(-1) * (total_outer_radius_outer_part(outer_radius, thickness, offset) + ((tape_base + thickness)/2)), 0, 0]) {
		inner_part(
			height,
			outer_radius,
			inner_radius,
			outlet_angle,
			tape_base,
			closing_snap_height,
			closing_snap_offset_share,
			thickness,
			offset,
			debug
		);
	}
	translate([(total_outer_radius_outer_part(outer_radius, thickness, offset) + ((tape_base + thickness)/2)), 0, 0]) {
		outer_part_with_text_gate(
				height,
				outer_radius,
				inner_radius,
				outlet_angle,
				tape_thickness,
				closing_snap_height,
				connector_snap_angle,
				connector_snap_size,
				connector_snap_number,
				thickness,
				offset,
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
				text_font_line_3,
				add_inscription
		);
	}
} else if (part == "Animated Preview") {
	start_angle = -(outlet_angle);
	end_angle = -(tape_base_angle(thickness + tape_thickness, outer_radius + thickness + offset));
	move_range = end_angle - start_angle;

	step_angle = start_angle + abs(1 - 2 * $t) * move_range;
	echo($t);
	
	total_outer_radius_inner = outer_radius + thickness;
	tape_base_angle = tape_base_angle(thickness, total_outer_radius_inner);

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
						closing_snap_height,
						closing_snap_offset_share,
						thickness,
						offset,
						debug
				);
			}
		}
		color("Green", 1) {
			rotate([180, 0, 0]) {
				translate([0,0, -(height + 2 * thickness)]) {
					outer_part_with_text_gate(
							height,
							outer_radius,
							inner_radius,
							outlet_angle,
							tape_thickness,
							closing_snap_height,
							connector_snap_angle,
							connector_snap_size,
							connector_snap_number,
							thickness,
							offset,
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
							text_font_line_3,
							add_inscription
					);
				}
			}
		}
	}
}

// Example
// tapeholder_show();

module tapeholder_show() {

	start_angle = -(outlet_angle);
	end_angle = -(tape_base_angle(thickness + tape_thickness, outer_radius + thickness + offset));
	move_range = end_angle - start_angle;

	step_angle = start_angle + abs(1 - 2 * $t) * move_range;
	echo($t);
	
	total_outer_radius_inner = outer_radius + thickness;
	tape_base_angle = tape_base_angle(thickness, total_outer_radius_inner);

	color("Brown", 1) {
		//rotate([0, 0, step_angle]) {
		//rotate([0, 0, -(tape_base_angle(thickness + tape_thickness, outer_radius + thickness + offset))]) {
		rotate([0, 0, -(outlet_angle + tape_base_angle)]) {
			inner_part(
					height,
					outer_radius,
					inner_radius,
					outlet_angle,
					tape_base,
					closing_snap_height,
					closing_snap_offset_share,
					thickness,
					offset,
					debug
			);
		}
	}
	color("Green", 1) {
		rotate([180, 0, 0]) {
			translate([0,0, -(height + 2 * thickness)]) {
				outer_part(
						height,
						outer_radius,
						inner_radius,
						outlet_angle,
						tape_thickness,
						closing_snap_height,
						connector_snap_angle,
						connector_snap_size,
						connector_snap_number,
						thickness,
						offset,
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
						text_font_line_3,
						add_inscription
				);
			}
		}
	}
}
