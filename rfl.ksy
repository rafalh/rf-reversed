# RFL format reverse engineered by:
# * Rafal Harabien (Open Faction project)
# * wardd64 (Unity Faction project)
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
        doc: 0xC8 is the last supported version in RF 1.2, standard PC levels use version 0xB4, PS2 levels use versions 0xAE and 0xAF
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
      - id: num_sections
        type: u4
      - id: sections_total_size
        type: u4
        doc: number of bytes used by all sections except trailing one (end)
      - id: level_name
        type: vstring
      - id: mod_name
        type: vstring
        if: version >= 0xB2
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
            'section_type::static_geometry': geometry
            'section_type::geo_regions': geo_regions_section
            'section_type::lights': lights_section
            'section_type::cutscene_cameras': cutscene_cameras_section
            'section_type::ambient_sounds': ambient_sounds_section
            'section_type::events': events_section
            'section_type::mp_respawn_points': mp_respawn_points_section
            'section_type::level_properties': level_properties_section
            'section_type::particle_emitters': particle_emitters_section
            'section_type::gas_regions': gas_regions_section
            'section_type::room_effects': room_effects_section
            'section_type::climbing_regions': climbing_regions_section
            'section_type::bolt_emitters': bolt_emitter_section
            'section_type::targets': targets_section
            'section_type::decals': decals_section
            'section_type::push_regions': push_regions_section
            'section_type::lightmaps': lightmaps_section
            'section_type::movers': movers_section
            'section_type::moving_groups': groups_section
            'section_type::cutscenes': cutscenes_section
            'section_type::cutscene_path_nodes': cutscene_path_nodes_section
            'section_type::cutscene_paths': cutscene_paths_section
            'section_type::tga_files': tga_files_section
            'section_type::vcm_files': vcm_files_section
            'section_type::mvf_files': mvf_files_section
            'section_type::v3d_files': v3d_files_section
            'section_type::vfx_files': vfx_files_section
            'section_type::eax_effects': eax_effects_section
            'section_type::waypoint_lists': waypoint_lists_section
            'section_type::nav_points': nav_points_section
            'section_type::entities': entities_section
            'section_type::items': items_section
            'section_type::clutters':  clutters_section
            'section_type::triggers': triggers_section
            'section_type::player_start': player_start_section
            'section_type::level_info': level_info_section
            'section_type::brushes': brushes_section
            'section_type::groups': groups_section
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
  uv:
    doc: UV coordinates
    seq:
      - id: u
        type: f4
      - id: v
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
      - id: num_uids
        type: u4
      - id: uids
        type: u4
        repeat: expr
        repeat-expr: num_uids

  # Geometry
  room:
    seq:
      - id: id
        type: s4
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
      - id: is_liquid_room
        type: u1
        doc: 1 or 0
      - id: has_ambient_light
        type: u1
        doc: 1 or 0
      - id: is_subroom
        type: u1
        doc: 1 or 0
      - id: has_alpha
        type: u1
        doc: 1 or 0, 1 if any face has texture with alpha channel, updated by RED only if brush has is_detail flag
      - id: life
        type: f4
        doc: -1.0f == infinite
      - id: eax_effect
        type: vstring
        if: _root.header.version >= 0xB4
      - id: liquid_properties
        type: room_liquid_properties
        if: is_liquid_room == 1
      - id: ambient_color
        type: color
        if: has_ambient_light == 1
  room_liquid_properties:
    doc: similar to room_effect_liquid_properties
    seq:
      - id: depth
        type: f4
      - id: color
        type: color
      - id: surface_texture
        type: vstring
      - id: visibility
        type: f4
      - id: liquid_type
        type: u4
        enum: liquid_type
      - id: liquid_alpha
        type: u4
      - id: contains_plankton
        type: u1
        doc: 0 or 1
      - id: texture_pixels_per_meter_u
        type: u4
      - id: texture_pixels_per_meter_v
        type: u4
      - id: texture_angle_radians
        type: f4
      - id: waveform
        type: s4
        doc: -1 - None, 0 - Calm, 1 - Choppy
      - id: texture_scroll_rate
        type: uv
        doc: times/s
  vertex:
    seq:
      - id: index
        type: u4
        doc: index in geometry::vertices
      - id: texture_coords
        type: uv
        doc: texture UV coordinates
      - id: lightmap_coords
        type: uv
        if: _parent.as<face>.lighting_data_index != -1
        doc: lightmap UV coordinates
  face:
    seq:
      - id: plane
        type: f4
        repeat: expr
        repeat-expr: 4
        doc: normal vector and distance from 0
      - id: texture
        type: s4
        doc: index in geometry::textures array, -1 if portal
      - id: lighting_data_index
        type: s4
        doc: index in geometry::face_lighting_data array or -1 if no lightmap is used
      - id: face_id
        type: s4
        doc: before building geometry an ID can be ambiguous; -1 for liquid surface
      - id: reserved1
        size: 8
        doc: unused, always FF FF FF FF FF FF FF FF
      - id: portal_index_plus_2
        type: u4
        doc: index in geometry::portals + 2 if the face was generated by a portal, 0 otherwise
      - id: flags
        type: face_flags
        doc: flags can differ depending on section (e.g. is_detail flag is used in static_geometry but not in brushes)
      - id: lightmap_res
        type: u1
        doc: 1 - default, 8 - lowest, 9 - low, A - high, B - highest
      - id: reserved2
        type: u2
        doc: always 0
      - id: smoothing_groups
        type: u4
        doc: each bit controls one smoothing group
      - id: room_index
        type: s4
      - id: num_vertices
        type: u4
      - id: vertices
        type: vertex
        repeat: expr
        repeat-expr: num_vertices
  face_flags:
    doc: 8 bit long bitfield
    seq:
      - id: has_holes
        type: b1
        doc: value & 0x80, 1 if source brush has is_detail flag and texture has pixels with alpha channel < 50%, holes are taken into account when shooting
      - id: has_alpha
        type: b1
        doc: value & 0x40, 1 if source brush has is_detail flag and texture has alpha channel
      - id: full_bright
        type: b1
        doc: value & 0x20
      - id: scroll_texture
        type: b1
        doc: value & 0x10, 1 if face texture is scrolled according to data in geometry::face_scroll_data
      - id: is_detail
        type: b1
        doc: value & 0x08, 1 if source brush has is_detail flag
      - id: liquid_surface
        type: b1
        doc: value & 0x04, face generated by liquid room effect
      - id: mirrored
        type: b1
        doc: value & 0x02
      - id: show_sky
        type: b1
        doc: value & 0x01
  face_scroll_data:
    seq:
      - id: face_id
        type: u4
      - id: uv
        type: f4
        doc: U velocity
      - id: vv
        type: f4
        doc: V velocity
  geometry:
    seq:
      - id: unknown1
        size: "_root.header.version >= 0xC8 ? 10 : 6"
        doc: typically zeros
      - id: num_textures
        type: u4
      - id: textures
        type: vstring
        repeat: expr
        repeat-expr: num_textures
      - id: num_face_scroll_data
        type: u4
        if: _root.header.version > 0xB4
      - id: face_scroll_data
        type: face_scroll_data
        repeat: expr
        repeat-expr: num_face_scroll_data
        if: _root.header.version > 0xB4
      - id: unknown_up_to_version_b4
        type: u4
        if: _root.header.version <= 0xB4
      - id: num_rooms
        type: u4
        doc: only compiled geometry
      - id: rooms
        type: room
        repeat: expr
        repeat-expr: num_rooms
      - id: num_subroom_lists
        type: u4
        doc: typically equal to num_rooms
      - id: subroom_lists
        type: subroom_list
        repeat: expr
        repeat-expr: num_subroom_lists
      - id: num_portals
        type: u4
      - id: portals
        type: portal
        repeat: expr
        repeat-expr: num_portals
      - id: num_vertices
        type: u4
      - id: vertices
        type: vec3
        repeat: expr
        repeat-expr: num_vertices
      - id: num_faces
        type: u4
      - id: faces
        type: face
        repeat: expr
        repeat-expr: num_faces
      - id: num_face_lighting_data
        type: u4
      - id: face_lighting_data
        type: face_lighting_data
        repeat: expr
        repeat-expr: num_face_lighting_data
      - id: legacy_num_face_scroll_data
        type: u4
        if: _root.header.version <= 0xB4
      - id: legacy_face_scroll_data
        type: face_scroll_data
        repeat: expr
        repeat-expr: legacy_num_face_scroll_data
        if: _root.header.version <= 0xB4
  subroom_list:
    seq:
      - id: room_index
        type: u4
        doc: parent room
      - id: num_subrooms
        type: u4
      - id: subroom_indices
        type: u4
        repeat: expr
        repeat-expr: num_subrooms
        doc: contained rooms
  portal:
    seq:
      - id: room_index1
        type: u4
      - id: room_index2
        type: u4
      - id: point1
        type: vec3
      - id: point2
        type: vec3
  face_lighting_data:
    seq:
      - id: lightmap_index
        type: u4
        doc: index in lightmaps_section::lightmaps array
      - id: x
        type: u1
        doc: X coordinate of lightmap bitmap fragment used by this face
      - id: y
        type: u1
        doc: Y coordinate of lightmap bitmap fragment used by this face
      - id: w
        type: u1
        doc: width of lightmap bitmap fragment used by this face
      - id: h
        type: u1
        doc: height of lightmap bitmap fragment used by this face
      - id: unknown_floats
        type: f4
        repeat: expr
        repeat-expr: 2
        doc: typically positive small numbers
      - id: aabb
        type: aabb
      - id: plane
        type: f4
        repeat: expr
        repeat-expr: 4
        doc: normal vector and distance from 0
      - id: unknown_zeros
        size: 8
        doc: typically zeros
      - id: unknown_indices
        type: u4
        repeat: expr
        repeat-expr: 3
        doc: typically permutation of [0, 1, 2], some indices?
      - id: unknown_floats3
        type: f4
        repeat: expr
        repeat-expr: 4
        doc: related to position and size in 3d space
      - id: room_index
        type: s4
        doc: index in rooms, sometimes -1
  # Geo Regions
  geo_regions_section:
    seq:
      - id: num_geo_regions
        type: u4
      - id: geo_regions
        type: geo_region
        repeat: expr
        repeat-expr: num_geo_regions
  geo_region:
    seq:
      - id: uid
        type: u4
      - id: flags
        type: geo_region_flags
      - id: hardness
        type: u2
        doc: in range 0-100
      - id: shallow_geomod_depth
        type: f4
        if: flags.use_shallow_geomods
      - id: pos
        type: vec3
      - id: rot
        type: mat3
        if: flags.is_box
      - id: width
        type: f4
        if: flags.is_box
      - id: height
        type: f4
        if: flags.is_box
      - id: depth
        type: f4
        if: flags.is_box
      - id: radius
        type: f4
        if: flags.is_sphere
  geo_region_flags:
    doc: 16 bit long bitfield
    seq:
      - id: reserved1
        type: b1
        doc: value & 0x80
      - id: is_ice
        type: b1
        doc: value & 0x40
      - id: use_shallow_geomods
        type: b1
        doc: value & 0x20
      - id: reserved2
        type: b1
        doc: value & 0x10, always 0
      - id: hidden_in_editor
        type: b1
        doc: value & 0x08
      - id: is_box
        type: b1
        doc: value & 0x04
      - id: is_sphere
        type: b1
        doc: value & 0x02
      - id: reserved3
        type: b1
        doc: value & 0x01, always 0
      - id: reserved4
        type: b8
        doc: value & 0xFF00
  # Lights
  lights_section:
    seq:
      - id: num_lights
        type: u4
      - id: lights
        type: light
        repeat: expr
        repeat-expr: num_lights
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
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
      - id: flags
        type: light_flags
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
      - id: dropoff_type
        type: u4
        enum: light_dropoff_type
        doc: editable in RED in game version 1.00, removed in 1.10 patch
      - id: tube_light_width
        type: f4
      - id: intensity
        type: f4
      - id: unknown
        size: 20
        doc: typically [1.0f, 0.0f, 0.0f, 1.0f, 0.0f]
  light_flags:
    doc: 32 bit long bitfield
    seq:
      - id: reserved1
        type: b2
        doc: value & 0xC0
      - id: light_type
        type: b2
        enum: light_type
        doc: value & 0x30
      - id: is_enabled
        type: b1
        doc: value & 0x08
      - id: shadow_casting
        type: b1
        doc: value & 0x04
      - id: unknown_2
        type: b1
        doc: value & 0x02
      - id: dynamic
        type: b1
        doc: value & 0x01
      - id: reserved2
        type: b24
        doc: value & 0xFFFFFF00
  # Cutscene Cameras
  cutscene_cameras_section:
    seq:
      - id: num_cutscene_cameras
        type: u4
      - id: cutscene_cameras
        type: cutscene_camera
        repeat: expr
        repeat-expr: num_cutscene_cameras
  cutscene_camera:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: vstring
        doc: always "Cutscene Camera"
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
        doc: always "Cutscene Camera"
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
  # Ambient Sounds
  ambient_sounds_section:
    seq:
      - id: num_ambient_sounds
        type: u4
      - id: ambient_sounds
        type: ambient_sound
        repeat: expr
        repeat-expr: num_ambient_sounds
  ambient_sound:
    seq:
      - id: uid
        type: u4
      - id: pos
        type: vec3
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
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
      - id: num_events
        type: u4
      - id: events
        type: event
        repeat: expr
        repeat-expr: num_events
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
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
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
        if: (_root.header.version >= 0x91 and (class_name.str == "Teleport" or class_name.str == "Play_Vclip" or class_name.str == "Teleport_Player")) or (_root.header.version >= 0x98 and class_name.str == "Alarm")
      - id: color
        type: color
        if: _root.header.version >= 0xB0
  # Multiplayer Respawn Points
  mp_respawn_points_section:
    seq:
      - id: num_mp_respawn_points
        type: u4
      - id: mp_respawn_points
        type: mp_respawn_point
        repeat: expr
        repeat-expr: num_mp_respawn_points
  mp_respawn_point:
    seq:
      - id: uid
        type: u4
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
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
        doc: typically 0
      - id: fog_color
        type: color
      - id: fog_near_plane
        type: f4
      - id: fog_far_plane
        type: f4
  # Particle Emitters
  particle_emitters_section:
    seq:
      - id: num_particle_emitters
        type: u4
      - id: particle_emitters
        type: particle_emitter
        repeat: expr
        repeat-expr: num_particle_emitters
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
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
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
        type: particle_emitter_flags
      - id: particle_flags
        type: particle_flags
      - id: stickieness
        type: b4
      - id: bounciness
        type: b4
      - id: push_effect
        type: b4
      - id: swirliness
        type: b4
      - id: unknown
        type: u1
        doc: typically 1
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
  particle_emitter_flags:
    doc: 32 bit long bitfield
    seq:
      - id: reserved1
        type: b2
        doc: value & 0xC0
      - id: unknown_20
        type: b1
        doc: value & 0x20
      - id: emitter_initially_on
        type: b1
        doc: value & 0x10
      - id: direction_dependent_velocity
        type: b1
        doc: value & 0x08
      - id: force_spawn_every_frame
        type: b1
        doc: value & 0x04
      - id: unknown_2
        type: b1
        doc: value & 0x02
      - id: unknown_1
        type: b1
        doc: value & 0x01
      - id: reserved2
        type: b24
        doc: value & 0xFFFFFF00
  particle_flags:
    doc: 16 bit long bitfield
    seq:
      - id: explode_on_impact
        type: b1
        doc: value & 0x80
      - id: unknown_40
        type: b1
        doc: value & 0x40
      - id: unknown_20
        type: b1
        doc: value & 0x20
      - id: collide_with_world
        type: b1
        doc: value & 0x10
      - id: gravity
        type: b1
        doc: value & 0x08
      - id: fade
        type: b1
        doc: value & 0x04
      - id: glow
        type: b1
        doc: value & 0x02
      - id: unknown_1
        type: b1
        doc: value & 0x01
      - id: reserved
        type: b3
        doc: value & 0xE000
      - id: play_collision_sound
        type: b1
        doc: value & 0x1000
      - id: die_on_impact
        type: b1
        doc: value & 0x0800
      - id: collide_with_liquids
        type: b1
        doc: value & 0x0400
      - id: random_orient
        type: b1
        doc: value & 0x0200
      - id: loop_anim
        type: b1
        doc: value & 0x0100
  # Gas Regions
  gas_regions_section:
    seq:
      - id: num_gas_regions
        type: u4
      - id: gas_regions
        type: gas_region
        repeat: expr
        repeat-expr: num_gas_regions
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
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
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
  # Room Effects
  room_effects_section:
    seq:
      - id: num_room_effects
        type: u4
      - id: room_effects
        type: room_effect
        repeat: expr
        repeat-expr: num_room_effects
  room_effect:
    seq:
      - id: effect_type
        type: u4
        enum: room_effect_type
      - id: ambient_light_color
        type: color
        if: effect_type == room_effect_type::ambient_light
      - id: liquid_properties
        type: room_effect_liquid_properties
        if: effect_type == room_effect_type::liquid_room
      - id: room_is_cold
        type: u1
        doc: 0 or 1
      - id: room_is_outside
        type: u1
        doc: 0 or 1
      - id: room_is_air_lock
        type: u1
        doc: 0 or 1
      - id: uid
        type: u4
      - id: class_name
        type: vstring
        doc: always "Room Effect"
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
        doc: always "Room Effect"
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
  room_effect_liquid_properties:
    doc: similar to room_liquid_properties
    seq:
      - id: waveform
        type: u4
        enum: liquid_waveform_type
      - id: depth
        type: f4
      - id: surface_texture
        type: vstring
      - id: liquid_color
        type: color
      - id: visibility
        type: f4
      - id: liquid_type
        type: u4
        enum: liquid_type
      - id: contains_plankton
        type: u1
      - id: texture_pixels_per_meter_u
        type: u4
      - id: texture_pixels_per_meter_v
        type: u4
      - id: texture_angle_degrees
        type: f4
      - id: texture_scroll_rate
        type: uv
        doc: times/s
  # Climbing Regions
  climbing_regions_section:
    seq:
      - id: num_climbing_regions
        type: u4
      - id: climbing_regions
        type: climbing_region
        repeat: expr
        repeat-expr: num_climbing_regions
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
      - id: num_bolt_emitters
        type: u4
      - id: bolt_emitters
        type: bolt_emitter
        repeat: expr
        repeat-expr: num_bolt_emitters
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
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
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
      - id: num_segments
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
        type: bolt_emitter_flags
      - id: initially_on
        type: u1
        doc: 0 or 1
  bolt_emitter_flags:
    doc: 32 bit long bitfield
    seq:
      - id: reserved1
        type: b3
        doc: value & 0xE0
      - id: trg_dir_lock
        type: b1
        doc: value & 0x10
      - id: src_dir_lock
        type: b1
        doc: value & 0x08
      - id: glow
        type: b1
        doc: value & 0x04
      - id: fade
        type: b1
        doc: value & 0x02
      - id: unknown_1
        type: b1
        doc: value & 0x01
      - id: reserved2
        type: b24
        doc: value & 0xFFFFFF00
  # Targets
  targets_section:
    seq:
      - id: num_targets
        type: u4
      - id: targets
        type: target
        repeat: expr
        repeat-expr: num_targets
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
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
  # Decals
  decals_section:
    seq:
      - id: num_decals
        type: u4
      - id: decals
        type: decal
        repeat: expr
        repeat-expr: num_decals
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
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
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
      - id: num_push_regions
        type: u4
      - id: push_regions
        type: push_region
        repeat: expr
        repeat-expr: num_push_regions
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
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
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
        type: push_region_flags
      - id: turbulence
        type: u2
  push_region_flags:
    doc: 16 bit long bitfield
    seq:
      - id: reserved1
        type: b1
        doc: value & 0x80
      - id: jump_pad
        type: b1
        doc: value & 0x40
      - id: doesnt_affect_player
        type: b1
        doc: value & 0x20
      - id: radial
        type: b1
        doc: value & 0x10
      - id: grows_towards_region_boundaries
        type: b1
        doc: value & 0x08
      - id: grows_towards_region_center
        type: b1
        doc: value & 0x04
      - id: grounded
        type: b1
        doc: value & 0x02
      - id: mass_independent
        type: b1
        doc: value & 0x01
      - id: reserved2
        type: b8
        doc: value & 0xFF00
  # Lightmaps
  lightmaps_section:
    seq:
      - id: num_lightmaps
        type: u4
      - id: lightmaps
        type: lightmap
        repeat: expr
        repeat-expr: num_lightmaps
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
  # Movers
  movers_section:
    seq:
      - id: num_movers
        type: u4
      - id: movers
        type: brush
        repeat: expr
        repeat-expr: num_movers
  # Moving groups / Groups
  groups_section:
    seq:
      - id: num_groups
        type: u4
      - id: groups
        type: group
        repeat: expr
        repeat-expr: num_groups
  group:
    seq:
      - id: name
        type: vstring
      - id: unknown
        type: u1
        doc: typically 0
      - id: is_moving
        type: u1
        doc: 0 or 1
      - id: moving_data
        type: moving_group_data
        if: is_moving != 0
      - id: objects
        type: uid_list
        doc: non-brush members
      - id: brushes
        type: uid_list
        doc: brush-only members
  moving_group_data:
    seq:
      - id: num_keyframes
        type: u4
      - id: keyframes
        type: keyframe
        repeat: expr
        repeat-expr: num_keyframes
      - id: num_member_transforms
        type: u4
      - id: member_transforms
        type: moving_group_member_transform
        repeat: expr
        repeat-expr: num_member_transforms
        doc: transform applied to keyframe to get each member transform
      - id: is_door
        type: u1
        doc: 0 or 1
      - id: rotate_in_place
        type: u1
        doc: 0 or 1
      - id: starts_backwards
        type: u1
        doc: 0 or 1
      - id: use_trav_time_as_spd
        type: u1
        doc: 0 or 1
      - id: force_orient
        type: u1
        doc: 0 or 1
      - id: no_player_collide
        type: u1
        doc: 0 or 1
      - id: movement_type
        type: u4
        enum: movement_type
      - id: starting_keyframe
        type: u4
      - id: start_sound
        type: vstring
      - id: start_vol
        type: f4
      - id: looping_sound
        type: vstring
      - id: looping_vol
        type: f4
      - id: stop_sound
        type: vstring
      - id: stop_vol
        type: f4
      - id: close_sound
        type: vstring
      - id: close_vol
        type: f4
  moving_group_member_transform:
    seq:
      - id: uid
        type: u4
      - id: pos
        type: vec3
      - id: rot
        type: mat3
  keyframe:
    seq:
      - id: uid
        type: u4
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
      - id: pause_time
        type: f4
      - id: depart_travel_time
        type: f4
      - id: return_travel_time
        type: f4
      - id: accel_time
        type: f4
      - id: decel_time
        type: f4
      - id: trigger_uid
        type: s4
      - id: contain_uid1
        type: s4
      - id: contain_uid2
        type: s4
      - id: degrees_about_axis
        type: f4
  # Cutscenes
  cutscenes_section:
    seq:
      - id: num_cutscenes
        type: u4
      - id: cutscenes
        type: cutscene
        repeat: expr
        repeat-expr: num_cutscenes
  cutscene:
    seq:
      - id: uid
        type: u4
      - id: hide_player
        type: u1
      - id: fov
        type: f4
      - id: num_shots
        type: u4
      - id: shots
        type: cutscene_shot
        repeat: expr
        repeat-expr: num_shots
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
      - id: num_cutscene_path_nodes
        type: u4
      - id: cutscene_path_nodes
        type: cutscene_path_node
        repeat: expr
        repeat-expr: num_cutscene_path_nodes
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
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
  # Cutscene Paths
  cutscene_paths_section:
    seq:
      - id: num_cutscene_paths
        type: u4
      - id: cutscene_paths
        type: cutscene_path
        repeat: expr
        repeat-expr: num_cutscene_paths
  cutscene_path:
    seq:
      - id: name
        type: vstring
      - id: num_path_nodes
        type: u4
      - id: path_nodes
        type: u4
        repeat: expr
        repeat-expr: num_path_nodes
  # TGA Files
  tga_files_section:
    seq:
      - id: num_tga_files
        type: u4
      - id: tga_files
        type: vstring
        repeat: expr
        repeat-expr: num_tga_files
        doc: many files, not textures
  # VCM Files
  vcm_files_section:
    seq:
      - id: num_vcm_files
        type: u4
      - id: vcm_files
        type: vstring
        repeat: expr
        repeat-expr: num_vcm_files
      - id: unknown
        type: u4
        repeat: expr
        repeat-expr: num_vcm_files
        doc: typically 1
  # MVF Files
  mvf_files_section:
    seq:
      - id: num_mvf_files
        type: u4
      - id: mvf_files
        type: vstring
        repeat: expr
        repeat-expr: num_mvf_files
      - id: unknown
        type: u4
        repeat: expr
        repeat-expr: num_mvf_files
        doc: typically 1 or 2
  # V3D Files
  v3d_files_section:
    seq:
      - id: num_v3d_files
        type: u4
      - id: v3d_files
        type: vstring
        repeat: expr
        repeat-expr: num_v3d_files
      - id: unknown
        type: u4
        repeat: expr
        repeat-expr: num_v3d_files
        doc: typically 1 or 2
  # VFX Files
  vfx_files_section:
    seq:
      - id: num_vfx_files
        type: u4
      - id: vfx_files
        type: vstring
        repeat: expr
        repeat-expr: num_vfx_files
      - id: unknown
        type: u4
        repeat: expr
        repeat-expr: num_vfx_files
        doc: typically 1
  # EAX Effects
  eax_effects_section:
    seq:
      - id: num_eax_effects
        type: u4
      - id: eax_effects
        type: eax_effect
        repeat: expr
        repeat-expr: num_eax_effects
  eax_effect:
    seq:
      - id: effect_type
        type: vstring
      - id: uid
        type: u4
      - id: class_name
        type: vstring
        doc: always "EAX Effect"
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: script_name
        type: vstring
        doc: always "EAX Effect"
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
  # Waypoint Lists
  waypoint_lists_section:
    seq:
      - id: num_waypoint_lists
        type: u4
      - id: waypoint_lists
        type: waypoint_list
        repeat: expr
        repeat-expr: num_waypoint_lists
  waypoint_list:
    seq:
      - id: name
        type: vstring
      - id: num_waypoints
        type: u4
      - id: waypoints
        type: u4
        repeat: expr
        repeat-expr: num_waypoints
        doc: indices in nav_points_section::nav_points array
  # Nav Points
  nav_points_section:
    seq:
      - id: num_nav_points
        type: u4
      - id: nav_points
        type: nav_point
        repeat: expr
        repeat-expr: num_nav_points
      - id: nav_point_connections
        type: nav_point_connections
        repeat: expr
        repeat-expr: num_nav_points
  nav_point:
    seq:
      - id: uid
        type: u4
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
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
      - id: unknown1
        type: u1
        doc: typically 0
      - id: unknown2
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
      - id: num_indices
        type: u1
      - id: indices
        type: u4
        repeat: expr
        repeat-expr: num_indices
        doc: indices in nav_points_section::nav_points array
  # Entities
  entities_section:
    seq:
      - id: num_entities
        type: u4
      - id: entities
        type: entity
        repeat: expr
        repeat-expr: num_entities
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
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
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
      - id: unknown1
        type: u1
        doc: typically 0
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
      - id: unknown2
        type: u1
        doc: typically 0
      - id: start_crouched
        type: u1
        doc: 1 or 0
      - id: life
        type: f4
      - id: armor
        type: f4
        doc: -1.0f if entity has no armor
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
      - id: unknown3
        type: u4
        doc: typically 0
      - id: turret_uid
        type: s4
      - id: alert_camera_uid
        type: s4
      - id: alarm_event_uid
        type: s4
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
      - id: num_items
        type: u4
      - id: items
        type: item
        repeat: expr
        repeat-expr: num_items
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
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
      - id: count
        type: u4
      - id: respawn_time
        type: u4
      - id: team_id
        type: u4
  # Clutters
  clutters_section:
    seq:
      - id: num_clutters
        type: u4
      - id: clutters
        type: clutter
        repeat: expr
        repeat-expr: num_clutters
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
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
      - id: unknown
        type: u4
        doc: typically 0
      - id: skin
        type: vstring
      - id: links
        type: uid_list
  # Triggers
  triggers_section:
    seq:
      - id: num_triggers
        type: u4
      - id: triggers
        type: trigger
        repeat: expr
        repeat-expr: num_triggers
  trigger:
    seq:
      - id: uid
        type: u4
      - id: script_name
        type: vstring
        doc: depends on trigger type,
             if first byte is 0xAB then second byte contains Pure Faction
             flags (0x2 = clientside, 0x4 = solo, 0x8 = teleport)
      - id: hidden_in_editor
        type: u1
        doc: 0 or 1
      - id: shape
        type: u4
        enum: trigger_shape
      - id: resets_after
        type: f4
      - id: resets_times
        type: s4
        doc: -1 - infinity
      - id: is_use_key_required
        type: u1
        doc: 1 or 0
      - id: key_name
        type: vstring
      - id: weapon_activates
        type: u1
        doc: 1 or 0
      - id: activated_by
        type: u1
        enum: trigger_activated_by
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
        if: shape == trigger_shape::sphere
      - id: rot
        type: mat3
        if: shape != trigger_shape::sphere
      - id: box_height
        type: f4
        if: shape != trigger_shape::sphere
      - id: box_width
        type: f4
        if: shape != trigger_shape::sphere
      - id: box_depth
        type: f4
        if: shape != trigger_shape::sphere
      - id: one_way
        type: u1
        if: shape != trigger_shape::sphere
        doc: 1 or 0
      - id: airlock_room_uid
        type: s4
        doc: UID, -1 if empty
      - id: attached_to_uid
        type: s4
        doc: UID, -1 if empty
      - id: use_clutter_uid
        type: s4
        doc: UID, -1 if empty
      - id: disabled
        type: u1
        doc: 1 or 0
      - id: button_active_time_seconds
        type: f4
      - id: inside_time_seconds
        type: f4
      - id: team
        type: s4
        enum: trigger_team
        if: _root.header.version >= 0xB1
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
        doc: typically 1
      - id: level_name
        type: vstring
      - id: author
        type: vstring
      - id: date
        type: vstring
      - id: has_movers
        type: u1
        doc: 0 or 1
      - id: multiplayer_level
        type: u1
        doc: 0 or 1
      - id: editor_view_configs
        type: editor_view_config
        repeat: expr
        repeat-expr: 4
  editor_view_config:
    seq:
      - id: view_type
        type: u4
        enum: editor_view_type
      - id: pos_3d
        type: vec3
        if: view_type == editor_view_type::free_look
      - id: pos_2d
        type: f4
        repeat: expr
        repeat-expr: 4
        if: view_type != editor_view_type::free_look
      - id: rot
        type: mat3
  # Brushes
  brushes_section:
    seq:
      - id: num_brushes
        type: u4
      - id: brushes
        type: brush
        repeat: expr
        repeat-expr: num_brushes
  brush:
    seq:
      - id: uid
        type: u4
      - id: pos
        type: vec3
      - id: rot
        type: mat3
      - id: geometry
        type: geometry
      - id: flags
        type: brush_flags
      - id: life
        type: s4
      - id: state
        type: u4
        enum: brush_state
  brush_flags:
    doc: 32 bit long bitfield
    seq:
      - id: reserved1
        type: b3
        doc: value & 0xE0
      - id: emits_steam
        type: b1
        doc: value & 0x10
      - id: unknown_8
        type: b1
        doc: value & 0x08
      - id: detail
        type: b1
        doc: value & 0x04
      - id: air
        type: b1
        doc: value & 0x02
      - id: portal
        type: b1
        doc: value & 0x01
      - id: reserved2
        type: b24
        doc: value & 0xFFFFFF00

