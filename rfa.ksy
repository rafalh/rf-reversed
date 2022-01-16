# RFA format reverse engineered by:
# * Rafał Harabień (Open Faction project)
meta:
  id: rfa
  title: Red Faction Animation
  application: Red Faction
  file-extension: rfa
  license: GPL-3.0-or-later
  encoding: ASCII
  endian: le

seq:
  - id: header
    type: file_header
  - id: bones
    type: bone
    repeat: expr
    repeat-expr: header.num_bones

instances:
  morph_vert_mappings:
    pos: header.morph_vert_mappings_offset
    type: s2
    repeat: expr
    repeat-expr: header.num_morph_vertices
    doc: mapping of morphed vertices indices from this animation to mesh vertices
  morph_vert_data:
    pos: header.morph_vert_data_offset
    type: morph_vert_data
    doc: morphing data, used for facial animations, e.g. for speaking

types:
  file_header:
    seq:
      - id: magic
        contents: [0x56, 0x4D, 0x56, 0x46]
      - id: version
        type: s4
        doc: 8 or 7
      - id: pos_reduction
        type: f4
        doc: delta, unknown purpose, seems unused by the game engine
      - id: rot_reduction
        type: f4
        doc: epsilon, unknown purpose, seems unused by the game engine
      - id: start_time
        type: s4
        doc: |
          animation start time in 1/4800 s, when the animation is activated current time is initialized to this value
          so it is basically duration to cut from the beginning of the animation
      - id: end_time
        type: s4
        doc: animation end time in 1/4800 s
      - id: num_bones
        type: s4
      - id: num_morph_vertices
        type: s4
      - id: num_morph_keyframes
        type: s4
      - id: ramp_in_time
        type: s4
        doc: |
          duration of period immediately after animation start during which weights of all bones are lineary interpolated
          from 0 to their nominal value, used only for action animations, in 1/4800 s
      - id: ramp_out_time
        type: s4
        doc: |
          duration of period immediately before animation end during which weights of all bones are lineary interpolated
          from their nominal value to 0, used only for action animations, in 1/4800 s
      - id: total_rotation
        type: quat
        doc: unknown purpose, seems unused by the game engine
      - id: total_translation
        type: vec3
        doc: unknown purpose, seems unused by the game engine
      - id: morph_vert_mappings_offset
        type: s4
      - id: morph_vert_data_offset
        type: s4
      - id: bone_offsets
        type: s4
        repeat: expr
        repeat-expr: num_bones

  vec3:
    doc: 3D vector with float components
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4

  short_vec3:
    doc: 3D vector with signed char components
    seq:
      - id: x
        type: s1
      - id: y
        type: s1
      - id: z
        type: s1

  quat:
    doc: quaternion with float components
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      - id: w
        type: f4

  short_quat:
    doc: quaternion with signed short int components
    seq:
      - id: x
        type: s2
      - id: y
        type: s2
      - id: z
        type: s2
      - id: w
        type: s2

  bone:
    seq:
      - id: weight
        type: f4
        doc: |
          determines importance of the animation for this bone,
          used for mixing multiple animations together,
          in case of action animation value of 10 fully cancels state animation influence,
          should be in range 1-10
      - id: num_rotation_keys
        type: s2
      - id: num_translation_keys
        type: s2
      - id: rotation_keys
        type: rotation_key
        repeat: expr
        repeat-expr: num_rotation_keys
      - id: translation_keys
        type: translation_key
        repeat: expr
        repeat-expr: num_translation_keys

  rotation_key:
    seq:
      - id: time
        type: s4
        doc: keyframe time in 1/4800 s
      - id: rotation
        type: short_quat
        doc: rotation in this keyframe, seems inverted (RF bug?)
      - id: ease_in
        type: s1
        doc: used in unknown interpolation algorithm
      - id: ease_out
        type: s1
        doc: used in unknown interpolation algorithm
      - id: pad
        type: s2
        doc: unused, makes structure 32-bit aligned

  translation_key:
    seq:
      - id: time
        type: s4
        doc: keyframe time in 1/4800 s
      - id: translation
        type: vec3
        doc: translation in this keyframe
      - id: in_tangent
        type: vec3
        doc: Bezier interpolation in tangent
      - id: out_tangent
        type: vec3
        doc: Bezier interpolation out tangent

  morph_vert_data:
    seq:
      - id: times
        type: s4
        repeat: expr
        repeat-expr: _root.header.num_morph_keyframes
        if: _root.header.version >= 8
      - id: bbox_min
        type: vec3
        if: _root.header.version >= 8 and _root.header.num_morph_keyframes * _root.header.num_morph_vertices > 0
      - id: bbox_max
        type: vec3
        if: _root.header.version >= 8 and _root.header.num_morph_keyframes * _root.header.num_morph_vertices > 0
      - id: keyframes
        type: morph_keyframe_data
        repeat: expr
        repeat-expr: _root.header.num_morph_keyframes
  
  morph_keyframe_data:
    seq:
      - id: positions
        type: short_vec3
        repeat: expr
        repeat-expr: _root.header.num_morph_vertices
        if: _root.header.version >= 8
      - id: positions_v7
        type: vec3
        repeat: expr
        repeat-expr: _root.header.num_morph_vertices
        if: _root.header.version < 8
