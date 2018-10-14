meta:
  id: rfl
  title: Red Faction Level
  application: Red Faction
  endian: le
  license: GPL-3.0-or-later
  file-extension: rfl
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
      - id: signature
        contents: [0x55, 0xDA, 0xBA, 0xD4]
      - id: version
        doc: 0xC8 is the last supported version in RF 1.2, standard maps has version 0xB4
        type: u4
      - id: timestamp
        type: u4
        doc: last map modification
      - id: player_start_offset
        type: u4
        doc: file offset to player_start_section section header
      - id: level_info_offset
        type: u4
        doc: file offset to level_info_section section header
      - id: sections_count
        type: u4
      - id: unknown
        type: u4
        doc: sections data size - 8
      - id: level_name
        type: vstring
      - id: mod_name
        type: vstring
  section:
    seq:
      - id: type
        type: u4
        enum: section_type
      - id: len
        type: u4
      - id: body
        size: len
        type:
          switch-on: type
          cases:
            'section_type::static_geometry': rooms_section
            'section_type::geo_regions': geo_regions_section
            'section_type::lights': lights_section
            'section_type::cutscene_cameras': cutscene_cameras_section
            'section_type::ambient_sounds': ambient_sounds_section
            'section_type::events': events_section
            'section_type::mp_respawns': mp_respawns_section
            'section_type::level_properties': level_properties_section
            'section_type::particle_emitters': particle_emitters_section
            'section_type::gas_regions': gas_regions_section
            # 'section_type::room_effects': 
            'section_type::climbing_regions': climbing_regions_section
            'section_type::bolt_emitters': bolt_emitter_section
            'section_type::targets': targets_section
            'section_type::decals': decals_section
            'section_type::push_regions': push_regions_section
            'section_type::lightmaps': lightmaps_section
            # 'section_type::movers': 
            # 'section_type::moving_groups': 
            'section_type::cutscenes': cutscenes_section
            'section_type::cutscene_path_nodes': cutscene_path_nodes_section
            'section_type::cutscene_paths': cutscene_paths_section
            'section_type::tga_unknown': tga_files_section
            'section_type::vcm_unknown': vcm_files_section
            'section_type::mvf_unknown': mvf_files_section
            'section_type::v3d_unknown': v3d_files_section
            'section_type::vfx_unknown': vfx_files_section
            # 'section_type::eax_effects': 
            'section_type::waypoint_lists': waypoint_lists_section
            'section_type::nav_points': nav_points_section
            'section_type::entities': entities_section
            'section_type::items': items_section
            'section_type::clutters':  clutters_section
            'section_type::triggers': triggers_section
            'section_type::player_start': player_start_section
            'section_type::level_info': level_info_section
            'section_type::brushes': brushes_section
            #'section_type::groups': groups_section
            'section_type::editor_only_lights': lights_section
  vstring:
    doc: variable-length string
    seq:
      - id: len
        type: u2
      - id: str
        type: str
        size: len
        encoding: ASCII
  vec3:
    doc: 3D vector
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  mat3:
    doc: rotation matrix, rows are in a non-standard order - 2, 3, 1
    seq:
      - id: forward
        type: vec3
      - id: right
        type: vec3
      - id: up
        type: vec3
  aabb:
    doc: axis aligned bounding box
    seq:
      - id: p1
        type: vec3
      - id: p2
        type: vec3
  color:
    seq:
      - id: r
        type: u1
      - id: g
        type: u1
      - id: b
        type: u1
      - id: a
        type: u1
  uid_list:
    seq:
      - id: count
        type: u4
      - id: uids
        type: u4
        repeat: expr
        repeat-expr: count

  # Geometry
  room:
    seq:
      - id: id
        type: u4
        doc: uid of room effect element or big numbers (>0x70000000)
      - id: aabb
        type: aabb
      - id: is_skyroom
        type: u1
        doc: 1 or 0
      - id: is_cold
        type: u1
        doc: 1 or 0
      - id: is_outside
        type: u1
        doc: 1 or 0
      - id: is_airlock
        type: u1
        doc: 1 or 0
      - id: liquid_room
        type: u1
        doc: 1 or 0
      - id: ambient_light
        type: u1
        doc: 1 or 0
      - id: is_subroom
        type: u1
        doc: 1 or 0
      - id: unknown
        type: u1
      - id: life
        type: f4
        doc: -1 == infinite
      - id: eax_effect
        type: vstring
      - id: liquid_depth
        type: f4
        if: liquid_room == 1
      - id: liquid_color
        type: color
        if: liquid_room == 1
      - id: liquid_surface_texture
        type: vstring
        if: liquid_room == 1
      - id: liquid_visibility
        type: f4
        if: liquid_room == 1
      - id: liquid_type
        type: u4
        if: liquid_room == 1
      - id: liquid_alpha
        type: u4
        if: liquid_room == 1
      - id: liquid_unknown
        size: 13
        if: liquid_room == 1
      - id: liquid_waveform
        type: f4
        if: liquid_room == 1
        doc: 0xFFFFFFF for None
      - id: liquid_surface_texture_scroll_u
        type: f4
        if: liquid_room == 1
      - id: liquid_surface_texture_scroll_v
        type: f4
        if: liquid_room == 1
      - id: ambient_color
        type: color
        if: ambient_light == 1
  vertex:
    seq:
      - id: index
        type: u4
        doc: index in rooms_section::vertices
      - id: tex_u
        type: f4
      - id: tex_v
        type: f4
      - id: lm_u
        type: f4
        if: _parent.lm_unknown2 != 0xFFFFFFFF
        doc: lightmap U
      - id: lm_v
        type: f4
        if: _parent.lm_unknown2 != 0xFFFFFFFF
        doc: lightmap V
  face:
    seq:
      - id: unknown
        type: f4
        repeat: expr
        repeat-expr: 4
        doc: plane (normal vector and distance from 0)?
      - id: texture
        type: u4
      - id: lm_unknown2
        type: u4
        doc: if not 0xFFFFFFFF vertex has lightmap coordinates; it's not lightmap id
      - id: unknown3
        type: u4
        doc: face id? sometimes is repeated.
      - id: unknown4
        size: 8
        doc: FF FF FF FF FF FF FF FF
      - id: unknown5
        type: u4
        doc: not 0 for portals
      - id: flags
        type: u1
        enum: face_flags
      - id: lightmap_res
        type: u1
        doc: 1 - default, 8 - lowest, 9 - low, A - high, B - highest
      - id: unknown6
        size: 6
      - id: room_index
        type: u4
      - id: vertices_count
        type: u4
      - id: vertices
        type: vertex
        repeat: expr
        repeat-expr: vertices_count
  face_scroll:
    seq:
      - id: face_id
        type: u4
      - id: uv
        type: f4
        doc: U velocity
      - id: vv
        type: f4
        doc: V velocity
  rooms_section:
    seq:
      - id: unknown
        size: "_root.header.version > 0xB4 ? 10 : 6"
      - id: textures_count
        type: u4
      - id: textures
        type: vstring
        repeat: expr
        repeat-expr: textures_count
      - id: scroll_count
        type: u4
      - id: scroll
        type: face_scroll
        repeat: expr
        repeat-expr: scroll_count
      - id: rooms_count
        type: u4
        doc: only compiled geometry
      - id: rooms
        type: room
        repeat: expr
        repeat-expr: rooms_count
      - id: unknown_count
        type: u4
        doc: equal to rooms_count, only compiled geometry
      - id: unknown2
        type: rooms_unk
        repeat: expr
        repeat-expr: unknown_count
      - id: unknown_count2
        type: u4
      - id: unknown3
        type: u1
        repeat: expr
        repeat-expr: unknown_count2 * 32
      - id: vertices_count
        type: u4
      - id: vertices
        type: vec3
        repeat: expr
        repeat-expr: vertices_count
      - id: faces_count
        type: u4
      - id: faces
        type: face
        repeat: expr
        repeat-expr: faces_count
      - id: unknown_count3
        type: u4
      - id: unknown4
        type: rooms_unk2
        repeat: expr
        repeat-expr: unknown_count3
      - id: unknown5
        type: u4
        if: _root.header.version == 0xB4
  rooms_unk:
    seq:
      - id: mesh_index
        type: u4
      - id: links_count
        type: u4
        doc: contained meshes?
      - id: links
        type: u4
        repeat: expr
        repeat-expr: links_count
  rooms_unk2:
    seq:
      - id: lightmap
        type: u4
      - id: unk
        size: 88
      - id: face
        type: u4
        doc: index in faces
  # Geo Regions
  geo_regions_section:
    seq:
      - id: count
        type: u4
      - id: geo_regions
        type: geo_region
        repeat: expr
        repeat-expr: count
  geo_region:
    seq:
      - id: uid
        type: u4
      - id: flags
        type: u2
        enum: geo_region_flags
      - id: hardness
        type: u2
        doc: in range 0-100
      - id: shallow_geomod_depth
        type: f4
        if: flags.to_i & geo_region_flags::use_shallow_geomods.to_i != 0
      - id: pos
        type: vec3
      - id: rot
        type: mat3
        if: flags.to_i & geo_region_flags::sphere.to_i == 0
      - id: width
        type: f4
        if: flags.to_i & geo_region_flags::sphere.to_i == 0
      - id: height
        type: f4
        if: flags.to_i & geo_region_flags::sphere.to_i == 0
      - id: depth
        type: f4
        if: flags.to_i & geo_region_flags::sphere.to_i == 0
      - id: radius
        type: f4
        if: flags.to_i & geo_region_flags::sphere.to_i != 0
  # Lights
  lights_section:
    seq:
      - id: count
        type: u4
      - id: lights
        type: light
        repeat: expr
        repeat-expr: count
  light:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: vstring
        doc: "Light"
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
      - id: reserved
        type: u1
      - id: flags
        type: u4
        enum: light_flags
      - id: color
        type: color
      - id: range
        type: f4
      - id: fov
        type: f4
      - id: fov_dropoff
        type: f4
      - id: intensity_at_max_range
        type: f4
      - id: unknown1
        type: f4
      - id: tube_light_width
        type: f4
      - id: light_on_intensity
        type: f4
      - id: unknown2
        size: 20
  # Cutscene Cameras
  cutscene_cameras_section:
    seq:
      - id: count
        type: u4
      - id: cutscene_cameras
        type: cutscene_camera
        repeat: expr
        repeat-expr: count
  cutscene_camera:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: vstring
        doc: "Cutscene Camera"
      - id: unknown
        size: 48
      - id: script_name
        type: vstring
      - id: unknown2
        type: u1
        doc: 0x00
  # Ambient Sounds
  ambient_sounds_section:
    seq:
      - id: count
        type: u4
      - id: ambient_sounds
        type: ambient_sound
        repeat: expr
        repeat-expr: count
  ambient_sound:
    seq:
      - id: uid
        type: u4
      - id: pos
        type: vec3
      - id: unknown
        type: u1
      - id: sound_file_name
        type: vstring
      - id: min_dist
        type: f4
      - id: volume_scale
        type: f4
      - id: rolloff
        type: f4
      - id: start_delay_ms
        type: u4
  # Events
  events_section:
    seq:
      - id: count
        type: u4
      - id: events
        type: event
        repeat: expr
        repeat-expr: count
  event:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: vstring
      - id: pos
        type: vec3
      - id: script_name
        type: vstring
      - id: unknown
        type: u1
      - id: delay
        type: f4
      - id: bool1
        type: u1
      - id: bool2
        type: u1
      - id: int1
        type: u4
      - id: int2
        type: u4
      - id: float1
        type: f4
      - id: float2
        type: f4
      - id: str1
        type: vstring
      - id: str2
        type: vstring
      - id: links
        type: uid_list
      - id: rot
        type: mat3
        if: class_name.str == "Alarm" or class_name.str == "Teleport" or class_name.str == "Play_Vclip" or class_name.str == "Teleport_Player"
      - id: color
        type: color
  # Multiplayer Respawn Points
  mp_respawns_section:
    seq:
      - id: count
        type: u4
      - id: mp_respawns
        type: mp_respawn
        repeat: expr
        repeat-expr: count
  mp_respawn:
    seq:
      - id: uid
        type: u4
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
      - id: zero
        type: u1
        doc: 0x00
      - id: team
        type: u4
      - id: red_team
        type: u1
      - id: blue_team
        type: u1
      - id: bot
        type: u1
  # Level Properties
  level_properties_section:
    seq:
      - id: geomod_texture
        type: vstring
      - id: hardness
        type: u4
      - id: ambient_color
        type: color
      - id: unknown
        type: u1
      - id: fog_color
        type: color
      - id: fog_near_plane
        type: f4
      - id: fog_far_plane
        type: f4
  # Particle Emitters
  particle_emitters_section:
    seq:
      - id: count
        type: u4
      - id: particle_emitters
        type: particle_emitter
        repeat: expr
        repeat-expr: count
  particle_emitter:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: vstring
        doc: always "Particle Emitter"
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
        doc: always "Particle Emitter"
      - id: unknown
        type: u1
      - id: shape
        type: u4
        enum: particle_emitter_shape
      - id: sphere_radius
        type: f4
      - id: plane_width
        type: f4
      - id: plane_depth
        type: f4
      - id: texture
        type: vstring
      - id: spawn_delay
        type: f4
      - id: spawn_randomize
        type: f4
      - id: velocity
        type: f4
      - id: velocity_randomize
        type: f4
      - id: acceleration
        type: f4
      - id: decay
        type: f4
      - id: decay_randomize
        type: f4
      - id: particle_radius
        type: f4
      - id: particle_radius_randomize
        type: f4
      - id: growth_rate
        type: f4
      - id: gravity_multiplier
        type: f4
      - id: random_direction
        type: f4
      - id: particle_color
        type: color
      - id: fade_to_color
        type: color
      - id: emitter_flags
        type: u4
        enum: particle_emitter_flags
      - id: particle_flags
        type: u2
        enum: particle_flags
      - id: stickieness
        type: b4
      - id: bounciness
        type: b4
      - id: push_effect
        type: b4
      - id: swirliness
        type: b4
      - id: unk
        type: u1
      - id: time_on
        type: f4
      - id: time_on_randomize
        type: f4
      - id: time_off
        type: f4
      - id: time_off_randomize
        type: f4
      - id: active_distance
        type: f4
  # Gas Regions
  gas_regions_section:
    seq:
      - id: count
        type: u4
      - id: gas_regions
        type: gas_region
        repeat: expr
        repeat-expr: count
  gas_region:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: vstring
        doc: always "Gas Region"
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
        doc: always "Gas Region"
      - id: unknown
        type: u1
      - id: shape
        type: u4
        enum: gas_region_shape
      - id: radius
        type: f4
        if: shape == gas_region_shape::sphere
      - id: height
        type: f4
        if: shape == gas_region_shape::box
      - id: width
        type: f4
        if: shape == gas_region_shape::box
      - id: depth
        type: f4
        if: shape == gas_region_shape::box
      - id: gas_color
        type: color
      - id: gas_density
        type: f4
  # Climbing Regions
  climbing_regions_section:
    seq:
      - id: count
        type: u4
      - id: climbing_regions
        type: climbing_region
        repeat: expr
        repeat-expr: count
  climbing_region:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: vstring
        doc: always "Climbing Region"
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
        doc: always "Climbing Region"
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
      - id: type
        type: u4
        enum: climbing_region_type
      - id: extents
        type: vec3
  # Bolt Emitters
  bolt_emitter_section:
    seq:
      - id: count
        type: u4
      - id: bolt_emitters
        type: bolt_emitter
        repeat: expr
        repeat-expr: count
  bolt_emitter:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: vstring
        doc: always "Bolt Emitter"
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
        doc: always "Bolt Emitter"
      - id: unknown
        type: u1
      - id: target_uid
        type: s4
      - id: src_ctrl_dist
        type: f4
      - id: trg_ctrl_dist
        type: f4
      - id: thickness
        type: f4
      - id: jitter
        type: f4
      - id: segments_count
        type: u4
      - id: spawn_delay
        type: f4
      - id: spawn_delay_randomize
        type: f4
      - id: decay
        type: f4
      - id: decay_randomize
        type: f4
      - id: color
        type: color
      - id: texture
        type: vstring
      - id: flags
        type: u4
        enum: bolt_emitter_flags
      - id: initially_on
        type: u1
        doc: 0 or 1
  # Targets
  targets_section:
    seq:
      - id: count
        type: u4
      - id: targets
        type: target
        repeat: expr
        repeat-expr: count
  target:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: vstring
        doc: always "Target"
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
        doc: always "Target"
      - id: unknown
        type: u1
  # Decals
  decals_section:
    seq:
      - id: count
        type: u4
      - id: decals
        type: decal
        repeat: expr
        repeat-expr: count
  decal:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: vstring
        doc: always "Decal"
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
        doc: always "Decal"
      - id: unknown
        type: u1
      - id: extents
        type: vec3
      - id: texture
        type: vstring
      - id: alpha
        type: u4
      - id: self_illuminated
        type: u1
      - id: tiling
        type: u4
        enum: decal_tiling
      - id: scale
        type: f4
  # Push Regions
  push_regions_section:
    seq:
      - id: count
        type: u4
      - id: push_regions
        type: push_region
        repeat: expr
        repeat-expr: count
  push_region:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: vstring
        doc: always "Push Region"
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
        doc: always "Push Region"
      - id: unknown
        type: u1
      - id: shape
        type: u4
        enum: push_region_shape
      - id: extents
        type: vec3
        if: shape != push_region_shape::sphere
      - id: radius
        type: f4
        if: shape == push_region_shape::sphere
      - id: strength
        type: f4
      - id: flags
        type: u2
        enum: push_region_flags
      - id: turbulence
        type: u2
  # Lightmaps
  lightmaps_section:
    seq:
      - id: count
        type: u4
      - id: lightmaps
        type: lightmap
        repeat: expr
        repeat-expr: count
  lightmap:
    seq:
      - id: w
        type: u4
        doc: size of lightmap
      - id: h
        type: u4
        doc: size of lightmap
      - id: bitmap
        size: w * h * 3
        doc: bitmap (24 bpp)
  # Cutscenes
  cutscenes_section:
    seq:
      - id: count
        type: u4
      - id: cutscenes
        type: cutscene
        repeat: expr
        repeat-expr: count
  cutscene:
    seq:
      - id: uid
        type: u4
      - id: hide_player
        type: u1
      - id: fov
        type: f4
      - id: shots_count
        type: u4
      - id: shots
        type: cutscene_shot
        repeat: expr
        repeat-expr: shots_count
  cutscene_shot:
    seq:
      - id: camera_uid
        type: s4
      - id: pre_wait
        type: f4
      - id: path_time
        type: f4
      - id: post_wait
        type: f4
      - id: look_at_uid
        type: s4
      - id: trigger_uid
        type: s4
      - id: path_name
        type: vstring
  # Cutscene Path Nodes
  cutscene_path_nodes_section:
    seq:
      - id: count
        type: u4
      - id: cutscene_path_nodes
        type: cutscene_path_node
        repeat: expr
        repeat-expr: count
  cutscene_path_node:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: vstring
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
      - id: unknown
        type: u1
  # Cutscene Paths
  cutscene_paths_section:
    seq:
      - id: count
        type: u4
      - id: cutscene_paths
        type: cutscene_path
        repeat: expr
        repeat-expr: count
  cutscene_path:
    seq:
      - id: name
        type: vstring
      - id: path_nodes_count
        type: u4
      - id: path_nodes
        type: u4
        repeat: expr
        repeat-expr: path_nodes_count
  # TGA Files
  tga_files_section:
    seq:
      - id: tga_files_count
        type: u4
      - id: tga_files
        type: vstring
        repeat: expr
        repeat-expr: tga_files_count
        doc: many files, not textures
  # VCM Files
  vcm_files_section:
    seq:
      - id: vcm_files_count
        type: u4
      - id: vcm_files
        type: vstring
        repeat: expr
        repeat-expr: vcm_files_count
      - id: unknown
        type: u4
        repeat: expr
        repeat-expr: vcm_files_count
        doc: 0x00000001
  # MVF Files
  mvf_files_section:
    seq:
      - id: mvf_files_count
        type: u4
      - id: mvf_files
        type: vstring
        repeat: expr
        repeat-expr: mvf_files_count
      - id: unknown
        type: u4
        repeat: expr
        repeat-expr: mvf_files_count
  # V3D Files
  v3d_files_section:
    seq:
      - id: v3d_files_count
        type: u4
      - id: v3d_files
        type: vstring
        repeat: expr
        repeat-expr: v3d_files_count
      - id: unknown
        type: u4
        repeat: expr
        repeat-expr: v3d_files_count
  # VFX Files
  vfx_files_section:
    seq:
      - id: vfx_files_count
        type: u4
      - id: vfx_files
        type: vstring
        repeat: expr
        repeat-expr: vfx_files_count
      - id: unknown
        type: u4
        repeat: expr
        repeat-expr: vfx_files_count
  # Waypoint Lists
  waypoint_lists_section:
    seq:
      - id: count
        type: u4
      - id: waypoint_lists
        type: waypoint_list
        repeat: expr
        repeat-expr: count
  waypoint_list:
    seq:
      - id: name
        type: vstring
      - id: count
        type: u4
      - id: waypoints
        type: u4
        repeat: expr
        repeat-expr: count
        doc: probably index in waypoints objects array
  # Nav Points
  nav_points_section:
    seq:
      - id: count
        type: u4
      - id: nav_points
        type: rfl_nav_point
        repeat: expr
        repeat-expr: count
      - id: nav_point_connections
        type: nav_point_connections
        repeat: expr
        repeat-expr: count
  rfl_nav_point:
    seq:
      - id: uid
        type: u4
      - id: unknown
        type: u1
        doc: typically 0
      - id: height
        type: f4
      - id: pos
        type: vec3
      - id: radius
        type: f4
      - id: type
        type: u4
        enum: nav_point_type
      - id: directional
        type: u1
        doc: 0 or 1
      - id: rot
        type: mat3
        if: directional != 0
      - id: unknown2
        type: u1
        doc: typically 0
      - id: unknown3
        type: u1
        doc: typically 0
      - id: crunch
        type: u1
        doc: 0 or 1
      - id: pause_time
        type: f4
      - id: links
        type: uid_list
  nav_point_connections:
    seq:
      - id: count
        type: u1
      - id: indices
        type: u4
        repeat: expr
        repeat-expr: count
  # Entities
  entities_section:
    seq:
      - id: count
        type: u4
      - id: entities
        type: entity
        repeat: expr
        repeat-expr: count
  entity:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: vstring
        doc: depends on type
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
      - id: unknown
        type: u1
      - id: cooperation
        type: u4
        enum: entity_cooperation
      - id: friendliness
        type: u4
        enum: entity_friendliness
      - id: team_id
        type: u4
      - id: waypoint_list
        type: vstring
      - id: waypoint_method
        type: vstring
      - id: unknown2
        type: u1
      - id: boarded
        type: u1
        doc: 1 or 0
      - id: ready_to_fire_state
        type: u1
        doc: 1 or 0
      - id: only_attack_player
        type: u1
        doc: 1 or 0
      - id: weapon_is_holstered
        type: u1
        doc: 1 or 0
      - id: deaf
        type: u1
        doc: 1 or 0
      - id: sweep_min_angle
        type: u4
      - id: sweep_max_angle
        type: u4
      - id: ignore_terrain_when_firing
        type: u1
        doc: 1 or 0
      - id: unknown3
        type: u1
      - id: start_crouched
        type: u1
        doc: 1 or 0
      - id: life
        type: f4
      - id: armor
        type: f4
      - id: fov
        type: u4
      - id: default_primary_weapon
        type: vstring
      - id: default_secondary_weapon
        type: vstring
      - id: item_drop
        type: vstring
      - id: state_anim
        type: vstring
      - id: corpse_pose
        type: vstring
      - id: skin
        type: vstring
      - id: death_anim
        type: vstring
      - id: ai_mode
        type: u1
        enum: entity_ai_mode
      - id: ai_attack_style
        type: u1
        enum: entity_ai_attack_style
      - id: unknown4
        size: 4
      - id: turret_uid
        type: u4
      - id: alert_camera_uid
        type: u4
      - id: alarm_event_uid
        type: u4
      - id: run
        type: u1
        doc: 1 or 0
      - id: start_hidden
        type: u1
        doc: 1 or 0
      - id: wear_helmet
        type: u1
        doc: 1 or 0
      - id: end_game_if_killed
        type: u1
        doc: 1 or 0
      - id: cower_from_weapon
        type: u1
        doc: 1 or 0
      - id: question_unarmed_player
        type: u1
        doc: 1 or 0
      - id: dont_hum
        type: u1
        doc: 1 or 0
      - id: no_shadow
        type: u1
        doc: 1 or 0
      - id: always_simulate
        type: u1
        doc: 1 or 0
      - id: perfect_aim
        type: u1
        doc: 1 or 0
      - id: permanent_corpse
        type: u1
        doc: 1 or 0
      - id: never_fly
        type: u1
        doc: 1 or 0
      - id: never_leave
        type: u1
        doc: 1 or 0
      - id: no_persona_messages
        type: u1
        doc: 1 or 0
      - id: fade_corpse_immediately
        type: u1
        doc: 1 or 0
      - id: never_collide_with_player
        type: u1
        doc: 1 or 0
      - id: use_custom_attack_range
        type: u1
        doc: 1 or 0
      - id: custom_attack_range
        type: f4
        if: use_custom_attack_range == 1
      - id: left_hand_holding
        type: vstring
      - id: right_hand_holding
        type: vstring
  # Items
  items_section:
    seq:
      - id: count
        type: u4
      - id: items
        type: item
        repeat: expr
        repeat-expr: count
  item:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: vstring
        doc: depends on type
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
      - id: reserved
        type: u1
        doc: 0x00
      - id: count
        type: u4
      - id: respawn_time
        type: u4
      - id: team_id
        type: u4
  # Clutters
  clutters_section:
    seq:
      - id: count
        type: u4
      - id: clutters
        type: clutter
        repeat: expr
        repeat-expr: count
  clutter:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: vstring
        doc: depends on type
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
      - id: unknown2
        size: 5
      - id: skin
        type: vstring
      - id: links
        type: uid_list
  # Triggers
  triggers_section:
    seq:
      - id: count
        type: u4
      - id: trigger
        type: trigger
        repeat: expr
        repeat-expr: count
  trigger:
    seq:
      - id: uid
        type: u4
      - id: script_name
        type: vstring
        doc: depends on type
      - id: unknown
        type: u1
      - id: is_box
        type: u1
        doc: 1 or 0
      - id: unknown2
        size: 3
      - id: resets_after
        type: f4
      - id: resets_count
        type: u2
        doc: 0xFFFF - infinity
      - id: unknown3
        type: u2
      - id: is_use_key_required
        type: u1
        doc: 1 or 0
      - id: key_name
        type: vstring
      - id: weapon_activates
        type: u1
        doc: 1 or 0
      - id: unknown4
        type: u1
      - id: is_npc
        type: u1
        doc: 1 or 0
      - id: is_auto
        type: u1
        doc: 1 or 0
      - id: in_vehicle
        type: u1
        doc: 1 or 0
      - id: pos
        type: vec3
      - id: sphere_radius
        type: f4
        if: is_box == 0
      - id: rot
        type: mat3
        if: is_box != 0
      - id: box_height
        type: f4
        if: is_box != 0
      - id: box_width
        type: f4
        if: is_box != 0
      - id: box_depth
        type: f4
        if: is_box != 0
      - id: one_way
        type: u1
        if: is_box != 0
        doc: 1 or 0
      - id: airlock_room
        type: u4
        doc: UID
      - id: attached_to
        type: u4
        doc: UID
      - id: use_clutter
        type: u4
        doc: UID
      - id: disabled
        type: u1
        doc: 1 or 0
      - id: button_active_time
        type: f4
      - id: inside_time
        type: f4
      - id: unknown5
        type: u4
        doc: 0xFFFFFFFF
      - id: links
        type: uid_list
  # Player Start
  player_start_section:
    seq:
      - id: pos
        type: vec3
      - id: rot
        type: mat3
  # Level Info
  level_info_section:
    seq:
      - id: unknown
        type: u4
        doc: 0x00000001
      - id: level_name
        type: vstring
      - id: author
        type: vstring
      - id: date
        type: vstring
      - id: unknown2
        type: u1
        doc: 00
      - id: multiplayer_level
        type: u1
        doc: 0 or 1
      - id: unknown3
        size: 220
  # Brushes
  brushes_section:
    seq:
      - id: brushes_count
        type: u4
      - id: brushes
        type: brush
        repeat: expr
        repeat-expr: brushes_count
  brush:
    seq:
      - id: uid
        type: u4
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: unknown
        size: 10
        doc: 00 00 ...
      - id: textures_count
        type: u4
      - id: textures
        type: vstring
        repeat: expr
        repeat-expr: textures_count
      - id: unknown2
        size: 16
        doc: 00 00 ...
      - id: vertices_count
        type: u4
      - id: vertices
        type: vec3
        repeat: expr
        repeat-expr: vertices_count
      - id: faces_count
        type: u4
      - id: faces
        type: face
        repeat: expr
        repeat-expr: faces_count
      - id: unknown3
        type: u4
        doc: 0
      - id: flags
        type: u4
        enum: brush_flags
      - id: life
        type: u4
      - id: unknown4
        type: u4
        doc: 3? 0?
  # Groups
  groups_section:
    seq:
      - id: count
        type: u4
      - id: groups
        type: group
        repeat: expr
        repeat-expr: count
  group:
    seq:
      - id: name
        type: vstring
      - id: unknown1
        type: u1
      - id: unknown2_moving
        type: u1
      - id: unknown3
        type: u4
      - id: count
        type: u4
      - id: uids
        type: u4
        repeat: expr
        repeat-expr: count