enums:
  section_type:
    0x00000000: end
    0x00000100: static_geometry
    0x00000200: geo_regions
    0x00000300: lights
    0x00000400: cutscene_cameras
    0x00000500: ambient_sounds
    0x00000600: events
    0x00000700: mp_respawn_points
    0x00000800: unknown_800
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
    0x00007000: tga_files
    0x00007001: vcm_files
    0x00007002: mvf_files
    0x00007003: v3d_files
    0x00007004: vfx_files
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
  brush_state:
    0x0: normal
    0x2: locked
    0x3: selected
  light_type:
    1: omnidirectional
    2: circular_spotlight
    3: tube_light
  light_dropoff_type:
    0: linear
    1: squared
    2: cosine
    3: sqrt
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
  decal_tiling:
    0: none
    1: u
    2: v
  push_region_shape:
    1: sphere
    2: axis_aligned_box
    3: oriented_box
  climbing_region_type:
    1: ladder
    2: chain_fence
  trigger_shape:
    0: sphere
    1: box
  trigger_activated_by:
    0: players_only
    1: all_objects
    2: linked_objects
    3: ai_only
    4: player_vehicle_only
    5: geomods
  trigger_team:
    -1: none
    0:  team_1
    1:  team_2
  movement_type:
    0: one_way
    1: ping_pong_once
    2: ping_pong_infinite
    3: loop_once
    4: loop_infinite
    5: lift
  room_effect_type:
    1: sky_room
    2: liquid_room
    3: ambient_light
    4: none
  liquid_type:
    1: water
    2: lava
    3: acid
  liquid_waveform_type:
    1: none
    2: calm
    3: choppy
  editor_view_type:
    0: free_look
    1: top
    2: bottom
    3: front
    4: back
    5: left
    6: right
