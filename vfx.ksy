# VFX format reverse engineered by Rafał Harabień
meta:
  id: vfx
  title: Red Faction Effect
  application: Red Faction
  encoding: ASCII
  endian: le
  license: GPL-3.0-or-later
  file-extension: vfx

seq:
  - id: header
    type: file_header
  - id: sections
    type: section
    repeat: eos

types:
  file_header:
    seq:
      - id: signature
        contents: VSFX
      - id: version
        doc: minimal supported version is 0x30000
        type: u4
      - id: unk_0
        type: u4
        if: version >= 0x30008
      - id: end_frame
        type: u4
        doc: number of frames - 1 (15 frames per second)
      - id: num_geometric_objects
        type: u4
        doc: meshes and splines
      - id: num_lights
        type: u4
      - id: num_dummies
        type: u4
      - id: num_particle_systems
        type: u4
      - id: num_space_warps
        type: u4
      - id: num_cameras
        type: u4
      - id: num_sels
        type: u4
        if: version >= 0x3000F
      - id: num_materials
        type: u4
        if: version >= 0x40000
      - id: unk_1
        type: u4
        if: version >= 0x40002
      - id: unk_2
        type: u4
        if: version >= 0x40003
      - id: unk_3
        type: u4
        if: version >= 0x40005
      - id: unk_4
        type: u4
        if: version < 0x3000A
        doc: unused
      - id: unk_5
        type: u4
        repeat: expr
        repeat-expr: 5
      - id: unk_6
        type: u4
        if: version >= 0x3000D
      - id: unk_7
        type: u4
        if: version >= 0x30009
        repeat: expr
        repeat-expr: 5
      - id: unk_8
        type: u4
        repeat: expr
        repeat-expr: 5
      - id: unk_9
        type: u4
        if: version >= 0x3000F

  section:
    seq:
      - id: type
        type: u4
        enum: section_type
      - id: len
        type: u4
        doc: length of section in bytes
      - id: body
        size: len - 4
        type:
          switch-on: type
          cases:
            'section_type::mesh': mesh
            'section_type::material_modifier': material_modifier
            'section_type::spline': spline
            'section_type::particle_system': particle_system
            'section_type::material': material
            'section_type::camera': camera
            'section_type::light': light
            'section_type::space_warp': space_warp
            'section_type::dummy': dummy

  mesh:
    seq:
      - id: name
        type: strz
      - id: parent_name
        type: strz
        doc: '"Scene Root" or parent name in case of linked object'
      - id: unk_0
        type: s1
        enum: bool
        doc: usually false
      - id: num_vertices
        type: s4
        doc: number of vertices?
      - id: unk_1
        type: vec3
        repeat: expr
        repeat-expr: num_vertices
        if: _root.header.version < 0x3000A
        doc: positions? unused by the game engine
      - id: num_triangles
        type: s4
      - id: triangles
        type: mesh_triangle
        repeat: expr
        repeat-expr: num_triangles
      - id: fps
        type: u4
        if: _root.header.version >= 0x30009
        doc: 15 by default
      - id: unk_2
        type: f4
        if: _root.header.version >= 0x40004
      - id: unk_3
        type: f4
        if: _root.header.version >= 0x40004
      - id: num_frames
        type: s4
        if: _root.header.version >= 0x40004
        doc: num frames?
      - id: unk_2_old
        type: s4
        if: _root.header.version < 0x40004
        doc: value is divided by fps, start frame?
      - id: unk_3_old
        type: s4
        if: _root.header.version < 0x40004
        doc: value is divided by fps, end frame?
      - id: num_materials
        type: s4
      - id: materials_indices
        type: s4
        repeat: expr
        repeat-expr: num_materials
        if: _root.header.version >= 0x40000
      - id: materials
        type: 'mesh_material_old(_root.header.version >= 0x3000C ? unk_3_old - unk_2_old + 1 : unk_3_old - unk_2_old)'
        repeat: expr
        repeat-expr: num_materials
        if: _root.header.version < 0x40000
      - id: center
        type: vec3
        doc: bounding sphere offset?
      - id: radius
        type: f4
        doc: bounding sphere radius
      - id: flags_old
        type: u4
        if: _root.header.version < 0x30002
      - id: flags
        type: u4
        doc: >
          0x1 - facing,
          0x2 - no-interp,
          0x4 - morph,
          0x8 - fire,
          0x10 - fullbright,
          0x20 - seethrough,
          0x40 - corona,
          0x80 - sky,
          0x100 - dump-UVs,
          0x800 - facting-rod
      - id: unk_5
        type: f4
        repeat: expr
        repeat-expr: 2
        if: (flags & 1) != 0 and _root.header.version == 0x3000A
      - id: num_unk_6
        type: s4
        doc: number of vertices?
      - id: unk_6
        type: mesh_unk_6
        repeat: expr
        repeat-expr: num_unk_6
      - id: is_static
        type: u1
        enum: bool
        if: _root.header.version >= 0x30009
        doc: usually set to true unless its a morphed object or a child object
      - id: frames
        type: mesh_frame(_index, flags, num_vertices, num_triangles, is_static == bool::true)
        repeat: expr
        repeat-expr: '_root.header.version >= 0x40004 ? num_frames : (_root.header.version >= 0x3000C ? unk_3_old - unk_2_old + 1 : unk_3_old - unk_2_old)'
      - id: unk_7
        type: vec3
        if: is_static == bool::true and _root.header.version >= 0x3000A
        doc: translation perhaps but exporter always writes [0, 0, 0]
      - id: unk_8
        type: quat
        if: is_static == bool::true and _root.header.version >= 0x3000A
        doc: rotation perhaps but exporter always writes [0, 0, 0, 1]
      - id: unk_9
        type: vec3
        if: is_static == bool::true and _root.header.version >= 0x3000A
        doc: scale perhaps but exporter always writes [1, 1, 1]
      - id: num_translation_keyframes
        type: s4
        if: is_static == bool::true
      - id: translation_keyframes
        type: vec3_keyframe
        repeat: expr
        repeat-expr: num_translation_keyframes
        if: is_static == bool::true
        doc: translation?
      - id: num_rotation_keyframes
        type: s4
        if: is_static == bool::true
      - id: rotation_keyframes
        type: quat_keyframe
        repeat: expr
        repeat-expr: num_rotation_keyframes
        if: is_static == bool::true
        doc: rotation?
      - id: num_scale_keyframes
        type: s4
        if: is_static == bool::true
      - id: scale_keyframes
        type: vec3_keyframe
        repeat: expr
        repeat-expr: num_scale_keyframes
        if: is_static == bool::true
        doc: scale?

  mesh_material_old:
    params:
      - id: num_frames
        type: u4
    seq:
      - id: type
        type: s4
        enum: material_type
      - id: additive
        type: s1
        enum: bool
        if: _root.header.version >= 0x30003 and (type == material_type::texture or type == material_type::double_texture)
        doc: usually false, specified in Advanced Transparency section
      - id: tex_0
        type: material_texture
        if: type == material_type::texture or type == material_type::double_texture
      - id: tex_1
        type: material_texture
        if: type == material_type::double_texture
      - id: anim_offset_old
        type: s4
        if: _root.header.version < 0x30012
      - id: anim_type_old
        type: s4
        if: _root.header.version < 0x30012
      - id: unk_0
        type: f4
        if: (type == material_type::texture or type == material_type::double_texture) and _root.header.version >= 0x30007
        doc: usually 0.0
      - id: unk_1
        type: f4
        if: (type == material_type::texture or type == material_type::double_texture) and _root.header.version >= 0x30007
        doc: usually 0.0
      - id: ref_cof
        type: f4
        if: (type == material_type::texture or type == material_type::double_texture) and _root.header.version >= 0x30007
        doc: usually 0.0
      - id: ref_tex_name
        type: strz
        if: type == material_type::texture or type == material_type::double_texture
        doc: usually empty string
      - id: unk_2
        type: f4
        repeat: expr
        repeat-expr: num_frames
        if: type == material_type::double_texture
      - id: solid_color
        type: rgb_s4
        if: type == material_type::solid
      - id: self_illumination
        type: f4
        if: _root.header.version >= 0x30011
        doc: in range [0.0, 1.0]

  mesh_triangle:
    seq:
      - id: indices
        type: s4
        repeat: expr
        repeat-expr: 3
      - id: unk_0
        type: f4
        repeat: expr
        repeat-expr: 6
        if: _root.header.version < 0x3000D
      - id: colors
        type: rgb_f4
        repeat: expr
        repeat-expr: 3
      - id: normal
        type: vec3
      - id: unk_1
        type: vec3
      - id: unk_2
        type: f4
      - id: material_nr
        type: s4
      - id: unk_3
        type: s4
        repeat: expr
        repeat-expr: 4
    
  mesh_unk_6:
    seq:
      - id: unk_0
        type: s4
        doc: usually 1
      - id: unk_1
        type: s4
        doc: unknown small numbers
      - id: unk_2
        type: f4
        doc: looks like uninitialized data - 0xCDCDCDCD
      - id: unk_3
        type: f4
        doc: looks like uninitialized data - 0xCDCDCDCD
      - id: num_unk_4
        type: s4
      - id: unk_4
        type: s4
        repeat: expr
        repeat-expr: num_unk_4
        doc: triangle indices, unknown purpose
    
  mesh_frame:
    params:
      - id: index
        type: u4
      - id: flags
        type: u4
      - id: num_vertices
        type: u4
      - id: num_triangles
        type: u4
      - id: is_static
        type: bool
    seq:
      - id: center
        type: vec3
        if: (flags & 4) != 0 or index == 0
        doc: 'center position? same as _parent::center'
      - id: positions_multiplier
        type: vec3
        if: (flags & 4) != 0 or index == 0
        doc: max(abs(xyz - center))
      - id: positions
        type: vec3_s2
        repeat: expr
        repeat-expr: num_vertices
        doc: compressed positions
        if: (flags & 4) != 0 or index == 0
      - id: unk_0
        type: f4
        repeat: expr
        repeat-expr: 2
        if: ((flags & 4) != 0 or index == 0) and (flags & 0x801) != 0 and _root.header.version >= 0x3000B
      - id: unk_1
        type: vec3
        if: ((flags & 4) != 0 or index == 0) and (flags & 0x800) != 0 and index == 0 and _root.header.version >= 0x40001
      - id: uvs
        type: uv
        repeat: expr
        repeat-expr: 3 * num_triangles
        if: ((flags & 0x100) != 0 or index == 0) and _root.header.version >= 0x3000D
        doc: UV mapping, u from 3ds max, negated v from 3ds max
      - id: translation
        type: vec3
        if: (flags & 4) == 0 and (not is_static or (_root.header.version < 0x3000E and index == 0))
      - id: rotation
        type: quat
        if: (flags & 4) == 0 and (not is_static or (_root.header.version < 0x3000E and index == 0))
      - id: scale
        type: vec3
        if: (flags & 4) == 0 and (not is_static or (_root.header.version < 0x3000E and index == 0))
      - id: unk_2
        size: 1
        if: _root.header.version < 0x30009
        doc: unused by the game engine
      - id: opacity
        type: f4
        if: _root.header.version < 0x40005

  material_modifier:
    doc: unknown purpose
    seq:
      - id: material_idx
        type: u4
        if: _root.header.version >= 0x40000
      - id: material_old
        type: material_modifier_material_old
        if: _root.header.version < 0x40000

  material_modifier_material_old:
    seq:
      - id: unk_0
        type: s4
      - id: num_unk_1
        type: s4
      - id: type
        type: s4
        enum: material_type
      - id: additive
        type: s1
        enum: bool
        if: _root.header.version >= 0x30012
        doc: usually false, specified in Advanced Transparency section
      - id: tex_0
        type: material_texture
      - id: tex_1
        type: material_texture
        if: type == material_type::double_texture
      - id: unk_1
        type: f4
        repeat: expr
        repeat-expr: num_unk_1
        if: type == material_type::double_texture and _root.header.version >= 0x30012
      - id: anim_offset_old
        type: s4
        if: _root.header.version < 0x30012
      - id: anim_type_old
        type: s4
        if: _root.header.version < 0x30012
      - id: unk_2
        type: f4
        if: _root.header.version >= 0x30007
        doc: usually 0.0
      - id: unk_3
        type: f4
        if: _root.header.version >= 0x30007
        doc: usually 0.0
      - id: ref_cof
        type: f4
        if: _root.header.version >= 0x30007
        doc: usually 0.0
      - id: ref_tex_name
        type: strz
        doc: usually empty string
      - id: self_illumination
        type: f4
        if: _root.header.version >= 0x30012
        doc: in range [0.0, 1.0]
      - id: unk_4
        type: f4
        repeat: expr
        repeat-expr: num_unk_1
        if: type == material_type::double_texture and _root.header.version < 0x30012

  vec3_keyframe:
    seq:
      - id: time
        type: s4
        doc: frame number * 320
      - id: value
        type: vec3
      - id: unk_0
        type: vec3
        doc: interpolation parameters perhaps
      - id: unk_1
        type: vec3
        doc: interpolation parameters perhaps

  quat_keyframe:
    seq:
      - id: time
        type: s4
        doc: frame number * 320
      - id: value
        type: quat
      - id: unk_0
        type: f4
        repeat: expr
        repeat-expr: 5
        doc: interpolation parameters perhaps

  spline:
    seq:
      - id: name
        type: strz
      - id: parent_name
        type: strz
      - id: unk_0
        type: u1
        enum: bool
      - id: num_vertices
        type: u4
      - id: positions_old
        type: vec3
        repeat: expr
        repeat-expr: num_vertices
        if: _root.header.version < 0x3000A
      - id: width
        type: f4
        doc: width=N in User Defined Properties in 3ds max
      - id: glow_name
        type: strz
        doc: glow texture file name, glow=filename in User Defined Properties in 3ds max
      - id: flags
        type: u4
        doc: >
          0x2 - no-interp,
          0x4 - morph,
          0x8 - fire,
      - id: fps
        type: u4
        doc: 15 by default
      - id: unk_2
        type: f4
        if: _root.header.version >= 0x40004
      - id: unk_3
        type: f4
        if: _root.header.version >= 0x40004
      - id: num_frames
        type: u4
        if: _root.header.version >= 0x40004
      - id: unk_2_old
        type: u4
        if: _root.header.version < 0x40004
      - id: unk_3_old
        type: u4
        if: _root.header.version < 0x40004
      - id: is_static
        type: u1
        enum: bool
        if: _root.header.version >= 0x30009
      - id: frames
        type: spline_frame(_index, flags, num_vertices, is_static == bool::true)
        repeat: expr
        repeat-expr: '_root.header.version >= 0x40004 ? num_frames : (_root.header.version >= 0x3000C ? (unk_3_old - unk_2_old + 1) : (unk_3_old - unk_2_old))'
      - id: unk_7
        type: vec3
        if: is_static == bool::true and _root.header.version >= 0x3000A
        doc: translation perhaps but exporter always writes [0, 0, 0]
      - id: unk_8
        type: quat
        if: is_static == bool::true and _root.header.version >= 0x3000A
        doc: rotation perhaps but exporter always writes [0, 0, 0, 1]
      - id: unk_9
        type: vec3
        if: is_static == bool::true and _root.header.version >= 0x3000A
        doc: scale perhaps but exporter always writes [1, 1, 1]
      - id: num_translation_keyframes
        type: s4
        if: is_static == bool::true
      - id: translation_keyframes
        type: vec3_keyframe
        repeat: expr
        repeat-expr: num_translation_keyframes
        if: is_static == bool::true
        doc: translation?
      - id: num_rotation_keyframes
        type: s4
        if: is_static == bool::true
      - id: rotation_keyframes
        type: quat_keyframe
        repeat: expr
        repeat-expr: num_rotation_keyframes
        if: is_static == bool::true
        doc: rotation?
      - id: num_scale_keyframes
        type: s4
        if: is_static == bool::true
      - id: scale_keyframes
        type: vec3_keyframe
        repeat: expr
        repeat-expr: num_scale_keyframes
        if: is_static == bool::true
        doc: scale?

  spline_frame:
    params:
      - id: index
        type: u4
      - id: flags
        type: u4
      - id: num_vertices
        type: u4
      - id: is_static
        type: bool
    seq:
      - id: center
        type: vec3
        if: (flags & 4) != 0 or index == 0
        doc: 'center position? same as _parent::center'
      - id: positions_multiplier
        type: vec3
        if: (flags & 4) != 0 or index == 0
        doc: max(abs(xyz - center))
      - id: positions
        type: vec3_s2
        repeat: expr
        repeat-expr: num_vertices
        doc: compressed positions
        if: (flags & 4) != 0 or index == 0
      - id: translation
        type: vec3
        if: (flags & 4) == 0 and (not is_static or (_root.header.version < 0x3000E and index == 0))
      - id: rotation
        type: quat
        if: (flags & 4) == 0 and (not is_static or (_root.header.version < 0x3000E and index == 0))
      - id: scale
        type: vec3
        if: (flags & 4) == 0 and (not is_static or (_root.header.version < 0x3000E and index == 0))
      - id: unk_0
        type: u1
        enum: bool

  dummy:
    seq:
      - id: name
        type: strz
      - id: parent_name
        type: strz
      - id: unk_0
        type: u1
        enum: bool
        doc: usually false
      - id: transform
        type: vec3_quat
      - id: num_anim_transforms
        type: u4
        doc: number of frames
      - id: anim_transforms
        type: vec3_quat
        repeat: expr
        repeat-expr: num_anim_transforms

  particle_system:
    seq:
      - id: name
        type: strz
      - id: parent_name
        type: strz
      - id: unk_0
        type: u1
        enum: bool
        doc: usually false
      - id: flags
        type: u4
        if: _root.header.version >= 0x30010
        doc: >
          0x2 - apply gravity,
          0x10 - randomize orientation,
          0x20 - no cull,
          0x100 - drops
      - id: num_warps
        type: s4
      - id: warps
        type: strz
        repeat: expr
        repeat-expr: num_warps
      - id: unk_1
        type: s4
        doc: usually 4
      - id: num_frames
        type: s4
      - id: material_idx
        type: s4
        if: _root.header.version >= 0x40000
      - id: material_old
        type: particle_system_material_old(num_frames, flags)
        if: _root.header.version < 0x40000
      - id: particle_count
        type: s4
        doc: Viewport count in 3ds max
      - id: start
        type: s4
        doc: Start in Timing section in 3ds max
      - id: life
        type: s4
        doc: Life in Timing section in 3ds max * 320
      - id: life_variation
        type: f4
        doc: Life variation in Timing section in 3ds max
      - id: emitter_type
        type: s4
        doc: 0 - rectangle, 2 - spherical
      - id: flags_old
        type: s4
        if: _root.header.version < 0x30010
      - id: shrink_at_brith
        type: f4
        if: _root.header.version >= 0x30005
      - id: shrink_at_death
        type: f4
        if: _root.header.version >= 0x30005
      - id: shrink_at_brith_old
        type: s4
        if: _root.header.version < 0x30005
        doc: value is divided by 100
      - id: shrink_at_death_old
        type: s4
        if: _root.header.version < 0x30005
        doc: value is divided by 100
      - id: fade_at_birth
        type: f4
        if: _root.header.version >= 0x30006
      - id: fade_at_death
        type: f4
        if: _root.header.version >= 0x30006
      - id: tail_distance
        type: f4
        if: flags & 0x100 != 0
        doc: used for the drops type
      - id: unk_2
        size: 56
        if: _root.header.version < 0x3000D
        doc: unused by the game engine
      - id: frames
        type: particle_frame
        repeat: expr
        repeat-expr: num_frames
      
  particle_system_material_old:
    params:
      - id: num_frames
        type: u4
      - id: flags
        type: u4
    seq:
      - id: type
        type: s4
        enum: material_type
        if: (flags & 0x100) == 0
      - id: additive
        type: s1
        enum: bool
        if: _root.header.version >= 0x30003 and (type == material_type::texture or type == material_type::double_texture)
        doc: usually false, specified in Advanced Transparency section
      - id: tex_0_name
        type: strz
        if: type == material_type::texture or type == material_type::double_texture
      - id: tex_0_playback_rate
        type: s4
        if: (type == material_type::texture or type == material_type::double_texture) and _root.header.version >= 0x30012
      - id: tex_1_name
        type: strz
        if: type == material_type::double_texture
      - id: tex_1_playback_rate
        type: s4
        if: type == material_type::double_texture and _root.header.version >= 0x30012
      - id: unk_1
        type: f4
        repeat: expr
        repeat-expr: num_frames
        if: type == material_type::double_texture
      - id: solid_color
        type: rgb_s4
        if: (flags & 0x100) != 0
      - id: self_illumination
        type: f4
        if: _root.header.version >= 0x30011
        doc: in range [0.0, 1.0]

  particle_frame:
    seq:
      - id: pos
        type: vec3
      - id: orient
        type: quat
      - id: emitter_width
        type: f4
      - id: emitter_length
        type: f4
      - id: particle_size
        type: f4
      - id: speed
        type: f4
        doc: speed in m/s, speed from 3ds max / 39.37 (speed in 3ds max must be in inches/s)
      - id: speed_variation
        type: f4
        doc: speed variation in m/s, variation from 3ds max / 39.37 (speed in 3ds max must be in inches/s)
      - id: birth_rate
        type: f4
        doc: birth rate from 3ds max / 320
      - id: opacity
        type: f4
        if: _root.header.version < 0x40005
        doc: in range [0.0, 1.0]

  camera:
    seq:
      - id: name
        type: strz
      - id: parent_name
        type: strz
      - id: start_frame
        type: s4
      - id: end_frame
        type: s4
      - id: transforms
        type: vec3_quat
        repeat: expr
        repeat-expr: '_root.header.version >= 0x3000E ? (end_frame - start_frame + 1) : (end_frame - start_frame)'

  light:
    seq:
      - id: name
        type: strz
      - id: parent_name
        type: strz
      - id: unk_0
        type: u1
        enum: bool
        doc: usually false
      - id: params
        type: light_params
      - id: num_anim_frames
        type: u4
      - id: anim_frames
        type: light_params
        repeat: expr
        repeat-expr: num_anim_frames

  light_params:
    seq:
      - id: pos
        type: vec3
      - id: radius
        type: f4
        doc: Far Attenuation -> End in 3ds max
      - id: multiplier
        type: f4
      - id: color
        type: rgb_f4
      - id: is_on
        type: u1
        enum: bool

  space_warp: 
    # Most force types crash the exporter. Motor and Push types do not crash but data looks weird so most likely it
    # works by chance. It is possible that RF uses its own force types because in vfx files because space warps are
    # named VWind01 in vfx files (VWind could be a custom force type implemented in some not public Volition plugin)
    seq:
      - id: name
        type: strz
      - id: parent_name
        type: strz
      - id: unk_0
        type: s4
        doc: Basic Torque in case of Motor, Basic Force in case of Push
      - id: num_frames
        type: s4
      - id: frame_data
        type: space_warp_frame_data
        repeat: expr
        repeat-expr: num_frames
  
  space_warp_frame_data:
    seq:
      - id: pos
        type: vec3
      - id: orient
        type: quat
      - id: unk_0
        type: f4
        repeat: expr
        repeat-expr: 5

  material:
    seq:
      - id: type
        type: s4
        enum: material_type
      - id: unk_0
        type: s4
        if: _root.header.version >= 0x40003
        doc: usually 15
      - id: additive
        type: s1
        enum: bool
        if: type == material_type::texture or type == material_type::double_texture or _root.header.version >= 0x40006
        doc: usually false, specified in Advanced Transparency section
      - id: tex_0
        type: material_texture
        if: type == material_type::texture or type == material_type::double_texture
      - id: tex_1
        type: material_texture
        if: type == material_type::double_texture
      - id: num_unk_1
        type: s4
        if: type == material_type::double_texture
      - id: unk_0_legacy
        type: s4
        if: type == material_type::double_texture and _root.header.version < 0x40003
        doc: same meaning as unk_0 but used only in older versions
      - id: unk_1
        type: f4
        repeat: expr
        repeat-expr: num_unk_1
        if: type == material_type::double_texture
      - id: unk_2
        type: f4
        if: type == material_type::texture or type == material_type::double_texture
        doc: usually 0.0
      - id: unk_3
        type: f4
        if: type == material_type::texture or type == material_type::double_texture
        doc: usually 0.0
      - id: ref_cof
        type: f4
        if: type == material_type::texture or type == material_type::double_texture
        doc: usually 0.0
      - id: ref_tex_name
        type: strz
        if: type == material_type::texture or type == material_type::double_texture
        doc: usually empty string
      - id: solid_color
        type: rgb_s4
        if: type == material_type::solid
      - id: num_self_illumination
        type: s4
        if: _root.header.version >= 0x40003
        doc: usually numer of frames
      - id: self_illumination
        type: f4
        repeat: expr
        repeat-expr: '_root.header.version >= 0x40003 ? num_self_illumination : 1'
        doc: samples in range [0.0, 1.0]
      - id: num_opacity
        type: s4
        if: _root.header.version >= 0x40005
        doc: usually numer of frames
      - id: opacity
        type: f4
        repeat: expr
        repeat-expr: num_opacity
        if: _root.header.version >= 0x40005
        doc: samples in range [0.0, 1.0]

  material_texture:
    seq:
      - id: name
        type: strz
        doc: $original_map and $original_map_rgb have special meaning
      - id: anim_offset
        type: s4
        if: _root.header.version >= 0x30012
        doc: usually 0, "Start Frame" in 3ds max / 2
      - id: anim_speed
        type: f4
        if: _root.header.version >= 0x30012
        doc: usually 1.0, "Playback Rate" in 3ds max
      - id: anim_type
        type: s4
        if: _root.header.version >= 0x30012
        doc: usually 2

  vec3:
    doc: 3D vector
    seq:
      - id: x
        type: f4
        doc: negated x from 3ds max
      - id: y
        type: f4
        doc: z from 3ds max
      - id: z
        type: f4
        doc: negated y from 3ds max

  vec3_s2:
    doc: 3D vector
    seq:
      - id: x
        type: s2
      - id: y
        type: s2
      - id: z
        type: s2

  uv:
    seq:
      - id: u
        type: f4
      - id: v
        type: f4

  quat:
    doc: 3D quaternion
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      - id: w
        type: f4

  vec3_quat:
    seq:
      - id: pos
        type: vec3
        doc: position
      - id: orient
        type: quat
        doc: orientation
  
  rgb_f4:
    seq:
      - id: red
        type: f4
        doc: red channel intensity in range 0.0 - 1.0
      - id: green
        type: f4
        doc: green channel intensity in range 0.0 - 1.0
      - id: blue
        type: f4
        doc: blue channel intensity in range 0.0 - 1.0

  rgb_s4:
    seq:
      - id: red
        type: s4
        doc: red channel intensity in range 0 - 255
      - id: green
        type: s4
        doc: green channel intensity in range 0 - 255
      - id: blue
        type: s4
        doc: blue channel intensity in range 0 - 255

enums:

  section_type:
    0x4F584653: mesh              # 'sfxo', observed in many RF PC files
    0x4C54414D: material          # 'matl', observed in many RF PC files
    0x54524150: particle_system   # 'part', observed in many RF PC files
    0x534C4553: sels              # 'sels', not observed in RF PC files
    0x54474C41: light             # 'algt', observed in RF PC vfx files: Lil_RedEyeFlareLight
    0x50524157: space_warp        # 'warp', observed in RF PC vfx files: NanoAttackMissile, Explosion_TorpedoHit, fish_death, Explosion_Sub, WaterSplash01
    0x454E4843: spline            # 'chne', not observed in RF PC files
    0x444F4D4D: material_modifier # 'mmod', object named '$material_modifier' in 3ds max, not observed in RF PC files
    0x41524D43: camera            # 'cmra', not observed in RF PC files
    0x594D4D44: dummy             # 'dmmy', observed in RF PC vfx files: CTFflag-red, CTFflag-blue, grabber_thrusterfx, fighter01, spike_thrusterfx, spiketribeam, Cutscene08_fx, Cutscene09_fx

  bool:
    0: false
    1: true

  material_type:
    0: texture
    1: double_texture
    2: solid
