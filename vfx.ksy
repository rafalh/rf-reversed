# VFX format reverse engineered by Rafał Harabień
meta:
  id: vfx
  title: Red Faction Effect
  application: Red Faction
  file-extension: vfx
  license: GPL-3.0-or-later
  encoding: ASCII
  endian: le

seq:
  - id: header
    type: file_header
  - id: sections
    type: section
    repeat: eos

types:
  file_header:
    seq:
      - id: magic
        contents: VSFX
      - id: version
        doc: minimal supported version is 0x30000 but the game uses 0x30008+
        type: s4
      - id: flags
        type: s4
        if: version >= 0x30008
      - id: end_frame
        type: s4
        doc: number of frames - 1 (15 frames per second)
      - id: num_meshes
        type: s4
        doc: total number of meshes and chains in this file, used for memory allocation
      - id: num_lights
        type: s4
        doc: total number of lights in this file, used for memory allocation
      - id: num_dummies
        type: s4
        doc: total number of dummies in this file, used for memory allocation
      - id: num_particle_systems
        type: s4
        doc: total number of particle systems in this file, used for memory allocation
      - id: num_spacewarps
        type: s4
        doc: total number of spacewarps in this file, used for memory allocation
      - id: num_cameras
        type: s4
        doc: total number of cameras in this file, used for memory allocation
      - id: num_selsets
        type: s4
        if: version >= 0x3000F
        doc: total number of spacewarps in this file, used for memory allocation
      - id: num_materials
        type: s4
        if: version >= 0x40000
        doc: total number of materials in this file, used for memory allocation
      - id: num_mix_frames
        type: s4
        if: version >= 0x40002
        doc: total number of mix frames in all materials, used for memory allocation
      - id: num_self_illumination_frames
        type: s4
        if: version >= 0x40003
        doc: total number of self illumination frames in all materials, used for memory allocation
      - id: num_opacity_frames
        type: s4
        if: version >= 0x40005
        doc: total number of opacity frames in all materials, used for memory allocation
      - id: unk_1
        type: s4
        if: version < 0x3000A
        doc: unused
      - id: num_faces
        type: s4
        doc: total number of faces in all meshes, used for memory allocation
      - id: num_mesh_material_indices
        type: s4
        doc: total number of material indices in all meshes, used for memory allocation
      - id: num_vertex_normals
        type: s4
        doc: total number of mesh_face_vertex objects in all meshes, used for memory allocation
      - id: num_adjacent_faces
        type: s4
        doc: total number of all adjacent faces in all mesh_face_vertex objects in all meshes, used for memory allocation
      - id: num_mesh_frames
        type: s4
        doc: total number of mesh frames in all meshes, used for memory allocation
      - id: num_uv_frames
        type: s4
        if: version >= 0x3000D
        doc: total number of uv frames in all meshes, used for memory allocation
      - id: num_mesh_transform_frames
        type: s4
        if: version >= 0x30009
        doc: total number of mesh transform frames in all meshes (mesh frames with transformations), used for memory allocation
      - id: num_mesh_transform_keyframe_lists
        type: s4
        if: version >= 0x30009
        doc: total number of mesh_transform_keyframe_list in all meshes, used for memory allocation
      - id: num_mesh_translation_keys
        type: s4
        if: version >= 0x30009
        doc: total number of translation keys in all mesh_transform_keyframe_list objects, used for memory allocation
      - id: num_mesh_rotation_keys
        type: s4
        if: version >= 0x30009
        doc: total number of rotation keys in all mesh_transform_keyframe_list objects, used for memory allocation
      - id: num_mesh_scale_keys
        type: s4
        if: version >= 0x30009
        doc: total number of scale keys in all mesh_transform_keyframe_list objects, used for memory allocation
      - id: num_light_frames
        type: s4
        doc: total number of light frames in all lights, used for memory allocation
      - id: num_dummy_frames
        type: s4
        doc: total number of dummy frames in all dummies, used for memory allocation
      - id: num_part_sys_frames
        type: s4
        doc: total number of particle system frames in all particle systems, used for memory allocation
      - id: num_spacewarp_frames
        type: s4
        doc: total number of spacewarp frames in all spacewarps, used for memory allocation
      - id: num_camera_frames
        type: s4
        doc: total number of camera frames in all cameras, used for memory allocation
      - id: num_selset_objects
        type: s4
        if: version >= 0x3000F
        doc: total number of selset objects in this file, used for memory allocation

  section:
    seq:
      - id: type
        type: s4
        enum: section_type
      - id: len
        type: s4
        doc: length of section in bytes
      - id: body
        size: len - 4
        type:
          switch-on: type
          cases:
            'section_type::mesh': mesh
            'section_type::material_modifier': material_modifier
            'section_type::chain': chain
            'section_type::particle_system': particle_system
            'section_type::material': material
            'section_type::camera': camera
            'section_type::light': light
            'section_type::spacewarp': spacewarp
            'section_type::dummy': dummy

  mesh:
    seq:
      - id: name
        type: strz
      - id: parent_name
        type: strz
        doc: '"Scene Root" or parent name in case of linked object'
      - id: save_parent
        type: s1
        enum: bool
        doc: usually false, seems unused by the game engine
      - id: num_vertices
        type: s4
        doc: number of vertices
      - id: unk_0
        type: vec3
        repeat: expr
        repeat-expr: num_vertices
        if: _root.header.version < 0x3000A
        doc: positions perhaps, unused by the game engine
      - id: num_faces
        type: s4
      - id: faces
        type: mesh_face
        repeat: expr
        repeat-expr: num_faces
      - id: frames_per_second
        type: s4
        if: _root.header.version >= 0x30009
        doc: 15 by default
      - id: start_time
        type: f4
        if: _root.header.version >= 0x40004
      - id: end_time
        type: f4
        if: _root.header.version >= 0x40004
      - id: num_frames
        type: s4
        if: _root.header.version >= 0x40004
        doc: num frames?
      - id: start_frame
        type: s4
        if: _root.header.version < 0x40004
        doc: start time divided by frames_per_second, affects mesh and blending factor animation
      - id: end_frame
        type: s4
        if: _root.header.version < 0x40004
        doc: end time divided by frames_per_second, does not seem to be used by the game engine
      - id: num_materials
        type: s4
      - id: materials_indices
        type: s4
        repeat: expr
        repeat-expr: num_materials
        if: _root.header.version >= 0x40000
      - id: materials
        type: 'mesh_material_old(_root.header.version >= 0x3000C ? end_frame - start_frame + 1 : end_frame - start_frame)'
        repeat: expr
        repeat-expr: num_materials
        if: _root.header.version < 0x40000
      - id: bounding_center
        type: vec3
        doc: bounding sphere center
      - id: bounding_radius
        type: f4
        doc: bounding sphere radius
      - id: flags_old
        type: s4
        if: _root.header.version < 0x30002
      - id: flags
        type: mesh_flags
      - id: width
        type: f4
        if: flags.facing and _root.header.version == 0x3000A
      - id: height
        type: f4
        if: flags.facing and _root.header.version == 0x3000A
      - id: num_face_vertices
        type: s4
      - id: face_vertices
        type: mesh_face_vertex
        repeat: expr
        repeat-expr: num_face_vertices
        doc: also called vertex_normal
      - id: is_keyframed
        type: u1
        enum: bool
        if: _root.header.version >= 0x30009
        doc: set to true unless its a morphed object or a child object
      - id: frames
        type: mesh_frame(_index, num_vertices, num_faces, flags.facing, flags.facing_rod, flags.morph, flags.dump_uvs, is_keyframed == bool::true)
        repeat: expr
        repeat-expr: '_root.header.version >= 0x40004 ? num_frames : (_root.header.version >= 0x3000C ? end_frame - start_frame + 1 : end_frame - start_frame)'
      - id: pivot_translation
        type: vec3
        if: is_keyframed == bool::true and _root.header.version >= 0x3000A
        doc: translation performed before keyframe transform
      - id: pivot_rotation
        type: quat
        if: is_keyframed == bool::true and _root.header.version >= 0x3000A
        doc: rotation performed before keyframe transform
      - id: pivot_scale
        type: vec3
        if: is_keyframed == bool::true and _root.header.version >= 0x3000A
        doc: scale performed before keyframe transform, it seems exporter always writes [1, 1, 1]
      - id: keyframes
        type: mesh_transform_keyframe_list
        if: is_keyframed == bool::true

  mesh_transform_keyframe_list:
    seq:
      - id: num_translation_keyframes
        type: s4
      - id: translation_keyframes
        type: vec3_keyframe
        repeat: expr
        repeat-expr: num_translation_keyframes
      - id: num_rotation_keyframes
        type: s4
      - id: rotation_keyframes
        type: quat_keyframe
        repeat: expr
        repeat-expr: num_rotation_keyframes
      - id: num_scale_keyframes
        type: s4
      - id: scale_keyframes
        type: vec3_keyframe
        repeat: expr
        repeat-expr: num_scale_keyframes

  mesh_flags:
    seq:
      - id: raw
        type: u4
    instances:
      facing:
        value: (raw & 0x00000001) != 0
      no_interp:
        value: (raw & 0x00000002) != 0
      morph:
        value: (raw & 0x00000004) != 0
      fire:
        value: (raw & 0x00000008) != 0
      fullbright:
        value: (raw & 0x00000010) != 0
      seethrough:
        value: (raw & 0x00000020) != 0
      corona:
        value: (raw & 0x00000040) != 0
      sky:
        value: (raw & 0x00000080) != 0
      dump_uvs:
        value: (raw & 0x00000100) != 0
      facing_rod:
        value: (raw & 0x00000800) != 0

  mesh_material_old:
    params:
      - id: num_frames
        type: s4
    seq:
      - id: type
        type: s4
        enum: material_type
      - id: additive
        type: s1
        enum: bool
        if: _root.header.version >= 0x30003 and (type == material_type::image or type == material_type::vmix)
        doc: usually false, specified in Advanced Transparency section
      - id: tex_0
        type: material_texture
        if: type == material_type::image or type == material_type::vmix
      - id: tex_1
        type: material_texture
        if: type == material_type::vmix
      - id: start_frame_old
        type: s4
        if: (type == material_type::image or type == material_type::vmix) and _root.header.version < 0x30012
      - id: anim_type_old
        type: s4
        if: (type == material_type::image or type == material_type::vmix) and _root.header.version < 0x30012
      - id: specular_level
        type: f4
        if: (type == material_type::image or type == material_type::vmix) and _root.header.version >= 0x30007
        doc: usually 0.0, used for lighting
      - id: glossiness
        type: f4
        if: (type == material_type::image or type == material_type::vmix) and _root.header.version >= 0x30007
        doc: usually 0.0, used for lighting
      - id: reflection_amount
        type: f4
        if: (type == material_type::image or type == material_type::vmix) and _root.header.version >= 0x30007
        doc: usually 0.0
      - id: refl_tex_name
        type: strz
        if: type == material_type::image or type == material_type::vmix
        doc: usually empty string
      - id: mix_frames
        type: f4
        repeat: expr
        repeat-expr: num_frames
        if: type == material_type::vmix
      - id: solid_color
        type: rgb_s4
        if: type == material_type::color_only
      - id: self_illumination
        type: f4
        if: _root.header.version >= 0x30011
        doc: in range [0.0, 1.0]

  mesh_face:
    seq:
      - id: indices
        type: s4
        repeat: expr
        repeat-expr: 3
      - id: uvs
        type: uv
        repeat: expr
        repeat-expr: 3
        if: _root.header.version < 0x3000D
      - id: colors
        type: rgb_f4
        repeat: expr
        repeat-expr: 3
      - id: normal
        type: vec3
      - id: center
        type: vec3
      - id: radius
        type: f4
      - id: material_index
        type: s4
        doc: |
          in version >= 0x40000 it is 0-based index for materials_indices array or -1 in case of no material
          in version < 0x40000 it is 1-based index in materials array
      - id: smoothing_group
        type: s4
      - id: face_vertex_indices
        type: s4
        repeat: expr
        repeat-expr: 3
    
  mesh_face_vertex:
    seq:
      - id: smoothing_group
        type: s4
        doc: usually 1
      - id: vertex_index
        type: s4
        doc: index in position array, purpose is unclear
      - id: u
        type: f4
        doc: looks like uninitialized data - 0xCDCDCDCD, was used for U texture coordinate in ancient versions
      - id: v
        type: f4
        doc: looks like uninitialized data - 0xCDCDCDCD, was used for V texture coordinate in ancient versions
      - id: num_adjacent_faces
        type: s4
      - id: adjacent_faces
        type: s4
        repeat: expr
        repeat-expr: num_adjacent_faces
        doc: face indices, used for vertex normal calculation
    
  mesh_frame:
    params:
      - id: index
        type: s4
      - id: num_vertices
        type: s4
      - id: num_faces
        type: s4
      - id: facing
        type: bool
      - id: facing_rod
        type: bool
      - id: morph
        type: bool
      - id: dump_uvs
        type: bool
      - id: is_keyframed
        type: bool
    seq:
      - id: center
        type: vec3
        if: morph or index == 0
        doc: 'center position? same as _parent::center'
      - id: positions_multiplier
        type: vec3
        if: morph or index == 0
        doc: max(abs(xyz - center))
      - id: positions
        type: vec3_s2
        repeat: expr
        repeat-expr: num_vertices
        doc: compressed positions, to uncompress multiply by positions_multiplier and add center
        if: morph or index == 0
      - id: width
        type: f4
        if: (morph or index == 0) and (facing or facing_rod) and _root.header.version >= 0x3000B
      - id: height
        type: f4
        if: (morph or index == 0) and (facing or facing_rod) and _root.header.version >= 0x3000B
      - id: up_vector
        type: vec3
        if: (morph or index == 0) and facing_rod and index == 0 and _root.header.version >= 0x40001
      - id: uvs
        type: uv
        repeat: expr
        repeat-expr: 3 * num_faces
        if: (dump_uvs or index == 0) and _root.header.version >= 0x3000D
        doc: UV mapping, u from 3ds max, negated v from 3ds max
      - id: translation
        type: vec3
        if: not morph and (not is_keyframed or (_root.header.version < 0x3000E and index == 0))
      - id: rotation
        type: quat
        if: not morph and (not is_keyframed or (_root.header.version < 0x3000E and index == 0))
      - id: scale
        type: vec3
        if: not morph and (not is_keyframed or (_root.header.version < 0x3000E and index == 0))
      - id: unk_0
        size: 1
        if: _root.header.version < 0x30009
        doc: unused by the game engine
      - id: opacity
        type: f4
        if: _root.header.version < 0x40005

  material_modifier:
    doc: unknown purpose
    seq:
      - id: material_index
        type: s4
        if: _root.header.version >= 0x40000
      - id: material_old
        type: material_modifier_material_old
        if: _root.header.version < 0x40000

  material_modifier_material_old:
    seq:
      - id: frames_per_second
        type: s4
        if: _root.header.version >= 0x30009
      - id: num_mix_frames
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
        if: type == material_type::vmix
      - id: mix_frames
        type: f4
        repeat: expr
        repeat-expr: num_mix_frames
        if: type == material_type::vmix and _root.header.version >= 0x30012
      - id: start_frame_old
        type: s4
        if: _root.header.version < 0x30012
      - id: anim_type_old
        type: s4
        if: _root.header.version < 0x30012
      - id: specular_level
        type: f4
        if: _root.header.version >= 0x30007
        doc: usually 0.0, used for lighting
      - id: glossiness
        type: f4
        if: _root.header.version >= 0x30007
        doc: usually 0.0, used for lighting
      - id: reflection_amount
        type: f4
        if: _root.header.version >= 0x30007
        doc: usually 0.0
      - id: refl_tex_name
        type: strz
        doc: usually empty string
      - id: self_illumination
        type: f4
        if: _root.header.version >= 0x30012
        doc: in range [0.0, 1.0]
      - id: mix_frames_old
        type: f4
        repeat: expr
        repeat-expr: num_mix_frames
        if: type == material_type::vmix and _root.header.version < 0x30012

  vec3_keyframe:
    seq:
      - id: time
        type: s4
        doc: frame number * 320
      - id: value
        type: vec3
      - id: in_tangent
        type: vec3
        doc: interpolation parameters perhaps
      - id: out_tangent
        type: vec3
        doc: interpolation parameters perhaps

  quat_keyframe:
    seq:
      - id: time
        type: s4
        doc: frame number * 320
      - id: value
        type: quat
      - id: tension
        type: f4
      - id: continuity
        type: f4
      - id: bias
        type: f4
      - id: ease_in
        type: f4
      - id: ease_out
        type: f4

  chain:
    doc: spline in 3ds max
    seq:
      - id: name
        type: strz
      - id: parent_name
        type: strz
      - id: save_parent
        type: u1
        enum: bool
        doc: usually false, seems unused by the game engine
      - id: num_vertices
        type: s4
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
        type: chain_flags
      - id: frames_per_second
        type: s4
        doc: 15 by default
      - id: start_time
        type: f4
        if: _root.header.version >= 0x40004
      - id: end_time
        type: f4
        if: _root.header.version >= 0x40004
      - id: num_frames
        type: s4
        if: _root.header.version >= 0x40004
      - id: start_frame
        type: s4
        if: _root.header.version < 0x40004
      - id: end_frame
        type: s4
        if: _root.header.version < 0x40004
      - id: is_keyframed
        type: u1
        enum: bool
        if: _root.header.version >= 0x30009
      - id: frames
        type: chain_frame(_index, num_vertices, flags.morph, is_keyframed == bool::true)
        repeat: expr
        repeat-expr: '_root.header.version >= 0x40004 ? num_frames : (_root.header.version >= 0x3000C ? (end_frame - start_frame + 1) : (end_frame - start_frame))'
      - id: base_translation
        type: vec3
        if: is_keyframed == bool::true and _root.header.version >= 0x3000A
        doc: translation performed before keyframe transform
      - id: base_rotation
        type: quat
        if: is_keyframed == bool::true and _root.header.version >= 0x3000A
        doc: rotation performed before keyframe transform
      - id: base_scale
        type: vec3
        if: is_keyframed == bool::true and _root.header.version >= 0x3000A
        doc: scale performed before keyframe transform, it seems exporter always writes [1, 1, 1]
      - id: num_translation_keyframes
        type: s4
        if: is_keyframed == bool::true
      - id: translation_keyframes
        type: vec3_keyframe
        repeat: expr
        repeat-expr: num_translation_keyframes
        if: is_keyframed == bool::true
      - id: num_rotation_keyframes
        type: s4
        if: is_keyframed == bool::true
      - id: rotation_keyframes
        type: quat_keyframe
        repeat: expr
        repeat-expr: num_rotation_keyframes
        if: is_keyframed == bool::true
      - id: num_scale_keyframes
        type: s4
        if: is_keyframed == bool::true
      - id: scale_keyframes
        type: vec3_keyframe
        repeat: expr
        repeat-expr: num_scale_keyframes
        if: is_keyframed == bool::true

  chain_flags:
    seq:
      - id: raw
        type: u4
    instances:
      no_interp:
        value: (raw & 0x00000002) != 0
      morph:
        value: (raw & 0x00000004) != 0
      fire:
        value: (raw & 0x00000008) != 0

  chain_frame:
    params:
      - id: index
        type: s4
      - id: num_vertices
        type: s4
      - id: morph
        type: bool
      - id: is_keyframed
        type: bool
    seq:
      - id: center
        type: vec3
        if: morph or index == 0
        doc: 'center position? same as _parent::center'
      - id: positions_multiplier
        type: vec3
        if: morph or index == 0
        doc: max(abs(xyz - center))
      - id: positions
        type: vec3_s2
        repeat: expr
        repeat-expr: num_vertices
        if: morph or index == 0
        doc: compressed positions, to uncompress multiply by positions_multiplier and add center
      - id: translation
        type: vec3
        if: not morph and (not is_keyframed or (_root.header.version < 0x3000E and index == 0))
      - id: rotation
        type: quat
        if: not morph and (not is_keyframed or (_root.header.version < 0x3000E and index == 0))
      - id: scale
        type: vec3
        if: not morph and (not is_keyframed or (_root.header.version < 0x3000E and index == 0))
      - id: visible
        type: u1
        enum: bool

  dummy:
    seq:
      - id: name
        type: strz
      - id: parent_name
        type: strz
      - id: save_parent
        type: u1
        enum: bool
        doc: usually false, unknown purpose
      - id: pos
        type: vec3
        doc: position
      - id: orient
        type: quat
        doc: orientation
      - id: num_frames
        type: s4
        doc: number of frames
      - id: frames
        type: vec3_quat
        repeat: expr
        repeat-expr: num_frames

  particle_system:
    seq:
      - id: name
        type: strz
      - id: parent_name
        type: strz
      - id: save_parent
        type: u1
        enum: bool
        doc: usually false, unknown purpose
      - id: flags
        type: particle_system_flags
        if: _root.header.version >= 0x30010
      - id: num_warps
        type: s4
      - id: warps
        type: strz
        repeat: expr
        repeat-expr: num_warps
      - id: start_time
        type: s4
        doc: animation start time in 1/15 of a second
      - id: num_frames
        type: s4
      - id: material_index
        type: s4
        if: _root.header.version >= 0x40000
      - id: material_old
        type: particle_system_material_old(num_frames, flags.drops)
        if: _root.header.version < 0x40000
      - id: particle_count
        type: s4
        doc: Viewport count in 3ds max
      - id: start
        type: s4
        doc: Start in Timing section in 3ds max, in 1/15 of a second
      - id: lifetime
        type: s4
        doc: Life in Timing section in 3ds max * 320
      - id: lifetime_variation
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
        if: flags.drops
        doc: used for the drops type
      - id: unk_1
        size: 56
        if: _root.header.version < 0x3000D
        doc: unused by the game engine
      - id: frames
        type: particle_frame
        repeat: expr
        repeat-expr: num_frames
        doc: 15 fps

  particle_system_flags:
    seq:
      - id: raw
        type: u4
    instances:
      apply_gravity:
        value: (raw & 0x00000002) != 0
      randomize_orientation:
        value: (raw & 0x00000010) != 0
      no_cull:
        value: (raw & 0x00000020) != 0
      drops:
        value: (raw & 0x00000100) != 0

  particle_system_material_old:
    params:
      - id: num_frames
        type: s4
      - id: drops
        type: bool
    seq:
      - id: type
        type: s4
        enum: material_type
        if: not drops
      - id: additive
        type: s1
        enum: bool
        if: _root.header.version >= 0x30003 and (type == material_type::image or type == material_type::vmix)
        doc: usually false, specified in Advanced Transparency section
      - id: tex_0_name
        type: strz
        if: type == material_type::image or type == material_type::vmix
      - id: tex_0_playback_rate
        type: s4
        if: (type == material_type::image or type == material_type::vmix) and _root.header.version >= 0x30012
      - id: tex_1_name
        type: strz
        if: type == material_type::vmix
      - id: tex_1_playback_rate
        type: s4
        if: type == material_type::vmix and _root.header.version >= 0x30012
      - id: mix_frames
        type: f4
        repeat: expr
        repeat-expr: num_frames
        if: type == material_type::vmix
      - id: solid_color
        type: rgb_s4
        if: drops
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
      - id: width
        type: f4
      - id: height
        type: f4
      - id: drop_size
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
      - id: frames
        type: vec3_quat
        repeat: expr
        repeat-expr: '_root.header.version >= 0x3000E ? (end_frame - start_frame + 1) : (end_frame - start_frame)'

  light:
    doc: it seems it is not used by RF engine at all
    seq:
      - id: name
        type: strz
      - id: parent_name
        type: strz
      - id: save_parent
        type: u1
        enum: bool
        doc: usually false, unknown puprose
      - id: params
        type: light_params
      - id: num_frames
        type: s4
      - id: frames
        type: light_params
        repeat: expr
        repeat-expr: num_frames

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

  spacewarp: 
    # Most force types crash the exporter. Motor and Push types do not crash but data looks weird so most likely it
    # works by chance. It is possible that RF uses its own force types because in vfx files because space warps are
    # named VWind01 in vfx files (VWind could be a custom force type implemented in some non-public Volition plugin)
    seq:
      - id: name
        type: strz
      - id: parent_name
        type: strz
      - id: type
        type: s4
      - id: num_frames
        type: s4
      - id: frames
        type: spacewarp_frame
        repeat: expr
        repeat-expr: num_frames
  
  spacewarp_frame:
    seq:
      - id: pos
        type: vec3
      - id: orient
        type: quat
      - id: strength
        type: f4
      - id: decay
        type: f4
      - id: turbulence
        type: f4
      - id: frequency
        type: f4
      - id: scale
        type: f4

  material:
    seq:
      - id: type
        type: s4
        enum: material_type
      - id: frames_per_second
        type: s4
        if: _root.header.version >= 0x40003
        doc: usually 15
      - id: additive
        type: s1
        enum: bool
        if: type == material_type::image or type == material_type::vmix or _root.header.version >= 0x40006
        doc: usually false, specified in Advanced Transparency section
      - id: tex_0
        type: material_texture
        if: type == material_type::image or type == material_type::vmix
      - id: tex_1
        type: material_texture
        if: type == material_type::vmix
      - id: num_mix_frames
        type: s4
        if: type == material_type::vmix
      - id: frames_per_second_legacy
        type: s4
        if: type == material_type::vmix and _root.header.version < 0x40003
        doc: same meaning as frames_per_second but used only in older versions
      - id: mix_frames
        type: f4
        repeat: expr
        repeat-expr: num_mix_frames
        if: type == material_type::vmix
        doc: 0.0 - draw only tex_0, 1.0 - draw only tex_1, other values - blend tex_0 and tex_1
      - id: specular_level
        type: f4
        if: type == material_type::image or type == material_type::vmix
        doc: usually 0.0, used for lighting
      - id: glossiness
        type: f4
        if: type == material_type::image or type == material_type::vmix
        doc: usually 0.0, used for lighting
      - id: reflection_amount
        type: f4
        if: type == material_type::image or type == material_type::vmix
        doc: usually 0.0
      - id: refl_tex_name
        type: strz
        if: type == material_type::image or type == material_type::vmix
        doc: usually empty string
      - id: solid_color
        type: rgb_s4
        if: type == material_type::color_only
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
      - id: start_frame
        type: s4
        if: _root.header.version >= 0x30012
        doc: usually 0, "Start Frame" in 3ds max / 2
      - id: playback_rate
        type: f4
        if: _root.header.version >= 0x30012
        doc: usually 1.0, "Playback Rate" in 3ds max
      - id: anim_type
        type: s4
        enum: anim_type
        if: _root.header.version >= 0x30012
        doc: pingpong is not implemented in RF

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
    0x534C4553: selset            # 'sels', not observed in RF PC files
    0x54474C41: light             # 'algt', observed in RF PC vfx files: Lil_RedEyeFlareLight
    0x50524157: spacewarp         # 'warp', observed in RF PC vfx files: NanoAttackMissile, Explosion_TorpedoHit, fish_death, Explosion_Sub, WaterSplash01
    0x454E4843: chain             # 'chne', not observed in RF PC files
    0x444F4D4D: material_modifier # 'mmod', object named '$material_modifier' in 3ds max, not observed in RF PC files
    0x41524D43: camera            # 'cmra', not observed in RF PC files
    0x594D4D44: dummy             # 'dmmy', observed in RF PC vfx files: CTFflag-red, CTFflag-blue, grabber_thrusterfx, fighter01, spike_thrusterfx, spiketribeam, Cutscene08_fx, Cutscene09_fx

  bool:
    0: false
    1: true

  material_type:
    0: image
    1: vmix
    2: color_only

  anim_type:
    0: loop
    1: pingpong
    2: once
