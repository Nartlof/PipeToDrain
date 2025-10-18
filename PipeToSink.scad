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
GlobalThickness = 3;
// External diameter of the pipe
PipeExternalDiamenter = 100;
// Thickness of the pipe
PipeThickness = 1;
// Level of water inside the siphon seal 
WaterLevel = 50;
// Gap between parts
Gap = 0.5;

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

echo(CupElevationFromBotton, CupElevationFromTop);

$fa = ($preview) ? $fa : 2;
$fs = ($preview) ? $fs : .2;
