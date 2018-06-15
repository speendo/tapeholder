$fn=100;

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
				rotate([0,0,asin(overlap/2)]) {
					if (outer) {
						// Outer
						translate([2 * snapRadius,0,0]) {
							make_snap(snapHeight, snapRadius, roundTip);
						}
					} else {
						// Inner
						make_snap(snapHeight, snapRadius, roundTip);
					}
				}
			}
		}
	}
	
	module make_snap(snapHeight, snapRadius, roundTip) {
		if (roundTip) {
			cylinder(h = snapHeight - snapRadius, r = snapRadius);
			translate([0,0, snapHeight-snapRadius]) {
				sphere(r = snapRadius);
			}
		} else {
			cylinder(h = snapHeight, r = snapRadius);
		}
	}
}

closing_snap(snapHeight=10, snapRadius=2, snapDistance=17, cutCylinderRadius = 14, overlap=1, rotation = 0, outer = false, closing = true);
//closing_snap(snapHeight=10, snapRadius=2, snapDistance=17, cutCylinderRadius = 20, overlap=1, rotation = 0, outer = true, closing = true);

// Outer
difference() {
	cylinder(r=20, h=8);
	translate([0,0,-1]) {
		cylinder(r=18, h=10);
	}
}

// Inner
difference() {
	cylinder(r=16, h=8);
	translate([0,0,-1]) {
		cylinder(r=14, h=10);
	}
}
