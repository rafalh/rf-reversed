/*****************************************************************************
*
*  PROJECT:     Open Faction
*  LICENSE:     See LICENSE in the top level directory
*  FILE:        v3d_format.h
*  PURPOSE:     V3D format specification (v3m/v3c)
*  DEVELOPERS:  Rafał Harabień
*
*****************************************************************************/

// V3D is a 3D modelling format used by Red Faction game.
// RF mesh files have two extensions: .v3m and .v3c - they share file structure (V3D format).
// V3M is used for static meshes. It does not have bones or collision spheres.
// V3C is used for character meshes. It usually has bones and collision spheres.
// See v3d_file for top level file structure.
// Note: V3D format uses little-endian encoding. If you use big-endian architecture conversion is necessary.

#ifndef V3D_FORMAT_H_INCLUDED
#define V3D_FORMAT_H_INCLUDED

#include <stdint.h>

// Enable structure packing (no padding will be used)
#pragma pack(push, 1)

// File signature constants
#define V3M_SIGNATURE 0x52463344 // 'RF3D', uses .v3m file extension
#define V3C_SIGNATURE 0x5246434D // 'RFCM', uses .v3c file extension

// V3D version described in this file
#define V3D_VERSION 0x40000

// V3D file header
// Note: signature depends on file extension
struct v3d_file_header
{
    uint32_t signature;         // always V3M_SIGNATURE or V3C_SIGNATURE
    uint32_t version;           // always V3D_VERSION
    uint32_t num_submeshes;     // number of submesh sections
    uint32_t num_all_vertices;  // ccrunch resets to 0
    uint32_t num_all_triangles; // ccrunch resets to 0
    uint32_t unknown0;          // ccrunch resets to 0
    uint32_t num_all_materials; // total number of materials in all submeshes, sum of v3d_submesh::num_materials
                                // from all submesh sections
    uint32_t unknown1;          // always 0 in game files
    uint32_t unknown2;          // always 0 in game files
    uint32_t num_colspheres;    // number of colsphere sections
};

// Header of V3D section
struct v3d_section_header
{
    uint32_t type; // see v3d_section_type
    uint32_t size; // size of data after section header - unused for V3M_SUBMESH
};

// Section type, see v3d_section_header
enum v3d_section_type
{
    V3D_END       = 0x00000000, // terminating section
    V3D_SUBMESH   = 0x5355424D, // 'SUBM' see v3d_submesh
    V3D_COLSPHERE = 0x43535048, // 'CSPH' see v3d_col_sphere
    V3D_BONE      = 0x424F4E45, // 'BONE', see v3d_bones
    V3D_DUMB      = 0x44554D42, // 'DUMB', see v3d_dumb_section, removed by ccrunch
};

// LOD mesh geometry batch information
struct v3d_batch_info
{
    uint16_t num_vertices;
    uint16_t num_triangles;
    uint16_t positions_size;
    uint16_t indices_size;
    uint16_t same_pos_vertex_offsets_size;
    uint16_t bone_links_size;
    uint16_t tex_coords_size;
    uint32_t render_flags; // for example: 0x518C41 or 0x110C21
};

// Submesh material definition
struct v3d_material
{
    char diffuse_map_name[32]; // zero terminated string
    float emissive_factor;     // 0.0 - 1.0, maxed with ambient light, if 1.0 mesh is full bright
    float unknown[2];          // always 0.0 in game files, not used by RF engine
    float ref_cof;             // 0.0 - 1.0, reflection coefficient, not used by RF engine
    char ref_map_name[32];     // zero terminated string - not empty if ref_cof>0.0, not used by RF engine
    uint32_t flags;            // bitfield - values seen in game 0x1, 0x9, 0x11, 0x19, not used by RF engine
};

// Alignment in v3d_lod_mesh_data
#define V3D_ALIGNMENT 0x10

// Flags for v3d_triangle
enum v3d_triangle_flags
{
    V3D_TRI_DOUBLE_SIDED = 0x20, // disables back-face culling
};

// Triangle indices and flags
struct v3d_triangle
{
    uint16_t indices[3]; // vertex indices
    uint16_t flags;      // see v3d_triangle_flags
};

// Likage of vertex to bones used in v3d_batch_data
struct v3d_vertex_bones
{
    // One vertex can be linked maximaly to 4 bones
    uint8_t weights[4]; // in range 0-255, 0 if slot is unused
    uint8_t bones[4];   // bone indexes, 0xFF if slot is unused
};

// Vector in 3D space
struct v3d_vec3
{
    float x;
    float y;
    float z;
};

