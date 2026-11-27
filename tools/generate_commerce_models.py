#!/usr/bin/env python3
"""Author editable retail, kitchen and refuge fixtures for The Tower Descent.

blender --background --factory-startup --python tools/generate_commerce_models.py -- --root . --render

Original geometry only. Reuses the v0.11 mesh/export helpers without changing
their outputs. All runtime assets are metres, +Y up, -Z front, bottom-centred.
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

PI = math.pi
cube, cylinder, rod = G.cube, G.cylinder, G.rod
tube, torus, mesh, bolt = G.tube, G.torus, G.mesh, G.bolt


def setup_materials():
    G.setup_materials()
    palette = {
        "walnut_dark": ((.105, .055, .027), .60, 0),
        "champagne_brass": ((.55, .36, .15), .30, .85),
        "ceramic_ivory": ((.73, .74, .68), .34, 0),
        "steel_satin": ((.43, .47, .48), .37, .85),
        "enamel_cream": ((.54, .60, .56), .38, .15),
        "canvas_refuge": ((.10, .24, .20), .94, 0),
        "fabric_pillow": ((.62, .65, .57), .94, 0),
        "water_blue": ((.035, .20, .32), .52, 0),
        "curtain_pale": ((.43, .54, .48), .94, 0),
        "blue_key": ((.025, .24, .45), .38, .12),
        "oven_glass": ((.014, .025, .030), .14, .12),
    }
    for name, (color, rough, metal) in palette.items():
        G.M[name] = G.material(name, color, rough, metal)
    glass = G.material("glass_shop_smoke", (.36, .53, .54), .16, .02)
    glass.diffuse_color = (.36, .53, .54, .16)
    glass.node_tree.nodes["Principled BSDF"].inputs["Alpha"].default_value = .16
    if hasattr(glass, "surface_render_method"):
        glass.surface_render_method = "DITHERED"
    elif hasattr(glass, "blend_method"):
        glass.blend_method = "BLEND"
    G.M["glass_shop_smoke"] = glass


def screw(x, y, z, axis=(0, 1, 0), radius=.004):
    bolt((x, y, z), radius, axis=axis)


def caster(x, y, radius=.045):
    cylinder("Swivel caster stem", (x, y, radius * 2 + .025), .012, .055, "steel_dark")
    cube("Fork left cheek", (x-.022, y, radius+.015), (.009, .055, .065), "steel_brushed", .003)
    cube("Fork right cheek", (x+.022, y, radius+.015), (.009, .055, .065), "steel_brushed", .003)
    cylinder("Rubber caster wheel", (x, y, radius), radius, .034, "rubber_black", (1, 0, 0), 28, .003)
    cylinder("Caster hub and axle", (x, y, radius), radius*.45, .053, "steel_edge", (1, 0, 0), 20)


def tubular_handle(name, x0, x1, y, z, rise, mat="steel_brushed", radius=.012):
    tube(name, [(x0,y,z), (x0,y+.025,z+rise*.8), (x0+.035,y+.035,z+rise),
                (x1-.035,y+.035,z+rise), (x1,y+.025,z+rise*.8), (x1,y,z)], radius, mat)


def retail_display_case():
    # Museum-like low cabinet, glazing and two display levels, readable from outside.
    cube("Recessed kick plate", (0,0,.065), (1.24,.51,.13), "polymer_anthracite", .018)
    cube("Walnut pedestal", (0,0,.285), (1.40,.64,.43), "walnut_dark", .012)
    for x in [-.63+i*.07 for i in range(19)]:
        cube("Vertical timber relief", (x,.324,.29), (.033,.012,.36), "walnut_dark", .003)
    for z in [.105,.50]:
        cube("Brass cabinet rail", (0,.328,z), (1.40,.014,.018), "champagne_brass", .003)
    cube("Velvet display base", (0,0,.523), (1.34,.59,.035), "fabric_teal", .006)
    for x in [-.685,.685]:
        for y in [-.305,.305]:
            cube("Brass glazed corner post", (x,y,.85), (.025,.025,.66), "champagne_brass", .003)
    for y in [-.31,.31]:
        cube("Transparent display pane", (0,y,.85), (1.35,.008,.63), "glass_shop_smoke", .001)
        cube("Brass top long rail", (0,y,1.18), (1.41,.026,.025), "champagne_brass", .003)
    for x in [-.69,.69]:
        cube("Transparent end pane", (x,0,.85), (.008,.59,.63), "glass_shop_smoke", .001)
        cube("Brass top end rail", (x,0,1.18), (.026,.62,.025), "champagne_brass", .003)
    cube("Glazed top", (0,0,1.187), (1.36,.59,.008), "glass_shop_smoke", .001)
    cube("Inner glass shelf", (0,0,.85), (1.31,.56,.012), "glass_shop_smoke", .001)
    for x in [-.59,.59]:
        for y in [-.245,.245]:
            cube("Shelf corner clamp", (x,y,.843), (.055,.045,.014), "champagne_brass", .003)
    for x,y,w,d,h in [(-.38,0,.31,.28,.07), (.19,.03,.45,.33,.10), (.40,0,.19,.22,.055)]:
        cube("Removable fabric display plinth", (x,y,.54+h/2), (w,d,h), "fabric_pillow", .012)
    for x in [-.055,.055]:
        cube("Rear sliding panel pull", (x,-.32,.91), (.014,.024,.10), "champagne_brass", .003)
    cylinder("Display cabinet key barrel", (0,.335,.39), .011,.007, "steel_dark", (0,1,0),20)


def cash_register():
    cube("Cash drawer chassis", (0,0,.066), (.43,.35,.13), "steel_dark", .016)
    cube("Drawer front", (0,.181,.068), (.407,.014,.092), "polymer_anthracite", .007)
    cylinder("Drawer key lock", (0,.191,.07), .010,.006, "steel_edge", (0,1,0), 20)
    cube("Cash drawer handle recess", (0,.193,.098), (.23,.009,.014), "rubber_black", .004)
    for x in [-.17,.17]:
        for y in [-.13,.13]:
            cylinder("Register rubber foot", (x,y,.008), .019,.016,"rubber_black",vertices=20)
    cylinder("POS swivel base", (-.065,-.065,.156), .065,.034,"steel_brushed")
    rod("POS monitor support", (-.065,-.065,.165), (-.065,-.10,.325),.025,"polymer_anthracite")
    cube("POS monitor shell", (-.065,-.075,.38), (.32,.043,.225),"polymer_anthracite",.018,(math.radians(-12),0,0))
    cube("POS dark screen glass", (-.065,-.048,.382), (.287,.008,.189),"lens_blue",.008,(math.radians(-12),0,0))
    for row in range(3):
        cube("Unlit display interface rule",(-.12,-.031,.43-row*.038),(.14,.002,.006),"screen_teal",.001)
    cube("Thermal receipt printer", (.135,.005,.21), (.14,.18,.15),"ceramic_ivory",.015)
    cube("Receipt exit slot", (.135,.10,.248), (.104,.008,.010),"rubber_black",.002)
    cube("Blank receipt tongue", (.135,.108,.263), (.085,.002,.037),"label_ivory",.0005,(math.radians(-12),0,0))
    cube("Card reader body",(-.075,.115,.174),(.16,.13,.048),"polymer_anthracite",.010,(math.radians(10),0,0))
    angle=math.radians(10)
    def card_face(local_y, local_z):
        return .115+local_y*math.cos(angle)-local_z*math.sin(angle), .174+local_y*math.sin(angle)+local_z*math.cos(angle)
    face_y,face_z=card_face(-.034,.026)
    cube("Card reader display",(-.075,face_y,face_z),(.114,.052,.003),"screen_teal",.002,(angle,0,0))
    for row in range(3):
        for col in range(3):
            face_y,face_z=card_face(.005+row*.018,.027)
            cube("Payment keypad",(-.11+col*.033,face_y,face_z),(.022,.013,.006),
                 "paint_rescue_red" if (row,col)==(2,2) else "label_ivory",.002,(angle,0,0))
    tube("POS cable to drawer",[(-.065,-.105,.31),(-.08,-.16,.21),(-.13,-.16,.14)],.005,"rubber_black")


def shutter_control():
    cube("Wall switch back plate", (0,-.008,.16), (.13,.028,.32),"steel_brushed",.009)
    cube("Sealed shutter control housing", (0,.018,.16),(.115,.065,.29),"enamel_cream",.012)
    for z in [.065,.14,.215]:
        cylinder("Button gasket",(0,.055,z),.027,.012,"rubber_black",(0,1,0),28)
        cylinder("Shutter control button",(0,.064,z),.021,.012,
                 "paint_rescue_red" if z==.14 else "polymer_anthracite",(0,1,0),24)
    # Simple raised arrow pictograms, visible without tiny lettering.
    G.prism_xz("Up arrow",[(-.010,.214),(.010,.214),(0,.226)],.002,"label_ivory",0,y=.071)
    G.prism_xz("Down arrow",[(-.010,.070),(.010,.070),(0,.058)],.002,"label_ivory",0,y=.071)
    cube("Stop square",(0,.071,.14),(.014,.002,.014),"label_ivory",.001)
    cylinder("Maintenance key barrel",(0,.055,.274),.012,.011,"steel_edge",(0,1,0),24)
    cube("Key barrel slot",(0,.062,.274),(.002,.002,.013),"rubber_black",0)
    for x in [-.047,.047]:
        for z in [.028,.292]:
            screw(x,.053,z,radius=.003)
    cylinder("Flexible cable gland",(0,-.012,.007),.015,.024,"polymer_anthracite")


def service_trolley():
    for x in [-.31,.31]:
        for y in [-.22,.22]:
            caster(x,y)
            rod("Upright shelf support",(x,y,.115),(x,y,.88),.016,"steel_brushed")
    for z in [.20,.50,.80]:
        cube("Pressed steel tray floor",(0,0,z),(.68,.50,.018),"steel_satin",.006)
        for y in [-.25,.25]:
            cube("Turned tray lip",(0,y,z+.029),(.68,.016,.06),"steel_brushed",.004)
        for x in [-.34,.34]:
            cube("End tray lip",(x,0,z+.029),(.016,.50,.06),"steel_brushed",.004)
    for x in [-.31,.31]:
        tube("Trolley push handle",[(x,-.22,.81),(x,-.26,.94),(x,0,.97),(x,.26,.94),(x,.22,.81)],.016,"steel_brushed")
        G.rubber_grip((x,-.13,.967),(x,.13,.967),.019,rings=7)
    cube("Lower tray rubber liner",(0,0,.213),(.60,.41,.006),"rubber_black",.004)


def industrial_sink():
    for x in [-.52,.52]:
        for y in [-.265,.265]:
            rod("Square-section sink leg",(x,y,.08),(x,y,.87),.018,"steel_brushed",vertices=4)
            cylinder("Adjustable sink foot",(x,y,.045),.026,.09,"rubber_black",vertices=24)
    for y in [-.265,.265]:
        rod("Low longitudinal brace",(-.52,y,.25),(.52,y,.25),.012,"steel_brushed")
    rod("Low cross brace",(0,-.265,.25),(0,.265,.25),.012,"steel_brushed")
    # A real open bowl: rim segments surround a recessed four-wall basin.
    for y in [-.322,.322]:
        cube("Sink top rim long",(0,y,.90),(1.2,.055,.035),"steel_brushed",.006)
    for x in [-.575,.575]:
        cube("Sink top rim end",(x,0,.90),(.05,.59,.035),"steel_brushed",.005)
    cube("Draining board",(.40,0,.897),(.30,.59,.03),"steel_satin",.005)
    for y in [-.23+i*.055 for i in range(9)]:
        cube("Raised draining board rib",(.40,y,.918),(.25,.013,.008),"steel_brushed",.003)
    x0,x1,y0,y1=-.55,.23,-.29,.29
    verts=[(x0,y0,.89),(x1,y0,.89),(x1,y1,.89),(x0,y1,.89),
           (x0+.045,y0+.045,.645),(x1-.045,y0+.045,.645),(x1-.045,y1-.045,.645),(x0+.045,y1-.045,.645)]
    bowl=mesh("Deep drawn open basin",verts,[(0,4,5,1),(1,5,6,2),(2,6,7,3),(3,7,4,0),(4,7,6,5)],"steel_satin",.008)
    shell=bowl.modifiers.new("Sink sheet thickness","SOLIDIFY")
    shell.thickness=.003
    cylinder("Drain steel flange",(-.16,0,.653),.035,.005,"steel_edge",vertices=32)
    cylinder("Dark drain interior",(-.16,0,.657),.021,.003,"steel_dark",vertices=24,bevel=0)
    for x in [-.172,-.16,-.148]:
        cube("Drain strainer bar",(x,0,.66),(.003,.038,.002),"steel_brushed",0)
    tube("Trap and waste pipe",[(-.16,0,.643),(-.16,0,.42),(-.16,-.11,.37),(-.16,-.20,.45),(-.16,-.27,.45)],.023,"steel_dark")
    cube("Splashback",(0,-.325,1.02),(1.2,.024,.24),"steel_brushed",.004)
    cylinder("Tap foot",(-.16,-.26,.94),.027,.04,"steel_edge")
    tube("Gooseneck kitchen tap",[(-.16,-.26,.94),(-.16,-.26,1.20),(-.16,-.15,1.29),(-.16,.00,1.27),(-.16,.04,1.19)],.014,"steel_edge")
    cylinder("Tap aerator",(-.16,.04,1.176),.019,.032,"steel_dark")
    for x,mat in [(-.33,"blue_key"),(.01,"paint_rescue_red")]:
        cylinder("Tap valve pedestal",(x,-.26,.94),.020,.04,"steel_brushed")
        rod("Tap quarter-turn lever",(x,-.26,.965),(x+.055,-.26,.965),.007,"steel_edge")
        cylinder("Tap hot-cold cap",(x,-.26,.972),.009,.005,mat,vertices=20)


def kitchen_stove():
    for x in [-.41,.41]:
        for y in [-.28,.28]:
            cylinder("Oven adjustable foot",(x,y,.065),.028,.13,"steel_dark",vertices=24)
    cube("Stainless oven body",(0,0,.47),(1.,.75,.76),"steel_satin",.016)
    cube("Recessed lower vent",(0,.386,.20),(.87,.018,.10),"steel_dark",.005)
    for x in [-.39+i*.052 for i in range(16)]:
        cube("Oven ventilation grille",(x,.398,.20),(.010,.006,.072),"steel_brushed",.001)
    cube("Oven door frame",(0,.39,.48),(.88,.034,.39),"steel_dark",.010)
    cube("Double glazed oven window",(0,.411,.48),(.72,.012,.26),"oven_glass",.006)
    for x in [-.36,.36]:
        rod("Door handle mount",(x,.40,.68),(x,.46,.68),.013,"steel_brushed")
    rod("Oven insulated handle",(-.39,.46,.68),(.39,.46,.68),.018,"polymer_anthracite")
    cube("Stove control fascia",(0,.39,.78),(.96,.04,.13),"steel_brushed",.007)
    for x in [-.36,-.18,0,.18,.36]:
        cylinder("Cooking control dial",(x,.426,.78),.034,.033,"polymer_anthracite",(0,1,0),28)
        cube("Dial indicator",(x,.445,.795),(.004,.002,.016),"label_ivory",.0005)
    cube("Raised range top",(0,0,.877),(1.03,.78,.045),"steel_brushed",.007)
    for x in [-.255,.255]:
        for y in [-.19,.19]:
            cylinder("Black burner tray",(x,y,.905),.155,.014,"steel_dark",vertices=40)
            for radius in [.035,.066,.097]:
                torus("Cold heating ring",(x,y,.918),radius,.005,"polymer_anthracite",major_segments=32)
            for axis in [0,1]:
                a,b=((x-.13,y,.935),(x+.13,y,.935)) if axis==0 else ((x,y-.13,.935),(x,y+.13,.935))
                rod("Pan support grate",a,b,.007,"steel_dark",vertices=8)
    cube("Rear range upstand",(0,-.39,1.01),(1.03,.025,.25),"steel_brushed",.005)
    for x in [-.47,.47]:
        for z in [.14,.82]:
            screw(x,.386,z)


def extraction_hood():
    # Bottom is local zero for deliberate mounting by the environment builder.
    verts=[(-.72,-.48,.04),(.72,-.48,.04),(.72,.48,.04),(-.72,.48,.04),
           (-.49,-.29,.37),(.49,-.29,.37),(.49,.29,.37),(-.49,.29,.37)]
    mesh("Tapered extraction canopy",verts,[(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(4,5,6,7)],"steel_satin",.008)
    for y in [-.47,.47]:
        cube("Canopy lower long rim",(0,y,.035),(1.44,.035,.07),"steel_brushed",.004)
    for x in [-.71,.71]:
        cube("Canopy lower end rim",(x,0,.035),(.035,.92,.07),"steel_brushed",.004)
    for x in [-.35,.35]:
        cube("Filter dark backing",(x,0,.045),(.63,.81,.015),"steel_dark",.002)
        for y in [-.36+i*.055 for i in range(14)]:
            cube("Removable baffle filter louvre",(x,y,.026),(.59,.035,.025),"steel_brushed",.002,(math.radians(18),0,0))
        tube("Filter pull loop",[(x-.045,.28,.012),(x-.045,.30,-.023),(x+.045,.30,-.023),(x+.045,.28,.012)],.004,"steel_edge")
    cube("Flue collar",(0,-.07,.40),(.52,.42,.06),"steel_brushed",.005)
    cube("Square extraction duct",(0,-.07,.59),(.46,.37,.36),"steel_satin",.004)
    for x in [-.59,.59]:
        cube("Protected canopy tasklight",(x,.24,.013),(.09,.28,.014),"label_ivory",.004)
    for x in [-.66,.66]:
        for y in [-.40,.40]:
            screw(x,y,.01,axis=(0,0,1))


def utility_cutoff_panel():
    cube("Isolation cabinet back plate",(0,-.017,.29),(.40,.035,.58),"steel_dark",.006)
    cube("Sealed steel cabinet",(0,.032,.29),(.38,.13,.54),"enamel_cream",.012)
    cube("Front door gasket",(0,.102,.29),(.355,.012,.515),"rubber_black",.006)
    cube("Isolation cabinet door",(0,.113,.29),(.345,.014,.505),"enamel_cream",.008)
    cube("Rotary isolator yellow backing",(0,.126,.29),(.21,.014,.21),"paint_safety_yellow",.008)
    cylinder("Isolator escutcheon",(0,.142,.29),.075,.018,"polymer_anthracite",(0,1,0),36)
    cube("Large red isolation handle",(0,.171,.29),(.036,.050,.15),"paint_rescue_red",.008,(0,math.radians(-28),0))
    cylinder("Cabinet amber status rim",(.10,.129,.47),.023,.012,"steel_dark",(0,1,0),24)
    cylinder("Cabinet amber lens",(.10,.139,.47),.017,.009,"beacon_amber",(0,1,0),24)
    G.text_label("ISOLER",(-.045,.126,.46),.032,"label_ink")
    for z in [.14,.42]:
        cylinder("Door barrel hinge",(-.18,.09,z),.012,.07,"steel_brushed")
    cylinder("Panel keyed latch",(.14,.13,.29),.011,.012,"steel_edge",(0,1,0),20)
    cube("Switch lower label",(0,.129,.09),(.25,.003,.038),"label_ivory",.002)
    G.text_label("CUISINES A21",(0,.132,.09),.021,"label_ink")
    for x in [-.12,0,.12]:
        cylinder("Cable entry gland",(x,0,.023),.022,.046,"polymer_anthracite",vertices=20)
    for x in [-.145,.145]:
        for z in [.065,.515]:
            screw(x,.127,z)


def fire_blanket_cabinet():
    cube("Wall mounted blanket cabinet",(0,0,.21),(.29,.090,.38),"paint_rescue_red",.012)
    cube("Blanket cabinet front lid",(0,.049,.212),(.271,.012,.355),"paint_rescue_red",.007)
    cube("White fire blanket instruction plaque",(0,.057,.236),(.223,.003,.225),"label_ivory",.004)
    G.text_label("COUVERTURE",(0,.060,.31),.022,"paint_rescue_red")
    G.text_label("ANTI-FEU",(0,.060,.28),.029,"paint_rescue_red")
    # Relief pictogram of a blanket over a flame: authored mesh, no external logo.
    G.prism_xz("Fire symbol",[(-.018,.16),(-.029,.184),(-.010,.206),(-.008,.233),(.012,.211),(.024,.189),(.018,.165)],.002,"paint_rescue_red",.0002,y=.060)
    tube("Blanket pictogram outline",[(-.056,.061,.175),(-.066,.061,.225),(0,.061,.247),(.066,.061,.225),(.056,.061,.175)],.003,"paint_rescue_red")
    for x in [-.065,.065]:
        cube("Pull tab",(x,.026,.035),(.027,.005,.09),"webbing_black",.002)
        cube("Pull tab bright stitch",(x,.029,.027),(.018,.002,.009),"label_ivory",.001)
    G.text_label("TIRER",(0,.061,.105),.021,"label_ivory")
    for x in [-.12,.12]:
        screw(x,.057,.37,radius=.003)


def folding_cot():
    for x in [-.365,.365]:
        rod("Long cot frame rail",(x,-1.0,.43),(x,1.0,.43),.019,"steel_brushed")
        for y in [-.95,.95]:
            cylinder("Rail end cap",(x,y,.43),.021,.10,"rubber_black",(0,1,0),24)
    for y in [-.94,.94]:
        rod("Cot frame end brace",(-.35,y,.43),(.35,y,.43),.015,"steel_dark")
    for y in [-.65,.65]:
        for side in [-1,1]:
            rod("Folding cross leg",(side*.30,y,.04),(-side*.31,y,.425),.014,"steel_brushed")
            cube("Non-marking cot foot",(side*.30,y,.027),(.075,.070,.05),"rubber_black",.009)
        cylinder("Cross-leg pivot",(0,y,.233),.024,.044,"steel_dark",(0,1,0),24)
        screw(0,y+.025,.233,radius=.008)
    # Subtly sagged canvas, tensioned at the side rails.
    verts,faces=[],[]
    for j in range(7):
        y=-.91+j*.30333
        for i in range(9):
            x=-.345+i*.08625
            z=.445-.024*math.sin(i*PI/8)*math.sin(j*PI/6)
            verts.append((x,y,z))
    for j in range(6):
        for i in range(8):
            k=j*9+i
            faces.append((k,k+1,k+10,k+9))
    canvas=mesh("Tensioned canvas sleeping surface",verts,faces,"canvas_refuge",smooth=True)
    solid=canvas.modifiers.new("Canvas real thickness","SOLIDIFY")
    solid.thickness=.008
    for x in [-.345,.345]:
        tube("Canvas sewn edge",[(x,-.91,.449),(x,0,.449),(x,.91,.449)],.006,"canvas_refuge")
    cube("Cot head pillow",(0,.69,.49),(.55,.31,.085),"fabric_pillow",.034)
    for y in [-.70,.1,.65]:
        for x in [-.355,.355]:
            cube("Canvas attachment webbing",(x,y,.45),(.058,.040,.012),"webbing_black",.003)
    cube("Folded blanket on cot",(0,-.58,.48),(.56,.40,.055),"fabric_teal",.014)
    for y in [-.72,-.69,-.66]:
        cube("Folded blanket seam",(0,y,.51),(.54,.003,.003),"canvas_refuge",.0008)


def water_canister():
    cube("Moulded water canister",(0,0,.205),(.285,.215,.36),"water_blue",.038)
    cube("Canister reinforced base",(0,0,.045),(.286,.216,.065),"water_blue",.018)
    # Hollow carry bridge with negative space below, not a solid box handle.
    tube("Integrated hollow carry handle",[(-.080,0,.365),(-.080,0,.422),(-.052,0,.444),(.052,0,.444),(.080,0,.422),(.080,0,.365)],.018,"water_blue")
    cylinder("Filler neck",(.085,.045,.382),.041,.045,"water_blue",vertices=32)
    cylinder("Screw filler cap",(.085,.045,.414),.047,.030,"ceramic_ivory",vertices=24)
    for i in range(16):
        a=i*2*PI/16
        cube("Cap gripping rib",(.085+.046*math.cos(a),.045+.046*math.sin(a),.413),(.007,.007,.025),"ceramic_ivory",.001,(0,0,a))
    cube("Water marking panel",(0,.110,.218),(.175,.003,.17),"label_ivory",.008)
    G.text_label("EAU",(0,.114,.248),.040,"blue_key")
    G.text_label("10 L",(0,.114,.195),.030,"blue_key")
    for x in [-.118,.118]:
        cube("Moulded vertical strength rib",(x,-.105,.212),(.022,.015,.25),"water_blue",.007)
    cylinder("Canister dispensing tap mount",(0,.119,.079),.026,.035,"ceramic_ivory",(0,1,0),28)
    cylinder("Quarter turn water spout",(0,.15,.066),.013,.04,"ceramic_ivory",vertices=24)
    cube("Tap blue paddle",(0,.15,.105),(.055,.019,.012),"blue_key",.005)


def privacy_screen():
    # Three linked panels, staggered feet; fabric has genuine pleated geometry.
    for panel,x in enumerate([-.62,0,.62]):
        for side in [-1,1]:
            xx=x+side*.295
            rod("Screen vertical tubular upright",(xx,0,.16),(xx,0,1.73),.014,"steel_brushed")
        for z in [.27,1.73]:
            rod("Screen horizontal frame",(x-.295,0,z),(x+.295,0,z),.014,"steel_brushed")
        verts,faces=[],[]
        columns=24
        for z in [.30,1.69]:
            for i in range(columns+1):
                xx=x-.27+i*.54/columns
                yy=.014*math.cos(i*PI/2)
                verts.append((xx,yy,z))
        for i in range(columns):
            faces.append((i,i+1,i+columns+2,i+columns+1))
        cloth=mesh("Pleated privacy curtain",verts,faces,"curtain_pale",smooth=True)
        shell=cloth.modifiers.new("Curtain cloth thickness","SOLIDIFY")
        shell.thickness=.002
        for i in range(6):
            xx=x-.23+i*.092
            torus("Curtain suspension ring",(xx,0,1.72),.021,.0025,"steel_dark",(1,0,0),20)
        # Feet are centred under each panel with an explicit forward/back spread.
        rod("Screen T-foot stem",(x,0,.05),(x,0,.27),.014,"steel_brushed")
        rod("Screen stability crossbar",(x,-.23,.06),(x,.23,.06),.014,"steel_brushed")
        for y in [-.21,.21]:
            caster(x,y,.027)
    for x in [-.31,.31]:
        for z in [.49,1.48]:
            cylinder("Panel connecting hinge",(x,0,z),.020,.07,"steel_dark",vertices=24)
            screw(x,.022,z,radius=.006)


SPECS = [
    ("retail_display_case", "Vitrine de boutique", retail_display_case, (0,0,.60)),
    ("cash_register", "Caisse et terminal de paiement", cash_register, (0,0,.15)),
    ("shutter_control", "Commande de rideau de service", shutter_control, (0,0,.14)),
    ("service_trolley", "Chariot de service inox", service_trolley, (0,0,.96)),
    ("industrial_sink", "Plonge de cuisine et robinet", industrial_sink, (0,0,.90)),
    ("kitchen_stove", "Fourneau professionnel", kitchen_stove, (0,0,.68)),
    ("extraction_hood", "Hotte et filtres d'extraction", extraction_hood, (0,0,.03)),
    ("utility_cutoff_panel", "Coffret de coupure A21", utility_cutoff_panel, (0,0,.29)),
    ("fire_blanket_cabinet", "Armoire de couverture anti-feu", fire_blanket_cabinet, (0,0,.04)),
    ("folding_cot", "Lit pliant de refuge", folding_cot, (0,0,.43)),
    ("water_canister", "Jerrican d'eau 10 litres", water_canister, (0,0,.44)),
    ("privacy_screen", "Paravent de secours trois panneaux", privacy_screen, (0,0,1.73)),
]


def exact_mesh_bounds(asset):
    """Use real vertices; transformed bounding-box corners overestimate angled parts."""
    bpy.context.view_layer.update()
    points=[obj.matrix_world@vertex.co for obj in asset["parts"] for vertex in obj.data.vertices]
    return Vector(tuple(min(p[i] for p in points) for i in range(3))), Vector(tuple(max(p[i] for p in points) for i in range(3)))


def finalize_asset(asset):
    G.finalize_asset(asset)
    lo,hi=exact_mesh_bounds(asset)
    offset=Vector(((lo.x+hi.x)/2,(lo.y+hi.y)/2,lo.z))
    for obj in asset["parts"]:
        obj.location-=offset
    old_grip=asset["grip_godot"]
    asset["grip_godot"]=(old_grip[0]-offset.x,old_grip[1]-offset.z,old_grip[2]+offset.y)
    asset["root"]["grip_godot_m"]=list(asset["grip_godot"])
    lo,hi=exact_mesh_bounds(asset)
    size=hi-lo
    asset["dimensions_godot"]=(size.x,size.z,size.y)
    asset["dimensions_source"]=tuple(size)


def write_catalog(records, path):
    G.write_catalog(records, path)
    text = path.read_text(encoding="utf-8")
    replacements = {
        "tools/generate_rescue_models.py": "tools/generate_commerce_models.py",
        "rescue_v011/": "commerce_v012/",
        "Rescue model": "Commerce model",
        "RescueAsset_": "CommerceAsset_",
        '"rescue_asset_id"': '"commerce_asset_id"',
    }
    for old,new in replacements.items():
        text=text.replace(old,new)
    path.write_text(text,encoding="utf-8")


def render_previews(directory, camera):
    scene=bpy.context.scene
    scene.cycles.samples=40
    paths=[]
    for asset in G.ASSETS:
        for other in G.ASSETS:
            other["collection"].hide_render = other is not asset
            other["root"].location=(0,0,0)
        lo,hi=G.bounds(asset)
        direction=(.9,1.6,1.1)
        if asset["id"]=="extraction_hood":
            direction=(.9,1.6,-.9)
        G.point_camera(camera,(lo+hi)/2,1,direction)
        bpy.context.view_layer.update()
        view=camera.matrix_world.inverted()
        points=[view@(obj.matrix_world@Vector(c)) for obj in asset["parts"] for c in obj.bound_box]
        width=max(p.x for p in points)-min(p.x for p in points)
        height=max(p.y for p in points)-min(p.y for p in points)
        camera.data.ortho_scale=max(width,height*1.25)*1.18
        scene.render.resolution_x,scene.render.resolution_y=750,600
        scene.render.filepath=str(directory/f"commerce_{asset['id']}.png")
        # For the underside view the display floor would hide the object.
        bpy.data.objects["Studio floor - never exported"].hide_render = asset["id"]=="extraction_hood"
        bpy.ops.render.render(write_still=True)
        paths.append(scene.render.filepath)
        print("PREVIEW "+asset["id"],flush=True)
    return paths


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--root",type=Path,default=Path(__file__).resolve().parents[1])
    parser.add_argument("--render",action="store_true")
    args=parser.parse_args(sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else [])
    root=args.root.resolve()
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for collection in list(bpy.data.collections):
        if collection.name!="Collection":
            bpy.data.collections.remove(collection)
    scene=bpy.context.scene
    scene.unit_settings.system,scene.unit_settings.scale_length,scene.unit_settings.length_unit="METRIC",1.0,"METERS"
    setup_materials()
    model_dir=root/"prototype/assets/models/commerce_v012"
    source_dir=root/"docs/assets/v0.12"
    preview_dir=source_dir/"previews"
    for directory in [model_dir,source_dir,preview_dir]:
        directory.mkdir(parents=True,exist_ok=True)
    records=[]
    for asset_id,label,builder,grip in SPECS:
        collection=bpy.data.collections.new(asset_id)
        scene.collection.children.link(collection)
        obj=bpy.data.objects.new(asset_id,None)
        collection.objects.link(obj)
        obj.empty_display_size=.08
        G.ACTIVE={"id":asset_id,"label":label,"collection":collection,"root":obj,"parts":[],"grip":grip}
        G.PART_INDEX=0
        builder()
        finalize_asset(G.ACTIVE)
        row=G.export_asset(G.ACTIVE,model_dir)
        row["path"]=f"res://assets/models/commerce_v012/{asset_id}.glb"
        # UVs are independently projected per mesh; no baking claim across parts.
        row["uv"]="Smart-projected UVs per named source mesh; material textures use object coordinates."
        records.append(row)
        G.ASSETS.append(G.ACTIVE)
        print(f"ASSET {asset_id}: {row['triangles']} triangles, {row['bytes']} bytes",flush=True)
    write_catalog(records,root/"prototype/scripts/commerce_asset_catalog.gd")
    camera=G.setup_studio()
    for index,asset in enumerate(G.ASSETS):
        asset["root"].location=((index%4-1.5)*2.3,(index//4-1)*2.8,0)
        asset["collection"].hide_render=False
    G.point_camera(camera,(0,0,.7),12,(1.1,1.6,1.9))
    scene.render.resolution_x,scene.render.resolution_y=1600,1000
    G.deselect()
    for asset in G.ASSETS:
        asset["root"].select_set(True)
    bpy.context.view_layer.objects.active=G.ASSETS[0]["root"]
    for screen in bpy.data.screens:
        for area in screen.areas:
            if area.type=="VIEW_3D":
                area.spaces.active.region_3d.view_distance=12
                area.spaces.active.region_3d.view_location=Vector((0,0,.7))
    bpy.context.preferences.filepaths.save_version=0
    source_path=source_dir/"commerce_equipment.blend"
    bpy.ops.wm.save_as_mainfile(filepath=str(source_path),compress=True)
    manifest={
        "schema_version":1,"library":"The Tower Descent commerce/kitchen/refuge v0.12",
        "generator":"tools/generate_commerce_models.py","blender_version":bpy.app.version_string,
        "units":"metres","source_axes":{"up":"+Z","front":"+Y","right":"+X"},
        "runtime_axes":{"up":"+Y","front":"-Z","right":"+X"},
        "source":{"path":"docs/assets/v0.12/commerce_equipment.blend","bytes":source_path.stat().st_size,
                  "sha256":hashlib.sha256(source_path.read_bytes()).hexdigest()},
        "authoring":"Original deterministic editable Blender geometry; shared v0.11 geometry/export helpers; no external models.",
        "uv_convention":"Smart projection per source mesh; tiling shared albedos use object coordinates in Godot.",
        "limitations":["Static meshes: no rig, LOD or articulated animation.",
                        "Collisions and gameplay interactions are authored by scene integration, not embedded.",
                        "Display-case glazing uses alpha blending; shadows/reflections vary by renderer.",
                        "Material roughness and metalness are authored scalar settings, not measured material scans."],
        "assets":records,"total_glb_bytes":sum(r["bytes"] for r in records),
        "total_triangles":sum(r["triangles"] for r in records),
    }
    (model_dir/"manifest.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    if args.render:
        render_previews(preview_dir,camera)
    print(f"DONE: {len(records)} GLBs, {manifest['total_glb_bytes']:,} bytes, {manifest['total_triangles']:,} triangles",flush=True)


if __name__=="__main__":
    main()
