meta:
  id: rfl
  title: Red Faction Level
  application: Red Faction
  endian: le
  license: GPL-3.0-or-later
  file-extension: rfl
seq:
  - id: header
    type: rfl_header
  - id: sections
    type: rfl_section
    repeat: until
    repeat-until: _.type == rfl_section_type::end
types:
  rfl_header:
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
        doc: file offset to rfl_player_start section header
      - id: level_info_offset
        type: u4
        doc: file offset to rfl_level_info section header
      - id: sections_count
        type: u4
      - id: unknown
        type: u4
        doc: sections data size - 8
      - id: level_name
        type: rfl_string
      - id: mod_name
        type: rfl_string
  rfl_section:
    seq:
      - id: type
        type: u4
        enum: rfl_section_type
      - id: len
        type: u4
      - id: body
        size: len
        type:
          switch-on: type
          cases:
            'rfl_section_type::static_geometry': rfl_rooms_sect
            'rfl_section_type::geo_regions': rfl_geo_regions
            'rfl_section_type::lights': rfl_lights
            'rfl_section_type::cutscene_cameras': rfl_cutscene_cameras
            'rfl_section_type::ambient_sounds': rfl_ambient_sounds
            'rfl_section_type::events': rfl_events
            'rfl_section_type::mp_respawns': rfl_mp_respawns
            'rfl_section_type::level_properties': rfl_level_properties
            # 'rfl_section_type::particle_emitters': 
            # 'rfl_section_type::gas_regions': 
            # 'rfl_section_type::room_effects': 
            # 'rfl_section_type::bolt_emitters': 
            # 'rfl_section_type::targets': 
            # 'rfl_section_type::decals': 
            # 'rfl_section_type::push_regions': 
            'rfl_section_type::lightmaps': rfl_lightmaps
            # 'rfl_section_type::movers': 
            # 'rfl_section_type::moving_groups': 
            'rfl_section_type::cutscenes': rfl_cutscenes
            'rfl_section_type::cutscene_path_nodes': rfl_cutscene_path_nodes
            'rfl_section_type::cutscene_paths': rfl_cutscene_paths
            'rfl_section_type::tga_unknown': rfl_tga_files
            'rfl_section_type::vcm_unknown': rfl_vcm_files
            'rfl_section_type::mvf_unknown': rfl_mvf_files
            'rfl_section_type::v3d_unknown': rfl_v3d_files
            'rfl_section_type::vfx_unknown': rfl_vfx_files
            # 'rfl_section_type::eax_effects': 
            'rfl_section_type::waypoint_lists': rfl_waypoint_lists
            'rfl_section_type::nav_points': rfl_nav_points
            'rfl_section_type::entities': rfl_entities
            'rfl_section_type::items': rfl_items
            'rfl_section_type::clutters':  rfl_clutters
            'rfl_section_type::triggers': rfl_triggers
            'rfl_section_type::player_start': rfl_player_start
            'rfl_section_type::level_info': rfl_level_info
            'rfl_section_type::brushes': rfl_brushes_sect
            #'rfl_section_type::groups': rfl_groups
            'rfl_section_type::editor_only_lights': rfl_lights
  rfl_string:
    doc: variable-length string
    seq:
      - id: len
        type: u2
      - id: str
        type: str
        size: len
        encoding: ASCII
  rfl_vec3:
    doc: 3D vector
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  rfl_mat3:
    doc: rotation matrix, rows are in a non-standard order - 2, 3, 1
    seq:
      - id: forward
        type: rfl_vec3
      - id: right
        type: rfl_vec3
      - id: up
        type: rfl_vec3
  rfl_aabb:
    doc: axis aligned bounding box
    seq:
      - id: p1
        type: rfl_vec3
      - id: p2
        type: rfl_vec3
  rfl_color:
    seq:
      - id: r
        type: u1
      - id: g
        type: u1
      - id: b
        type: u1
      - id: a
        type: u1
  rfl_uid_list:
    seq:
      - id: count
        type: u4
      - id: uids
        type: u4
        repeat: expr
        repeat-expr: count

  # Sections
  rfl_level_properties:
    seq:
      - id: geomod_texture
        type: rfl_string
      - id: hardness
        type: u4
      - id: ambient_color
        type: rfl_color
      - id: unknown
        type: u1
      - id: fog_color
        type: rfl_color
      - id: fog_near_plane
        type: f4
      - id: fog_far_plane
        type: f4
  rfl_geo_regions:
    seq:
      - id: count
        type: u4
      - id: geo_regions
        type: rfl_geo_region
        repeat: expr
        repeat-expr: count
  rfl_geo_region:
    seq:
      - id: uid
        type: u4
      - id: flags
        type: u2
        enum: rfl_geo_region_flags
      - id: hardness
        type: u2
        doc: in range 0-100
      - id: shallow_geomod_depth
        type: f4
        if: flags.to_i & rfl_geo_region_flags::use_shallow_geomods.to_i != 0
      - id: pos
        type: rfl_vec3
      - id: rot
        type: rfl_mat3
        if: flags.to_i & rfl_geo_region_flags::sphere.to_i == 0
      - id: width
        type: f4
        if: flags.to_i & rfl_geo_region_flags::sphere.to_i == 0
      - id: height
        type: f4
        if: flags.to_i & rfl_geo_region_flags::sphere.to_i == 0
      - id: depth
        type: f4
        if: flags.to_i & rfl_geo_region_flags::sphere.to_i == 0
      - id: radius
        type: f4
        if: flags.to_i & rfl_geo_region_flags::sphere.to_i != 0
  rfl_lights:
    seq:
      - id: count
        type: u4
      - id: lights
        type: rfl_light
        repeat: expr
        repeat-expr: count
  rfl_light:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: rfl_string
        doc: "Light"
      - id: pos
        type: rfl_vec3
      - id: rot
        type: rfl_mat3
      - id: script_name
        type: rfl_string
      - id: reserved
        type: u1
      - id: flags
        type: u4
        enum: rfl_light_flags
      - id: color
        type: rfl_color
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
  rfl_events:
    seq:
      - id: count
        type: u4
      - id: events
        type: rfl_event
        repeat: expr
        repeat-expr: count
  rfl_event:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: rfl_string
      - id: pos
        type: rfl_vec3
      - id: script_name
        type: rfl_string
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
        type: rfl_string
      - id: str2
        type: rfl_string
      - id: links
        type: rfl_uid_list
      - id: rot
        type: rfl_mat3
        if: class_name.str == "Alarm" or class_name.str == "Teleport" or class_name.str == "Play_Vclip" or class_name.str == "Teleport_Player"
      - id: color
        type: rfl_color
  rfl_room:
    seq:
      - id: id
        type: u4
        doc: uid of room effect element or big numbers (>0x70000000)
      - id: aabb
        type: rfl_aabb
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
        type: rfl_string
      - id: liquid_depth
        type: f4
        if: liquid_room == 1
      - id: liquid_color
        type: rfl_color
        if: liquid_room == 1
      - id: liquid_surface_texture
        type: rfl_string
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
        type: rfl_color
        if: ambient_light == 1
  rfl_vertex:
    seq:
      - id: index
        type: u4
        doc: index in rfl_rooms_sect::vertices
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
  rfl_face:
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
        doc: if not 0xFFFFFFFF rfl_vertex has lightmap coordinates; it's not lightmap id
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
        enum: rfl_face_flags
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
        type: rfl_vertex
        repeat: expr
        repeat-expr: vertices_count
  rfl_face_scroll:
    seq:
      - id: face_id
        type: u4
      - id: uv
        type: f4
        doc: U velocity
      - id: vv
        type: f4
        doc: V velocity
  rfl_rooms_sect:
    seq:
      - id: unknown
        size: "_root.header.version > 0xB4 ? 10 : 6"
      - id: textures_count
        type: u4
      - id: textures
        type: rfl_string
        repeat: expr
        repeat-expr: textures_count
      - id: scroll_count
        type: u4
      - id: scroll
        type: rfl_face_scroll
        repeat: expr
        repeat-expr: scroll_count
      - id: rooms_count
        type: u4
        doc: only compiled geometry
      - id: rooms
        type: rfl_room
        repeat: expr
        repeat-expr: rooms_count
      - id: unknown_count
        type: u4
        doc: equal to rooms_count, only compiled geometry
      - id: unknown2
        type: rfl_rooms_unk
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
        type: rfl_vec3
        repeat: expr
        repeat-expr: vertices_count
      - id: faces_count
        type: u4
      - id: faces
        type: rfl_face
        repeat: expr
        repeat-expr: faces_count
      - id: unknown_count3
        type: u4
      - id: unknown4
        type: rfl_rooms_unk2
        repeat: expr
        repeat-expr: unknown_count3
      - id: unknown5
        type: u4
        if: _root.header.version == 0xB4
  rfl_rooms_unk:
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
  rfl_rooms_unk2:
    seq:
      - id: lightmap
        type: u4
      - id: unk
        size: 88
      - id: face
        type: u4
        doc: index in faces
  
  rfl_player_start:
    seq:
      - id: pos
        type: rfl_vec3
      - id: rot
        type: rfl_mat3
  rfl_level_info:
    seq:
      - id: unknown
        type: u4
        doc: 0x00000001
      - id: level_name
        type: rfl_string
      - id: author
        type: rfl_string
      - id: date
        type: rfl_string
      - id: unknown2
        type: u1
        doc: 00
      - id: multiplayer_level
        type: u1
        doc: 0 or 1
      - id: unknown3
        size: 220
  rfl_tga_files:
    seq:
      - id: tga_files_count
        type: u4
      - id: tga_files
        type: rfl_string
        repeat: expr
        repeat-expr: tga_files_count
        doc: many files, not textures
  rfl_vcm_files:
    seq:
      - id: vcm_files_count
        type: u4
      - id: vcm_files
        type: rfl_string
        repeat: expr
        repeat-expr: vcm_files_count
      - id: unknown
        type: u4
        repeat: expr
        repeat-expr: vcm_files_count
        doc: 0x00000001
  rfl_mvf_files:
    seq:
      - id: mvf_files_count
        type: u4
      - id: mvf_files
        type: rfl_string
        repeat: expr
        repeat-expr: mvf_files_count
      - id: unknown
        type: u4
        repeat: expr
        repeat-expr: mvf_files_count
  rfl_v3d_files:
    seq:
      - id: v3d_files_count
        type: u4
      - id: v3d_files
        type: rfl_string
        repeat: expr
        repeat-expr: v3d_files_count
      - id: unknown
        type: u4
        repeat: expr
        repeat-expr: v3d_files_count
  rfl_vfx_files:
    seq:
      - id: vfx_files_count
        type: u4
      - id: vfx_files
        type: rfl_string
        repeat: expr
        repeat-expr: vfx_files_count
      - id: unknown
        type: u4
        repeat: expr
        repeat-expr: vfx_files_count
  rfl_cutscenes:
    seq:
      - id: count
        type: u4
      - id: cutscenes
        type: rfl_cutscene
        repeat: expr
        repeat-expr: count
  rfl_cutscene:
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
        type: rfl_cutscene_shot
        repeat: expr
        repeat-expr: shots_count
  rfl_cutscene_shot:
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
        type: rfl_string
  rfl_cutscene_path_nodes:
    seq:
      - id: count
        type: u4
      - id: cutscene_path_nodes
        type: rfl_cutscene_path_node
        repeat: expr
        repeat-expr: count
  rfl_cutscene_path_node:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: rfl_string
      - id: pos
        type: rfl_vec3
      - id: rot
        type: rfl_mat3
      - id: script_name
        type: rfl_string
      - id: unknown
        type: u1
  rfl_cutscene_paths:
    seq:
      - id: count
        type: u4
      - id: cutscene_paths
        type: rfl_cutscene_path
        repeat: expr
        repeat-expr: count
  rfl_cutscene_path:
    seq:
      - id: name
        type: rfl_string
      - id: path_nodes_count
        type: u4
      - id: path_nodes
        type: u4
        repeat: expr
        repeat-expr: path_nodes_count
  rfl_waypoint_lists:
    seq:
      - id: count
        type: u4
      - id: waypoint_lists
        type: rfl_waypoint_list
        repeat: expr
        repeat-expr: count
  rfl_waypoint_list:
    seq:
      - id: name
        type: rfl_string
      - id: count
        type: u4
      - id: waypoints
        type: u4
        repeat: expr
        repeat-expr: count
        doc: probably index in waypoints objects array
  rfl_nav_points:
    seq:
      - id: count
        type: u4
      - id: nav_points
        type: rfl_nav_point
        repeat: expr
        repeat-expr: count
      - id: nav_point_connections
        type: rfl_nav_point_connections
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
        type: rfl_vec3
      - id: radius
        type: f4
      - id: type
        type: u4
        enum: rfl_nav_point_type
      - id: directional
        type: u1
        doc: 0 or 1
      - id: rot
        type: rfl_mat3
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
        type: rfl_uid_list
  rfl_nav_point_connections:
    seq:
      - id: count
        type: u1
      - id: indices
        type: u4
        repeat: expr
        repeat-expr: count
  rfl_level_properies:
    seq:
      - id: geomod_texture
        type: rfl_string
      - id: hardness
        type: u4
      - id: ambient_color
        type: rfl_color
      - id: unknown
        type: u1
      - id: fog_color
        type: rfl_color
      - id: fog_near_plane
        type: f4
      - id: fog_far_plane
        type: f4
  rfl_lightmap:
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
  rfl_lightmaps:
    seq:
      - id: lightmaps_count
        type: u4
      - id: lightmaps
        type: rfl_lightmap
        repeat: expr
        repeat-expr: lightmaps_count
  rfl_cutscene_cameras:
    seq:
      - id: count
        type: u4
      - id: cutscene_cameras
        type: rfl_cutscene_camera
        repeat: expr
        repeat-expr: count
  rfl_cutscene_camera:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: rfl_string
        doc: "Cutscene Camera"
      - id: unknown
        size: 48
      - id: script_name
        type: rfl_string
      - id: unknown2
        type: u1
        doc: 0x00
  rfl_ambient_sounds:
    seq:
      - id: count
        type: u4
      - id: ambient_sounds
        type: rfl_ambient_sound
        repeat: expr
        repeat-expr: count
  rfl_ambient_sound:
    seq:
      - id: uid
        type: u4
      - id: pos
        type: rfl_vec3
      - id: unknown
        type: u1
      - id: sound_file_name
        type: rfl_string
      - id: min_dist
        type: f4
      - id: volume_scale
        type: f4
      - id: rolloff
        type: f4
      - id: start_delay_ms
        type: u4
  rfl_mp_respawns:
    seq:
      - id: count
        type: u4
      - id: respawns
        type: rfl_mp_respawn
        repeat: expr
        repeat-expr: count
  rfl_mp_respawn:
    seq:
      - id: uid
        type: u4
      - id: pos
        type: rfl_vec3
      - id: rot
        type: rfl_mat3
      - id: script_name
        type: rfl_string
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
  rfl_gas_region:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: rfl_string
        doc: "Gas Region"
      - id: pos
        type: rfl_vec3
      - id: rot
        type: rfl_mat3
      - id: script_name
        type: rfl_string
      - id: unknown2
        size: 17
  rlf_climbing_region:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: rfl_string
        doc: "Climbing Region"
      - id: pos
        type: rfl_vec3
      - id: rot
        type: rfl_mat3
      - id: script_name
        type: rfl_string
      - id: unknown2
        size: 17
  rlf_bolt_emiter:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: rfl_string
        doc: "Bolt Emiter"
      - id: pos
        type: rfl_vec3
      - id: rot
        type: rfl_mat3
      - id: script_name
        type: rfl_string
      - id: unknown2
        size: 45
      - id: image
        type: rfl_string
      - id: unknown3
        size: 5
  rfl_entities:
    seq:
      - id: count
        type: u4
      - id: entities
        type: rfl_entity
        repeat: expr
        repeat-expr: count
  rfl_entity:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: rfl_string
        doc: depends on type
      - id: pos
        type: rfl_vec3
      - id: rot
        type: rfl_mat3
      - id: script_name
        type: rfl_string
      - id: unknown
        type: u1
      - id: cooperation
        type: u4
        enum: rfl_entity_cooperation
      - id: friendliness
        type: u4
        enum: rfl_entity_friendliness
      - id: team_id
        type: u4
      - id: waypoint_list
        type: rfl_string
      - id: waypoint_method
        type: rfl_string
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
        type: rfl_string
      - id: default_secondary_weapon
        type: rfl_string
      - id: item_drop
        type: rfl_string
      - id: state_anim
        type: rfl_string
      - id: corpse_pose
        type: rfl_string
      - id: skin
        type: rfl_string
      - id: death_anim
        type: rfl_string
      - id: ai_mode
        type: u1
        enum: rfl_entity_ai_mode
      - id: ai_attack_style
        type: u1
        enum: rfl_entity_ai_attack_style
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
        type: rfl_string
      - id: right_hand_holding
        type: rfl_string
  rfl_items:
    seq:
      - id: count
        type: u4
      - id: items
        type: rfl_item
        repeat: expr
        repeat-expr: count
  rfl_item:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: rfl_string
        doc: depends on type
      - id: pos
        type: rfl_vec3
      - id: rot
        type: rfl_mat3
      - id: script_name
        type: rfl_string
      - id: reserved
        type: u1
        doc: 0x00
      - id: count
        type: u4
      - id: respawn_time
        type: u4
      - id: team_id
        type: u4
  rfl_clutters:
    seq:
      - id: count
        type: u4
      - id: clutters
        type: rfl_clutter
        repeat: expr
        repeat-expr: count
  rfl_clutter:
    seq:
      - id: uid
        type: u4
      - id: class_name
        type: rfl_string
        doc: depends on type
      - id: pos
        type: rfl_vec3
      - id: rot
        type: rfl_mat3
      - id: script_name
        type: rfl_string
      - id: unknown2
        size: 5
      - id: skin
        type: rfl_string
      - id: links
        type: rfl_uid_list
  rfl_triggers:
    seq:
      - id: count
        type: u4
      - id: trigger
        type: rfl_trigger
        repeat: expr
        repeat-expr: count
  rfl_trigger:
    seq:
      - id: uid
        type: u4
      - id: script_name
        type: rfl_string
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
        type: rfl_string
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
        type: rfl_vec3
      - id: sphere_radius
        type: f4
        if: is_box == 0
      - id: rot
        type: rfl_mat3
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
        type: rfl_uid_list
  rfl_brushes_sect:
    seq:
      - id: brushes_count
        type: u4
      - id: brushes
        type: rfl_brush
        repeat: expr
        repeat-expr: brushes_count
  rfl_brush:
    seq:
      - id: uid
        type: u4
      - id: pos
        type: rfl_vec3
      - id: rot
        type: rfl_mat3
      - id: unknown
        size: 10
        doc: 00 00 ...
      - id: textures_count
        type: u4
      - id: textures
        type: rfl_string
        repeat: expr
        repeat-expr: textures_count
      - id: unknown2
        size: 16
        doc: 00 00 ...
      - id: vertices_count
        type: u4
      - id: vertices
        type: rfl_vec3
        repeat: expr
        repeat-expr: vertices_count
      - id: faces_count
        type: u4
      - id: faces
        type: rfl_face
        repeat: expr
        repeat-expr: faces_count
      - id: unknown3
        type: u4
        doc: 0
      - id: flags
        type: u4
        enum: rfl_brush_flags
      - id: life
        type: u4
      - id: unknown4
        type: u4
        doc: 3? 0?
  rfl_groups:
    seq:
      - id: count
        type: u4
      - id: groups
        type: rfl_group
        repeat: expr
        repeat-expr: count
  rfl_group:
    seq:
      - id: name
        type: rfl_string
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
  rfl_section_type:
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
  rfl_face_flags:
    0x01: show_sky
    0x02: mirrored
    0x04: unknown
    0x08: unknown2
    0x20: full_bright
    0x40: unknown3
    0x80: unknown4
  rfl_brush_flags:
    0x1:  portal
    0x2:  air
    0x4:  detail
    0x10: emit_steam
  rfl_geo_region_flags:
    0x02: sphere
    0x04: unk
    0x20: use_shallow_geomods
    0x40: is_ice
  rfl_light_flags:
    0x1:   dynamic
    0x4:   shadow_casting
    0x8:   is_enabled
    0x10:  omnidirectional
    0x20:  circular_spotlight
    #0x30:  tube_light
    0x200: unknown
  rfl_entity_ai_mode:
    0: catatonic
    1: waiting
    2: waypoints
    3: collecting
    4: motion_detection
  rfl_entity_ai_attack_style:
    0: default
    1: evasive
    2: direct
    3: stand_ground
  rfl_entity_cooperation:
    0: uncooperative
    1: species_cooperative
    2: cooperative
  rfl_entity_friendliness:
    0: unfriendly
    1: neutral
    2: friendly
    3: outcast
  rfl_nav_point_type:
    0: walking
    1: flying
