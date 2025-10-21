/**
 * Project Name : PipeToDrain
 *
 * Author: Carlos Eduardo Foltran
 * GitHub: https://github.com/Nartlof/PipeToDrain
 * Thingiverse: [Thingiverse Project URL]
 * License: Creative Commons CC0 1.0 Universal (CC0 1.0)
 * Description: This is an adaptor to transfor an open end of a pipe into a siphoned drain
 *
 * Date Created: 20251018
 * Last Updated: [Date of last modification]
 *
 * This OpenSCAD file is provided under the Creative Commons CC0 1.0 Universal (CC0 1.0) License.
 * You are free to use, modify, and distribute this design for any purpose, without any restrictions.
 *
 * For more details about the CC0 license, visit: https://creativecommons.org/publicdomain/zero/1.0/
 */

// Thickness of the piece
GlobalThickness = 2;
// External diameter of the pipe
PipeExternalDiamenter = 100;
// Thickness of the pipe
PipeThickness = 1;
// Level of water inside the siphon seal 
WaterLevel = 50;
// Space bellow the grid
DrainSpace = 20;
// Screew's head diameter
ScreewHeadDiamenter = 8;
// Screew's pass-throu diameter
ScreewPassDiameter = 4;
// Screew's engaging diameter
ScreewEngageDiameter = 3;
// Gap between parts
Gap = 0.5;

// Calculating the height of screew's head
ScreewHeadHeight = (ScreewHeadDiamenter - ScreewEngageDiameter) / 2;

// Calculating the external diameter of the adapter considering the gap
DrainExternalDiameter = PipeExternalDiamenter - 2 * PipeThickness - 2 * Gap;
DrainInternalDiameter = DrainExternalDiameter - 2 * GlobalThickness;
// The nominal diameter of the part is used to calculate the relations of areas
DrainNominalDiametar = (DrainExternalDiameter + DrainInternalDiameter) / 2;
// As the flow of water is diveded into 3 parts, all diameters are calculated so the area
// for the flow is constant, so flow area is 1/3 of the total area
FlowArea = (PI * DrainNominalDiametar ^ 2 / 4) / 3;
// Calculating the diameter of the exit from the flow area
ExitNominalDiameter = sqrt(4 * FlowArea / PI);
ExitExternalDiameter = ExitNominalDiameter + GlobalThickness;
ExitInternalDiameter = ExitNominalDiameter - GlobalThickness;
// The cup diameter is such as it has twice the area for the flow
CupNominalDiameter = sqrt(4 * 2 * FlowArea / PI);
CupExternalDiameter = CupNominalDiameter + GlobalThickness;
CupInternalDiameter = CupNominalDiameter - GlobalThickness;
// The distance from the edge of the cup to the botton of the drain must be 
// such that the area of the flow is preserved, So:
// FlowArea = CupElevationFromBotton * CupNominalDiameter * PI
CupElevationFromBotton = FlowArea / (CupNominalDiameter * PI);
// Same thing for the space above the exit pipe.
CupElevationFromTop = FlowArea / (ExitNominalDiameter * PI);
// The total internal height of the cup must be the WaterLevel pluss the elevation from the top
CupInternalHeigth = CupElevationFromTop + WaterLevel;
// The heigth of the exit pipe is the Waterlevel pluss the elevation of the cup from the botton
ExitInternalHeigth = CupElevationFromBotton + WaterLevel;
// The total height of the drain is the sum of all internal heights pluss the space above the cup
DrainExternalHeight = GlobalThickness + CupElevationFromBotton + WaterLevel + CupElevationFromTop + GlobalThickness + DrainSpace;

$fa = ($preview) ? $fa : 2;
$fs = ($preview) ? $fs : .2;

function FilletIntersection(FilletRadius) =
  let (height = (FilletRadius + GlobalThickness) / 2) height + (2 * height * (1 - cos(30)) * tan(60));

module Fillet(FilletInternalRadius = 10) {
  union() {
    // This is the circular part corresponding to a 60deg arch
    intersection() {
      rotate(a=-30)
        square(size=FilletInternalRadius + GlobalThickness, center=false);
      square(size=FilletInternalRadius + GlobalThickness, center=false);
      difference() {
        circle(r=FilletInternalRadius + GlobalThickness);
        circle(r=FilletInternalRadius);
      }
    }
    // this is the straigth part
    intersection() {
      square(size=FilletInternalRadius + GlobalThickness, center=false);
      rotate(a=60)
        translate(v=[FilletInternalRadius, 0])
          square(size=[GlobalThickness, FilletInternalRadius], center=false);
    }
  }
}

