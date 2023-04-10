# V3M/V3C format reverse engineered by:
# * Rafał Harabień (Open Faction project)
meta:
  id: v3m_v3c
  title: Red Faction Mesh
  application: Red Faction
  file-extension:
    - v3m
    - v3c
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
        doc: file signature, value depends if this is V3C (character mesh) or V3M (static mesh), see is_v3m and is_v3c instances
      - id: version
        doc: always 0x40000
        type: s4
      - id: num_submeshes
        type: s4
        doc: number of submesh chunks
      - id: num_vertices
        type: s4
        doc: ccrunch resets value to 0
      - id: num_mesh_faces
        type: s4
        doc: ccrunch resets value to 0
      - id: num_mesh_normals
        type: s4
        doc: ccrunch resets value to 0
      - id: num_mesh_materials
        type: s4
        doc: total number of materials in all submeshes
      - id: num_lod_meshes
        type: s4
        doc: ccrunch resets value to 0
      - id: num_dumbs
        type: s4
        doc: ccrunch resets value to 0 (dumb chunks are discarded)
      - id: num_cspheres
        type: s4
        doc: number of csphere chunks
    instances:
      is_v3m:
        value: magic == 0x52463344
        doc: static mesh
      is_v3c:
        value: magic == 0x5246434D
        doc: character mesh
  
  file_chunk:
    seq:
      - id: type
        type: s4
        enum: file_chunk_type
      - id: len
        type: s4
        doc: length of chunk in bytes, unused in submesh chunk
      - id: body
        #size: len
        type:
          switch-on: type
          cases:
            'file_chunk_type::submesh': submesh
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
  
  plane:
    seq:
      - id: normal
        type: vec3
      - id: dist
        type: f4
  
  bbox:
    doc: axis aligned bounding box
    seq:
      - id: min
        type: vec3
      - id: max
        type: vec3
  
  submesh:
    doc: LOD mesh group
    seq:
      - id: name
        size: 24
        type: strz
      - id: parent_name
        size: 24
        type: strz
        doc: unused by the game
      - id: version
        type: s4
      - id: num_levels
        type: s4
      - id: distances
        type: f4
        repeat: expr
        repeat-expr: num_levels
      - id: offset
        type: vec3
      - id: radius
        type: f4
      - id: bbox
        type: bbox
      - id: meshes
        type: lod_mesh
        repeat: expr
        repeat-expr: num_levels
      - id: num_materials
        type: s4
      - id: materials
        type: mesh_material
        repeat: expr
        repeat-expr: num_materials
      - id: num_unknown1
        type: s4
      - id: unknown1
        size: 28 * num_unknown1
        doc: repeated submesh name and some additional numbers
  
  lod_mesh:
    seq:
      - id: flags
        size: 4
        type: lod_mesh_flags
      - id: num_vecs
        type: s4
        doc: number of vertices
      - id: num_chunks
        type: u2
      - id: data_block_size
        type: s4
      - id: data_block
        size: data_block_size
        type: raw_lod_mesh_data
      - id: unknown1
        type: s4
      - id: chunk_info
        type: chunk_info
        repeat: expr
        repeat-expr: num_chunks
      - id: num_prop_points
        type: s4
      - id: num_textures
        type: s4
      - id: textures
        type: texture
        repeat: expr
        repeat-expr: num_textures
    instances:
      data:
        io: data_block._io
        pos: 0
        size-eos: true
        type: lod_mesh_data
  
  lod_mesh_flags:
    seq:
      - id: unk_80
        type: b1
        doc: value & 0x80
      - id: unk_40
        type: b1
        doc: value & 0x40
      - id: face_planes
        type: b1
        doc: value & 0x20
      - id: unk_10
        type: b1
        doc: value & 0x10
      - id: unk_8
        type: b1
        doc: value & 0x8
      - id: reflection
        type: b1
        doc: value & 0x4
      - id: character
        type: b1
        doc: value & 0x2
      - id: orig_map
        type: b1
        doc: value & 0x1
  
  raw_lod_mesh_data:
    seq:
      - id: raw_data
        size-eos: true
  
  chunk_info:
    seq:
      - id: num_vertices
        type: u2
      - id: num_faces
        type: u2
      - id: vecs_alloc
        type: u2
      - id: faces_alloc
        type: u2
      - id: same_pos_vertex_offsets_alloc
        type: u2
      - id: wi_alloc
        type: u2
      - id: uvs_alloc
        type: u2
      - id: render_flags
        type: u4
  
  lod_mesh_data:
    seq:
      - id: chunk_headers
        type: mesh_chunk_header
        repeat: expr
        repeat-expr: _parent.num_chunks
      - id: padding0
        size: (0x10 - _io.pos) % 0x10
      - id: chunk_data
        type: mesh_chunk_data(_index)
        repeat: expr
        repeat-expr: _parent.num_chunks
      - id: padding1
        size: (0x10 - _io.pos) % 0x10
      - id: prop_points
        type: prop_point
        repeat: expr
        repeat-expr: _parent.num_prop_points

  mesh_chunk_header:
    seq:
      - id: unknown0
        size: 0x20
      - id: texture_idx
        type: s4
      - id: unknown1
        size: 0x14
  
  mesh_chunk_data:
    params:
      - id: chunk_index
        type: s4
    seq:
      - id: vecs
        type: vec3
        repeat: expr
        repeat-expr: _parent._parent.chunk_info[chunk_index].vecs_alloc / 12
        doc: vertex positions
      - id: padding0
        size: (0x10 - _parent._io.pos) % 0x10
      - id: norms
        type: vec3
        repeat: expr
        repeat-expr: _parent._parent.chunk_info[chunk_index].vecs_alloc / 12
        doc: vertex normals
      - id: padding1
        size: (0x10 - _parent._io.pos) % 0x10
      - id: uvs
        type: uv
        repeat: expr
        repeat-expr: _parent._parent.chunk_info[chunk_index].uvs_alloc / 8
        doc: texture coordinates
      - id: padding2
        size: (0x10 - _parent._io.pos) % 0x10
      - id: faces
        type: face
        repeat: expr
        repeat-expr: _parent._parent.chunk_info[chunk_index].faces_alloc / 8
      - id: padding3
        size: (0x10 - _parent._io.pos) % 0x10
      - id: planes
        type: plane
        if: _parent._parent.flags.face_planes
        repeat: expr
        repeat-expr: _parent._parent.chunk_info[chunk_index].num_faces
        doc: face planes used for culling
      - id: padding4
        size: (0x10 - _parent._io.pos) % 0x10
        if: _parent._parent.flags.face_planes
      - id: same_pos_vertex_offsets
        type: s2
        repeat: expr
        repeat-expr: _parent._parent.chunk_info[chunk_index].same_pos_vertex_offsets_alloc / 2
        doc: |
          used for face clipping optimization
          if value is positive:
          vecs[i] == vecs[i - same_pos_vertex_offsets[i]]
      - id: padding5
        size: (0x10 - _parent._io.pos) % 0x10
      - id: wi
        type: weight_index_array
        if: _parent._parent.chunk_info[chunk_index].wi_alloc > 0
        repeat: expr
        repeat-expr: _parent._parent.chunk_info[chunk_index].wi_alloc / 8
        doc: bone weights for vertices
      - id: padding6
        size: (0x10 - _parent._io.pos) % 0x10
        if: _parent._parent.chunk_info[chunk_index].wi_alloc > 0
      - id: orig_map
        type: s2
        if: _parent._parent.flags.orig_map
        repeat: expr
        repeat-expr: _parent._parent.num_vecs
        doc: mapping to original vertex indices, needed for a morphing animation
      - id: padding7
        size: (0x10 - _parent._io.pos) % 0x10
        if: _parent._parent.flags.orig_map
  
  prop_point:
    seq:
      - id: name
        size: 0x44
        type: strz
      - id: orient
        type: quat
      - id: pos
        type: vec3
      - id: parent_index
        type: s4
        doc: parent bone index or -1
  
  texture:
    seq:
      - id: id
        type: u1
      - id: filename
        type: strz

  face:
    doc: triangle
    seq:
      - id: indices
        type: u2
        repeat: expr
        repeat-expr: 3
      - id: flags
        type: u2
        doc: 0x20 - double-sided (disables back-face culling)

  weight_index_array:
    seq:
      - id: weights
        type: u1
        repeat: expr
        repeat-expr: 4
        doc: bone weigths (0-255)
      - id: indices
        type: u1
        repeat: expr
        repeat-expr: 4
        doc: bone indices

  mesh_material:
    seq:
      - id: tex_name
        size: 32
        type: strz
      - id: self_illumination
        type: f4
      - id: specular_level
        type: f4
        doc: not used on PC
      - id: glossiness
        type: f4
        doc: not used on PC
      - id: reflection_amount
        type: f4
        doc: not used on PC
      - id: refl_tex_name
        size: 32
        type: strz
        doc: not used on PC
      - id: flags
        type: u4

  csphere:
    doc: collision sphere
    seq:
      - id: name
        size: 24
        type: strz
        doc: collision sphere name
      - id: parent_index
        type: s4
        doc: parent bone index or -1
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
      - id: base_rotation
        type: quat
        doc: rotation part of inverse bone matrix (model to bone transformation), seems inverted (RF bug?)
      - id: base_translation
        type: vec3
        doc: translation part of inverse bone matrix (model to bone transformation)
      - id: parent_index
        type: s4
        doc: index of parent bone, -1 for root bone

enums:
  file_chunk_type:
    0x00000000: end
    0x5355424D: submesh
    0x43535048: csphere
    0x424F4E45: bones
    0x44554D42: dumb
