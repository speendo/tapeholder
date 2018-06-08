height = 40;
outer_radius = 57;
inner_radius = 25;

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
convexity = 3;

$fn = resolution;

module inner_part(height, outer_radius, inner_radius, outlet_angle, tape_base, closing_snap_height, closing_snap_offset_share, thickness, offset) {
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
							round_outer_cut(total_outer_radius, thickness, resolution);
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
								round_outer_cuts(height + thickness, total_outer_radius + tape_base, thickness, resolution);
								pillar_cut(height + thickness, total_outer_radius + tape_base, thickness);
								radius_cuts(height + thickness, total_outer_radius + tape_base, thickness);
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

module outer_part(height, outer_radius, inner_radius, tape_thickness, closing_snap_height, connector_snap_angle, connector_snap_size, connector_snap_number, thickness, offset) {
	total_outer_radius = outer_radius + 2 * thickness + offset;
	
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
					round_outer_cuts(height + 2 * thickness, total_outer_radius, thickness, resolution);
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
				round_inner_cuts(height + 3 * thickness + offset, inner_radius - 2 * thickness - offset, thickness, resolution);
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

// Functions
function tape_base_angle(thickness, total_outer_radius) = atan(thickness / (total_outer_radius));

// Ressources
module pie(radius, angle, height, spin=0) {
<<<<<<< HEAD
	// submodules
	module pieCube() {
		translate([-radius - 1, 0, -1]) {
			cube([2*(radius + 1), radius, height + 2]);
		}
	}

	ang = abs(angle % 360);
	
	negAng = angle < 0 ? angle : 0;
	
	rotate([0,0,negAng + spin]) {
		if (angle == 0) {
			cylinder(r=radius, h=height);
		} else if (abs(angle) > 0 && ang <= 180) {
			difference() {
				intersection() {
					cylinder(r=radius, h=height);
					translate([0,0,0]) {
						pieCube();
					}
				}
				rotate([0, 0, ang]) {
					pieCube();
				}
			}
		} else if (ang > 180) {
			intersection() {
				cylinder(r=radius, h=height);
				union() {
					translate([0, 0, 0]) {
						pieCube();
					}
					rotate([0, 0, ang - 180]) {
						pieCube();
=======
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
>>>>>>> 9477ffd8272bad6835fb144ef1fcbec04c86153a
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

// Example
tapeholder_show();

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
			inner_part(height, outer_radius, inner_radius, outlet_angle, tape_base, closing_snap_height, closing_snap_offset_share, thickness, offset);
		}
	}
	color("Green", 1) {
		rotate([180, 0, 0]) {
			translate([0,0, -(height + 2 * thickness)]) {
				outer_part(height, outer_radius, inner_radius, tape_thickness, closing_snap_height, connector_snap_angle, connector_snap_size, connector_snap_number, thickness, offset);
			}
		}
	}
}
