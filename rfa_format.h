/*****************************************************************************
*
*  PROJECT:     Open Faction
*  LICENSE:     See LICENSE in the top level directory
*  FILE:        rfa_format.h
*  PURPOSE:     RFA format documentation
*  DEVELOPERS:  Rafał Harabień
*
*****************************************************************************/

// RFA is character animation file used by Red Faction game.
// See rfa_file for top level file structure.
// Note: RFA format uses little-endian encoding. If you use big-endian architecture conversion is necessary.

#ifndef RFA_FORMAT_H_INCLUDED
#define RFA_FORMAT_H_INCLUDED

#include <stdint.h>

// enable structure packing
#pragma pack(push, 1)

#define RFA_SIGNATURE 0x46564D56 // 'VMVF'

// RF supports version 7 and 8
#define RFA_VERSION8 0x8
#define RFA_VERSION7 0x7

// Vector in 3D space (float components)
struct rfa_vec3
{
    float x, y, z;
};

// Vector in 3D space (8 bit uint components)
struct rfa_vec3_u8
{
    uint8_t x, y, z;
};

// Quaternion (rotation in 3D space)
struct rfa_quaternion
{
    float x, y, z, w;
};

// Quaternion (rotation in 3D space)
struct rfa_quaternion_u16
{
    uint16_t x, y, z, w;
};

// Axis-aligned bounding box
struct rfa_aabb
{
    struct rfa_vec3 min;
    struct rfa_vec3 max;
};

// RFA file header
struct rfa_file_header
{
    uint32_t signature; // always RFA_SIGNATURE
    uint32_t version; // RFA_VERSION8 or RFA_VERSION7
    float unk; // delta
    float unk2; // epsilon
    uint32_t start_time;
    uint32_t end_time;
    uint32_t num_bones;
    int32_t num_morph_vertices;
    int32_t num_morph_keyframes;
    uint32_t ramp_in_time; // ramp in * 160
    uint32_t ramp_out_time; // ramp out * 160
    struct rfa_quaternion unk3;
    struct rfa_vec3 unk4;
};

// Single keyframe of bone rotation animation
struct rfa_rot_key // size = 4+4*2+4=16
{
    uint32_t time;
    struct rfa_quaternion_u16 rot; // rotation at t=time
    int8_t next_interp; // some interpolation factors
    int8_t prev_interp; // some interpolation factors
    int8_t unk3[2]; // always 0?
};

// Single keyframe of bone position animation
struct rfa_pos_key // size = 4+9*4=40
{
    uint32_t time;
    struct rfa_vec3 pos; // position at t=time
    struct rfa_vec3 prev_interp; // used for interpolation before t=time
    struct rfa_vec3 next_interp; // used for interpolation after t=time
};

// Note:
// Structures described below use variable-size arrays and conditional fields existence.
// They cannot be defined using C/C++ so they were described using C-like pseudo-code.

#if 0 // disable compilation of pseudo-code

// Offsets to other structures in the file used for faster access without a need to parse entire file
struct rfa_offsets
{
    // Offsets are relative to file beginning
    uint32_t morph_vertices_offset; // offset to rfa_morph_vertices
    uint32_t morph_keyframes_offset; // offset to rfa_morph_keyframes8 or rfa_morph_keyframes7
    uint32_t bone_offsets[rfa_file_header::num_bones]; // offsets to rfa_bone
};

// Bone animation
struct rfa_bone
{
    float unk; // 0-255?
    uint16_t num_rot_keys;
    uint16_t num_pos_keys;
    struct rfa_rot_key rot_keys[num_rot_keys];
    struct rfa_pos_key pos_keys[num_pos_keys];
};

// Morphed verices indices
struct rfa_morph_vertices
{
    uint16_t vertex_indices[rfa_file_header::num_morph_vertices];
};

// Vertices morph animation for file version 8
struct rfa_morph_keyframes8
{
    uint32_t times[rfa_file_header::num_morph_keyframes];
    if (rfa_file_header::num_morph_keyframes * rfa_file_header::num_morph_vertices > 0) {
        struct rfa_aabb aabb;
    }
    // positions relative to aabb (0 -> aabb.min, 255 -> aabb.max)
    struct rfa_vec3_u8 positions[rfa_file_header::num_morph_keyframes][rfa_file_header::num_morph_vertices];
};

// Vertices morph animation for file version 7
struct rfa_morph_keyframes7
{
    struct rfa_vec3 positions[rfa_file_header::num_morph_keyframes][rfa_file_header::num_morph_vertices];
};

// Top-level file structure
struct rfa_file
{
    struct rfa_file_header hdr;
    struct rfa_offsets offsets;
    struct rfa_bone bones[rfa_file_header::num_bones];
    struct rfa_morph_vertices morph_vertices;
    // alignment to 4
    if (rfa_file_header::version == RFA_VERSION7) {
        struct rfa_morph_keyframes7 morph_keyframes;
    }
    else {
        struct rfa_morph_keyframes8 morph_keyframes;
    }
};

#endif // pseudo-code

#pragma pack(pop)

#endif // RFA_FORMAT_H_INCLUDED
