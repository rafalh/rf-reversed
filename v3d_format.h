/*****************************************************************************
*
*  PROJECT:     Open Faction
*  LICENSE:     See LICENSE in the top level directory
*  FILE:        include/v3d_format.h
*  PURPOSE:     V3D format specification (v3m/v3c)
*  DEVELOPERS:  Rafal Harabien
*
*****************************************************************************/

#ifndef V3D_FORMAT_H_INCLUDED
#define V3D_FORMAT_H_INCLUDED

#include <stdint.h>

#ifdef C_ASSERT
#undef C_ASSERT
#define HAS_C_ASSERT
#endif
#define C_ASSERT(e) extern void __C_ASSERT__##__LINE__(int [(e)?1:-1])

C_ASSERT(sizeof(float) == 4);

#ifndef HAS_C_ASSERT
#undef C_ASSERT
#endif

#ifdef __BIG_ENDIAN__
#error Big Endian not supported
#endif

#pragma pack(push, 1)

/**
V3M and V3D has both the same format (called V3D).
V3M is used for static meshes without bones and collision spheres.
V3C is used for meshes with bones.
**/
#define V3M_SIGNATURE 0x52463344 // RF3D
#define V3C_SIGNATURE 0x5246434D // RFCM
#define V3D_VERSION 0x40000

struct v3d_file_header
{
    uint32_t signature;         // always V3M_SIGNATURE or V3C_SIGNATURE
    uint32_t version;           // always V3D_VERSION
    uint32_t num_submeshes;     // number of submesh sections
    uint32_t num_all_vertices;  // ccrunch resets to 0
    uint32_t num_all_triangles; // ccrunch resets to 0
    uint32_t unknown0;          // ccrunch resets to 0
    uint32_t num_all_materials; // total number of materials in all submeshes
    uint32_t unknown2;          // always 0 in game files
    uint32_t unknown3;          // always 0 in game files
    uint32_t num_colspheres;    // number of colsphere sections
};

struct v3d_section_header
{
    uint32_t type; // see v3d_section_type
    uint32_t size; // size of data after section header - unused for V3M_SUBMESH
};

enum v3d_section_type
{
    V3D_END       = 0x00000000, // terminating section
    V3D_SUBMESH   = 0x5355424D, // 'SUBM' see v3d_submesh
    V3D_COLSPHERE = 0x43535048, // 'CSPH' see v3d_col_sphere
    V3D_BONE      = 0x424F4E45, // 'BONE', see v3d_bones
    V3D_DUMB      = 0x44554D42, // 'DUMB', see v3d_dumb_section, removed by ccrunch
};

struct v3d_batch_info
{
    uint16_t num_vertices;
    uint16_t num_triangles;
    // some size values are with alignment
    uint16_t positions_size;
    uint16_t indices_size;
    uint16_t unknown_size;
    uint16_t bone_links_size;
    uint16_t tex_coords_size;
    uint32_t unknown3; // 0x518C41 or 0x110C21
};

enum v3d_material_flags
{
    V3D_MAT_UNK1 = 0x1,
    V3D_MAT_UNK2 = 0x8,
    V3D_MAT_TWO_SIDED = 0x10,
};

struct v3d_material
{
    char diffuse_map_name[32]; // zero terminated string
    float unk_cof;             // from 0.0 to 1.0 - used mostly with lights
    float unknown[2];          // always 0.0 in game
    float ref_cof;             // from 0.0 to 1.0 - reflection coefficient?
    char ref_map_name[32];     // zero terminated string - not empty if ref_cof>0.0
    uint32_t flags;            // bitfield - values seen in game 0x1, 0x9, 0x11, 0x19, see v3d_material_flags
};

// Alignment in v3d_lod_mesh_data
#define V3D_ALIGNMENT 0x10

struct v3d_triangle
{
    uint16_t indices[3];
    uint16_t unknown; // 0x0 or 0x20 (flags or padding?)
};

struct v3d_vertex_bones
{
    // One vertex can be linked maximaly to 4 bones
    uint8_t weights[4]; // in range 0-255, 0 if slot is unused
    uint8_t bones[4];   // bone indexes, 0xFF if slot is unused
};

struct v3d_bounding_sphere
{
    float center_x, center_y, center_z; // bounding sphere position
    float radius;                       // bounding sphere radius
};

struct v3d_aabb
{
    float aabb_x1, aabb_y1, aabb_z1; // axis aligned bounding box minima
    float aabb_x2, aabb_y2, aabb_z2; // axis aligned bounding box maxima
};

#if 0 // pseudo-code

struct v3d_batch_header
{ // this is not used by RF - only read and then over-written by values from v3d_batch_info
    char unknown[56];
  /*char unknown[40];
    uint16_t num_vertices;    // see v3d_batch_info
    uint16_t num_triangles;   // see v3d_batch_info
    uint16_t positions_size;  // see v3d_batch_info
    uint16_t indices_size;    // see v3d_batch_info
    uint16_t unknown_size;    // see v3d_batch_info
    uint16_t bone_links_size; // see v3d_batch_info
    uint16_t tex_coords_size; // see v3d_batch_info
    uint16_t unknown2;*/
};

