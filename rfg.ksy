# RFG format reverse engineered by:
# * Rafal Harabien (Open Faction project)
meta:
  id: rfg
  title: Red Faction Editor Group
  application: Red Faction
  file-extension: rfg
  license: GPL-3.0-or-later
  endian: le
  imports:
    - rfl

seq:
  - id: header
    type: file_header
  - id: num_groups
    type: s4
  - id: groups
    type: group
    repeat: expr
    repeat-expr: num_groups
  
types:
  file_header:
    seq:
      - id: magic
        contents: [0x0D, 0xD0, 0x3D, 0xD4]
      - id: version
        doc: 0xC8 is the last supported version in RF 1.2, standard PC levels use version 0xB4, PS2 levels use versions 0xAE and 0xAF
        type: s4
  group:
    seq:
      - id: group_name
        type: rfl::vstring
      - id: is_moving
        type: u1
        doc: 0 or 1
      - id: moving_data
        type: rfl::moving_group_data
        if: is_moving != 0
      - id: brushes
        type: rfl::brushes_section
      - id: geo_regions
        type: rfl::geo_regions_section
      - id: lights
        type: rfl::lights_section
      - id: cutscene_cameras
        type: rfl::cutscene_cameras_section
      - id: cutscene_path_nodes
        type: rfl::cutscene_path_nodes_section
      - id: ambient_sounds
        type: rfl::ambient_sounds_section
      - id: events
        type: rfl::events_section
      - id: mp_respawn_points
        type: rfl::mp_respawn_points_section
      - id: num_nav_points
        type: s4
      - id: nav_points
        type: rfl::nav_point
        repeat: expr
        repeat-expr: num_nav_points
        # Note: no navpoint connections
      - id: entities
        type: rfl::entities_section
      - id: items
        type: rfl::items_section
      - id: clutters
        type: rfl::clutters_section
      - id: triggers
        type: rfl::triggers_section
      - id: particle_emitters
        type: rfl::particle_emitters_section
      - id: gas_regions
        type: rfl::gas_regions_section
      - id: decals
        type: rfl::decals_section
      - id: climbing_regions
        type: rfl::climbing_regions_section
      - id: room_effects
        type: rfl::room_effects_section
      - id: eax_effects
        type: rfl::eax_effects_section
      - id: bolt_emitters
        type: rfl::bolt_emitters_section
      - id: targets
        type: rfl::targets_section
      - id: push_regions
        type: rfl::push_regions_section