// Vector in 2D space
struct v3d_vec2
{
    float x;
    float y;
};

// Quaternion
struct v3d_quat
{
    float x;
    float y;
    float z;
    float w;
};

// Plane in 3D space
struct v3d_plane
{
    struct v3d_vec3 normal; // plane normal (A, B, C values)
    float dist;             // distance from point <0, 0, 0> (D value)
};

// Axis-aligned bounding box
struct v3d_aabb
{
    v3d_vec3 min; // box minima
    v3d_vec3 max; // box maxima
};

// mesh geometry batch
struct v3d_batch_header
{
    char reserved0[0x20];        // ignored by game engine (over-written in memory)
    uint32_t texture_idx;        // texture index in v3d_submesh_lod::textures array
    char reserved1[0x38 - 0x24]; // ignored by game engine (over-written in memory)
};

 // LOD mesh prop point, size 0x64, used as special point that can be referenced from the game code by name
struct v3d_lod_prop
{
    char name[0x44];     // zero-terminated string, for example "thruster_11"
    struct v3d_quat rot; // rotation
    struct v3d_vec3 pos; // position
    int32_t unknown;     // -1
};

// Flags for v3d_submesh_lod
enum v3d_lod_flags
{
    V3D_LOD_MORPH_VERTICES_MAP = 0x01, // include morph vertices mapping in v3d_batch_data, used by characters
    V3D_LOD_FLAG_2             = 0x02, // unknown, used by characters
    V3D_LOD_FLAG_10            = 0x10, // use most detailed LOD for collisions instead of least detailed, used by driller01.v3m
    V3D_LOD_TRIANGLE_PLANES    = 0x20, // causes v3d_batch_data::planes to be included, used by static meshes,
                                       // should be set if any triangle does not have V3D_TRI_DOUBLE_SIDED flag
};

// Spheres used for collision detection by characters (used in V3C files)
struct v3d_col_sphere
{
    struct v3d_section_header hdr; // type is V3D_COLSPHERE
    char name[24];                 // collision sphere name
    int32_t bone;                  // bone index or -1
    struct v3d_vec3 pos;           // center position relative to bone
    float radius;                  // sphere radius
};

// Single bone
struct v3d_bone
{
    char name[24];       // bone name, used by game
    struct v3d_quat rot; // quaternion
    struct v3d_vec3 pos; // bone to model translation
    int32_t parent;      // index of parent bone (-1 for root)
};

#define V3D_MAX_BONES 50 // maximal number of bones

// Note:
// Structures described below use variable-size arrays and conditional fields existence.
// They cannot be defined using C/C++ so they were described using C-like pseudo-code.

#if 0 // disable compilation of pseudo-code

// align to V3D_ALIGNMENT relative to v3d_lod_mesh_data struct start
#define V3D_MESH_DATA_PADDING() char _padding[((_pos + V3D_ALIGNMENT - 1) & (V3D_ALIGNMENT - 1)) - _pos]

// LOD mesh geometry batch data
// batch is a single draw-call, triangle list with a single material
struct v3d_batch_data
{
    struct v3d_vec3 positions[v3d_batch_info::num_vertices];       // vertex positions
    V3D_MESH_DATA_PADDING();
    struct v3d_vec3 normals[v3d_batch_info::num_vertices];         // vertex normals, used for lighting
                                                                   // Note: vanilla game does not use lighting with most of meshes
    V3D_MESH_DATA_PADDING();
    struct v3d_vec2 tex_coords[v3d_batch_info::num_vertices];      // UVs for diffuse texture
    V3D_MESH_DATA_PADDING();
    struct v3d_triangle triangles[v3d_batch_info::num_triangles];  // triangle indices and flags
    V3D_MESH_DATA_PADDING();
    if (v3d_submesh_lod::flags & V3D_LOD_TRIANGLE_PLANES)
    {
        struct v3d_plane planes[v3d_batch_info::num_triangles];    // triangle planes used for back-face culling
        V3D_MESH_DATA_PADDING();
    }
    int16_t same_pos_vertex_offsets[v3d_batch_info::num_vertices]; // used for triangle clipping optimization
                                                                   // if value is positive:
                                                                   // positions[i] == positions[i - same_pos_vertex_offsets[i]]
    V3D_MESH_DATA_PADDING();
    if (v3d_batch_info::bone_links_size)
    {
        struct v3d_vertex_bones bone_links[v3d_batch_info::num_vertices]; // links vertices with bones
        V3D_MESH_DATA_PADDING();
    }
    if (v3d_submesh_lod::flags & V3D_LOD_MORPH_VERTICES_MAP)
    {
        int16_t morph_vertices_map[v3d_submesh_lod::num_vertices]; // maps indices from RFA morph animation
                                                                   // (rfa_morph_vertices::vertex_indices) to indices
                                                                   // in this batch
        V3D_MESH_DATA_PADDING();
    }
};

