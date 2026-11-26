#!/usr/bin/env python3
"""Author editable residence and telecommunications equipment for The Tower Descent.

blender --background --factory-startup --python tools/generate_residential_models.py -- --root . --render
Original metre-scale geometry; uses shared mesh/export helpers, no external models.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import math
from pathlib import Path
import sys
import bpy
from mathutils import Vector
sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate_rescue_models as G
import generate_commerce_models as C
cube, cylinder, rod, tube = G.cube, G.cylinder, G.rod, G.tube
PI = math.pi


def setup_materials():
    G.setup_materials()
    palette = {
        'walnut_residence': ((.18,.095,.045),.57,0),
        'upholstery_sand': ((.58,.49,.35),.93,0),
        'linen_cream': ((.76,.73,.61),.94,0),
        'book_ocean': ((.04,.18,.23),.76,0),
        'book_rust': ((.34,.09,.055),.76,0),
        'book_ochre': ((.43,.31,.10),.75,0),
        'enamel_pale': ((.63,.72,.67),.42,.12),
        'medical_pale': ((.76,.82,.77),.50,0),
        'wire_blue': ((.018,.19,.46),.68,0),
        'wire_yellow': ((.92,.59,.025),.68,0),
        'wire_green': ((.028,.34,.17),.68,0),
    }
    for name,(color,rough,metal) in palette.items(): G.M[name]=G.material(name,color,rough,metal)
    G.M['status_green']=G.material('status_green',(.04,.58,.28),.3,0,.35)
    G.M['status_amber']=G.material('status_amber',(.95,.41,.035),.3,0,.35)


def feet(width,depth,height=.12,mat='walnut_residence'):
    for x in [-width/2,width/2]:
        for y in [-depth/2,depth/2]: cube('Load-bearing foot',(x,y,height/2),(.065,.065,height),mat,.008)


def rest_armchair():
    feet(.66,.64,.20)
    cube('Solid timber seat frame',(0,0,.27),(.81,.81,.16),'walnut_residence',.026)
    cube('Upholstered seat cushion',(0,.06,.43),(.65,.63,.20),'upholstery_sand',.075)
    cube('High padded back',(0,-.29,.78),(.69,.18,.66),'upholstery_sand',.055,rotation=(-.12,0,0))
    for x in [-.38,.38]:
        cube('Timber arm upright',(x,.08,.43),(.09,.64,.37),'walnut_residence',.014)
        cube('Rounded armrest cushion',(x,.06,.65),(.13,.71,.10),'upholstery_sand',.035)
    for z in [.59,.85]:
        for x in [-.17,.17]: cylinder('Recessed upholstery button',(x,-.185,z),.017,.008,'upholstery_sand',(0,1,0),16,0)
    cube('Folded linen throw',(0,.22,.55),(.48,.24,.035),'linen_cream',.009)
    for x in [-.20,-.10,0,.10,.20]: cube('Throw subtle woven fold',(x,.235,.571),(.008,.20,.004),'medical_pale',0)


def medicine_cabinet():
    cube('Wall cabinet steel back',(0,-.075,.35),(.57,.05,.70),'enamel_pale',.012)
    for x in [-.28,.28]: cube('Cabinet side',(x,0,.35),(.025,.20,.70),'enamel_pale',.006)
    for z in [.015,.27,.52,.685]: cube('Cabinet shelf',(0,0,z),(.57,.20,.025),'enamel_pale',.005)
    # Door occupies the left half; right side intentionally exposes labelled packs.
    cube('Sliding cabinet door',(-.145,.115,.35),(.285,.025,.67),'medical_pale',.008)
    G.cross_badge((-.145,.131,.49),.105,'oxygen_green')
    cube('Recessed pull',(-.03,.132,.32),(.018,.025,.14),'steel_brushed',.005)
    for z in [.09,.34,.59]:
        for i in range(3): cube('Sealed support pack',(0.02+i*.065,.015,z),(.048,.105,.10),'medical_pale' if i%2 else 'label_ivory',.004)
    G.text_label('SOINS',(-.145,.132,.23),.036,'label_ink')
    for x in [-.23,.23]:
        for z in [.07,.63]: G.bolt((x,-.105,z),.006,axis=(0,-1,0))


def resident_bookcase():
    cube('Bookcase plinth',(0,0,.06),(1.42,.37,.12),'walnut_residence',.015)
    cube('Veneered backing',(0,-.16,1.02),(1.36,.035,1.92),'walnut_residence',.004)
    for x in [-.67,.67]: cube('Bookcase side',(x,0,1.03),(.055,.36,1.94),'walnut_residence',.008)
    for z in [.14,.58,1.02,1.46,1.98]: cube('Horizontal shelf',(0,0,z),(1.40,.38,.045),'walnut_residence',.008)
    mats=['book_ocean','book_rust','book_ochre','linen_cream']
    for row,z in enumerate([.19,.63,1.07,1.51]):
        for i in range(10):
            x=-.56+i*.118; h=.25+((i+row)%3)*.034
            cube('Resident book binding',(x,.015,z+h/2),(.085,.245,h),mats[(i+row)%4],.003)
            for dz in [-.075,.065]: cube('Book spine line',(x,.14,z+h/2+dz),(.064,.004,.007),'label_ivory',0)


def coffee_table():
    feet(.88,.47,.35)
    cube('Low table lower shelf',(0,0,.15),(.96,.53,.025),'walnut_residence',.009)
    cube('Rounded walnut top',(0,0,.405),(1.14,.69,.07),'walnut_residence',.026)
    cube('Linen runner',(0,0,.445),(.42,.66,.008),'linen_cream',.003)
    cube('Closed personal album',(-.24,.04,.475),(.25,.30,.045),'book_ocean',.006)
    for x in [.22,.36]:
        cylinder('Cup ceramic body',(x,.02,.495),.045,.095,'medical_pale',vertices=24,bevel=.006)
        cylinder('Cup dark interior',(x,.02,.545),.034,.003,'book_ocean',vertices=24,bevel=0)
        G.torus('Cup handle',(x+.047,.02,.503),.027,.006,'medical_pale',(0,1,0),24)


def reading_lamp():
    cylinder('Weighted lamp foot',(0,0,.025),.19,.05,'steel_dark',vertices=48,bevel=.006)
    cylinder('Brass vertical standard',(0,0,.70),.018,1.35,'brass_valve',vertices=24)
    rod('Lamp arm',(0,0,1.35),(0,.20,1.50),.014,'brass_valve')
    G.cone('Pleated shade',(0,.20,1.48),.21,.13,.25,'linen_cream')
    cylinder('Lower shade rim',(0,.20,1.355),.212,.014,'brass_valve',vertices=40)
    cylinder('Warm diffuser',(0,.20,1.36),.18,.004,'led_warm',vertices=40,bevel=0)
    cube('Foot switch',(0,.12,.065),(.08,.045,.025),'rubber_black',.007)
    tube('Power cord',[(0,-.03,.03),(.09,-.17,.013),(.21,-.23,.013),(.34,-.19,.013)],.006,'rubber_black')


def wall_intercom():
    cube('Intercom mounting back',(0,-.018,.19),(.22,.045,.38),'enamel_pale',.014)
    cube('Intercom console fascia',(0,.02,.19),(.20,.07,.34),'medical_pale',.018)
    for i in range(5): cube('Speaker grille slot',(.025,.058,.275+i*.012),(.105,.003,.005),'label_ink',.001)
    cube('Display glass',(.027,.06,.19),(.12,.006,.055),'screen_teal',.004)
    for z in [.08,.115]: cylinder('Call button',(.027,.066,z),.017,.010,'anodized_blue',(0,1,0),20,.001)
    cube('Handset left grip',(-.075,.08,.18),(.052,.06,.25),'polymer_anthracite',.018)
    for z in [.05,.31]: cube('Handset earpiece',(-.075,.082,z),(.063,.076,.07),'polymer_anthracite',.019)
    tube('Curled handset cord',[(-.075,.04,.055),(-.10,.03,.01),(-.02,.03,.01),(0,.02,.05)],.005,'rubber_black')
    G.text_label('AUBE',(.027,.066,.235),.016,'label_ivory')


def service_latch_panel():
    cube('Latch housing',(0,0,.235),(.28,.12,.47),'steel_dark',.010)
    cube('Marked steel face',(0,.067,.235),(.26,.016,.44),'enamel_pale',.006)
    cube('Latch guide',(0,.092,.23),(.075,.035,.26),'steel_brushed',.004)
    cylinder('Sliding latch bolt',(0,.12,.22),.022,.32,'steel_edge',vertices=24)
    rod('Transverse release handle',(-.065,.13,.23),(.065,.13,.23),.015,'paint_safety_yellow')
    G.text_label('SERVICE',(0,.08,.41),.028,'label_ink')
    G.text_label('18 - 19',(-.084,.08,.11),.014,'label_ink')
    for x in [-.10,.10]:
        for z in [.04,.43]: G.bolt((x,.084,z),.006)


def telecom_rack():
    cube('Rack weighted plinth',(0,0,.065),(.70,.78,.13),'steel_dark',.012)
    cube('Rack top',(0,0,2.07),(.70,.78,.07),'steel_dark',.010)
    for x in [-.32,.32]:
        for y in [-.35,.35]: cube('Rack upright',(x,y,1.08),(.045,.045,1.99),'steel_brushed',.003)
    for x in [-.335,.335]: cube('Rack side panel',(x,0,1.1),(.022,.71,1.91),'polymer_anthracite',.005)
    cube('Rack rear',(0,-.36,1.1),(.64,.025,1.91),'steel_dark',.006)
    for row,z in enumerate([.28,.56,.84,1.12,1.40,1.68,1.90]):
        cube('Rack network appliance',(0,.025,z),(.58,.62,.18),'polymer_anthracite',.006)
        for i in range(7): cube('Module air vent',(-.20+i*.06,.342,z),(.027,.005,.082),'label_ink',.001)
        for x in [-.27,.27]: cube('Module mounting ear',(x,.35,z),(.045,.02,.15),'steel_brushed',.002)
        cylinder('Individual status LED',(.23,.365,z+.04),.008,.006,'status_green' if row%3 else 'status_amber',(0,1,0),12,0)
    for x in [-.27,.27]: rod('Rack door handle',(x,.385,.91),(x,.385,1.21),.014,'steel_brushed')
    G.text_label('NACRE / A17',(0,.361,2.04),.025,'label_ivory')


def patch_panel():
    cube('Patch panel chassis',(0,-.035,.16),(.51,.14,.32),'steel_dark',.007)
    cube('Panel brushed fascia',(0,.04,.16),(.51,.025,.31),'steel_brushed',.003)
    for row,z in enumerate([.105,.22]):
        for i in range(6):
            x=-.20+i*.08
            cube('RJ style socket recess',(x,.056,z),(.045,.018,.035),'label_ink',.001)
            cube('Socket latch bridge',(x,.067,z-.018),(.032,.012,.006),'enamel_pale',.001)
    for i in range(3):
        x=-.16+i*.16
        tube('Local patch lead',[(x,.08,.22),(x+.025,.20,.20),(x+.04,.22,.06),(x+.08,.08,.105)],.009,['wire_blue','wire_yellow','wire_green'][i])
    G.text_label('RECEPTION - COMPARAISON',(0,.058,.292),.014,'label_ivory')


def ups_battery():
    cube('UPS cast base',(0,0,.045),(.48,.62,.09),'steel_dark',.012)
    cube('UPS main enclosure',(0,0,.40),(.43,.57,.70),'enamel_pale',.018)
    cube('Front ventilated panel',(0,.29,.40),(.35,.015,.60),'polymer_anthracite',.006)
    for i in range(9): cube('Cooling vent',(0,.303,.18+i*.028),(.27,.006,.010),'label_ink',.001)
    cube('Battery status display',(0,.304,.61),(.22,.012,.09),'screen_teal',.004)
    cylinder('Protected power key',(0,.318,.51),.025,.016,'paint_safety_yellow',(0,1,0),24)
    for x in [-.20,.20]:
        rod('Lifting handle',(x,-.03,.69),(x,.16,.69),.012,'steel_dark')
    G.text_label('SECOURS',(0,.315,.705),.027,'label_ivory')
    tube('Protected output cable',[(.15,-.28,.20),(.22,-.35,.15),(.30,-.38,.06)],.014,'rubber_black')


def relay_console():
    for x in [-.62,.62]: cube('Console supporting pedestal',(x,0,.43),(.24,.64,.86),'steel_dark',.014)
    cube('Console desk worktop',(0,0,.89),(1.56,.78,.09),'walnut_residence',.018)
    cube('Monitor foot',(0,-.12,.96),(.38,.24,.045),'steel_dark',.008)
    cube('Monitor upright',(0,-.16,1.10),(.08,.07,.28),'steel_brushed',.004)
    cube('Relay monitor housing',(0,-.10,1.31),(.89,.10,.51),'polymer_anthracite',.019,rotation=(-.08,0,0))
    cube('Relay monitor dark screen',(0,-.042,1.31),(.79,.012,.40),'screen_teal',.004,rotation=(-.08,0,0))
    cube('Keyboard chassis',(0,.23,.964),(.56,.22,.045),'polymer_anthracite',.009)
    for row in range(4):
        for col in range(10): cube('Keyboard key',(-.234+col*.052,.16+row*.043,.992),(.040,.033,.013),'enamel_pale',.002)
    cylinder('Desk microphone base',(.56,.15,.974),.085,.045,'steel_dark',vertices=28)
    tube('Gooseneck microphone',[(.56,.15,.99),(.56,.15,1.12),(.51,.20,1.23),(.46,.24,1.24)],.010,'rubber_black')
    cylinder('Microphone capsule',(.45,.25,1.24),.022,.06,'polymer_anthracite',(1,-1,0),24)
    G.text_label('AUBE / A17',(0,-.034,1.565),.030,'label_ivory')


def voice_recorder():
    cube('Recorder protective body',(0,0,.045),(.24,.17,.09),'polymer_anthracite',.014)
    cube('Recording channel display',(-.045,.086,.051),(.105,.010,.043),'screen_teal',.003)
    for i,mat in enumerate(['paint_rescue_red','steel_brushed','steel_brushed']):
        cylinder('Transport control button',(.036+i*.031,.088,.043),.010,.008,mat,(0,1,0),16,0)
    for x in [-.09,.09]:
        cylinder('Microphone grille',(x,-.006,.098),.025,.035,'steel_brushed',(0,0,1),24)
        for i in range(3): rod('Microphone grille stripe',(x-.018,-.026+i*.009,.118),(x+.018,-.026+i*.009,.118),.0015,'steel_dark',12,0)
    G.text_label('ARCHIVES',(0,.087,.078),.012,'label_ivory')
    for x in [-.108,.108]: G.bolt((x,.087,.024),.0035)


SPECS=[
('rest_armchair','Fauteuil de repos résidentiel',rest_armchair,(0,0,.50)),
('medicine_cabinet','Armoire de soins des résidents',medicine_cabinet,(0,0,.35)),
('resident_bookcase','Bibliothèque commune en noyer',resident_bookcase,(0,0,1.0)),
('coffee_table','Table basse et album des résidents',coffee_table,(0,0,.40)),
('reading_lamp','Lampe de lecture sur pied',reading_lamp,(0,0,.75)),
('wall_intercom','Interphone des résidences',wall_intercom,(0,0,.18)),
('service_latch_panel','Commande du passage de service',service_latch_panel,(0,0,.23)),
('telecom_rack','Baie de télécommunications',telecom_rack,(0,0,1.10)),
('patch_panel','Panneau de brassage local',patch_panel,(0,0,.16)),
('ups_battery','Alimentation secourue du relais',ups_battery,(0,0,.40)),
('relay_console','Console de contrôle du relais A17',relay_console,(0,0,.95)),
('voice_recorder','Enregistreur à deux canaux',voice_recorder,(0,0,.05)),
]


def write_catalog(records,path):
    G.write_catalog(records,path)
    text=path.read_text(encoding='utf-8')
    for old,new in {
        'tools/generate_rescue_models.py':'tools/generate_residential_models.py',
        'rescue_v011/':'residential_v013/', 'Rescue model':'Residential model',
        'RescueAsset_':'ResidentialAsset_', '"rescue_asset_id"':'"residential_asset_id"',
    }.items(): text=text.replace(old,new)
    path.write_text(text,encoding='utf-8')


def render_previews(directory,camera):
    scene=bpy.context.scene; scene.cycles.samples=24
    for asset in G.ASSETS:
        for other in G.ASSETS:
            other['collection'].hide_render=other is not asset
            other['root'].location=(0,0,0)
        lo,hi=G.bounds(asset)
        G.point_camera(camera,(lo+hi)/2,1,(.9,1.6,1.1))
        bpy.context.view_layer.update(); view=camera.matrix_world.inverted()
        points=[view@(obj.matrix_world@Vector(c)) for obj in asset['parts'] for c in obj.bound_box]
        width=max(p.x for p in points)-min(p.x for p in points)
        height=max(p.y for p in points)-min(p.y for p in points)
        camera.data.ortho_scale=max(width,height*1.25)*1.18
        scene.render.resolution_x,scene.render.resolution_y=750,600
        scene.render.filepath=str(directory/f"residential_{asset['id']}.png")
        bpy.ops.render.render(write_still=True)
        print('PREVIEW '+asset['id'],flush=True)


def main():
    parser=argparse.ArgumentParser(); parser.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[1]); parser.add_argument('--render',action='store_true')
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else [])
    root=args.root.resolve(); bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
    for collection in list(bpy.data.collections):
        if collection.name!='Collection': bpy.data.collections.remove(collection)
    scene=bpy.context.scene; scene.unit_settings.system='METRIC'; scene.unit_settings.scale_length=1.; scene.unit_settings.length_unit='METERS'
    setup_materials()
    model_dir=root/'prototype/assets/models/residential_v013'; source_dir=root/'docs/assets/v0.13'; preview_dir=source_dir/'previews'
    for path in [model_dir,source_dir,preview_dir]: path.mkdir(parents=True,exist_ok=True)
    records=[]
    for asset_id,label,builder,grip in SPECS:
        collection=bpy.data.collections.new(asset_id); scene.collection.children.link(collection)
        obj=bpy.data.objects.new(asset_id,None); collection.objects.link(obj); obj.empty_display_size=.08
        G.ACTIVE={'id':asset_id,'label':label,'collection':collection,'root':obj,'parts':[],'grip':grip}; G.PART_INDEX=0
        builder(); C.finalize_asset(G.ACTIVE); row=G.export_asset(G.ACTIVE,model_dir)
        row['path']=f'res://assets/models/residential_v013/{asset_id}.glb'; row['uv']='Smart projection per named source mesh; shared albedos use object coordinates.'
        records.append(row); G.ASSETS.append(G.ACTIVE)
        print(f"ASSET {asset_id}: {row['triangles']} triangles, {row['bytes']} bytes",flush=True)
    write_catalog(records,root/'prototype/scripts/residential_asset_catalog.gd')
    camera=G.setup_studio()
    for index,asset in enumerate(G.ASSETS):
        asset['root'].location=((index%4-1.5)*2.2,(index//4-1)*2.7,0); asset['collection'].hide_render=False
    G.point_camera(camera,(0,0,.8),12,(1.1,1.6,1.9)); scene.render.resolution_x,scene.render.resolution_y=1600,1000
    G.deselect()
    for asset in G.ASSETS: asset['root'].select_set(True)
    bpy.context.view_layer.objects.active=G.ASSETS[0]['root']; bpy.context.preferences.filepaths.save_version=0
    source_path=source_dir/'residential_equipment.blend'; bpy.ops.wm.save_as_mainfile(filepath=str(source_path),compress=True)
    manifest={'schema_version':1,'library':'The Tower Descent residences/telecommunications v0.13','generator':'tools/generate_residential_models.py','blender_version':bpy.app.version_string,'units':'metres','source_axes':{'up':'+Z','front':'+Y','right':'+X'},'runtime_axes':{'up':'+Y','front':'-Z','right':'+X'},'source':{'path':'docs/assets/v0.13/residential_equipment.blend','bytes':source_path.stat().st_size,'sha256':hashlib.sha256(source_path.read_bytes()).hexdigest()},'authoring':'Original deterministic editable Blender geometry with named parts; shared geometry/export helpers; no external models.','limitations':['Static geometry, no rig or articulated animation.','Scene code supplies collision shapes and gameplay interactions.','Material scalar parameters are artistic values, not measured scans.','No claim of real electrical or medical functionality.'],'assets':records,'total_glb_bytes':sum(r['bytes'] for r in records),'total_triangles':sum(r['triangles'] for r in records)}
    (model_dir/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    if args.render: render_previews(preview_dir,camera)
    print(f"DONE {len(records)} models / {manifest['total_triangles']} triangles",flush=True)

if __name__=='__main__': main()
