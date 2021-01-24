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
  - id: sections
    type: section
    repeat: until
    repeat-until: _.type == section_type::end

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
        doc: number of submesh sections
      - id: num_all_vertices
        type: s4
        doc: ccrunch resets value to 0
      - id: num_all_triangles
        type: s4
        doc: ccrunch resets value to 0
      - id: num_all_vertex_normals
        type: s4
        doc: ccrunch resets value to 0
      - id: num_all_materials
        type: s4
        doc: total number of materials in all submeshes
      - id: num_all_lods
        type: s4
        doc: ccrunch resets value to 0
      - id: num_dumbs
        type: s4
        doc: ccrunch resets value to 0 (dumb sections are discarded)
      - id: num_colspheres
        type: s4
        doc: number of colsphere sections
    instances:
      is_v3m:
        value: magic == 0x52463344
        doc: static mesh
      is_v3c:
        value: magic == 0x5246434D
        doc: character mesh
  
  section:
    seq:
      - id: type
        type: s4
        enum: section_type
      - id: len
        type: s4
        doc: length of section in bytes, unused in submesh section
      - id: body
        #size: len
        type:
          switch-on: type
          cases:
            'section_type::submesh': submesh
            'section_type::colsphere': colsphere
            'section_type::bones': bones
  
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
      - id: name
        size: 24
        type: strz
      - id: unknown0
        size: 24
        type: strz
      - id: version
        type: s4
      - id: num_lods
        type: s4
      - id: lod_distances
        type: f4
        repeat: expr
        repeat-expr: num_lods
      - id: offset
        type: vec3
      - id: radius
        type: f4
      - id: aabb
        type: aabb
      - id: lods
        type: lod_mesh
        repeat: expr
        repeat-expr: num_lods
      - id: num_materials
        type: s4
      - id: materials
        type: material
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
      - id: num_vertices
        type: s4
      - id: num_batches
        type: u2
      - id: data_size
        type: s4
      - id: raw_data
        size: data_size
        type: raw_lod_mesh_data
      - id: unknown1
        type: s4
      - id: batch_info
        type: batch_info
        repeat: expr
        repeat-expr: num_batches
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
        io: raw_data._io
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
      - id: triangle_planes
        type: b1
        doc: value & 0x20
      - id: unk_10
        type: b1
        doc: value & 0x10
      - id: unk_8
        type: b1
        doc: value & 0x8
      - id: unk_4
        type: b1
        doc: value & 0x4
      - id: unk_2
        type: b1
        doc: value & 0x2
      - id: morph_vertices_map
        type: b1
        doc: value & 0x1
  
  raw_lod_mesh_data:
    seq:
      - id: raw_data
        size-eos: true
  
  batch_info:
    seq:
      - id: num_vertices
        type: u2
      - id: num_triangles
        type: u2
      - id: positions_size
        type: u2
      - id: indices_size
        type: u2
      - id: same_pos_vertex_offsets_size
        type: u2
      - id: bone_links_size
        type: u2
      - id: tex_coords_size
        type: u2
      - id: render_flags
        type: u4
  
  lod_mesh_data:
    seq:
      - id: batch_headers
        type: mesh_batch_header
        repeat: expr
        repeat-expr: _parent.num_batches
      - id: padding0
        size: (0x10 - _io.pos) % 0x10
      - id: batch_data
        type: mesh_batch_data(_index)
        repeat: expr
        repeat-expr: _parent.num_batches
      - id: padding1
        size: (0x10 - _io.pos) % 0x10
      - id: prop_points
        type: prop_point
        repeat: expr
        repeat-expr: _parent.num_prop_points

  mesh_batch_header:
    seq:
      - id: unknown0
        size: 0x20
      - id: texture_idx
        type: s4
      - id: unknown1
        size: 0x14
  
  mesh_batch_data:
    params:
      - id: batch_idx
        type: s4
    seq:
      - id: positions
        type: vec3
        repeat: expr
        #repeat-expr: _parent._parent.batch_info[batch_idx].num_vertices
        repeat-expr: _parent._parent.batch_info[batch_idx].positions_size / 12
      - id: padding0
        size: (0x10 - _parent._io.pos) % 0x10
      - id: normals
        type: vec3
        repeat: expr
        #repeat-expr: _parent._parent.batch_info[batch_idx].num_vertices
        repeat-expr: _parent._parent.batch_info[batch_idx].positions_size / 12
      - id: padding1
        size: (0x10 - _parent._io.pos) % 0x10
      - id: tex_coords
        type: uv
        repeat: expr
        #repeat-expr: _parent._parent.batch_info[batch_idx].num_vertices
        repeat-expr: _parent._parent.batch_info[batch_idx].tex_coords_size / 8
      - id: padding2
        size: (0x10 - _parent._io.pos) % 0x10
      - id: triangles
        type: triangle
        repeat: expr
        #repeat-expr: _parent._parent.batch_info[batch_idx].num_triangles
        repeat-expr: _parent._parent.batch_info[batch_idx].indices_size / 8
      - id: padding3
        size: (0x10 - _parent._io.pos) % 0x10
      - id: planes
        type: plane
        if: _parent._parent.flags.triangle_planes
        repeat: expr
        repeat-expr: _parent._parent.batch_info[batch_idx].num_triangles
      - id: padding4
        size: (0x10 - _parent._io.pos) % 0x10
        if: _parent._parent.flags.triangle_planes
      - id: same_pos_vertex_offsets
        type: s2
        repeat: expr
        #repeat-expr: _parent._parent.batch_info[batch_idx].num_vertices
        repeat-expr: _parent._parent.batch_info[batch_idx].same_pos_vertex_offsets_size / 2
      - id: padding5
        size: (0x10 - _parent._io.pos) % 0x10
      - id: bone_links
        type: vertex_bones
        if: _parent._parent.batch_info[batch_idx].bone_links_size > 0
        repeat: expr
        #repeat-expr: _parent._parent.batch_info[batch_idx].num_vertices
        repeat-expr: _parent._parent.batch_info[batch_idx].bone_links_size / 8
      - id: padding6
        size: (0x10 - _parent._io.pos) % 0x10
        if: _parent._parent.batch_info[batch_idx].bone_links_size > 0
      - id: morph_vertices_map
        type: s2
        if: _parent._parent.flags.morph_vertices_map
        repeat: expr
        repeat-expr: _parent._parent.num_vertices
      - id: padding7
        size: (0x10 - _parent._io.pos) % 0x10
        if: _parent._parent.flags.morph_vertices_map
  
  prop_point:
    seq:
      - id: name
        size: 0x44
        type: strz
      - id: rot
        type: quat
      - id: pos
        type: vec3
      - id: bone
        type: s4
        doc: index of parent bone or -1
  
  texture:
    seq:
      - id: id
        type: u1
      - id: filename
        type: strz

  triangle:
    seq:
      - id: indices
        type: u2
        repeat: expr
        repeat-expr: 3
      - id: flags
        type: u2
        doc: 0x20 - double-sided (disables back-face culling)

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
      - id: diffuse_map_name
        size: 32
        type: strz
      - id: emissive_factor
        type: f4
      - id: unknown
        type: f4
        repeat: expr
        repeat-expr: 2
      - id: ref_cof
        type: f4
      - id: ref_map_name
        size: 32
        type: strz
      - id: flags
        type: u4

  colsphere:
    seq:
      - id: name
        size: 24
        type: strz
        doc: collision sphere name
      - id: bone
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
      - id: rot
        type: quat
        doc: quaternion
      - id: pos
        type: vec3
        doc: bone to model translation
      - id: parent
        type: s4
        doc: index of parent bone (-1 for root)

enums:
  section_type:
    0x00000000: end
    0x5355424D: submesh
    0x43535048: colsphere
    0x424F4E45: bones
    0x44554D42: dumb
