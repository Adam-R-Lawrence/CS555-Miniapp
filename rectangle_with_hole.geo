// Gmsh script: rectangle_with_hole_refined.geo
// Creates a 2D mesh of a rectangle with a central circular hole,
// with mesh refinement near the hole boundary using Fields.

// --------------------
// Parameters
// --------------------
x_len = 2.0;       // Rectangle width
y_len = 1.5;       // Rectangle height
hole_radius = 0.3; // Radius of the circular hole
center_x = x_len / 2.0; // x-coordinate of hole center
center_y = y_len / 2.0; // y-coordinate of hole center

// Mesh Size Parameters for Refinement
coarse_mesh_size = 0.12;      // Target mesh element size far from the hole
refined_mesh_size = 0.02;     // Target mesh element size near the hole boundary
refinement_distance = 0.25;   // Distance from hole boundary over which mesh transitions
                               // from refined_mesh_size to coarse_mesh_size

// --------------------
// Geometry Definition
// --------------------
// Define corner points (use coarse_mesh_size as a fallback max size)
Point(1) = {0,      0,      0, coarse_mesh_size};
Point(2) = {x_len,  0,      0, coarse_mesh_size};
Point(3) = {x_len,  y_len,  0, coarse_mesh_size};
Point(4) = {0,      y_len,  0, coarse_mesh_size};

// Define points for the circular hole (use refined_mesh_size for points ON the boundary)
Point(5) = {center_x, center_y, 0, refined_mesh_size}; // Center (size less critical here)
Point(6) = {center_x + hole_radius, center_y, 0, refined_mesh_size}; // Right
Point(7) = {center_x, center_y + hole_radius, 0, refined_mesh_size}; // Top
Point(8) = {center_x - hole_radius, center_y, 0, refined_mesh_size}; // Left
Point(9) = {center_x, center_y - hole_radius, 0, refined_mesh_size}; // Bottom

// Define lines for the rectangle boundary
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

// Define circle arcs for the hole boundary
Circle(5) = {6, 5, 7};
Circle(6) = {7, 5, 8};
Circle(7) = {8, 5, 9};
Circle(8) = {9, 5, 6};

// Define line loops
Line Loop(1) = {1, 2, 3, 4}; // Outer boundary loop
Line Loop(2) = {5, 6, 7, 8}; // Inner boundary loop (hole)

// Define the plane surface with the hole
Plane Surface(1) = {1, 2};

// --------------------
// Physical Groups (Optional but Recommended)
// --------------------
Physical Curve("OuterBoundary", 101) = {1, 2, 3, 4};
Physical Curve("HoleBoundary", 102) = {5, 6, 7, 8};
Physical Surface("Domain", 201) = {1};

// --------------------
// Mesh Refinement using Fields
// --------------------

// Field 1: Calculate distance from the hole boundary curves
Field[1] = Distance;
// Specify the curves that form the hole boundary
Field[1].CurvesList = {5, 6, 7, 8};
// Optional: Set number of points per curve for distance calculation accuracy
// Field[1].NumPointsPerCurve = 100;

// Field 2: Threshold field to set mesh size based on distance from hole
Field[2] = Threshold;
Field[2].InField = 1; // Use Field 1 (Distance) as input

// Define mesh sizes based on distance:
Field[2].SizeMin = refined_mesh_size;    // Mesh size when distance is <= DistMin
Field[2].SizeMax = coarse_mesh_size;     // Mesh size when distance is >= DistMax
Field[2].DistMin = 0;                    // Start refinement right at the boundary
Field[2].DistMax = refinement_distance;  // Distance over which size transitions
Field[2].StopAtDistMax = 1;              // Keep SizeMax beyond DistMax (optional, good practice)
// Optional: Smooth transition using Sigmoid function (1=true, 0=false)
// Field[2].Sigmoid = 1;

// Set the Threshold field (Field 2) as the background mesh size field
Background Field = 2;

// Optional: Tell Gmsh meshing algorithms to primarily use the background field.
// Mesh.CharacteristicLengthExtendFromBoundary = 0; // 0=No, 1=Yes (Default)
// Mesh.CharacteristicLengthFromPoints = 0; // 0=No, 1=Yes (Default)
// These lines ensure the Background Field has priority over sizes defined on points/curves

// --------------------
// Meshing
// --------------------
// Choose a suitable 2D algorithm (Frontal-Delaunay often works well with fields)
Mesh.Algorithm = 6; // 6: Frontal-Delaunay, 5: Delaunay, 8: Frontal-Delaunay for Quads

// Generate the 2D mesh
Mesh 2;

// --------------------
// Saving
// --------------------
Mesh.Format = 2.2; // Gmsh legacy format v2.2 (ASCII)
Save "rectangle_with_hole_refined.msh";