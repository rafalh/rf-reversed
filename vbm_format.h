/*****************************************************************************
*
*  PROJECT:     Open Faction
*  LICENSE:     See LICENSE in the top level directory
*  FILE:        vbm_format.h
*  PURPOSE:     VBM format documentation
*  DEVELOPERS:  Rafał Harabień
*
*****************************************************************************/

/**
 * VBM (Volition Bitmap file)
 *
 * VBM is a proprietary Volition image file format used in Red Faction game.
 * VBM files are either static (only one frame) or animated (multiple frames are included).
 * Each frame contains pixel data for one or more mipmap levels.
 *
 * Note: all fields are little-endian. On big-endian architecture bytes needs to be swapped.
**/

#pragma once

#include <stdint.h>

#ifdef _MSC_VER
#pragma warning(disable : 4200)
#endif

#pragma pack(push, 1)

#define VBM_SIGNATURE 0x6D62762E // ".vbm"

enum vbm_color_format_t
{
    VBM_CF_1555 = 0,
    VBM_CF_4444 = 1,
    VBM_CF_565  = 2,
};

struct vbm_header_t
{
    int32_t signature;    // should be equal to VBM_SIGNATURE
    int32_t version;      // RF uses 1 and 2, makeVBM tool always creates files with version 1 */
    int32_t width;        // nominal image width
    int32_t height;       // nominal image height
    int32_t format;       // pixel data format, see vbm_color_format_t
    int32_t fps;          // frames per second, ignored if frames_count == 1
    int32_t num_frames;   // number of frames, always 1 for not animated VBM
    int32_t num_mipmaps;  // number of mipmap levels except for the full size (level 0)
};

#if 0 // pseudocode

struct vbm_file_t
{
    vbm_header_t  vbm_header;                        // file header
    vbm_frame_t   frames[vbm_header_t::num_frames];  // sequence of frames (at least one)
};

struct vbm_frame_t
{
    vbm_mipmap_t  mipmaps[vbm_header_t::num_mipmaps + 1];  // A frame is made of one or more mipmaps
};

struct vbm_mipmap_t
{
    uint16_t pixels[];  // Mipmaps are 16bpp images in one of three pixel formats (see format field in header)
};

#endif // pseudocode

#pragma pack(pop)