struct v3d_batch_data
{
    float positions[v3d_batch_info::num_vertices * 3];
    // padding (align to V3D_ALIGNMENT relative to v3d_lod_mesh_data)
    float normals[v3d_batch_info::num_vertices * 3];
    // padding (align to V3D_ALIGNMENT relative to v3d_lod_mesh_data)
    float tex_coords[v3d_batch_info::num_vertices * 2];
    // padding (align to V3D_ALIGNMENT relative to v3d_lod_mesh_data)
    struct v3d_triangle triangles[v3d_batch_info::num_triangles];
    // padding (align to V3D_ALIGNMENT relative to v3d_lod_mesh_data)
    if (v3d_submesh_lod::flags & 0x20)
    {
        float unknown_planes[v3d_batch_info::num_triangles * 4];
        // padding (align to V3D_ALIGNMENT relative to v3d_lod_mesh_data)
    }
    char unknown[v3d_batch_info::unknown_size];
    // padding (align to V3D_ALIGNMENT relative to v3d_lod_mesh_data)
    if (v3d_batch_info::bone_links_size)
    {
        struct v3d_vertex_bones bone_links[v3d_batch_info::num_vertices];
        // padding (align to V3D_ALIGNMENT relative to v3d_lod_mesh_data)
    }
    if (v3d_submesh_lod::flags & 0x1)
    {
        float unknown2[v3d_submesh_lod::unknown0 * 2];
        // padding (align to V3D_ALIGNMENT relative to v3d_lod_mesh_data)
    }
};

 // Mesh LOD prop point, size 0x64
struct v3d_lod_prop
{
    char name[0x44];  // for example "thruster_11"
    float unknown[7]; // pos + rot?
    int32_t unknown2; // -1
};

struct v3d_lod_mesh_data
{
    struct v3d_batch_header batch_headers[v3d_submesh_lod::num_batches];
    // padding (align to V3D_ALIGNMENT relative to v3d_lod_mesh_data)
    struct v3d_batch_data batch_data[v3d_submesh_lod::num_batches];
    // padding (align to V3D_ALIGNMENT relative to v3d_lod_mesh_data)
    struct v3d_lod_prop unk_props[v3d_submesh_lod::num_unk_props];
};

struct v3d_texture
{
    uint8_t id;      // index in v3d_submesh::materials
    char filename[]; // zero-terminated string (copy of v3d_material::diffuse_map_name)
};

struct v3d_submesh_lod
{
    uint32_t flags; // 0x1|0x02 - characters, 0x20 - static meshes, 0x10 only driller01.v3m
    uint32_t unknown0;
    uint16_t num_batches;
    uint32_t data_size;
    char data[data_size];    // see v3d_lod_mesh_data
    int32_t unknown1;        // -1, sometimes 0
    struct v3d_batch_info batch_info[num_batches];
    uint32_t num_unk_props;  // 0, 1
    uint32_t num_textures;
    struct v3d_texture textures[num_textures];
}

/* Submesh is a single object in 3ds max project. V3D with multiple submeshes is created if during export from 3ds max
   multiple objects were selected. */

struct v3d_submesh
{
    struct v3d_section_header hdr;      // header - type V3D_SUBMESH, size is 0 after ccrunch (entire section has to be processed to find the end)
    char name[24];                      // object name in 3ds max - zero terminated string
    char unknown[24];                   // "None" or duplicated name if object belongs to 3ds max group
    uint32_t version;                   // 7 (submesh ver?) values < 7 doesnt work
    uint32_t num_lods;                  // 1 - 3
    float lod_distances[num_lods];      // 0.0, 10.0
    struct v3d_bounding_sphere bsphere; // bounding sphere
    struct v3d_aabb aabb;               // axis aligned bounding box
    struct v3d_submesh_lod lods[num_lods];
    uint32_t num_materials;
    struct v3d_material materials[num_materials];
    uint32_t unknown3;                  // always 1 in game files
    struct
    {
        char unknown[24];               // same as submesh name
        float unknown2;                 // always 0
    } unknown4[unknown3];
}

struct v3d_col_sphere
{
    struct v3d_section_header hdr; // type V3D_COLSPHERE
    char name[24];                 // colsphere name
    int32_t bone;                  // bone index or -1
    float x, y, x;                 // position relative to bone
    float r;                       // radius
};

struct v3d_bone
{
    char name[24];  // bone name, used by game
    float rot[4];   // quaternion
    float pos[3];   // bone to model translation
    int32_t parent; // bone index (root has -1)
};

struct v3d_bones
{
    struct v3d_section_header hdr; // type V3D_BONE
    uint32_t num_bones;
    struct v3d_bone bones[num_bones];
};

// dump section is removed by ccrunch - available only in v3d generated by 3ds max exporter
struct v3d_dumb_section
{
    struct v3d_section_header hdr; // type V3D_DUMB_SECTION
    char group_name[24];
    int32_t unknown[8];            // for example: FF FF FF FF 00 00 00 00 00 00 00 80 00 00 00 00
                                   //              00 00 80 3F A9 13 D0 B2 00 00 00 00 00 00 00 80
};

struct v3d_file
{
    struct v3d_file_header hdr;
    struct v3d_section sections[]; // last section has type V3D_END
};

#endif // 0

#pragma pack(pop)

#endif // V3D_FORMAT_H_INCLUDED
