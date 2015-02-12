height = 20;
outer_radius = 35;
inner_radius = 15;

outlet_angle = 90;

tape_base = 2.5;
tape_thickness = 1;

connector_snap_number = 3;
connector_snap_size = 1;
connector_snap_angle = 45;

closing_snap_height = 1;

thickness = 2;

offset = 1;

resolution = 200;

$fn = resolution;

module inner_part(height, outer_radius, inner_radius, outlet_angle, tape_base, thickness, offset) {
  total_outer_radius = outer_radius + thickness;
  tape_base = max(tape_base, (thickness + offset));
  tape_base_angle = tape_base_angle(thickness, total_outer_radius);

  union() {
    difference() {
      union() {
        union() {
          // outer part
          difference() {
            cylinder(h = height + thickness, r = total_outer_radius);
            translate([0,0,thickness]) {
              union() {
                cylinder(h = height + 1, r = total_outer_radius - thickness);
                pie(total_outer_radius + 1, outlet_angle, height + thickness);
              }
            }
          }
          // tape_base
          difference() {
            // opening
            pie(total_outer_radius + tape_base + offset, tape_base_angle, height + thickness);
            translate([0,0,-1]) {
              cylinder(h = height + thickness + 2, r = total_outer_radius - thickness);
            }
          }
        }
        // inner part
        cylinder(h = height + thickness, r = inner_radius);
      }
      // inner hole
      translate([0, 0, -1]) {
        cylinder(h = height + thickness + 2, r = inner_radius - thickness);
      }
    }
    // closing_snap
    translate([- (outer_radius + thickness / 2), 0, 0]) {
      union() {
        cylinder(h = closing_snap_height + height + thickness / 2, d = thickness);
        translate([0, 0, closing_snap_height + height + thickness / 2]) {
          sphere(d = thickness);
        }
      }
    }
  }
}

module outer_part(height, outer_radius, inner_radius, tape_thickness, connector_snap_angle, connector_snap_size, connector_snap_number, thickness, offset) {
  total_outer_radius = outer_radius + 2 * thickness + offset;

  difference() {
    union() {
      // outer part
      difference() {
        cylinder(h = height + 2 * thickness, r = total_outer_radius);
        translate([0,0,thickness]) {
          union() {
            cylinder(h = height + thickness + 2, r = total_outer_radius - thickness);
            // opening
            pie(total_outer_radius + 1, outlet_angle, height + thickness + 1);
          }
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
      // closing_snap
      rotate([180, 0, 0]) {
        rotate([0, 0, -tape_base_angle(tape_thickness + thickness, outer_radius + thickness + offset)]) {
          translate([- (outer_radius + thickness / 2), 0, - (height + 2 * thickness)]) {
            union() {
              cylinder(h = closing_snap_height + height, d = thickness + offset);
              translate([0, 0, closing_snap_height + height]) {
                sphere(d = thickness + offset);
              }
            }
          }
        }
        rotate([0, 0, -outlet_angle]) {
          translate([- (outer_radius + thickness / 2), 0, - (height + 2 * thickness)]) {
            union() {
              cylinder(h = closing_snap_height + height, d = thickness + offset);
              translate([0, 0, closing_snap_height + height]) {
                sphere(d = thickness + offset);
              }
            }
          }
        }
      }
    }
  }
}

// Functions
function tape_base_angle(thickness, total_outer_radius) = atan(thickness / (total_outer_radius));

// Ressources
/**
* pie.scad
*
* Use this module to generate a pie- or pizza- slice shape, which is particularly useful
* in combination with `difference()` and `intersection()` to render shapes that extend a
* certain number of degrees around or within a circle.
*
* This openSCAD library is part of the [dotscad](https://github.com/dotscad/dotscad)
* project.
*
* @copyright Chris Petersen, 2013
* @license http://creativecommons.org/licenses/LGPL/2.1/
* @license http://creativecommons.org/licenses/by-sa/3.0/
*
* @see http://www.thingiverse.com/thing:109467
* @source https://github.com/dotscad/dotscad/blob/master/pie.scad
*
* @param float radius Radius of the pie
* @param float angle Angle (size) of the pie to slice
* @param float height Height (thickness) of the pie
* @param float spin Angle to spin the slice on the Z axis
*/
module pie(radius, angle, height, spin=0) {
  // Negative angles shift direction of rotation
  clockwise = (angle < 0) ? true : false;
  // Support angles < 0 and > 360
  normalized_angle = abs((angle % 360 != 0) ? angle % 360 : angle % 360 + 360);
  // Select rotation direction
  rotation = clockwise ? [0, 180 - normalized_angle] : [180, normalized_angle];
  // Render
  if (angle != 0) {
    rotate([0,0,spin]) linear_extrude(height=height)
    difference() {
      circle(radius);
      if (normalized_angle < 180) {
        union() for(a = rotation)
        rotate(a) translate([-radius, 0, 0]) square(radius * 2);
      }
      else if (normalized_angle != 360) {
        intersection_for(a = rotation)
        rotate(a) translate([-radius, 0, 0]) square(radius * 2);
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

  color("Brown", 1) {
    rotate([0, 0, step_angle]) {
    //  rotate([0, 0, -(tape_base_angle(thickness + tape_thickness, outer_radius + thickness + offset))]) {
    //rotate([0, 0, -(outlet_angle)]) {
      inner_part(height, outer_radius, inner_radius, outlet_angle, tape_base, thickness, offset);
    }
  }
  color("Green", 1) {
    rotate([180, 0, 0]) {
      translate([0,0, -(height + 2* thickness + (offset / 2))]) {
        outer_part(height, outer_radius, inner_radius, tape_thickness, connector_snap_angle, connector_snap_size, connector_snap_number, thickness, offset);
      }
    }
  }
}
