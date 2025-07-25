{
  "$GMObject":"",
  "%Name":"HighScoreTrophyRenderer",
  "eventList":[
    {"$GMEvent":"v1","%Name":"","collisionObjectId":null,"eventNum":0,"eventType":0,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},
    {"$GMEvent":"v1","%Name":"","collisionObjectId":null,"eventNum":0,"eventType":12,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},
    {"$GMEvent":"v1","%Name":"","collisionObjectId":null,"eventNum":0,"eventType":8,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},
    {"$GMEvent":"v1","%Name":"","collisionObjectId":null,"eventNum":64,"eventType":8,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},
  ],
  "managed":true,
  "name":"HighScoreTrophyRenderer",
  "overriddenProperties":[],
  "parent":{
    "name":"Highscorer",
    "path":"folders/_gml_raptor_/Helpers/Highscorer.yy",
  },
  "parentObjectId":{
    "name":"_raptorBase",
    "path":"objects/_raptorBase/_raptorBase.yy",
  },
  "persistent":false,
  "physicsAngularDamping":0.1,
  "physicsDensity":0.5,
  "physicsFriction":0.2,
  "physicsGroup":1,
  "physicsKinematic":false,
  "physicsLinearDamping":0.1,
  "physicsObject":false,
  "physicsRestitution":0.1,
  "physicsSensor":false,
  "physicsShape":1,
  "physicsShapePoints":[],
  "physicsStartAwake":true,
  "properties":[
    {"$GMObjectProperty":"v1","%Name":"rank_1_font","filters":[
        "GMFont",
      ],"listItems":[],"multiselect":false,"name":"rank_1_font","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"noone","varType":5,},
    {"$GMObjectProperty":"v1","%Name":"rank_2_font","filters":[
        "GMFont",
      ],"listItems":[],"multiselect":false,"name":"rank_2_font","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"noone","varType":5,},
    {"$GMObjectProperty":"v1","%Name":"rank_3_font","filters":[
        "GMFont",
      ],"listItems":[],"multiselect":false,"name":"rank_3_font","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"noone","varType":5,},
    {"$GMObjectProperty":"v1","%Name":"rank_default_font","filters":[
        "GMFont",
      ],"listItems":[],"multiselect":false,"name":"rank_default_font","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"noone","varType":5,},
    {"$GMObjectProperty":"v1","%Name":"rank_1_color","filters":[],"listItems":[],"multiselect":false,"name":"rank_1_color","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"$FF0CFAFF","varType":7,},
    {"$GMObjectProperty":"v1","%Name":"rank_2_color","filters":[],"listItems":[],"multiselect":false,"name":"rank_2_color","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"$FFD3DFE5","varType":7,},
    {"$GMObjectProperty":"v1","%Name":"rank_3_color","filters":[],"listItems":[],"multiselect":false,"name":"rank_3_color","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"$FF2A88ED","varType":7,},
    {"$GMObjectProperty":"v1","%Name":"rank_1_trophy_sprite","filters":[
        "GMSprite",
      ],"listItems":[],"multiselect":false,"name":"rank_1_trophy_sprite","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"noone","varType":5,},
    {"$GMObjectProperty":"v1","%Name":"rank_2_trophy_sprite","filters":[
        "GMSprite",
      ],"listItems":[],"multiselect":false,"name":"rank_2_trophy_sprite","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"noone","varType":5,},
    {"$GMObjectProperty":"v1","%Name":"rank_3_trophy_sprite","filters":[
        "GMSprite",
      ],"listItems":[],"multiselect":false,"name":"rank_3_trophy_sprite","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"noone","varType":5,},
    {"$GMObjectProperty":"v1","%Name":"apply_rank_color_to_sprites","filters":[],"listItems":[],"multiselect":false,"name":"apply_rank_color_to_sprites","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"0","varType":3,},
    {"$GMObjectProperty":"v1","%Name":"rank_default_color","filters":[],"listItems":[],"multiselect":false,"name":"rank_default_color","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"$FFBBBBBB","varType":7,},
    {"$GMObjectProperty":"v1","%Name":"from_rank","filters":[],"listItems":[],"multiselect":false,"name":"from_rank","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"-1","varType":1,},
    {"$GMObjectProperty":"v1","%Name":"to_rank","filters":[],"listItems":[],"multiselect":false,"name":"to_rank","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"-1","varType":1,},
    {"$GMObjectProperty":"v1","%Name":"draw_on_gui","filters":[],"listItems":[],"multiselect":false,"name":"draw_on_gui","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"True","varType":3,},
    {"$GMObjectProperty":"v1","%Name":"render_rank","filters":[],"listItems":[],"multiselect":false,"name":"render_rank","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"True","varType":3,},
    {"$GMObjectProperty":"v1","%Name":"score_decimals","filters":[],"listItems":[],"multiselect":false,"name":"score_decimals","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"0","varType":1,},
    {"$GMObjectProperty":"v1","%Name":"render_score","filters":[],"listItems":[],"multiselect":false,"name":"render_score","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"True","varType":3,},
    {"$GMObjectProperty":"v1","%Name":"render_time","filters":[],"listItems":[],"multiselect":false,"name":"render_time","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"0","varType":3,},
    {"$GMObjectProperty":"v1","%Name":"render_create_date","filters":[],"listItems":[],"multiselect":false,"name":"render_create_date","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"True","varType":3,},
    {"$GMObjectProperty":"v1","%Name":"rank_prefix_character","filters":[],"listItems":[],"multiselect":false,"name":"rank_prefix_character","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"\"#\"","varType":2,},
    {"$GMObjectProperty":"v1","%Name":"space_between_columns","filters":[],"listItems":[],"multiselect":false,"name":"space_between_columns","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"8","varType":1,},
    {"$GMObjectProperty":"v1","%Name":"space_between_rows","filters":[],"listItems":[],"multiselect":false,"name":"space_between_rows","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"4","varType":1,},
    {"$GMObjectProperty":"v1","%Name":"draw_debug_frame","filters":[],"listItems":[],"multiselect":false,"name":"draw_debug_frame","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"0","varType":3,},
    {"$GMObjectProperty":"v1","%Name":"render_background_darken","filters":[],"listItems":[],"multiselect":false,"name":"render_background_darken","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"0","varType":0,},
    {"$GMObjectProperty":"v1","%Name":"screen_align_v","filters":[],"listItems":[
        "fa_top",
        "fa_middle",
        "fa_bottom",
      ],"multiselect":false,"name":"screen_align_v","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"fa_top","varType":6,},
    {"$GMObjectProperty":"v1","%Name":"screen_align_h","filters":[],"listItems":[
        "fa_left",
        "fa_center",
        "fa_right",
      ],"multiselect":false,"name":"screen_align_h","rangeEnabled":false,"rangeMax":10.0,"rangeMin":0.0,"resourceType":"GMObjectProperty","resourceVersion":"2.0","value":"fa_right","varType":6,},
  ],
  "resourceType":"GMObject",
  "resourceVersion":"2.0",
  "solid":false,
  "spriteId":null,
  "spriteMaskId":null,
  "visible":true,
}