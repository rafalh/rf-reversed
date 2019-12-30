/*****************************************************************************
*
*  PROJECT:     Open Faction
*  LICENSE:     See LICENSE in the top level directory
*  FILE:        include/vf_format.h
*  PURPOSE:     VF (Volition Font) format documentation
*  DEVELOPERS:  Rafal Harabien
*
*****************************************************************************/

/**
 * VF is a proprietary Volition bitmap font file format used in Red Faction game.
 * 
 * Note: all fields are little-endian. On big-endian architecture bytes needs to be swapped.
 * 
 * Work is partially based on information from Roma Sorokin <sorok-roma@yandex.ru>
 **/

#pragma once

#include <stdint.h>

#pragma pack(push, 1)

#define VF_SIGNATURE 0x544E4656 // 'VFNT'

typedef struct _vf_header_t
{
    uint32_t    signature;        // should be equal to VF_SIGNATURE
    uint32_t    version;          // font version (0 or 1)
    uint32_t    format;           // exists if version >= 1, else font has VF_FMT_MONO_4 format, for values
                                  // description see vf_format_t
    uint32_t    num_chars;        // length of vf_file::chars array
    uint32_t    first_ascii;      // ascii code of first character supported by this font, usually equals
                                  // 0x20 (space character)
    uint32_t    default_spacing;  // spacing used for characters missing in the font (lower than first_ascii and
                                  // greater than first_ascii + num_chars)
    uint32_t    height;           // font height (height is the same for all characters)
    uint32_t    num_kern_pairs;   // length of vf_file::kern_pairs array
    uint32_t    kern_data_size;   // exists if version == 0, unused by RF (can be calculated from num_kern_pairs)
    uint32_t    char_data_size;   // exists if version == 0, unused by RF (can be calculated from num_chars)
    uint32_t    pixel_data_size;  // size of vf_file::pixels array
} vf_header_t;

typedef struct _vf_kern_pair_t 
{
    uint8_t char_before_idx; // index of character before spacing
    uint8_t char_after_idx;  // index of character after spacing
    int8_t  offset;          // value added to vf_char_desc_t::spacing
} vf_kern_pair_t;

typedef struct _vf_char_desc_t
{
    uint32_t    spacing;              // base spacing for this character (can be modified by kerning data), spacing is
                                      // similar to width but is used only during text rendering to update X coordinate
    uint32_t    width;                // character width in pixels, not to be confused with spacing
    uint32_t    pixel_data_offset;    // offset in vf_file::pixels, all pixels for one characters are stored in one run,
                                      // total number of pixels for a character equals:
                                      // vf_char_desc_t::width * vf_header_t::height
    uint16_t    first_kerning_entry;  // index in vf_file::kern_pairs array, entries can be checked from there because
                                      // array is sorted by character indices
    uint16_t    user_data;
} vf_char_desc_t;

enum vf_format_t
{
    VF_FMT_MONO_4 = 0xF,           // 1 byte per pixel, monochromatic, only values in range 0-14 are used
    VF_FMT_RGBA_4444 = 0xF0F0F0F,  // 2 byte per pixel, RGBA 4444 (4 bits per channel)
    VF_FMT_INDEXED = 0xFFFFFFF0    // 1 byte per pixel, indexed (palette is at the end of the file)
};

#if 0 // pseudocode

struct vf_file
{
    vf_header_t header;
    vf_kern_pair_t kern_pairs[num_kern_pairs]; // kerning data sorted by indices
    vf_char_desc_t chars[num_chars];           // character descriptors, ascii code is converted to index in this array
                                               // by substracting vf_header_t::first_ascii
    char pixels[pixel_data_size];              // raw pixel data interpreted according to vf_header_t::format
    uint32_t palette[256];                     // exists only if vf_header_t::format == VF_FMT_INDEXED, pixel data
                                               // consists of indices for this array, each entry is 32-bit BGRA color
};

#endif // pseudocode

#pragma pack(pop)
