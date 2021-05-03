# V3D format reverse engineered by:
# * Rafał Harabień (Open Faction project)
meta:
  id: v3d
  title: Red Faction Mesh
  application: Red Faction
  file-extension:
    - v3d
    - vcm
  license: GPL-3.0-or-later
  encoding: ASCII
  endian: le

seq:
  - id: header
    type: file_header
  - id: chunks
    type: file_chunk
    repeat: until
    repeat-until: _.type == file_chunk_type::end

types:
  file_header:
    seq:
      - id: magic
        type: s4
        doc: file signature, value depends if this is VCM (character mesh) or V3D (static mesh), see is_v3d and is_vcm instances
      - id: version
        doc: always 0x40000
        type: s4
      - id: num_submeshes
        type: s4
        doc: number of submesh sections
      - id: num_all_vertices
        type: s4
      - id: num_all_faces
        type: s4
      - id: num_all_vertex_normals
        type: s4
      - id: num_all_materials
        type: s4
        doc: total number of materials in all submeshes
      - id: num_all_lods
        type: s4
      - id: num_dumbs
        type: s4
        doc: number of dumb chunks
      - id: num_cspheres
        type: s4
        doc: number of csphere chunks
    instances:
      is_v3d:
        value: magic == 0x52463344
        doc: static mesh
      is_vcm:
        value: magic == 0x5246434D
        doc: character mesh
  
  file_chunk:
    seq:
      - id: type
        type: s4
        enum: file_chunk_type
      - id: size
        type: s4
        doc: length of chunk in bytes, unused in submesh chunk
      - id: body
        size: size
        type:
          switch-on: type
          cases:
            'file_chunk_type::submesh': lod_mesh
            'file_chunk_type::dumb': navpoint
            'file_chunk_type::csphere': csphere
            'file_chunk_type::bones': bones
  
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

  lod_mesh:
    seq:
      - id: mesh
        type: mesh
      - id: num_levels
        type: s4
      - id: levels
        type: lod_level_info
        repeat: expr
        repeat-expr: num_levels

  lod_level_info:
    seq:
      - id: name
        size: 24
        type: strz
      - id: dist
        type: f4

  mesh:
    seq:
      - id: name
        size: 24
        type: strz
      - id: parent_name
        size: 24
        type: strz
      - id: num_vecs
        type: s4
      - id: vecs
        type: vec3
        repeat: expr
        repeat-expr: num_vecs
      - id: num_norms
        type: s4
      - id: norms
        type: norm
        repeat: expr
        repeat-expr: num_norms
      - id: num_materials
        type: s4
      - id: materials
        type: material
        repeat: expr
        repeat-expr: num_materials
      - id: num_faces
        type: s4
      - id: faces
        type: face
        repeat: expr
        repeat-expr: num_faces
      - id: bounding_center
        type: vec3
      - id: bounding_radius
        type: f4
      - id: bbox_min
        type: vec3
      - id: bbox_max
        type: vec3
  
  norm:
    seq:
      - id: norm
        type: vec3
      - id: vindex
        type: s4

  face:
    seq:
      - id: vec_indices
        type: s4
        repeat: expr
        repeat-expr: 3
      - id: norm_indices
        type: s4
        repeat: expr
        repeat-expr: 3
      - id: uvs
        type: uv
        repeat: expr
        repeat-expr: 3
      - id: material_index
        type: s4

  navpoint:
    seq:
      - id: name
        size: 24
        type: strz
      - id: parent_index
        type: s4
        doc: index of parent bone or -1
      - id: orient
        type: quat
      - id: pos
        type: vec3

  vertex_bones:
    seq:
      - id: weights
        type: u1
        repeat: expr
        repeat-expr: 4
      - id: bones
        type: u1
        repeat: expr
        repeat-expr: 4

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
        type: u4

  csphere:
    seq:
      - id: name
        size: 24
        type: strz
        doc: collision sphere name
      - id: parent_index
        type: s4
        doc: bone index or -1
      - id: pos
        type: vec3
        doc: center position relative to bone
      - id: radius
        type: f4
        doc: sphere radius
  
  bones:
    seq:
      - id: num_bones
        type: s4
        doc: number of bones (max 50)
      - id: bones
        type: bone
        repeat: expr
        repeat-expr: num_bones
        doc: bones array
  
  bone:
    seq:
      - id: name
        size: 24
        type: strz
        doc: bone name, used by game
      - id: orient
        type: quat
        doc: quaternion
      - id: pos
        type: vec3
        doc: bone to model translation
      - id: parent_index
        type: s4
        doc: index of parent bone (-1 for root)

enums:
  file_chunk_type:
    0x00000000: end
    0x5355424D: submesh
    0x43535048: csphere
    0x424F4E45: bones
    0x44554D42: dumb
