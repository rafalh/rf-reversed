# RFM/RFC format reverse engineered by:
# * Rafał Harabień (Open Faction project)
meta:
  id: rfmc
  title: Red Faction Mesh (PS2)
  application: Red Faction
  file-extension:
    - rfm
    - rfc
  license: GPL-3.0-or-later
  encoding: ASCII
  endian: le

seq:
  - id: header
    type: file_header
  - id: sections
    type: section
    repeat: until
    repeat-until: _.type == section_type::end

types:
  file_header:
    seq:
      - id: magic
        contents: [0x12, 0x87, 0x12, 0x87]
      - id: unk0
        doc: always 0
        type: s4
      - id: version
        doc: always 1
        type: s4
      - id: num_lod_meshes
        type: s4
      - id: num_meshes
        type: s4
      - id: num_cspheres
        type: s4
      - id: num_navpoints
        type: s4
      - id: num_mesh_materials
        type: s4
  
  section:
    seq:
      - id: type
        type: u4
        enum: section_type
      - id: len
        type: s4
        doc: length of section in bytes, unused in submesh section
      - id: body
        size: len
        type:
          switch-on: type
          cases:
            'section_type::submesh': submesh
            'section_type::materials': materials
            'section_type::bones': bones
            'section_type::navpoint': navpoint
            'section_type::csphere': csphere
  
  vec3:
    doc: 3D vector
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  
  uv:
    doc: UV coordinates
    seq:
      - id: u
        type: f4
      - id: v
        type: f4
  
  quat:
    doc: Quaternion
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      - id: w
        type: f4
  
  plane:
    seq:
      - id: normal
        type: vec3
      - id: dist
        type: f4
  
  aabb:
    doc: axis aligned bounding box
    seq:
      - id: p1
        type: vec3
      - id: p2
        type: vec3

  submesh:
    seq:
      - id: dist
        type: f4
      - id: version
        type: s4
        doc: should be 3+
      - id: flags
        type: s4
      - id: num_original_vecs
        type: s4
      - id: bbox_max
        type: vec3
      - id: bbox_min
        type: vec3
      - id: bounding_center
        type: vec3
      - id: bounding_radius
        type: f4
      - id: data_block_size
        type: s4
      - id: data_block
        type: submesh_data_block
        size: data_block_size
        doc: block being processed by VIF PS2 unit
      - id: num_chunks
        type: u2
      - id: chunks
        type: submesh_chunk
        repeat: expr
        repeat-expr: num_chunks
      - id: num_tex_names
        type: s4
      - id: tex_names
        type: strz
        repeat: expr
        repeat-expr: num_tex_names
    instances:
      data:
        io: data_block._io
        pos: 0
        size-eos: true
        type: submesh_data

  submesh_chunk:
    seq:
      - id: num_vecs 
        type: u2
      - id: num_faces 
        type: u2
      - id: vecs_alloc 
        type: u2
      - id: faces_alloc 
        type: u2
      - id: wi_alloc 
        type: u2

  submesh_data:
    seq:
      - id: chunks 
        type: submesh_chunk_data(_index)
        repeat: expr
        repeat-expr: _parent.num_chunks

  submesh_chunk_data:
    params:
      - id: chunk_index
        type: s4
    seq:
      - id: positions 
        type: vec3
        repeat: expr
        repeat-expr: _parent._parent.chunks[chunk_index].num_vecs
      - id: padding0
        size: (0x10 - _io.pos) % 0x10
      - id: norms
        type: vec3
        repeat: expr
        repeat-expr: _parent._parent.chunks[chunk_index].num_vecs
      - id: padding1
        size: (0x10 - _io.pos) % 0x10
      - id: faces 
        type: vif_face
        repeat: expr
        repeat-expr: _parent._parent.chunks[chunk_index].num_faces
      - id: padding2
        size: (0x10 - _io.pos) % 0x10
      - id: wi 
        type: weight_index_array
        repeat: expr
        repeat-expr: _parent._parent.chunks[chunk_index].wi_alloc / 8
      - id: padding3
        size: (0x10 - _io.pos) % 0x10
  
  vif_face:
    seq:
      - id: vindex1
        type: s4
      - id: vindex2
        type: s4
      - id: vindex3
        type: s4
      - id: tex_index
        type: s4
      - id: norm
        type: vec3
      - id: nothing0
        type: f4
      - id: uv0
        type: f4
        repeat: expr
        repeat-expr: 2
      - id: sa_intensity
        type: f4
      - id: ch_intensity
        type: f4
      - id: uv1
        type: f4
        repeat: expr
        repeat-expr: 2
      - id: nothing
        type: f4
        repeat: expr
        repeat-expr: 2
      - id: uv2
        type: f4
        repeat: expr
        repeat-expr: 2
      - id: chrome_flag
        type: s4
      - id: self_illum_flag
        type: s4

  weight_index_array:
    seq:
      - id: weights
        type: u1
        repeat: expr
        repeat-expr: 4
      - id: indices
        type: u1
        repeat: expr
        repeat-expr: 4

  submesh_data_block:
    seq:
      - id: raw_data
        size-eos: true
  
  materials:
    seq:
      - id: num_materials
        type: s4
      - id: materials
        type: material
        repeat: expr
        repeat-expr: num_materials

  material:
    seq:
      - id: tex_name
        size: 32
        type: strz
      - id: self_illumination
        type: f4
      - id: specular_level
        type: f4
      - id: glossiness
        type: f4
      - id: reflection_amount
        type: f4
      - id: refl_tex_name
        size: 32
        type: strz
      - id: flags
        type: s4

  bones:
    seq:
      - id: num_bones
        type: s4
      - id: bones
        type: bone
        repeat: expr
        repeat-expr: num_bones

  bone:
    seq:
      - id: name
        size: 0x18
        type: strz
      - id: orient
        type: quat
      - id: pos
        type: vec3
      - id: parent_index
        type: s4

  navpoint:
    seq:
      - id: name
        size: 0x18
        type: strz
      - id: parent_index
        type: s4
      - id: orient
        type: quat
      - id: pos
        type: vec3

  csphere:
    seq:
      - id: name
        size: 0x18
        type: strz
      - id: parent_index
        type: s4
      - id: pos
        type: vec3
      - id: radius
        type: f4

enums:
  section_type:
    0x00000000: end
    0x87251110: submesh
    0x11133344: materials
    0x424f4e45: bones
    0x44554d42: navpoint
    0x43535048: csphere
