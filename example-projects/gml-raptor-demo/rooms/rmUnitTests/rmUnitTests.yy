{
  "$GMRoom":"v1",
  "%Name":"rmUnitTests",
  "creationCodeFile":"",
  "inheritCode":false,
  "inheritCreationOrder":false,
  "inheritLayers":false,
  "instanceCreationOrder":[
    {"name":"unitTestRoomController","path":"rooms/rmUnitTests/rmUnitTests.yy",},
    {"name":"inst_1C80FFDA","path":"rooms/rmUnitTests/rmUnitTests.yy",},
    {"name":"inst_7AEA4A04","path":"rooms/rmUnitTests/rmUnitTests.yy",},
    {"name":"inst_68AE67D8","path":"rooms/rmUnitTests/rmUnitTests.yy",},
    {"name":"inst_2777B2C7","path":"rooms/rmUnitTests/rmUnitTests.yy",},
    {"name":"inst_2D8D687B","path":"rooms/rmUnitTests/rmUnitTests.yy",},
    {"name":"inst_7F1B1670","path":"rooms/rmUnitTests/rmUnitTests.yy",},
  ],
  "isDnd":false,
  "layers":[
    {"$GMRInstanceLayer":"","%Name":"Controllers","depth":0,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[
        {"$GMRInstance":"v1","%Name":"unitTestRoomController","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"unitTestRoomController","objectId":{"name":"UnitTestRoomController","path":"objects/UnitTestRoomController/UnitTestRoomController.yy",},"properties":[],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":0.0,"y":-32.0,},
        {"$GMRInstance":"v1","%Name":"inst_1C80FFDA","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"inst_1C80FFDA","objectId":{"name":"MouseCursor","path":"objects/MouseCursor/MouseCursor.yy",},"properties":[],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":64.0,"y":-32.0,},
      ],"layers":[],"name":"Controllers","properties":[],"resourceType":"GMRInstanceLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":true,},
    {"$GMRInstanceLayer":"","%Name":"MessageBox","depth":100,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[],"layers":[],"name":"MessageBox","properties":[],"resourceType":"GMRInstanceLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":false,},
    {"$GMRLayer":"","%Name":"popups","depth":200,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[
        {"$GMRInstanceLayer":"","%Name":"popup_instances","depth":300,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[],"layers":[],"name":"popup_instances","properties":[],"resourceType":"GMRInstanceLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":false,},
        {"$GMREffectLayer":"","%Name":"popup_effects","depth":400,"effectEnabled":true,"effectType":"_filter_vignette","gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[],"name":"popup_effects","properties":[
            {"name":"g_VignetteEdges","type":0,"value":"0.2",},
            {"name":"g_VignetteEdges","type":0,"value":"1.2",},
            {"name":"g_VignetteSharpness","type":0,"value":"1",},
            {"name":"g_VignetteTexture","type":2,"value":"_filter_vignette_texture",},
          ],"resourceType":"GMREffectLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":false,},
        {"$GMREffectLayer":"","%Name":"popup_greyscale","depth":500,"effectEnabled":true,"effectType":"_filter_colourise","gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[],"name":"popup_greyscale","properties":[
            {"name":"g_Intensity","type":0,"value":"1",},
            {"name":"g_TintCol","type":1,"value":"#FFFFFFFF",},
          ],"resourceType":"GMREffectLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":false,},
      ],"name":"popups","properties":[],"resourceType":"GMRLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":false,},
    {"$GMRLayer":"","%Name":"ui","depth":600,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[
        {"$GMRInstanceLayer":"","%Name":"ui_instances","depth":700,"effectEnabled":true,"effectType":null,"gridX":16,"gridY":16,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[
            {"$GMRInstance":"v1","%Name":"inst_7AEA4A04","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"inst_7AEA4A04","objectId":{"name":"Label","path":"objects/Label/Label.yy",},"properties":[
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"text_color","path":"objects/_baseControl/_baseControl.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"THEME_CONTROL_BRIGHT",},
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"text_color_mouse_over","path":"objects/_baseControl/_baseControl.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"THEME_CONTROL_BRIGHT",},
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"draw_color","path":"objects/_baseControl/_baseControl.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"THEME_CONTROL_TEXT",},
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"draw_color_mouse_over","path":"objects/_baseControl/_baseControl.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"THEME_CONTROL_TEXT",},
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"LGTextObject","path":"objects/LGTextObject/LGTextObject.yy",},"propertyId":{"name":"text","path":"objects/LGTextObject/LGTextObject.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"[scale,1.5][ci_accent]UTE - raptor Unit Test Engine",},
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"scribble_text_align","path":"objects/_baseControl/_baseControl.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"\"[fa_top][fa_left]\"",},
              ],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":16.0,"scaleY":1.0,"x":48.0,"y":32.0,},
            {"$GMRInstance":"v1","%Name":"inst_68AE67D8","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"inst_68AE67D8","objectId":{"name":"Label","path":"objects/Label/Label.yy",},"properties":[
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"text_color","path":"objects/_baseControl/_baseControl.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"THEME_CONTROL_BRIGHT",},
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"text_color_mouse_over","path":"objects/_baseControl/_baseControl.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"THEME_CONTROL_BRIGHT",},
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"draw_color","path":"objects/_baseControl/_baseControl.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"THEME_CONTROL_TEXT",},
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"draw_color_mouse_over","path":"objects/_baseControl/_baseControl.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"THEME_CONTROL_TEXT",},
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"LGTextObject","path":"objects/LGTextObject/LGTextObject.yy",},"propertyId":{"name":"text","path":"objects/LGTextObject/LGTextObject.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"[scale,1.5]Discovered Test Suites",},
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"scribble_text_align","path":"objects/_baseControl/_baseControl.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"\"[fa_top][fa_left]\"",},
              ],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":9.5,"scaleY":1.0,"x":48.0,"y":96.0,},
            {"$GMRInstance":"v1","%Name":"inst_2777B2C7","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"inst_2777B2C7","objectId":{"name":"Label","path":"objects/Label/Label.yy",},"properties":[
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"text_color","path":"objects/_baseControl/_baseControl.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"THEME_CONTROL_BRIGHT",},
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"text_color_mouse_over","path":"objects/_baseControl/_baseControl.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"THEME_CONTROL_BRIGHT",},
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"draw_color","path":"objects/_baseControl/_baseControl.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"THEME_CONTROL_TEXT",},
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"draw_color_mouse_over","path":"objects/_baseControl/_baseControl.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"THEME_CONTROL_TEXT",},
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"LGTextObject","path":"objects/LGTextObject/LGTextObject.yy",},"propertyId":{"name":"text","path":"objects/LGTextObject/LGTextObject.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"[scale,1.5]Detailled Test Results",},
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"_baseControl","path":"objects/_baseControl/_baseControl.yy",},"propertyId":{"name":"scribble_text_align","path":"objects/_baseControl/_baseControl.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"\"[fa_top][fa_left]\"",},
              ],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":9.5,"scaleY":1.0,"x":848.0,"y":96.0,},
          ],"layers":[],"name":"ui_instances","properties":[],"resourceType":"GMRInstanceLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":true,},
        {"$GMRAssetLayer":"","%Name":"ui_sprites","assets":[
            {"$GMRSpriteGraphic":"","%Name":"graphic_1CDEDAA1","animationSpeed":1.0,"colour":4283190348,"frozen":false,"headPosition":0.0,"ignore":false,"inheritedItemId":null,"inheritItemSettings":false,"name":"graphic_1CDEDAA1","resourceType":"GMRSpriteGraphic","resourceVersion":"2.0","rotation":0.0,"scaleX":1921.0,"scaleY":145.0,"spriteId":{"name":"spr1pxWhite","path":"sprites/spr1pxWhite/spr1pxWhite.yy",},"x":0.0,"y":0.0,},
            {"$GMRSpriteGraphic":"","%Name":"graphic_5AD982F8","animationSpeed":1.0,"colour":4283190348,"frozen":false,"headPosition":0.0,"ignore":false,"inheritedItemId":null,"inheritItemSettings":false,"name":"graphic_5AD982F8","resourceType":"GMRSpriteGraphic","resourceVersion":"2.0","rotation":0.0,"scaleX":1921.0,"scaleY":33.0,"spriteId":{"name":"spr1pxWhite","path":"sprites/spr1pxWhite/spr1pxWhite.yy",},"x":0.0,"y":1056.0,},
          ],"depth":800,"effectEnabled":true,"effectType":"none","gridX":16,"gridY":16,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[],"name":"ui_sprites","properties":[],"resourceType":"GMRAssetLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":true,},
        {"$GMRInstanceLayer":"","%Name":"ui_test_results","depth":900,"effectEnabled":true,"effectType":null,"gridX":16,"gridY":16,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[
            {"$GMRInstance":"v1","%Name":"inst_2D8D687B","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"inst_2D8D687B","objectId":{"name":"UnitTestResultsViewer","path":"objects/UnitTestResultsViewer/UnitTestResultsViewer.yy",},"properties":[
                {"$GMOverriddenProperty":"v1","%Name":"","name":"","objectId":{"name":"UnitTestResultsViewer","path":"objects/UnitTestResultsViewer/UnitTestResultsViewer.yy",},"propertyId":{"name":"detail_mode","path":"objects/UnitTestResultsViewer/UnitTestResultsViewer.yy",},"resourceType":"GMOverriddenProperty","resourceVersion":"2.0","value":"False",},
              ],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":48.0,"y":144.0,},
            {"$GMRInstance":"v1","%Name":"inst_7F1B1670","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"inst_7F1B1670","objectId":{"name":"UnitTestResultsViewer","path":"objects/UnitTestResultsViewer/UnitTestResultsViewer.yy",},"properties":[],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":848.0,"y":144.0,},
          ],"layers":[],"name":"ui_test_results","properties":[],"resourceType":"GMRInstanceLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":true,},
      ],"name":"ui","properties":[],"resourceType":"GMRLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":true,},
    {"$GMRBackgroundLayer":"","%Name":"Background","animationFPS":15.0,"animationSpeedType":0,"colour":4280163870,"depth":1000,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"hspeed":0.0,"htiled":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"layers":[],"name":"Background","properties":[],"resourceType":"GMRBackgroundLayer","resourceVersion":"2.0","spriteId":null,"stretch":false,"userdefinedAnimFPS":false,"userdefinedDepth":false,"visible":true,"vspeed":0.0,"vtiled":false,"x":0,"y":0,},
    {"$GMRInstanceLayer":"","%Name":"test","depth":1100,"effectEnabled":true,"effectType":null,"gridX":16,"gridY":16,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[],"layers":[],"name":"test","properties":[],"resourceType":"GMRInstanceLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":true,},
  ],
  "name":"rmUnitTests",
  "parent":{
    "name":"UnitTestEngine",
    "path":"folders/_gml_raptor_/UnitTestEngine.yy",
  },
  "parentRoom":null,
  "physicsSettings":{
    "inheritPhysicsSettings":false,
    "PhysicsWorld":false,
    "PhysicsWorldGravityX":0.0,
    "PhysicsWorldGravityY":10.0,
    "PhysicsWorldPixToMetres":0.1,
  },
  "resourceType":"GMRoom",
  "resourceVersion":"2.0",
  "roomSettings":{
    "Height":1080,
    "inheritRoomSettings":false,
    "persistent":false,
    "Width":1920,
  },
  "sequenceId":null,
  "views":[
    {"hborder":32,"hport":1080,"hspeed":-1,"hview":1080,"inherit":false,"objectId":null,"vborder":32,"visible":true,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
    {"hborder":32,"hport":940,"hspeed":-1,"hview":940,"inherit":false,"objectId":null,"vborder":32,"visible":false,"vspeed":-1,"wport":1920,"wview":1920,"xport":0,"xview":0,"yport":0,"yview":0,},
  ],
  "viewSettings":{
    "clearDisplayBuffer":true,
    "clearViewBackground":true,
    "enableViews":true,
    "inheritViewSettings":false,
  },
  "volume":1.0,
}