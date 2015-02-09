height = 20;
outer_radius = 30;
inner_radius = 10;

outlet = 60;

tape_base = 5;

thickness = 2;

offset = 0.2;

resolution = 150;

color("Brown", 1) {
  inner_part(height, outer_radius, inner_radius, outlet, tape_base, thickness, offset);
}
color("Green", 1) {
  rotate([180, 0, 0]) {
    translate([0,0, -(height + 2* thickness)]) {
      outer_part(height, outer_radius, inner_radius, thickness, offset);
    }
  }
}

$fn = resolution;

module inner_part(height, outer_radius, inner_radius, outlet, tape_base, thickness, offset) {
  total_outer_radius = outer_radius + thickness;
  angle = atan(thickness / (total_outer_radius));
  tape_base = max(tape_base, (thickness + offset));

  difference() {
    union() {
      union() {
        // outer part
        difference() {
          cylinder(h = height + thickness, r = total_outer_radius);
          translate([0,0,thickness]) {
            union() {
              cylinder(h = height + 1, r = total_outer_radius - thickness);
              pie(total_outer_radius + 1, outlet, height + thickness);
            }
          }
        }
        // tape_base
        difference() {
          pie(total_outer_radius + tape_base + offset, angle, height + thickness, -angle);
          cylinder(h = height + thickness + 1, r = total_outer_radius - thickness);
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
}

module outer_part(height, outer_radius, inner_radius, thickness, offset) {
  difference() {
    union() {
      // outer part
      difference() {
        cylinder(h = height + 2 * thickness, r = outer_radius + 2 * thickness + offset);
        translate([0,0,thickness]) {
          cylinder(h = height + thickness + 1, r = outer_radius + thickness + offset);
        }
      }
      // inner part
      union() {
        cylinder(h = height + 2 * thickness + offset, r = inner_radius - thickness - offset);
        translate([0,0,height + 2 * thickness + offset]) {
          cylinder(h = thickness, r1 = inner_radius, r2= inner_radius - 2 * thickness - offset);
        }
      }
    }
    // inner hole
    translate([0, 0, -1]) {
      cylinder(h = height + 3 * thickness + offset + 2, r = inner_radius - 2 * thickness - offset);
    }
  }
}

// Resources
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