module MainBodyCut() {
  FilletRadiusExternal = (DrainInternalDiameter - CupExternalDiameter) / 2;
  FilletRadiusInternal = (CupInternalDiameter - ExitExternalDiameter) / 2;
  // External Wall
  translate(v=[DrainInternalDiameter / 2, FilletRadiusExternal + GlobalThickness, 0])
    square(size=[GlobalThickness, DrainExternalHeight - FilletRadiusExternal - GlobalThickness], center=false);
  // Botton
  translate(v=[ExitInternalDiameter / 2 + FilletIntersection(FilletRadius=FilletRadiusInternal), 0])
    square(
      size=[
        (DrainExternalDiameter - ExitInternalDiameter) / 2 - FilletIntersection(FilletRadius=FilletRadiusInternal) - FilletIntersection(FilletRadius=FilletRadiusExternal),
        GlobalThickness,
      ], center=false
    );
  // Internal Wall
  translate(v=[ExitInternalDiameter / 2, FilletRadiusInternal + GlobalThickness])
    square(size=[GlobalThickness, ExitInternalHeigth - FilletRadiusInternal], center=false);
  // External fillet
  translate(v=[DrainInternalDiameter / 2 - FilletRadiusExternal, FilletRadiusExternal + GlobalThickness])
    mirror(v=[0, 1, 0])
      Fillet(FilletInternalRadius=FilletRadiusExternal);
  // Internal fillet
  translate(v=[FilletRadiusInternal + GlobalThickness + ExitInternalDiameter / 2, FilletRadiusInternal + GlobalThickness, 0])
    rotate(a=180)
      Fillet(FilletInternalRadius=FilletRadiusInternal);
}

module CupCut() {
  // Calculating the fillet radius.
  FilletInternalRadius = (CupInternalDiameter - ExitExternalDiameter) / 2;
  // This is the cylindrical wall
  translate(v=[CupInternalDiameter / 2, 0])
    square(size=[GlobalThickness, CupInternalHeigth - FilletInternalRadius], center=false);
  // This is the top part
  translate(v=[0, CupInternalHeigth])
    difference() {
      translate(v=[ScreewPassDiameter / 2, 0])
        square(size=[(CupExternalDiameter - ScreewPassDiameter) / 2 - FilletIntersection(FilletRadius=FilletInternalRadius), GlobalThickness], center=false);
      //This is the chanfer for the screew head
      translate(v=[0, -Gap])
        rotate(a=45)
          square(size=[ScreewHeadDiamenter, GlobalThickness], center=false);
    }
  // This is the fillet
  translate(v=[CupInternalDiameter / 2 - FilletInternalRadius, CupInternalHeigth - FilletInternalRadius])
    Fillet(FilletInternalRadius);
}

module MainBody() // make me
{
  ScreewHousingDiamenter = ScreewPassDiameter + 2 * GlobalThickness;
  rotate_extrude(angle=360, convexity=2) MainBodyCut();
  translate(v=[0, 0, CupElevationFromBotton + GlobalThickness])
    difference() {
      union() {
        intersection() {
          translate(v=[-GlobalThickness / 2, -ExitNominalDiameter / 2, 0])
            cube(size=[GlobalThickness, ExitNominalDiameter, ExitInternalHeigth - CupElevationFromBotton + CupElevationFromTop], center=false);
          union() {
            difference() {
              cylinder(h=ExitInternalHeigth - CupElevationFromBotton, d=ExitNominalDiameter, center=false);
              cylinder(h=ExitNominalDiameter * sin(30) / 2, d1=ExitNominalDiameter, d2=0, center=false);
            }
            translate(v=[0, 0, ExitInternalHeigth - CupElevationFromBotton])
              cylinder(h=CupElevationFromTop, d1=ExitNominalDiameter, d2=ScreewHousingDiamenter, center=false);
          }
        }
        translate(v=[0, 0, ExitNominalDiameter * sin(30) / 2])
          union() {
            cylinder(h=ScreewHousingDiamenter / 2, d1=0, d2=ScreewHousingDiamenter, center=false);
            translate(v=[0, 0, ScreewHousingDiamenter / 2])
              cylinder(h=ExitInternalHeigth - CupElevationFromBotton + CupElevationFromTop - ScreewHousingDiamenter / 2 - ExitNominalDiameter * sin(30) / 2, d=ScreewHousingDiamenter);
          }
      }
      translate(v=[0, 0, ExitNominalDiameter * sin(30) / 2])
        cylinder(h=ExitInternalHeigth + 2 * GlobalThickness, d=ScreewEngageDiameter, center=false);
    }
}

module Cup() // make me
{
  rotate_extrude(angle=360, convexity=2) CupCut();
}

module Washer() // make me
{
  WasherThickness = GlobalThickness + ScreewHeadHeight;
  rotate_extrude(angle=360, convexity=2)
    difference() {
      union() {
        translate(v=[ScreewPassDiameter / 2, 0])
          square(size=[1.5 * ScreewHeadDiamenter - WasherThickness / 2, WasherThickness], center=false);
        translate(v=[ScreewPassDiameter / 2 + 1.5 * ScreewHeadDiamenter - WasherThickness / 2, WasherThickness / 2])
          rotate(a=30)
            circle(d=WasherThickness, $fn=6);
      }
      translate(v=[0, -Gap])
        rotate(a=45)
          square(size=[ScreewHeadDiamenter, WasherThickness], center=false);
    }
}

Washer();

/*
translate(v=[0, 0, CupElevationFromBotton + GlobalThickness])

  %Cup();
MainBody();

/*
translate(v=[0, CupElevationFromBotton+GlobalThickness])
  CupCut();
MainBodyCut();
//*/
