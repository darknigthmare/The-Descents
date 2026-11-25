#!/usr/bin/env python3
"""Original rescue equipment for The Tower Descent, generated with Blender 4.3+.

blender --background --factory-startup --python tools/generate_rescue_models.py -- --root . --render

No network, external meshes, or image textures. The editable source retains
named parts. Every mesh has bevelled edges where appropriate and a UV atlas.
Blender: metres, Z up, Y front. glTF/Godot: metres, Y up, -Z front.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import math
from pathlib import Path
import sys
import bpy
import bmesh
from mathutils import Vector

PI, TAU = math.pi, math.tau
ROOT = Path(__file__).resolve().parents[1]
ACTIVE = None
PART_INDEX = 0
M, ASSETS = {}, []


def material(name, color, roughness=.45, metallic=0., emission=0.):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    mat.diffuse_color = (*color, 1)
    shader = mat.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1)
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    if emission:
        shader.inputs["Emission Color"].default_value = (*color, 1)
        shader.inputs["Emission Strength"].default_value = emission
    return mat


def setup_materials():
    palette = {
        "paint_rescue_red": ((.52,.019,.012),.32,.24),
        "paint_safety_yellow": ((.98,.61,.025),.34,.18),
        "paint_rescue_orange": ((.93,.17,.018),.34,.22),
        "steel_brushed": ((.49,.56,.59),.28,.94),
        "steel_edge": ((.73,.78,.80),.19,1.),
        "steel_dark": ((.075,.105,.12),.34,.86),
        "brass_valve": ((.63,.39,.11),.30,.88),
        "rubber_black": ((.016,.023,.028),.80,0.),
        "polymer_anthracite": ((.033,.048,.058),.49,.02),
        "fabric_red": ((.40,.021,.022),.90,0.),
        "fabric_teal": ((.033,.19,.18),.86,0.),
        "webbing_black": ((.019,.025,.028),.96,0.),
        "rope_gold": ((.88,.60,.10),.88,0.),
        "label_ivory": ((.84,.87,.81),.58,0.),
        "label_ink": ((.008,.018,.021),.68,0.),
        "oxygen_green": ((.027,.22,.12),.34,.26),
        "anodized_blue": ((.022,.18,.34),.31,.75),
        "lens_blue": ((.16,.40,.47),.12,.38),
        "beacon_amber": ((1.,.18,.008),.19,.08),
    }
    for name, (color, rough, metal) in palette.items():
        M[name] = material(name, color, rough, metal)
    M["led_warm"] = material("led_warm", (.95,.89,.65),.22,.05,.65)
    M["screen_teal"] = material("screen_teal", (.025,.24,.27),.18,.08,.18)


def deselect():
    bpy.ops.object.select_all(action="DESELECT")


def finish(obj, name, mat, bevel=0., smooth=False):
    global PART_INDEX
    PART_INDEX += 1
    obj.name = f"{ACTIVE['id']}__{name}_{PART_INDEX:03d}"
    for coll in list(obj.users_collection):
        coll.objects.unlink(obj)
    ACTIVE["collection"].objects.link(obj)
    obj.parent = ACTIVE["root"]
    if mat:
        obj.data.materials.append(M[mat] if isinstance(mat, str) else mat)
    if obj.type == "MESH":
        if bevel:
            mod = obj.modifiers.new("Machined edge radius", "BEVEL")
            mod.width, mod.segments = bevel, 3
            mod.limit_method = "ANGLE"
            mod.harden_normals = True
        if smooth:
            for face in obj.data.polygons:
                face.use_smooth = True
        if bevel:
            normal = obj.modifiers.new("Weighted production normals", "WEIGHTED_NORMAL")
            normal.keep_sharp, normal.weight = True, 40
    ACTIVE["parts"].append(obj)
    return obj


def cube(name, loc, size, mat, bevel=.003, rotation=None):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = bpy.context.object
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if rotation:
        obj.rotation_euler = rotation
    return finish(obj, name, mat, bevel, bool(bevel))


def cylinder(name, loc, radius, depth, mat, axis=(0,0,1), vertices=32, bevel=.001):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc)
    obj = bpy.context.object
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = Vector(axis).to_track_quat("Z", "Y")
    return finish(obj, name, mat, bevel, True)


def rod(name, a, b, radius, mat, vertices=20, bevel=.0005):
    a, b = Vector(a), Vector(b)
    return cylinder(name, (a+b)/2, radius, (b-a).length, mat, b-a, vertices, bevel)


def cone(name, loc, radius1, radius2, depth, mat, axis=(0,0,1)):
    bpy.ops.mesh.primitive_cone_add(vertices=40, radius1=radius1, radius2=radius2, depth=depth, location=loc)
    obj = bpy.context.object
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = Vector(axis).to_track_quat("Z", "Y")
    return finish(obj, name, mat, .0008, True)


def torus(name, loc, radius, tube_radius, mat, axis=(0,0,1), major_segments=40):
    bpy.ops.mesh.primitive_torus_add(major_segments=major_segments, minor_segments=8,
                                    major_radius=radius, minor_radius=tube_radius, location=loc)
    obj = bpy.context.object
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = Vector(axis).to_track_quat("Z", "Y")
    return finish(obj, name, mat, smooth=True)


def mesh(name, verts, faces, mat, bevel=0., smooth=False):
    data = bpy.data.meshes.new(name)
    data.from_pydata(verts, [], faces)
    data.update()
    obj = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(obj)
    return finish(obj, name, mat, bevel, smooth)


def prism_xz(name, outline, thickness, mat, bevel=.0015, y=0):
    n = len(outline)
    verts = [(x,y-thickness/2,z) for x,z in outline] + [(x,y+thickness/2,z) for x,z in outline]
    faces = [tuple(reversed(range(n))), tuple(range(n,2*n))]
    faces += [(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    return mesh(name, verts, faces, mat, bevel, True)


def tube(name, points, radius, mat, closed=False):
    data = bpy.data.curves.new(name, "CURVE")
    data.dimensions, data.resolution_u = "3D", 3
    data.bevel_depth, data.bevel_resolution = radius, 2
    spline = data.splines.new("BEZIER")
    spline.bezier_points.add(len(points)-1)
    for point, co in zip(spline.bezier_points, points):
        point.co = co
        point.handle_left_type = point.handle_right_type = "AUTO"
    spline.use_cyclic_u = closed
    obj = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(obj)
    deselect()
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.convert(target="MESH")
    return finish(bpy.context.object, name, mat, smooth=True)


def lathe(name, profile, mat, segments=48, xy=(1,1), center=(0,0)):
    verts = []
    for z, radius in profile:
        verts.extend((center[0]+xy[0]*radius*math.cos(i*TAU/segments),
                      center[1]+xy[1]*radius*math.sin(i*TAU/segments), z) for i in range(segments))
    faces = []
    for row in range(len(profile)-1):
        for i in range(segments):
            a, b = row*segments+i, row*segments+(i+1)%segments
            faces.append((a,b,b+segments,a+segments))
    faces += [tuple(reversed(range(segments))),
              tuple((len(profile)-1)*segments+i for i in range(segments))]
    return mesh(name, verts, faces, mat, smooth=True)


def ring_curve(name, rx, ry, z, radius, mat):
    return tube(name, [(rx*math.cos(i*TAU/20),ry*math.sin(i*TAU/20),z)
                       for i in range(20)], radius, mat, True)


def text_label(text, loc, size, mat="label_ivory"):
    curve = bpy.data.curves.new("Stamped lettering", "FONT")
    curve.body, curve.align_x, curve.align_y = text, "CENTER", "CENTER"
    curve.size, curve.extrude, curve.bevel_depth = size, .00012, .00004
    obj = bpy.data.objects.new("Stamped lettering", curve)
    bpy.context.collection.objects.link(obj)
    obj.location, obj.rotation_euler = loc, (PI/2,0,PI)
    deselect()
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.convert(target="MESH")
    return finish(bpy.context.object, "Stamped lettering", mat)


def cross_badge(loc, width, mat="label_ivory"):
    x,y,z = loc
    cube("Medical cross horizontal",(x,y,z),(width,.0015,width/3),mat,.0004)
    cube("Medical cross vertical",(x,y+.0003,z),(width/3,.0015,width),mat,.0004)


def bolt(loc, radius=.005, axis=(0,1,0), mat="steel_edge"):
    cylinder("Hexagonal fastener",loc,radius,radius*.45,mat,axis,6,.0003)


def rubber_grip(a,b,radius=.017,color="rubber_black",rings=12):
    rod("Moulded non-slip grip",a,b,radius,color,24)
    axis = Vector(b)-Vector(a)
    for i in range(rings):
        at = Vector(a).lerp(Vector(b),(i+.5)/rings)
        torus("Grip raised rib",at,radius*1.01,.00075,color,axis,24)


def fire_axe():
    profiles = [(.015,.018),(.06,.019),(.24,.016),(.45,.0145),(.65,.014),(.81,.013)]
    verts = []
    for z,rad in profiles:
        cx = -.016*math.sin(z/.82*PI)
        verts.extend((cx+math.cos(TAU*i/20)*rad,math.sin(TAU*i/20)*rad*.76,z) for i in range(20))
    faces = []
    for row in range(len(profiles)-1):
        faces += [(row*20+i,row*20+(i+1)%20,(row+1)*20+(i+1)%20,(row+1)*20+i) for i in range(20)]
    faces += [tuple(reversed(range(20))),tuple(range(100,120))]
    mesh("Swept composite handle",verts,faces,"paint_safety_yellow",.001,True)
    rubber_grip((-.004,0,.025),(-.012,0,.245),.019,rings=16)
    torus("Lanyard steel eye",(0,0,.018),.009,.0028,"steel_dark",(0,1,0),24)
    cube("Impact protection collar",(-.009,0,.722),(.041,.039,.10),"rubber_black",.008)
    outline = [(-.215,.745),(-.223,.825),(-.183,.883),(-.057,.841),(.034,.836),(.046,.777),(-.054,.770)]
    widths = [.0017,.0017,.003,.021,.025,.025,.018]
    n = len(outline)
    verts = [(x,-w,z) for (x,z),w in zip(outline,widths)] + [(x,w,z) for (x,z),w in zip(outline,widths)]
    faces = [tuple(reversed(range(n))),tuple(range(n,2*n))]
    faces += [(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    mesh("Forged tapered axe blade",verts,faces,"steel_brushed",.002,True)
    prism_xz("Honed cutting edge",[(-.216,.746),(-.224,.825),(-.184,.883),(-.168,.870),(-.205,.819),(-.197,.752)],.004,"steel_edge",.0006)
    prism_xz("Red forged socket",[(-.047,.77),(-.045,.844),(.044,.84),(.050,.777)],.055,"paint_rescue_red",.004)
    mesh("Curved pointed pick",[(.035,-.021,.783),(.035,.021,.783),(.045,-.021,.833),(.045,.021,.833),
                               (.112,-.010,.857),(.112,.010,.857),(.168,0,.876)],
         [(0,2,4,6),(1,6,5,3),(0,1,3,2),(2,3,5,4),(0,6,1),(4,5,6)],"steel_dark",.0013,True)
    bolt((0,.029,.808),.008)
    cube("Reflective handle band",(-.015,0,.51),(.031,.025,.025),"label_ivory",.003)


def extinguisher():
    lathe("Pressure vessel",[(.025,.063),(.035,.080),(.065,.088),(.365,.088),
                            (.408,.079),(.438,.058),(.456,.028),(.466,.024)],"paint_rescue_red")
    lathe("Protective base boot",[(0,.076),(.006,.088),(.037,.091),(.048,.087)],"rubber_black")
    torus("Lower rolled weld",(0,0,.073),.087,.002,"paint_rescue_red")
    cylinder("Valve neck collar",(0,0,.473),.028,.020,"steel_brushed")
    cylinder("Brass valve assembly",(0,0,.504),.020,.046,"brass_valve",vertices=12)
    prism_xz("Lower carry handle",[(-.010,.514),(.084,.530),(.087,.548),(.012,.543),(-.014,.532)],.024,"steel_dark",.0025)
    prism_xz("Squeeze lever",[(-.038,.547),(.079,.553),(.085,.565),(-.026,.568),(-.046,.557)],.022,"paint_rescue_red",.003)
    bolt((-.018,.014,.543),.006)
    rod("Safety pin",(-.049,0,.535),(.022,0,.535),.0022,"steel_edge",12)
    torus("Pull-pin ring",(-.060,0,.536),.013,.0021,"steel_edge",(0,1,0),32)
    rod("Gauge connection",(0,.005,.507),(0,.037,.507),.006,"brass_valve")
    cylinder("Gauge housing",(0,.043,.508),.020,.012,"steel_dark",(0,1,0))
    cylinder("Gauge ivory face",(0,.050,.508),.0165,.0015,"label_ivory",(0,1,0),32,0)
    for i in range(9):
        a = (-.25+i/8*1.5)*PI
        rod("Gauge graduation",(math.cos(a)*.012,.0513,.508+math.sin(a)*.012),
            (math.cos(a)*.0145,.0513,.508+math.sin(a)*.0145),.00045,"label_ink",6,0)
    rod("Pressure needle",(0,.052,.508),(-.007,.052,.517),.00065,"paint_rescue_red",6,0)
    tube("Flexible discharge hose",[(.018,-.004,.504),(.093,-.004,.490),(.118,.008,.426),
                                     (.122,.015,.286),(.115,.027,.152)],.007,"rubber_black")
    cylinder("Hose coupling",(.030,-.004,.504),.012,.025,"brass_valve",(1,0,0),12)
    cone("Discharge nozzle",(.112,.031,.120),.018,.010,.067,"rubber_black",(.1,-.1,1))
    cube("Nozzle retaining clip",(.091,.014,.20),(.026,.026,.020),"steel_dark",.002)
    cube("Instruction panel",(0,.0876,.264),(.112,.003,.190),"label_ivory",.006)
    text_label("ABC",(0,.090,.315),.032,"label_ink")
    for z,width in [(.278,.072),(.265,.083),(.252,.071),(.215,.079),(.204,.061)]:
        cube("Instruction print rule",(0,.090,z),(width,.0008,.0022),"label_ink",0)
    for x in [-.032,0,.032]:
        cylinder("Instruction pictogram",(x,.090,.235),.010,.001,"paint_rescue_red",(0,1,0),20,0)


def halligan():
    cube("Forged shaft",(0,0,.477),(.023,.023,.692),"steel_brushed",.0035,(0,0,PI/4))
    for side in [-1,1]:
        prism_xz("Split fork tine",[(side*.012,.153),(side*.038,.102),(side*.044,.012),
                                    (side*.023,.003),(side*.018,.074),(side*.005,.116)],.019,"steel_brushed",.0018)
        prism_xz("Fork sharpened tip",[(side*.044,.012),(side*.023,.003),(side*.023,.018),(side*.044,.026)],.009,"steel_edge",.0006)
    cylinder("Forged fork shoulder",(0,0,.145),.023,.050,"steel_dark",vertices=12)
    cube("Head socket",(0,0,.836),(.056,.043,.054),"steel_dark",.006)
    cone("Tapered pike",(-.072,0,.844),.019,.001,.125,"steel_brushed",(-1,0,.16))
    prism_xz("Adze neck",[(.014,.814),(.070,.832),(.082,.864),(.025,.86)],.043,"steel_brushed",.003)
    prism_xz("Adze wedge blade",[(.061,.836),(.118,.862),(.116,.893),(.076,.881)],.075,"steel_brushed",.002)
    prism_xz("Adze sharpened edge",[(.106,.855),(.119,.861),(.117,.894),(.105,.888)],.075,"steel_edge",.0006)
    rubber_grip((0,0,.328),(0,0,.520),.016,rings=13)
    for z in [.29,.56]:
        cylinder("High visibility shaft band",(0,0,z),.018,.024,"paint_safety_yellow",vertices=24)


def bolt_cutter():
    for side in [-1,1]:
        rod("Tubular lever handle",(side*.130,0,.022),(side*.049,0,.435),.012,"paint_rescue_red",24)
        rubber_grip((side*.129,0,.028),(side*.101,0,.175),.017,rings=10)
        prism_xz("Compound leverage plate",[(side*.036,.400),(side*.063,.431),(side*.055,.512),
                                           (side*.017,.540),(side*.004,.509),(side*.031,.463)],.029,"steel_brushed",.003)
        prism_xz("Forged cutting jaw",[(side*.015,.499),(side*.057,.534),(side*.068,.585),
                                      (side*.039,.651),(side*.004,.634),(side*.020,.578),(side*.005,.546)],.037,"steel_dark",.002)
        prism_xz("Hardened cutting facet",[(side*.005,.634),(side*.020,.578),(side*.030,.579),(side*.019,.635)],.039,"steel_edge",.0007)
        for x,z in [(side*.043,.442),(side*.036,.523),(side*.040,.566)]:
            cylinder("Pivot washer",(x,.018,z),.014,.002,"steel_dark",(0,1,0),24,0)
            bolt((x,.021,z),.010)
    rod("Central stop",(-.030,0,.489),(.030,0,.489),.007,"steel_brushed",16)


def rescue_flashlight():
    cylinder("Aluminium barrel",(0,0,.122),.024,.212,"paint_safety_yellow")
    rubber_grip((0,0,.038),(0,0,.183),.025,rings=14)
    cylinder("End cap",(0,0,.018),.027,.026,"polymer_anthracite")
    cone("Flared lamp head",(0,0,.224),.026,.046,.061,"paint_safety_yellow")
    cylinder("Machined front bezel",(0,0,.261),.047,.020,"steel_dark")
    cylinder("Reflector lens",(0,0,.272),.0395,.003,"lens_blue",bevel=0)
    torus("Reflector rim",(0,0,.274),.036,.002,"steel_edge")
    cylinder("Central LED",(0,0,.275),.007,.0015,"led_warm",vertices=24,bevel=0)
    for i in range(8):
        a = TAU*i/8
        cube("Bezel protective tooth",(.043*math.cos(a),.043*math.sin(a),.270),(.009,.009,.012),"rubber_black",.001,(0,0,a))
    cylinder("Side switch surround",(0,.028,.198),.011,.006,"polymer_anthracite",(0,1,0))
    cylinder("Sealed side switch",(0,.032,.198),.008,.003,"paint_rescue_red",(0,1,0),24)
    tube("Pocket clip",[(0,-.024,.19),(0,-.035,.18),(0,-.037,.07),(0,-.030,.06)],.004,"steel_dark")
    tube("Wrist lanyard",[(0,.012,.018),(.028,.022,.009),(.041,.053,.012),(.020,.066,.011),(-.004,.038,.012)],.0022,"webbing_black")


def portable_worklight():
    for side in [-1,1]:
        tube("Splayed tubular stand",[(side*.18,-.13,.016),(side*.16,-.09,.050),(side*.14,0,.23),
                                     (side*.16,.10,.05),(side*.18,.14,.016)],.012,"paint_safety_yellow")
        for y in [-.12,.12]:
            cylinder("Stand rubber foot",(side*.177,y,.012),.018,.050,"rubber_black",(0,1,0),24)
        rod("Yoke side arm",(side*.145,0,.16),(side*.145,0,.335),.011,"paint_safety_yellow")
        cylinder("Lamp tilt knob",(side*.158,0,.335),.024,.018,"polymer_anthracite",(1,0,0),16)
    rod("Stand cross brace",(-.15,0,.11),(.15,0,.11),.010,"steel_dark")
    cube("Die-cast light housing",(0,0,.33),(.264,.078,.216),"polymer_anthracite",.018)
    cube("Reflector gasket",(0,.042,.33),(.234,.006,.187),"rubber_black",.013)
    cube("Light reflector panel",(0,.046,.33),(.216,.004,.170),"steel_brushed",.009)
    for row in range(4):
        for col in range(6):
            cube("Individual LED emitter",((col-2.5)*.032,.050,.33+(row-1.5)*.034),(.016,.004,.016),"led_warm",.003)
    for x in [-.120,.120]:
        for z in [.238,.422]:
            bolt((x,.046,z),.004)
    for z in [.245,.278,.31,.343,.376,.409]:
        cube("Rear cooling fin",(0,-.046,z),(.212,.022,.009),"steel_dark",.002)
    tube("Top carry handle",[(-.078,0,.432),(-.078,0,.485),(0,0,.495),(.078,0,.485),(.078,0,.432)],.010,"rubber_black")
    cube("Rear rechargeable battery",(0,-.068,.32),(.115,.036,.10),"paint_safety_yellow",.009)


def rescue_radio():
    cube("Impact resistant radio body",(0,0,.078),(.075,.046,.144),"paint_safety_yellow",.009)
    cube("Rubber lower bumper",(0,0,.016),(.077,.048,.025),"rubber_black",.006)
    for x in [-.038,.038]:
        cube("Rubber side rail",(x,0,.080),(.009,.044,.106),"rubber_black",.004)
    cube("Display bezel",(0,.024,.108),(.058,.008,.037),"polymer_anthracite",.003)
    cube("Radio status display",(0,.029,.108),(.047,.0015,.025),"screen_teal",.001)
    text_label("CH 01",(0,.0305,.108),.009)
    for z in [.132,.138]:
        for x in [-.023,-.014,-.005,.004,.013,.022]:
            cube("Microphone grille slot",(x,.024,z),(.004,.002,.0025),"rubber_black",.0006)
    for row in range(3):
        for col in range(3):
            cube("Sealed keypad button",((col-1)*.016,.026,.078-row*.015),(.011,.006,.009),"polymer_anthracite",.002)
    cube("Push-to-talk key",(-.043,0,.109),(.006,.027,.032),"paint_rescue_red",.003)
    cylinder("Volume knob",(.018,0,.158),.010,.023,"polymer_anthracite",vertices=16)
    cylinder("Antenna socket",(-.020,0,.157),.008,.020,"steel_dark",vertices=16)
    cone("Flexible antenna",(-.020,0,.205),.0055,.0035,.082,"rubber_black")
    cube("Rear belt clip",(0,-.029,.09),(.033,.008,.093),"polymer_anthracite",.006)


def trauma_bag():
    cube("Padded medical bag",(0,0,.135),(.45,.245,.25),"fabric_red",.035)
    cube("Reinforced fabric base",(0,0,.029),(.45,.245,.048),"webbing_black",.018)
    cube("Front zipped pocket",(0,.132,.127),(.285,.055,.166),"fabric_red",.022)
    cube("Pocket cross backing",(0,.161,.128),(.074,.004,.083),"paint_rescue_red",.006)
    cross_badge((0,.164,.128),.058)
    tube("Pocket seam piping",[(-.128,.16,.06),(-.14,.158,.08),(-.14,.158,.19),(-.12,.158,.204),
                               (.12,.158,.204),(.14,.158,.19),(.14,.158,.08),(.128,.16,.06)],.0015,"polymer_anthracite")
    for x in [-.165,.165]:
        cube("Webbing retention strap",(x,.126,.137),(.032,.007,.216),"webbing_black",.003)
        cube("Front strap clasp",(x,.135,.174),(.042,.012,.026),"polymer_anthracite",.004)
        tube("Top carry webbing",[(x,-.082,.248),(x,-.073,.310),(x,0,.335),(x,.073,.310),(x,.082,.248)],.010,"webbing_black")
    cube("Handle joining pad",(0,0,.33),(.32,.034,.029),"webbing_black",.010)
    tube("Top zipper seam",[(-.195,-.074,.252),(0,-.105,.267),(.195,-.074,.252)],.002,"steel_dark")
    torus("Zipper pull",(.187,-.079,.260),.009,.0017,"steel_brushed",(0,0,1),24)
    for x in [-.205,.205]:
        cube("End reinforced pocket",(x,0,.14),(.053,.17,.145),"webbing_black",.020)


def rope_coil():
    for i in range(10):
        pts = [(.129*math.cos(TAU*j/28)+.002*math.sin(i),.081*math.sin(TAU*j/28),.008+.009*i) for j in range(28)]
        tube("Individual coiled rope turn",pts,.0052,"rope_gold",True)
    for x in [-.060,.060]:
        tube("Coil retention tie",[(x,-.092,.010),(x,-.095,.090),(x,-.040,.100),
                                   (x,.092,.090),(x,.095,.010)],.0045,"webbing_black",True)
    tube("Free rope tail",[(.12,.025,.045),(.166,.058,.018),(.17,.118,.011),(.115,.143,.011),(.061,.123,.011)],.0052,"rope_gold")
    cylinder("Heat-shrink end sleeve",(.060,.123,.011),.006,.025,"paint_rescue_red",(1,.15,0),20)


def carabiner():
    tube("Forged D-frame",[(.022,0,.028),(-.020,0,.010),(-.036,0,.030),(-.035,0,.088),
                           (-.014,0,.119),(.020,0,.110),(.027,0,.091)],.0058,"paint_safety_yellow")
    a,b = (.023,0,.028),(.027,0,.091)
    rod("Hinged locking gate",a,b,.0043,"steel_brushed",20)
    cylinder("Screw-lock sleeve",(.025,0,.065),.0085,.026,"steel_dark",vertices=24)
    for i in range(7):
        torus("Locking sleeve knurl",(.025,0,.054+i*.0035),.0085,.0008,"steel_edge",major_segments=24)
    for p in [a,b]:
        cylinder("Gate pivot pin",(p[0],.006,p[2]),.003,.003,"steel_dark",(0,1,0),12)


def descender():
    torus("Large rope loop",(0,0,.097),.039,.0085,"anodized_blue",(0,1,0),56)
    torus("Attachment loop",(0,0,.025),.021,.0085,"anodized_blue",(0,1,0),48)
    cube("Figure-eight waist",(0,0,.055),(.023,.017,.028),"anodized_blue",.008)
    for side in [-1,1]:
        tube("Rope retaining ear",[(side*.031,0,.119),(side*.053,0,.133),(side*.057,0,.119)],.006,"anodized_blue")


def oxygen_cylinder():
    lathe("Medical oxygen bottle",[(.008,.043),(.020,.057),(.045,.062),(.335,.062),
                                   (.374,.056),(.405,.037),(.417,.019)],"oxygen_green")
    lathe("White shoulder marking",[(.350,.060),(.375,.055),(.402,.039),(.418,.019)],"label_ivory")
    cylinder("Bottle base ring",(0,0,.015),.064,.024,"rubber_black")
    cylinder("Bottle neck",(0,0,.424),.018,.022,"steel_brushed")
    cylinder("Valve assembly",(0,0,.451),.014,.039,"brass_valve",vertices=12)
    cylinder("Valve handwheel",(0,0,.478),.030,.013,"oxygen_green",vertices=12)
    for i in range(6):
        a = i*TAU/6
        cylinder("Handwheel lobe",(.025*math.cos(a),.025*math.sin(a),.478),.008,.014,"oxygen_green",vertices=12)
    rod("Regulator neck",(0,0,.45),(.063,0,.45),.010,"brass_valve",16)
    cylinder("Regulator body",(.063,0,.45),.022,.035,"steel_brushed",(0,1,0),24)
    cylinder("Regulator gauge rim",(.063,.023,.459),.023,.014,"steel_dark",(0,1,0))
    cylinder("Regulator gauge face",(.063,.031,.459),.019,.002,"label_ivory",(0,1,0),32,0)
    rod("Regulator needle",(.063,.033,.459),(.052,.033,.468),.0008,"paint_rescue_red",8,0)
    tube("Oxygen delivery hose",[(.078,0,.429),(.108,0,.37),(.11,.02,.16),(.09,.048,.11),(.076,.068,.18)],.003,"rubber_black")
    cube("Cylinder information label",(0,.062,.234),(.068,.002,.111),"label_ivory",.003)
    text_label("O2",(0,.064,.252),.026,"oxygen_green")
    for z in [.220,.209,.199]:
        cube("Cylinder label rule",(0,.064,z),(.047,.001,.002),"label_ink",0)


def rescue_helmet():
    segments, rows = 48,12
    verts,faces = [],[]
    for row in range(rows):
        t = row/(rows-1)*(PI/2-.035)
        verts.extend((.133*math.cos(t)*math.cos(TAU*i/segments),
                      .155*math.cos(t)*math.sin(TAU*i/segments),.050+.148*math.sin(t)) for i in range(segments))
    for row in range(rows-1):
        for i in range(segments):
            a,b = row*segments+i,row*segments+(i+1)%segments
            faces.append((a,b,b+segments,a+segments))
    faces.append(tuple((rows-1)*segments+i for i in range(segments)))
    shell = mesh("Moulded helmet shell",verts,faces,"paint_safety_yellow",smooth=True)
    solid = shell.modifiers.new("Real shell wall thickness","SOLIDIFY")
    solid.thickness,solid.offset = .004,-1
    ring_curve("Helmet protective brim",.145,.176,.045,.009,"paint_safety_yellow")
    ring_curve("Black shell rim",.134,.156,.045,.004,"rubber_black")
    tube("Raised crown ridge",[(0,-.12,.127),(0,-.075,.190),(0,0,.205),(0,.080,.185),(0,.125,.125)],.006,"paint_safety_yellow")
    cube("Front shield backing",(0,.146,.095),(.069,.010,.059),"polymer_anthracite",.007)
    cross_badge((0,.153,.095),.038)
    for side in [-1,1]:
        cylinder("Visor hinge",(side*.135,.025,.071),.018,.012,"steel_dark",(1,0,0),24)
        cube("Side reflective marking",(side*.129,-.040,.109),(.005,.075,.019),"label_ivory",.002)
    tube("Chin retention strap",[(-.128,0,.043),(-.101,.012,-.014),(0,.020,-.031),
                                 (.101,.012,-.014),(.128,0,.043)],.007,"webbing_black")
    cube("Chin strap buckle",(.062,.02,-.020),(.036,.016,.022),"polymer_anthracite",.004)


def rescue_stretcher():
    tube("Continuous tubular perimeter",[(-.252,-.82,.083),(-.252,.82,.083),(-.205,.88,.083),
                                          (.205,.88,.083),(.252,.82,.083),(.252,-.82,.083),
                                          (.205,-.88,.083),(-.205,-.88,.083)],.017,"steel_brushed",True)
    cube("Tensioned rescue bed",(0,0,.088),(.460,1.72,.038),"fabric_teal",.018)
    cube("Padded head support",(0,.650,.125),(.38,.29,.065),"fabric_teal",.025)
    for x in [-.235,.235]:
        for side in [-1,1]:
            rod("Carry handle shaft",(x,side*.77,.083),(x,side*1.01,.083),.015,"steel_brushed")
            rubber_grip((x,side*.86,.083),(x,side*1.01,.083),.020,"paint_rescue_orange",rings=10)
    for y in [-.50,0,.43]:
        cube("Patient restraint webbing",(0,y,.113),(.485,.045,.007),"webbing_black",.002)
        cube("Restraint quick release buckle",(.046,y,.121),(.066,.058,.016),"paint_rescue_red",.004)
        cube("Buckle push pad",(.046,y+.001,.132),(.031,.032,.005),"polymer_anthracite",.003)
    for x in [-.247,.247]:
        cylinder("Folding frame pivot",(x,0,.084),.028,.039,"steel_dark",(1,0,0),24)
        for y in [-.64,.64]:
            cube("Underside support foot",(x*.8,y,.025),(.045,.080,.050),"rubber_black",.010)
    for y in [-.7,.68]:
        rod("Underside frame brace",(-.24,y,.057),(.24,y,.057),.011,"steel_brushed")


def equipment_case():
    cube("Rigid equipment case shell",(0,0,.177),(.545,.315,.332),"polymer_anthracite",.025)
    cube("Gasket separating lid",(0,0,.280),(.550,.320,.010),"rubber_black",.003)
    cube("Raised lid",(0,0,.322),(.542,.313,.078),"polymer_anthracite",.021)
    for x in [-.23,.23]:
        for y in [-.119,.119]:
            cube("Protective corner rib",(x,y,.185),(.052,.083,.337),"rubber_black",.012)
    for x in [-.170,.170]:
        cube("Over-centre latch housing",(x,.170,.282),(.054,.027,.074),"steel_dark",.006)
        cube("Yellow latch lever",(x,.187,.285),(.040,.017,.054),"paint_safety_yellow",.006)
        bolt((x,.197,.306),.004)
        cube("Rear lid hinge",(x,-.169,.279),(.071,.027,.041),"steel_dark",.005)
    tube("Folding carry handle",[(-.095,0,.357),(-.095,0,.398),(0,0,.411),(.095,0,.398),(.095,0,.357)],.014,"rubber_black")
    cube("Red rescue identification plate",(0,.161,.192),(.130,.004,.108),"paint_rescue_red",.007)
    cross_badge((0,.165,.192),.069)
    cylinder("Pressure equalization valve",(-.147,.163,.116),.016,.010,"steel_dark",(0,1,0),16)
    for x in [-.19,.19]:
        for y in [-.105,.105]:
            cube("Case rubber foot",(x,y,.012),(.065,.052,.022),"rubber_black",.006)


def emergency_beacon():
    cylinder("Magnetic rubber base",(0,0,.014),.075,.028,"rubber_black",vertices=48)
    lathe("Sealed beacon body",[(.022,.069),(.03,.072),(.060,.068),(.068,.062)],"paint_safety_yellow")
    torus("Weather seal",(0,0,.067),.061,.003,"rubber_black")
    lathe("Amber optical dome",[(.068,.060),(.115,.057),(.134,.044),(.142,.017),(.143,.001)],"beacon_amber")
    for i in range(16):
        a = TAU*i/16
        tube("Optical diffuser rib",[(.059*math.cos(a),.059*math.sin(a),.076),
                                     (.057*math.cos(a),.057*math.sin(a),.113),
                                     (.044*math.cos(a),.044*math.sin(a),.132)],.0012,"beacon_amber")
    for i in range(8):
        a = TAU*i/8
        cube("Impact-resistant base rib",(.07*math.cos(a),.07*math.sin(a),.044),(.010,.012,.027),"polymer_anthracite",.002,(0,0,a))
    cylinder("Sealed activation switch",(0,.070,.044),.011,.005,"rubber_black",(0,1,0),24)
    cube("Switch power mark",(0,.073,.044),(.002,.001,.010),"label_ivory",.0004)


SPECS = [
    ("fire_axe","Hache de secours",fire_axe,(0,0,.20)),
    ("extinguisher","Extincteur ABC",extinguisher,(.02,0,.55)),
    ("halligan","Outil Halligan",halligan,(0,0,.43)),
    ("bolt_cutter","Coupe-boulons",bolt_cutter,(-.09,0,.20)),
    ("rescue_flashlight","Lampe de secours",rescue_flashlight,(0,0,.12)),
    ("portable_worklight","Projecteur portable",portable_worklight,(0,0,.49)),
    ("rescue_radio","Radio de secours",rescue_radio,(0,0,.075)),
    ("trauma_bag","Sac de traumatologie",trauma_bag,(0,0,.33)),
    ("rope_coil","Corde lovee",rope_coil,(0,0,.05)),
    ("carabiner","Mousqueton a verrouillage",carabiner,(0,0,.065)),
    ("descender","Descendeur en huit",descender,(0,0,.05)),
    ("oxygen_cylinder","Bouteille d'oxygene",oxygen_cylinder,(0,0,.478)),
    ("rescue_helmet","Casque de secours",rescue_helmet,(0,0,.08)),
    ("rescue_stretcher","Brancard de secours",rescue_stretcher,(0,.91,.08)),
    ("equipment_case","Valise de secours",equipment_case,(0,0,.40)),
    ("emergency_beacon","Balise d'urgence",emergency_beacon,(0,0,.07)),
]


def bounds(asset):
    bpy.context.view_layer.update()
    points = [obj.matrix_world@Vector(c) for obj in asset["parts"] for c in obj.bound_box]
    return Vector(tuple(min(p[i] for p in points) for i in range(3))),Vector(tuple(max(p[i] for p in points) for i in range(3)))


def finalize_asset(asset):
    for obj in asset["parts"]:
        # Mirrored fork/jaw outlines must have outward-facing normals too.
        bm = bmesh.new()
        bm.from_mesh(obj.data)
        bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
        bm.to_mesh(obj.data)
        bm.free()
        deselect()
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        for modifier in list(obj.modifiers):
            bpy.ops.object.modifier_apply(modifier=modifier.name)
    lo,hi = bounds(asset)
    offset = Vector(((lo.x+hi.x)/2,(lo.y+hi.y)/2,lo.z))
    for obj in asset["parts"]:
        obj.location -= offset
    grip = Vector(asset["grip"])-offset
    asset["grip_godot"] = (grip.x,grip.z,-grip.y)
    deselect()
    for obj in asset["parts"]:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = asset["parts"][0]
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=1.05,island_margin=.016,area_weight=.1,
                             correct_aspect=True,scale_to_bounds=True)
    bpy.ops.object.mode_set(mode="OBJECT")
    lo,hi = bounds(asset)
    size = hi-lo
    asset["dimensions_godot"],asset["dimensions_source"] = (size.x,size.z,size.y),tuple(size)
    asset["root"]["asset_id"] = asset["id"]
    asset["root"]["units"] = "metres"
    asset["root"]["source_front"],asset["root"]["runtime_front"] = "+Y","-Z"
    asset["root"]["grip_godot_m"] = list(asset["grip_godot"])
    triangles,materials = 0,set()
    for obj in asset["parts"]:
        obj.data.calc_loop_triangles()
        triangles += len(obj.data.loop_triangles)
        materials.update(slot.material.name for slot in obj.material_slots if slot.material)
        assert obj.data.uv_layers, obj.name
    asset["triangles"],asset["materials"] = triangles,sorted(materials)


def export_asset(asset,output):
    # Keep the editable source separated, but merge runtime geometry by material.
    # This avoids hundreds of individual MeshInstance3D/draw submissions on a rack.
    export_collection = bpy.data.collections.new("TEMP_EXPORT")
    bpy.context.scene.collection.children.link(export_collection)
    export_root = bpy.data.objects.new(asset["id"],None)
    export_collection.objects.link(export_root)
    export_root["asset_id"] = asset["id"]
    export_root["units"] = "metres"
    export_root["grip_godot_m"] = list(asset["grip_godot"])
    copies,temporary_mesh_names = [],[]
    deselect()
    for part in asset["parts"]:
        clone = part.copy()
        clone.data = part.data.copy()
        temporary_mesh_names.append(clone.data.name)
        export_collection.objects.link(clone)
        clone.parent = export_root
        clone.matrix_parent_inverse.identity()
        clone.matrix_world = part.matrix_world.copy()
        clone.select_set(True)
        copies.append(clone)
    bpy.context.view_layer.objects.active = copies[0]
    bpy.ops.object.join()
    joined = bpy.context.object
    joined.name = asset["id"]+"_render_mesh"
    export_root.select_set(True)
    bpy.context.view_layer.objects.active = export_root
    path = output/f"{asset['id']}.glb"
    bpy.ops.export_scene.gltf(filepath=str(path),export_format="GLB",use_selection=True,
        export_apply=True,export_yup=True,export_texcoords=True,export_normals=True,
        export_tangents=False,export_materials="EXPORT",export_cameras=False,
        export_lights=False,export_animations=False,export_extras=True)
    for obj in list(export_collection.objects):
        bpy.data.objects.remove(obj,do_unlink=True)
    bpy.data.collections.remove(export_collection)
    for name in temporary_mesh_names:
        data = bpy.data.meshes.get(name)
        if data is not None and data.users == 0:
            bpy.data.meshes.remove(data)
    return {
        "id":asset["id"],"label_fr":asset["label"],
        "path":f"res://assets/models/rescue_v011/{asset['id']}.glb",
        "sha256":hashlib.sha256(path.read_bytes()).hexdigest(),"bytes":path.stat().st_size,
        "dimensions_m":{axis:round(v,6) for axis,v in zip("xyz",asset["dimensions_godot"])},
        "source_dimensions_m":{axis:round(v,6) for axis,v in zip("xyz",asset["dimensions_source"])},
        "pivot":"bottom bounding-box centre","grip_offset_m":[round(v,6) for v in asset["grip_godot"]],
        "triangles":asset["triangles"],"mesh_parts":len(asset["parts"]),
        "source_mesh_parts":len(asset["parts"]),"runtime_meshes":1,"materials":asset["materials"],
        "uv":"UVMap: Smart UV atlas, non-overlapping islands per asset","embedded_images":0,
    }


def write_catalog(records,path):
    rows = []
    for r in records:
        d,g = r["dimensions_m"],r["grip_offset_m"]
        rows.append(f'\t"{r["id"]}": {{"dimensions": Vector3({d["x"]}, {d["y"]}, {d["z"]}), '
                    f'"grip": Vector3({g[0]}, {g[1]}, {g[2]}), "triangles": {r["triangles"]}}')
    header = '''extends RefCounted
## Generated by tools/generate_rescue_models.py. Authored Blender geometry.
## Metres; +Y up, -Z front. Origin is the bottom bounding-box centre.

const ASSET_ROOT := "res://assets/models/rescue_v011/"

const MATERIAL_ALBEDOS := {
	"steel_brushed": "brushed_steel",
	"paint_rescue_red": "rescue_red_paint",
	"rubber_black": "black_rubber",
}
const MATERIAL_TEXTURE_ROOT := "res://assets/materials/v011/"
const MODELS := {
'''
    footer = '''
}

static func all_ids() -> PackedStringArray:
\treturn PackedStringArray(MODELS.keys())

static func asset_path(id: String) -> String:
\treturn ASSET_ROOT + id + ".glb" if MODELS.has(id) else ""

static func grip_offset(id: String) -> Vector3:
\treturn MODELS.get(id, {}).get("grip", Vector3.ZERO)

static func dimensions(id: String) -> Vector3:
\treturn MODELS.get(id, {}).get("dimensions", Vector3.ZERO)

static func metadata_for(id: String) -> Dictionary:
\tvar result: Dictionary = MODELS.get(id, {}).duplicate(true)
\tif not result.is_empty():
\t\tresult["id"] = id
\t\tresult["path"] = asset_path(id)
\treturn result

static func instantiate(id: String) -> Node3D:
\tvar path := asset_path(id)
\tif path.is_empty() or not ResourceLoader.exists(path):
\t\tpush_warning("Rescue model unavailable: " + id)
\t\treturn null
\tvar scene := ResourceLoader.load(path) as PackedScene
\tif scene == null:
\t\tpush_warning("Rescue model did not import as a PackedScene: " + id)
\t\treturn null
\tvar model := scene.instantiate() as Node3D
\tif model == null:
\t\treturn null
\tmodel.name = "RescueAsset_" + id
\tmodel.set_meta("rescue_asset_id", id)
\tmodel.set_meta("grip_offset", grip_offset(id))
\tmodel.set_meta("authored_model", true)
\t_apply_shared_albedos(model)
\treturn model

static func _apply_shared_albedos(node: Node) -> void:
\tif node is MeshInstance3D:
\t\tvar instance := node as MeshInstance3D
\t\tif instance.mesh != null:
\t\t\tfor surface in range(instance.mesh.get_surface_count()):
\t\t\t\tvar original := instance.get_surface_override_material(surface)
\t\t\t\tif original == null:
\t\t\t\t\toriginal = instance.mesh.surface_get_material(surface)
\t\t\t\tif not original is StandardMaterial3D:
\t\t\t\t\tcontinue
\t\t\t\tvar texture_id: String = MATERIAL_ALBEDOS.get(original.resource_name, "")
\t\t\t\tif texture_id.is_empty():
\t\t\t\t\tcontinue
\t\t\t\tvar path := MATERIAL_TEXTURE_ROOT + texture_id + ".png"
\t\t\t\tif not ResourceLoader.exists(path):
\t\t\t\t\tcontinue
\t\t\t\tvar texture := ResourceLoader.load(path) as Texture2D
\t\t\t\tif texture == null:
\t\t\t\t\tcontinue
\t\t\t\tvar material := original.duplicate() as StandardMaterial3D
\t\t\t\tmaterial.albedo_texture = texture
\t\t\t\tmaterial.albedo_color = Color.WHITE
\t\t\t\tmaterial.uv1_triplanar = true
\t\t\t\tmaterial.uv1_world_triplanar = false
\t\t\t\tvar repeats := 6.0 if texture_id == "black_rubber" else 4.0
\t\t\t\tmaterial.uv1_scale = Vector3.ONE * repeats
\t\t\t\tinstance.set_surface_override_material(surface, material)
\tfor child in node.get_children():
\t\t_apply_shared_albedos(child)
'''
    path.write_text(header+",\n".join(rows)+","+footer,encoding="utf-8")


def setup_studio():
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.device,scene.cycles.samples,scene.cycles.use_denoising = "CPU",24,True
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format,scene.render.image_settings.color_mode = "PNG","RGB"
    scene.render.film_transparent = False
    scene.view_settings.view_transform = "AgX"
    scene.world.use_nodes = True
    background = scene.world.node_tree.nodes.get("Background")
    background.inputs["Color"].default_value = (.29,.34,.39,1)
    background.inputs["Strength"].default_value = .35
    studio = bpy.data.collections.new("STUDIO - preview only, never exported")
    scene.collection.children.link(studio)
    def relink(obj):
        for coll in list(obj.users_collection):
            coll.objects.unlink(obj)
        studio.objects.link(obj)
    bpy.ops.mesh.primitive_plane_add(size=200)
    ground = bpy.context.object
    ground.name,ground.location.z = "Studio floor - never exported",-.001
    ground.data.materials.append(material("Preview ground only",(.12,.16,.18),.86))
    relink(ground)
    for name,location,energy,size,color in [
        ("Large key",(3,4,5),600,4,(1,.91,.80)),
        ("Soft fill",(-3,2,2),380,3,(.76,.87,1)),
        ("Edge light",(0,-3,4),700,3,(.84,.91,1))]:
        data = bpy.data.lights.new(name,"AREA")
        data.energy,data.shape,data.size,data.color = energy,"DISK",size,color
        obj = bpy.data.objects.new(name,data)
        studio.objects.link(obj)
        obj.location = location
        obj.rotation_euler = (-obj.location).to_track_quat("-Z","Y").to_euler()
    data = bpy.data.cameras.new("Equipment preview camera")
    data.type = "ORTHO"
    camera = bpy.data.objects.new("Equipment preview camera",data)
    studio.objects.link(camera)
    scene.camera = camera
    return camera


def point_camera(camera,target,ortho,direction=(.9,1.6,1.0)):
    target = Vector(target)
    camera.location = target+Vector(direction).normalized()*4
    camera.rotation_euler = (target-camera.location).to_track_quat("-Z","Y").to_euler()
    camera.data.ortho_scale, camera.data.clip_start, camera.data.clip_end = ortho,.001,100


def render_previews(directory,camera):
    scene = bpy.context.scene
    thumbs = []
    for asset in ASSETS:
        for other in ASSETS:
            other["collection"].hide_render = other is not asset
            other["root"].location = (0,0,0)
        lo,hi = bounds(asset)
        size = hi-lo
        direction = (.85,1.6,1.05) if size.z>.20 else (.9,1.3,1.4)
        # Landscape tiles yield a 1600x900 contact sheet. Fit the projected box.
        point_camera(camera,(lo+hi)/2,1,direction)
        bpy.context.view_layer.update()
        view = camera.matrix_world.inverted()
        points = [view@(obj.matrix_world@Vector(c)) for obj in asset["parts"] for c in obj.bound_box]
        width = max(p.x for p in points)-min(p.x for p in points)
        height = max(p.y for p in points)-min(p.y for p in points)
        camera.data.ortho_scale = max(width,height*(400/172))*1.16
        scene.render.resolution_x,scene.render.resolution_y = 400,172
        scene.render.filepath = str(directory/f"{asset['id']}.png")
        bpy.ops.render.render(write_still=True)
        thumbs.append((asset,Path(scene.render.filepath)))
        print(f"PREVIEW {asset['id']}",flush=True)
    closeups = {
        "fire_axe":((0,0,.77),.46,(.4,1.6,.7)),
        "extinguisher":((0,0,.38),.52,(.55,1.6,.8)),
        "halligan":((0,0,.80),.36,(.9,1.6,.9)),
        "bolt_cutter":((0,0,.52),.34,(.4,1.6,.7)),
    }
    for asset in ASSETS:
        if asset["id"] not in closeups:
            continue
        for other in ASSETS:
            other["collection"].hide_render = other is not asset
        target,ortho,direction = closeups[asset["id"]]
        point_camera(camera,target,ortho,direction)
        scene.render.resolution_x = scene.render.resolution_y = 800
        scene.cycles.samples = 32
        scene.render.filepath = str(directory/f"detail_{asset['id']}.png")
        bpy.ops.render.render(write_still=True)
    from PIL import Image,ImageDraw,ImageFont
    sheet = Image.new("RGB",(1600,900),(18,28,33))
    draw = ImageDraw.Draw(sheet)
    fonts = [Path("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"),
             Path("/usr/share/fonts/truetype/liberation2/LiberationSans-Regular.ttf")]
    font_path = next((p for p in fonts if p.exists()),None)
    font = ImageFont.truetype(str(font_path),15) if font_path else ImageFont.load_default()
    small = ImageFont.truetype(str(font_path),12) if font_path else ImageFont.load_default()
    title = ImageFont.truetype(str(font_path),28) if font_path else ImageFont.load_default()
    draw.text((22,15),"THE TOWER DESCENT / SECOURS v0.11",font=title,fill=(237,232,212))
    draw.text((24,52),"16 modeles Blender originaux - metres, geometrie reelle, materiaux PBR - rendus Cycles",font=font,fill=(153,185,188))
    for i,(asset,path) in enumerate(thumbs):
        x,y = (i%4)*400,80+(i//4)*205
        sheet.paste(Image.open(path),(x,y))
        draw.text((x+12,y+172),asset["label"],font=font,fill=(237,232,212))
        d = asset["dimensions_godot"]
        draw.text((x+12,y+190),f"{d[0]:.2f} x {d[1]:.2f} x {d[2]:.2f} m / {asset['triangles']:,} triangles",font=small,fill=(153,185,188))
    sheet.save(directory.parent/"rescue_equipment_contact_sheet.png")


def main():
    global ACTIVE,PART_INDEX,ROOT
    parser = argparse.ArgumentParser()
    parser.add_argument("--root","--project-root",dest="project_root",type=Path,default=ROOT)
    parser.add_argument("--render",action="store_true")
    args = parser.parse_args(sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else [])
    ROOT = args.project_root.resolve()
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for coll in list(bpy.data.collections):
        if coll.name!="Collection":
            bpy.data.collections.remove(coll)
    scene = bpy.context.scene
    scene.unit_settings.system,scene.unit_settings.scale_length,scene.unit_settings.length_unit = "METRIC",1.0,"METERS"
    setup_materials()
    model_dir,source_dir = ROOT/"prototype/assets/models/rescue_v011",ROOT/"docs/assets/v0.11"
    preview_dir = source_dir/"renders"
    for directory in [model_dir,source_dir,preview_dir]:
        directory.mkdir(parents=True,exist_ok=True)
    records = []
    for asset_id,label,builder,grip in SPECS:
        collection = bpy.data.collections.new(asset_id)
        scene.collection.children.link(collection)
        root = bpy.data.objects.new(asset_id,None)
        collection.objects.link(root)
        root.empty_display_size = .05
        ACTIVE = {"id":asset_id,"label":label,"collection":collection,"root":root,"parts":[],"grip":grip}
        PART_INDEX = 0
        builder()
        finalize_asset(ACTIVE)
        records.append(export_asset(ACTIVE,model_dir))
        ASSETS.append(ACTIVE)
        print(f"ASSET {asset_id}: {ACTIVE['triangles']} triangles, {records[-1]['bytes']} bytes",flush=True)
    write_catalog(records,ROOT/"prototype/scripts/rescue_asset_catalog.gd")
    camera = setup_studio()
    for i,asset in enumerate(ASSETS):
        asset["root"].location = ((i%4-1.5)*1.5,(i//4-1.5)*2.2,0)
        asset["collection"].hide_render = False
    point_camera(camera,(0,0,.25),9.5,(1.1,1.6,1.9))
    camera.location = Vector((6,8,10))
    camera.rotation_euler = (Vector((0,0,.25))-camera.location).to_track_quat("-Z","Y").to_euler()
    scene.render.resolution_x,scene.render.resolution_y = 1600,900
    deselect()
    for asset in ASSETS:
        asset["root"].select_set(True)
    bpy.context.view_layer.objects.active = ASSETS[0]["root"]
    for screen in bpy.data.screens:
        for area in screen.areas:
            if area.type=="VIEW_3D":
                area.spaces.active.region_3d.view_distance = 10
                area.spaces.active.region_3d.view_location = Vector((0,0,.3))
    bpy.context.preferences.filepaths.save_version = 0
    source_path = source_dir/"rescue_equipment.blend"
    bpy.ops.wm.save_as_mainfile(filepath=str(source_path),compress=True)
    manifest = {
        "schema_version":1,"library":"The Tower Descent rescue equipment v0.11",
        "generator":"tools/generate_rescue_models.py","blender_version":bpy.app.version_string,
        "units":"metres","source_axes":{"up":"+Z","front":"+Y","right":"+X"},
        "runtime_axes":{"up":"+Y","front":"-Z","right":"+X"},
        "source":{"path":"docs/assets/v0.11/rescue_equipment.blend",
                  "sha256":hashlib.sha256(source_path.read_bytes()).hexdigest(),"bytes":source_path.stat().st_size},
        "authoring":"Original deterministic Blender Python geometry; no external models or embedded image textures.",
        "uv_convention":"One smart-projected UV atlas per asset; tiled material textures may use object/world coordinates.",
        "assets":records,"total_glb_bytes":sum(r["bytes"] for r in records),
        "total_triangles":sum(r["triangles"] for r in records),
    }
    for path in [model_dir/"manifest.json",source_dir/"rescue_equipment_manifest.json"]:
        path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    if args.render:
        render_previews(preview_dir,camera)
    print(f"DONE: {len(records)} GLBs, {manifest['total_glb_bytes']:,} bytes, {manifest['total_triangles']:,} triangles",flush=True)


if __name__=="__main__":
    main()