enums:
  section_type:
    0x00000000: end
    0x00000100: static_geometry
    0x00000200: geo_regions
    0x00000300: lights
    0x00000400: cutscene_cameras
    0x00000500: ambient_sounds
    0x00000600: events
    0x00000700: mp_respawns
    0x00000900: level_properties
    0x00000a00: particle_emitters
    0x00000b00: gas_regions
    0x00000c00: room_effects
    0x00000d00: climbing_regions
    0x00000e00: bolt_emitters
    0x00000f00: targets
    0x00001000: decals
    0x00001100: push_regions
    0x00001200: lightmaps
    0x00002000: movers
    0x00003000: moving_groups
    0x00004000: cutscenes
    0x00005000: cutscene_path_nodes
    0x00006000: cutscene_paths
    0x00007000: tga_unknown
    0x00007001: vcm_unknown
    0x00007002: mvf_unknown
    0x00007003: v3d_unknown
    0x00007004: vfx_unknown
    0x00008000: eax_effects
    0x00010000: waypoint_lists
    0x00020000: nav_points
    0x00030000: entities
    0x00040000: items
    0x00050000: clutters
    0x00060000: triggers
    0x00070000: player_start
    0x01000000: level_info
    0x02000000: brushes
    0x03000000: groups
    0x04000000: editor_only_lights
  face_flags:
    0x01: show_sky
    0x02: mirrored
    0x04: unknown
    0x08: unknown2
    0x20: full_bright
    0x40: unknown3
    0x80: unknown4
  brush_flags:
    0x1:  portal
    0x2:  air
    0x4:  detail
    0x10: emit_steam
  geo_region_flags:
    0x02: sphere
    0x04: unk
    0x20: use_shallow_geomods
    0x40: is_ice
  light_flags:
    0x1:   dynamic
    0x4:   shadow_casting
    0x8:   is_enabled
    0x10:  omnidirectional
    0x20:  circular_spotlight
    #0x30:  tube_light
    0x200: unknown
  entity_ai_mode:
    0: catatonic
    1: waiting
    2: waypoints
    3: collecting
    4: motion_detection
  entity_ai_attack_style:
    0: default
    1: evasive
    2: direct
    3: stand_ground
  entity_cooperation:
    0: uncooperative
    1: species_cooperative
    2: cooperative
  entity_friendliness:
    0: unfriendly
    1: neutral
    2: friendly
    3: outcast
  nav_point_type:
    0: walking
    1: flying
  gas_region_shape:
    1: sphere
    2: box
  particle_emitter_shape:
    1: plane
    2: sphere
  particle_emitter_flags:
    0x04: force_spawn_every_frame
    0x08: direction_dependent_velocity
    0x10: emitter_initially_on
    0x20: unknown
  particle_flags:
    0x0002: glow
    0x0004: fade
    0x0008: gravity
    0x0010: collide_with_world
    0x0040: unknown
    0x0080: explode_on_impact
    0x0100: loop_anim
    0x0200: random_orient
    0x0400: collide_with_liquids
    0x0800: die_on_impact
    0x1000: play_collision_sound
  decal_tiling:
    0: none
    1: u
    2: v
  push_region_shape:
    1: sphere
    2: axis_aligned_box
    3: oriented_box
  push_region_flags:
    0x01: mass_independent
    0x02: grounded
    0x04: grows_towards_region_center
    0x08: grows_towards_region_boundaries
    0x10: radial
    0x20: doesnt_affect_player
    0x40: jump_pad
  climbing_region_type:
    1: ladder
    2: chain_fence
  bolt_emitter_flags:
    0x2: fade
    0x4: glow
    0x8: src_dir_lock
    0x10: trg_dir_lock