// LOD mesh geometry data
struct v3d_lod_mesh_data
{
    struct v3d_batch_header batch_headers[v3d_submesh_lod::num_batches];
    V3D_MESH_DATA_PADDING();
    struct v3d_batch_data batch_data[v3d_submesh_lod::num_batches];
    V3D_MESH_DATA_PADDING();
    struct v3d_lod_prop prop_points[v3d_submesh_lod::num_prop_points];
};

// Texture used by v3d_submesh_lod
struct v3d_lod_texture
{
    uint8_t id;      // index in v3d_submesh::materials
    char filename[]; // zero-terminated string (copy of v3d_material::diffuse_map_name)
};

// Submesh level of details mesh
struct v3d_submesh_lod
{
    uint32_t flags;           // see v3d_lod_flags
    uint32_t num_vertices;    // number of vertices
    uint16_t num_batches;     // number of geometry batches
    uint32_t data_size;       // size of data
    char data[data_size];     // actual geometry data, see v3d_lod_mesh_data
    int32_t unknown1;         // -1, sometimes 0
    struct v3d_batch_info batch_info[num_batches];
    uint32_t num_prop_points; // number of prop points, usually 0 or 1
    uint32_t num_textures;    // number of textures used by this LOD, max 7
    struct v3d_lod_texture textures[num_textures]; // textures used by this LOD
};

// Submesh section
// Submesh is a single object in 3ds max project. Game renders all submeshes of a single V3D.
// V3D with multiple submeshes is created if multiple objects are selected during export from 3ds max
struct v3d_submesh
{
    struct v3d_section_header hdr;         // header, type is V3D_SUBMESH, size is 0 after ccrunch
                                           // (entire section has to be processed to find the end)
    char name[24];                         // object name in 3ds max, zero-terminated string
    char unknown0[24];                     // "None" or duplicated name if object belongs to 3ds max group
    uint32_t version;                      // 7, unknown (submesh version?), values < 7 do not work
    uint32_t num_lods;                     // number of levels of detail, must be in range 1 - 3
    float lod_distances[num_lods];         // minimal distance from object to camera for LOD to be used,
                                           // ascending order, example: [0, 10, 100]
    struct v3d_vec3 offset;                // mesh offset in 3D space
    float radius;                          // radius of bounding sphere
    struct v3d_aabb aabb;                  // axis-aligned bounding box
    struct v3d_submesh_lod lods[num_lods]; // level of detail meshes, most detailed first
    uint32_t num_materials;                // number of materials used by this submesh
    struct v3d_material materials[num_materials]; // materials used by this submesh
    uint32_t num_unknown1;                 // always 1 in game files
    struct
    {
        char unknown0[24];                 // usually the same as submesh name
        float unknown1;                    // always 0
    } unknown1[num_unknown1];
};

// Bones section (used in V3C files)
struct v3d_bones
{
    struct v3d_section_header hdr;    // type is V3D_BONE
    uint32_t num_bones;               // number of bones (for limit see V3D_MAX_BONES)
    struct v3d_bone bones[num_bones]; // bones array
};

// Dump section, removed by ccrunch, exists only in v3d generated by 3ds max exporter
struct v3d_dumb_section
{
    struct v3d_section_header hdr; // type is V3D_DUMB_SECTION
    char group_name[24];
    int32_t unknown[8];            // for example: FF FF FF FF 00 00 00 00 00 00 00 80 00 00 00 00
                                   //              00 00 80 3F A9 13 D0 B2 00 00 00 00 00 00 00 80
};

// General description of V3D section
// v3d_section_header should be used to determine section type and size
// Note: v3d_submesh section has invalid size in header so it has to be fully parsed
union v3d_section
{
    struct v3d_section_header hdr;
    struct v3d_submesh submesh;
    struct v3d_bones bones;
    struct v3d_colsphere colsphere;
};

// V3D file top-level structure
struct v3d_file
{
    struct v3d_file_header hdr;    // file header
    struct v3d_section sections[]; // sections array, last section has type V3D_END
};

#endif // 0

#pragma pack(pop)

#endif // V3D_FORMAT_H_INCLUDED
