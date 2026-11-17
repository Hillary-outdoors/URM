-- URMA · step 11 · Activities and their AMPs
-- Safe to run again. Paste the whole file into Supabase > SQL Editor and press Run.

begin;

insert into activities (name, centre_id, call_in_type, in_national_park)
select v.name, (select id from centres where name = v.centre), v.call_in, v.park
from (values
  ('AMP 1 ABL Low Ropes Course','Tongariro','None',false),
  ('AMP 2 ABL Local Initiatives (Tongariro)','Tongariro','None',false),
  ('AMP 2 Low ropes (Coromandel)','Coromandel','None',false),
  ('AMP 3 Pool Tyrolean','Tongariro','None',false),
  ('AMP 4 ABL Flying Fox','Tongariro','None',false),
  ('AMP 10 XL SUP','Coromandel','Water',false),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)','Tongariro','Mountain',true),
  ('AMP 11 level 1-2 Sea Kayaking Coromandel (Coromandel)','Coromandel','Water',false),
  ('AMP 12 Alpine Winter General (Tongariro)','Tongariro','Mountain',true),
  ('AMP 12 Level 3-4 Sea Kayaking Coromandel (Coromandel)','Coromandel','Water',false),
  ('AMP 13 Surf Sports Waikawau Bay','Coromandel','Water',false),
  ('AMP 14 Alpine Snow Sports Day','Tongariro','Mountain',true),
  ('AMP 15 Alpine Camping Above Bush Line','Tongariro','Mountain',true),
  ('AMP 16 Surfing','Coromandel','Water',false),
  ('AMP 17 Alpine Grade 2 Mountaineering','Tongariro','Mountain',true),
  ('AMP 18 Alpine Skills and Tertiary','Tongariro','Mountain',true),
  ('AMP 21 Bush Local Bush (Tongariro)','Tongariro','None',false),
  ('AMP 21 Coasteering Little bay to Waikawau (Coromandel)','Coromandel','Water',false),
  ('AMP 22 Bush River Travel (Tongariro)','Tongariro','Water',false),
  ('AMP 22 Snorkeling (Coromandel)','Coromandel','Water',false),
  ('AMP 23 Bush craft (Tongariro)','Tongariro','None',false),
  ('AMP 23 Sit on top kayak (Coromandel)','Coromandel','Water',false),
  ('AMP 25 Bush Solo Overnight (Tongariro)','Tongariro','None',false),
  ('AMP 25 Coasteering Rowner Bay (Coromandel)','Coromandel','Water',false),
  ('AMP 26 Coasteering Otautu Bay (Coromandel)','Coromandel','Water',false),
  ('AMP 26 Puerora Tramping (Tongariro)','Tongariro','None',false),
  ('AMP 27 Bush Overnight Camping (Tongariro)','Tongariro','None',false),
  ('AMP 27 Waka Taurua (Coromandel)','Coromandel','Water',false),
  ('AMP 28 Advanced Snorkel','Coromandel','Water',false),
  ('AMP 29 Coasteering -Black Rock','Coromandel','Water',false),
  ('AMP 30 Local Bush','Coromandel','None',false),
  ('AMP 31 Cave Okupata Cave (Tongariro)','Tongariro','Cave',false),
  ('AMP 31 Orienteering (Coromandel)','Coromandel','None',false),
  ('AMP 32 Bush Overnight camping (Coromandel)','Coromandel','None',false),
  ('AMP 32 Cave Pukehinau Cave (Tongariro)','Tongariro','Cave',false),
  ('AMP 33 Bush Long Programme Camping','Coromandel','None',false),
  ('AMP 40 Rock Tangiaro Abseil','Coromandel','None',false),
  ('AMP 41 Rock Whakapapa Area Crags','Tongariro','None',true),
  ('AMP 42 Rock Lower Rock Wall','Tongariro','None',false),
  ('AMP 43 Rock Meads Wall Traverse','Tongariro','Mountain',true),
  ('AMP 44 Rock Meads Wall Loop','Tongariro','Mountain',true),
  ('AMP 45 Rock Mangatepopo Area Crags','Tongariro','None',true),
  ('AMP 46 Rock Self-directed Abseil','Tongariro','None',false),
  ('AMP 47 Rock Taranaki Falls Abseil','Tongariro','None',true),
  ('AMP 48 Rock Pukehinau Abseil','Tongariro','None',false),
  ('AMP 50 Rock High Ropes Course','Tongariro','None',false),
  ('AMP 51 Rock Indoor Climbing Walls (Tongariro)','Tongariro','None',false),
  ('AMP 51 Rock Waitomo Crags (Tertiary)','Tongariro','None',false),
  ('AMP 52 Rock South Waikato Crags','Tongariro','None',false),
  ('AMP 54 Rock Kawakawa Bay Crag','Tongariro','None',false),
  ('AMP 55 Rock Kinloch 1.2 Crag','Tongariro','None',false),
  ('AMP 56 Rock Dunedin Crags','Tongariro','None',false),
  ('AMP 57 Rock Timaru Crags','Tongariro','None',false),
  ('AMP 58 Rock Sebastopol Bluffs','Tongariro','None',false),
  ('AMP 59 Rock Tukino','Tongariro','Mountain',true),
  ('AMP 61 Water Lake Otamangakau Water Activities','Tongariro','Water',false),
  ('AMP 62 Water Lake Taupo Activities','Tongariro','Water',false),
  ('AMP 63 Water Kayaking G2-3 Tarawera Slalom site','Tongariro','Water',false),
  ('AMP 64 Tongariro River - SOT, Inflatable','Tongariro','Water',false),
  ('AMP 65 Water Tongariro River Delta','Tongariro','Water',false),
  ('AMP 66 Water Kayaking G2 Aniwhenua','Tongariro','Water',false),
  ('AMP 68 Water Canoe G2 Tongariro (Tongariro)','Tongariro','Water',false),
  ('AMP 68 Water Kayaking G4 Kaituna (Tertiary)','Tongariro','Water',false),
  ('AMP 69 Water Kayaking Mohaka G2','Tongariro','Water',false),
  ('AMP 71 Water Tawhai Falls Jump','Tongariro','Water',true),
  ('AMP 72 Water Whanganui River Travel','Tongariro','Water',false),
  ('AMP 73 Water Kayak Piriaka','Tongariro','Water',false),
  ('AMP 74 Water Kayaking Waikato Reids Farm','Tongariro','Water',false),
  ('AMP 75 Water Pukehinau Stream Travel','Tongariro','Water',false),
  ('AMP 76 Water Kayaking Murchison G2-3','Tongariro','Water',false),
  ('AMP 77 Water Upper Mangatepopo Steep Creek Trip','Tongariro','Water',true),
  ('AMP 79 Water River rescue Grade 2 Tongariro','Tongariro','Water',false),
  ('AMP 81 COR Support Boats','Coromandel','Water',false),
  ('AMP 82 Driving (Coromandel)','Coromandel','None',false),
  ('AMP 82 Other Swimming Pool (Tongariro)','Tongariro','None',false),
  ('AMP 83 Other Competitive Events','Tongariro','None',false),
  ('AMP 87 Supervising Instruction Events','Tongariro','None',false),
  ('AMP Bush Tertiary','Tongariro','None',false),
  ('AMP Rock Wharepapa South','Tongariro','None',false),
  ('AMP Tertiary Snow Sports','Tongariro','Mountain',true)
) as v(name, centre, call_in, park)
on conflict (name) do nothing;

insert into amps (act_id, folder, activity_number, title, activity_description, location, camping, toilets, water, emergency_response, access_permission, instructor_requirements, client_competencies, specific_equipment, specific_policies, other_resources, key_hazards, previous_incidents, version, change_summary, updated_by)
select a.id, v.folder, v.num, v.title, v.activity_description, v.location, v.camping, v.toilets, v.water, v.emergency_response, v.access_permission, v.instructor_requirements, v.client_competencies, v.specific_equipment, v.specific_policies, v.other_resources, v.key_hazards, v.previous_incidents, 1, v.summ, v.by
from (values
  ('AMP 1 ABL Low Ropes Course','ABL · Tongariro','1','Low Ropes Courses','Initiatives within the Tawhitikuri Low ropes and Taurewa Initiatives areas.','Tawhitikuri and Taurewa sites','Local','YDC, OLS or TL','HR shed,
YDC or Lodge','Refer Instructor Handbook and CMS Tongariro','No','L1 competencies or DM approval','No Prerequisites','Ropes etc available in HR shed.','T1 Fundamental and T2 Handbook',null,null,'Fall backwards off element potentially injuring neck (2013), Head injury to spotter from not falling properly on trust fall (2011) Fractured finger from hand slipping down Prouty’s rope to knot (2023) Fractured arm falling off Birthday log (2025)','Loaded from the Word file · approved 11/5/2026 by Lee Vaughan, Centre Manager','G.Swift'),
  ('AMP 2 ABL Local Initiatives (Tongariro)','ABL · Tongariro','2','Local Initiative Activities','Activities within the local area including: Electric Fence, Alcatraz, Urban Caving, Tree Climbing, Orienteering, Crate Crossing, Spiders Web and Swamp activities','Tawhitikuri Site','Local','YDC or MOW','YDC or MOW','Refer Instructor Handbook and CMS Tongariro','no','L1 competencies, DM approval,','No Prerequisites','Helmets, refer to activity below. Bog Planks stored in resource Centre','T1 Fundamental and T2 Handbook','Other activities exist not listed above. This AMP cover them also, refer General section at bottom.
TREE CLIMB NO LONGER USED AS DEEMED UNSAFE WITH LIMB DAMAGE ON TREE',null,'Participant dislocated knee (orienteering), Students ignored instructors ended up on Jo’s cave track (orienteering), Student tripped while carrying metal grate, crushed several fingers (urban cave 2012), Participants dropped (electric fence & spiders web), Participant fell from top and was caught by instructor (Alcatraz 2012). Broken Ankle while being lowered Alcatraz (2025)','Loaded from the Word file · approved 11/5/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 2 Low ropes (Coromandel)','Coromandel · Coromandel','2','Low ropes',null,null,null,'Main Lodge',null,null,'Nil land','AblIM 1 competency','Nil','Specific Policies T1 Fundamental and T2 Handbookx','T1 Fundamental and T2 Handbookx','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

A LS.
Activity Management Plan- Tier 3 HILLARY
OUTDOORS
Activity 2 Low ropes teste
Activity Team building Initiatives involving height below NA Water Main Toilets Main Lodge
Description 2 meters Lodge
Emergency Refer Instructor handbook and Emergency Access Permission Nil land
Response Response system Required? HH own Tan
ee Instructor requirements | AblIM 1 competency
vacuations maps
Specific
Equipment Specific Policies T1 Fundamental and T2 Handbookx
Required
Other resources Nil Client Competencies Nil
and notes
Key Hazards 5 22
Height Social
From tng fall backwards off element potentially injuring neck 2013, Alcatraz student fell off top breaking leg 2024
Previous Incidents
Safety Management
cose [ered *dMinagementststegy
Spiders web — Minimum 2 lifters per side when lifting above waist height
Falling from height Group wall — No more than 4 people on platform, Spotters required when lifting students over, Students
not to sit on top of wall
Injury when lifting When lifting students 2 people minimum
Open hands vs interlocking fingers when lifting
Emotional trauma Ensure all clients are comfortable with being lifted and assisted
Approved Hayden Devine Centre a 5 ~ 7
ar y Manager Date 05/05/2026 Review in 1 year From date of approval
piofi A

','5 22','Safety Management','Read from a scan of the paper copy','Data import'),
  ('AMP 3 Pool Tyrolean','Pool tyrolean · Tongariro','3','Pool Tyrolean','Team Tyrolean activity over pool','Pool Tongariro Main site','-','Yes','Yes','See CMS','no','Risk Mgmt, Group Mgmt, Core competency (L1)
Activity familiarisation','None','Pool tyrolean equipment-stored in RC under stairs
Pool tyrolean equipment-stored in RC under stairs','Tier 2-Rope','Refer Swimming Pool AMP',null,'Fingers caught in pulley 
Finger injury while re-tensioning rope and team pulled unexpectedly','Loaded from the Word file · approved 11/5/2026 by Lee Vaughan,
Centre Manager','Data import'),
  ('AMP 4 ABL Flying Fox','ABL · Tongariro','4','Zip-lines','Flying-Fox','M.O.W. Site','MOW','MOW','MOW','Refer Instructor Handbook and CMS Tongariro. 
 - There is a specific system and equipment for rescue on the Flying Fox. Refer pg. 3 of this AMP','No',null,null,'Available in Shed at MOW','Worksafe NZ require 2 points of connection between the cable and the client',null,null,'2005 - Flying Fox near miss – retrieval rope thrown into air got wrapped around the neck of student on flying fox
2011 – Hillary Challenge , Participant unclipped from pulley (as activity required) in wrong order and fell to ground injuring ankle
2013 – Retrieval rope got tangled amongst rocks in river while performing rescue scenario.
1980s – Student used without supervision, held onto flying fox and landed in bushes on far side of stream.
1990s – Student not properly attached to lanyard. Landed in bushes on far side of road.','Loaded from the Word file by Lee Vaughan, Centre Manager','G Swift'),
  ('AMP 10 XL SUP','Coromandel · Coromandel','10','XL SUP',null,'Level 1se2 kayak area, Watkawau estuary necked oy 6 Switt','campsites Toilets beach','beach',null,null,'Response Plan Required?','SUP famil plus risk management','Acquire swim ability',null,'PFD required','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

A LOX.
ivi - HILLARY
Activity Management Plan ouTpoors
Water
40. XL SUP Location | Level 1se2 kayak area, Watkawau estuary necked oy 6 Switt
Activity 10 person inflatable stand-up paddle boarding . Doc | Doc campsites, Big Sandy
Description for small journeys and ABL Camping campsites Toilets beach
Emergency _| Refer Instructor Handbook and Crisis Management Access Permission
Response Plan Required?
Hazard
Evacuations Refer Tsuanami Safe Zones attached Instructor requirements SUP famil plus risk management
maps
Specific Fouow ter? instructor on thet table wat Wind below 15knots
Equipment —__—— loniiheifown|sultableiwater Specific Policies PFD required
Required Pump Instructor to be on separate watercraft if journeying
Other " A r
FOCGEECE am] Client Competencies Acquire swim ability
notes
| GED ay
Ey & GR *). Re
Key Hazards = i SS 6 / Va
Extreme Weather i . ie
Deepwater Movingwater Soci Yempershore Tame!
Previous Loss of paddles. Injuries from falling onto each other.
Incidents Hand and wrist injuries from falling. Damage to SUP
Safety Management
_— . Must be below 15knots at activity site, risk of SUP being blown away above this
Minimise | Wind
Plan trip around wind direction
Damage to SUP Keep SUP away from sharp objects
Store out of direct sunlight and deflate slightly
Injury from equipment Brief students on correct use of paddles
At least 4 people to carry SUP
[ Minimise | Tide in estuary Plan trip around tide times
piof3 A

AMP Loe
Activity Management Plan- HILLARY
ence Hayden Devine, Centre Manager | Date 23/02/2026 | Reviewin 1 year From date of approval Signed WC -
fay) nae NN
# a OT FF are ees, (I
ie, . SS _| Rae ey ee ge || |
= Yom ” Se eh ere at, ee eh |
ian or ; > | We ee ee) | \
sal mo) : ns au SRS ace CEES | aan
MOE Se Te WS ae eee
i EARS CS real \ te 2 NR i cee
Pid ee, Vm ee ara | eee EN ae fee
oye Se Ui \ Teg: eo ms oo ee Tag | trai wae
BAG 2B SS Re A x Ra”) a A AN
RS ae x ee FpSRAZY % | \— A NET AL ar BE DOT
Td Seman > en a oe
Vee Lo) le Ee f‘) Mah etd iy < ae SN RA: V/s _
f Lids <a.t i ot i fe be ea LM : Bae siya ae PN
(or pat Por ete. DS oo I a SOA A
OR RSS ER Ee eG RS erie N\A La ere
Les) eg BREA) Se rar SSIS ARS ONG hE sae ee ke eee
wep PAM UME uA ch en A NR ON are ee
Ray fice Ge Bethe oe —g Fas SAD) oe ra Sar a Oe
Las 46.2 (FC GE PA Re Car aR \ NSS es oS aR el ae
BELA fai RS ani —— , ,
mee — AMM” BST IPs ee ee
p2of3 AMP

AMP VN
Activity Management Plan- aL ol
se N ep [= —_ : :
a = oe me aan |e Ey \
a Ta = || aes
Ce aa is sR
ST oN || ee
x } ey —s ee adil
Le es hep Se
7 ¢ BRS - a ?
p3of3 AMP

','= i SS 6 / Va',null,'Read from a scan of the paper copy','Data import'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)','Alpine · Tongariro','11','Alpine Scrambling
in summer conditions','Extended hikes on rugged terrain above bush line where snow is not normally encountered','Tongariro National Park','None','Iwikau, Mangatepopo road end and hut','Minimal- Carry, Boil or treat','Refer Instructor Handbook and CMS Tongariro.','DOC concession required','L1, L2 Summer Mountain Comp and DM approval 
NZOIA Alpine 1 and DM approval','Basic fitness','Refer to instructor handbook','T1 Fundamental and T2 Handbook','Areas of exposure to weather and steep terrain with many short scrambles
Many adventures possible without summiting
Long climbs with no water',null,'Fall into Red crater from track Rock-fall on Ngauruhoe caused by public Fall on ice from near ridge to Dome on Ruapehu causing fatality (1987) Student lost control on descent of Ngauruhoe. Lacerated hip and 10cm deep laceration. Heli evac. (2012)','Loaded from the Word file · approved 11/5/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 11 level 1-2 Sea Kayaking Coromandel (Coromandel)','Coromandel · Coromandel','11','level 1-2 Sea Kayaking Coromandel',null,'Port Charles, Stony bay, Waikawau bay, Colville Bay eveted bsy 6 swift','Waikawau Bay DOC otherwise limited Toilets At DOC Camps,','At DOC Camps,',null,null,'Required? for further information','Conditions petency petency Req -','Teacher ability to be obtained before being deemed competent, can be done at start',null,'Required Ratios are with an instructor in single kayak, if instructor is in a double then 1:6','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

A LOX.
ivi - Ti HILLARY
Activity Management Plan- Tier 3 brriaietis
ee Level 1-2 Sea kayaking Coromandel Location Port Charles, Stony bay, Waikawau bay, Colville Bay eveted bsy 6 swift
Sea kayaking in decked sea kayaks,
7 single or multi-day trips in daylight _ Stony bay, DOC Camps,
peeivity hours-Where paddlers are no more Camping Waikawau Bay DOC otherwise limited Toilets At DOC Camps,
escription | oom fom sh d strength < Camps, Potiki bay aust be carried LNT -poo tube
an 200m from shore, wind streng} toad Reserve .
15Kn
Lots of private land blocks mixed with Doc reserve- See Outdoor access maps
Emergency | Refer Instructor Handbook and Crisis Access Permission Required? for further information
Response Management Plan.docx 4 Qutdoor access maps_
Hazard Refer Tsuanami Safe Zones Sea Kayak Competency Level 1-2 refer Competency Requirements/Zones.
Evacuations attached Instructor requirements Conditions petency petency Req -
maps
Ratio: (Refer Competency Requirements/Zones map)
- Level 1: 1:6 boats -Swell less than 1m, wind less than 10Kn
1:5 Boats + 1 competent teacher -Swell up to 1.5m, wind up to
15kn
-Level 2: 1:5 boats + 1 competent teacher -Swell less than 1.5m, wind less
than 15Kn
1:6 boats Swell less than 1.5m, wind less than 15kn powered
support vessel must accompany or be readily available (readily available
Specific =Vessel on the water and with a skipper, though not necessarily with group)
Equipment _| Refer Instructor Handbook Specific Policies
Required Ratios are with an instructor in single kayak, if instructor is in a double then 1:6
ratio applies (e.g. 1 instructor with 6 kayaks in total on water including
instructor kayak)
If wind is over 15kn then a powered support vessel must accompany. Ratio no
greater than 1:5 boats, Surf no more than 0.5m
(Note above ratios are for on water conditions not forecasted if conditions
change ratios may change, likely support boat will be required)
Nowcast Weather channel 19/20 Wet exit skills demonstrated on land
Trip reports when east of Port Jackson Swim ability attained beforehand
Other and Ship to shore Channel 60 Client Competencies Teacher ability to be obtained before being deemed competent, can be done at start
resources and | [Tip reports or ship to shore when on Ps of session eg in big sandy bay demonstrating control of boat, how to launch and land
motes Western Side Channel 64 , ;
etc or can be done by support boat accompanying group till competency is
Southerly swell generally results in good axarntrl
sea state
North East swells can result in rough sea
pilof6é A

A VIAN
Activity Management Plan- Tier 3 HI LLARY
Fr DD
Key Hazards v ——— = i)
ExtremeWeather Moving Water pernote ROCKIICe all Sociol quam) Deepwater
Capsize due to swell and wind, Damage and loss of equipment due to rocky shore, Group separating, Oyster cuts, Encounters with marine creatures, Severe sea sickness
Previous Kayaks breaking during trip
Incidents:
(From GBI)
Safety Management
Avoid channels in strong winds, maintain awareness of wind vs tide and select route accordingly. Instructor to position themselves between
participants and danger. Consider calling a support boat to shadow if the groups is struggling and/or can be blown into hazard.
Strong winds from any offshore direction can dump down on top of groups at 30knts plus.
If high level winds are 20 knots or over, stay off water.
This is seen in strong SW winds around the Port Charles and little Sandy areas
Minimal shelter from SW wind at Waikawau Bay
Rea) Monitor, ensure plenty of fluids to avoid dehydration, tow kayak to get to calm water faster. Paddle further away from cliffs to reduce clapitus (messy
PPE. | Rough water causing sea sickness chop)
Consider advising sea sickness tablets
Consider position of maximum effectiveness. Establish non-verbal comms with group and signals and reducing number of boats landing at any one
time. Define waiting area (NOT in surf zone), Consider Helmets — Instructor to be ready to paddle back out as needed.
(tat / cut Consider using competent students to assist with landing
PPE Wiraesatevieniee ss) GlniesetecdaLersibigs Rudders to be pulled up to prevent damage.
Waikawau Bay use estuary or N end of Beach for less swell
Little Sandy ~ be aware of rocks N end -hidden at mid tide, hazard for landing kayaks and clients running along beach.
Potiki Bay has very large boulders exposed at low tide which are slippery and challenging to move boats on. Consider briefing prior to landing and
‘Admin | Awkward Landing at- Potiki Bay briefing the importance of footwear on and working as a team to move boats.
Instructor to consider landing first at position of maximum effectiveness.
Consider taking weight out of boats prior to moving if expeditioning and utilising lots of hands to move double boats
Clients to be wearing appropriate shoes if potential for capsize.
Rant Instructors to use judgement around suitability of feature and client skill level and if helmets are to be worn.
Rock Gardening / Caves Consider one student boat at time with a safe waiting area outside of the feature.
PPE
Consider paddling backwards into caves
Keeping attention to incoming swell and watch trend of waves in feature before entering.
‘Avoid commercial vessels in this area, and do not remove mussels from lines. Mussels can be harvested from large mussel buoys
‘Avoid cluttering boat ramp area Avoid areas when busy with other water/land traffic, consider alternative landing locations
Little Sandy Bay has a tight turn around area
Instructors to brief their group on paddling as a pod when in areas of increased boat users. Consider environmental conditions when around
anchored boats. To avoid damage.
p2of6 A

a
AMP Lor.
Activity Management Plan- Tier 3 HILLARY
Approve >
In , \
d by Hayden Devine, Centre Manager Date 43/11/2025 Review in 1 year From date of approval Signed NG 7
Pee

Competency Requirements/ Zones
p3of6 A Mi >

= oN
AMD ovement Plan- Tier 3 nitcaRy
Ha 7 | | | | | |
| Sn casper — | es ee ae = a oe
_* iy | Ped | |
(=, AN ar sce 7 Sa x | “
Ss He a 1 EE II pee
[Pe gee
SA ee. pee Ff{ | tt tt
BAS; DAs N Sica. mS | |
auth o- =n wee
PT VSN ee Taare 7a eee ees
Lie RO aera = wen Ne
mn Fc Ay ORR Redo og OR, a ay ) SA ww
\ a Ee ee
ie Pie! CAN T16~ ee e on pe. ei
| ene NAY Se I Se a erg i as Re HAS Sa
| Nee Efe re Ve ok aS
Wa! ae! te i MT | OLE ASA
eee fae goaded 3 a P
Love SOFAy me (= ~ LOS : G6 3 janealens +f Pani Ha) oo oa it fb s € Set p
N eee SS Sy aN Wedel eae Ay ors
NG 9/5 ee WE Pe ae OS ot MEN is ee as eee
NN pa et en
| |} nays ey iy Nd Le ey) ( ae as i ae 2] Rae vay < ag a . 4
| i co” WON oS Wor Seb
p4of6 AMP

Lor.
HILLARY
a oe
ivi it Plan- Tier 3 ASEPTIC Ne ene acces rey “ j
Activity Managemen Be SLC BNO aie = Re SD el | |
TSA (VG SEs At Pe ATARI y- alg |
al Re eee Nr ak Aes FS ioe SSA MIP eA } . |
in: WI Ae Sake Oise Hea
| murs Se a ss a Sod) VL Pa i sire PGA AW Woes (aN : “hs _| |
FINA. UE: Ae er aoe) ea ieee aly - ie Hel
| SE eG A Aaa lA \ Ve ae pee eat ue al Le
Ee | r NS Hi i ene . GIs Se Vd wy i Eola
eae Sze a See eye (uaa |
puere | \ Me eae pele Nabe wo | |
eal ae aaa 1s Bae a oN ) pe x <a ly =x T
S ASG), oN) PO ears ferry Sk Level: a Ves |
| | | ! S Soe ara ye fhe NN ee pean | |
| | | Ne Dei EE BAe adl: SN eS Eee
ies [BSTEEEEE | | YY PMN NCAAs Bay PIE ; |
| “DBE ka Cae US Ge er Ae | RC) RSENS | |
I | ft | | < Ge OF AN os J]
Nw By Se ENG pit a ee ad
es oS ENC ae ek SA
| | | ora (eaves jae He \ =e we On a ee. Hiss x Axes a
ae wd ON A ah Sato ee ae ARS
| | | | | == Se Ao BO aes at Sort.
icc 7 De ge RN NS RS CONIA SONS eae
TEL © Hee an) ERAN RAS ee
} | | | | | | 2) = Pe eee any y.. ae oof
eee ¢ a IE ee A 6? aan
= TN ia) Hod teas Ware NE ral Re A
See. for AE eae Del ee
= | |__i__1+__, \ Zo) Da ge y ay Sarees Po Seanea
eo NE 8 cot Sg er SOT ies
Fa | Ns TAGES ER hago) eA
LE - Sen G6? ae Glee | Ueda aS CM
—— Lawot toni hes a Aa en Wy
“We eS Se) PA pete Se NOL mia 2k
7 bas epee ee am |
| gi ree a Sa eer a ie a
NANA Th ES acre | |
a . s ant WY yO Ge eeu dey sna UN = a
stukawao ia ee
AMP
p5of6

DAMP vament Plan- Tier 3 ntSr
SEI nm igceND
Le me % ast 2 (a — |
i, ¢ me |
Fete ..
x 4 2 rN ail . ‘ ~
*, * ee on
a! ‘
/ 8
peor’ Amp

','v ——— = i)',null,'Read from a scan of the paper copy','Data import'),
  ('AMP 12 Alpine Winter General (Tongariro)','Alpine · Tongariro','12','Alpine – Winter','Day walks in a snow environment','Tongariro National Park','Refer Overnight AMP','None, LNT principles','Melt or carry','Refer Instructor Handbook and CMS Tongariro. Consider “Red” call above South Crater','Yes, DOC concession','Alpine Winter (L1)-areas with low angle terrain, low chance of sliding
Alpine Winter (L2),+ Steep ground Management terrain where a slide could occur','Basic fitness','Refer Tier 2 handbook Avalanche page for equipment to be carried','T1 Fundamental and T2 Handbook
Avalanche matrix T2-Uncontrolled avalanche terrain everyone to carry avalanche equipment (Transceiver, probe, shovel) -exceptions approved by ARM 6 on pre approved route or for specific route','www.avalanche.net.nz
Refer AMP15 Camping above the Bushline for map of poor communication areas.',null,'Fatal slide in rubber boots and PVC pants, Client hit by skier,','Loaded from the Word file · approved 10/8/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 12 Level 3-4 Sea Kayaking Coromandel (Coromandel)','Tier 3 · Coromandel','12','Level 3-4 Sea Kayaking Coromandel','Sea kayaking in decked sea kayaks, single or multi-day trips in daylight hours-','Northern Coromandel from Amodeo bay to Kennedy bay','Port Jackson, Fletchers Bay, Fantail bay, Stony bay, Waikawau Bay DOC Camps, Rauporoa Bay, Potiki bay road Reserve','At DOC Camps, LNT','DOC Camps, other wise limited- must be carried.','Refer Instructor Handbook and Emergency Response Plan','Lots of private land blocks mixed with Doc reserve- See Outdoor access maps for further information  
Outdoor access maps','Sea Kayak Competency Level 3-4 refer Competency Requirements/Zones.','Wet exit skills demonstrated on land 
Swim test recommended. 
Consider skills progression before entering more committing coastal locations','Refer Instructor Handbook','Refer Instructor Handbook for policies on equipment, methodology and environment 
Ratios (Refer Competency Requirements/Zones map)
Level 3- 1:5 boats Swell less than 1.0m and wind less than 10Kn
 1:4 boats Swell up to 1.5m and wind less than 15kn
 1:5 boats Swell up to 1.5m and wind less than 15Kn with pre trip planning and experience
Level 4- 1:4 boats Swell up to 1.5m
 1:5 Boats Swell less than 1m and wind less than 10Kn with pre trip planning and experience
 
Ratios are with an instructor in single kayak, if instructor is in a double, then powered support vessel must accompany 
If wind is over 15kn then a powered support vessel must accompany. Ratio no greater than 1:5 boats, Surf no more than 0.5m
Any other conditions and a powered support vessel must accompany or be readily available (readily available = Vessel on the water and with a skipper) while operating within a 1:5 ratio or less.','Nowcast Weather channel 19/20  
Trip reports when east of Port Jackson and Ship to shore Channel 60 
Trip reports or ship to shore when on Western Side Channel 64  
Southerly swell generally results in good sea state
North East swells can result in rough sea states.',null,null,'Loaded from the Word file · approved 7/5/2026 by Hayden Devine, Cormandel Centre Manager','Data import'),
  ('AMP 13 Surf Sports Waikawau Bay','Coromandel · Coromandel','13','Surf Sports Waikawau Bay',null,'36°35''57"S 175°31''39"E Updated by G Swift',null,'Sothern end of Campground',null,null,null,'L2 Surf Sports Competency','resources and * 1',null,'1:6 active participants 1.0-1.5m (ASWH)','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

A LS.
Pa . . . . . . . HILLARY
Activity Management Plan-SOT Surf kayaking, Boogie Boarding and Swimming at Waikawau beach. ourpoors
Water Sit on top surf Waikawau Bay
. . . . Location 36°35''57"S 175°31''39"E Updated by G Swift
13 Boogie boarding or swimming
ivi Single sit on tops in the surf i At
Acti g . P ial Waikawau Bay camp- Toilets Sothern end of Campground
Description Boogie Boarding or Swimming DOC Campground ground
EMmersenc Refer Instructor handbook and Crisis Management Aecoss Poussin
Re 9 y plan. Power boats can be launched at South end of A DOC Concession
esponse Beach Required?
Hazard
Evacuations Tsunami Evacuation Map Instructor requirements L2 Surf Sports Competency
maps
-Ratios:
Sit on tops:
1:8 active participants (8 Sit on tops) -0-0.5m average set wave height (ASWH)
1:6 active participants (6 Sit on tops)-0.5-1.0m (ASWH) may increase to 1:8 if
conditions in table below are met
1:6 active participants (6 sit on tops) 1.0m-1.5m (ASWH)
Boogie Boards;
ifi 1:10+2 active participants 0-1.0m (ASWH
Specific Refer Instructor handbook-+instructor towline and age wae , . a « i ( )
Equipment k . Specific Policies 1:6 active participants 1.0-1.5m (ASWH)
. arabiner
Required
Swimmiing
1:10+2 use instructor judgement with swimming capabilities for conditions.
Group under instructors'' guidance can be 1:10+2 but students, not active on sit
on tops/boogie boards, should be in a buddy role on shore.(not active in water)
oth Swim Ability Acquired
er Surf forecast: www.swellmap.com/surf-forecasts/new- Client Competencies
resources and * 1
EOS zealand/waikawau Recommended flatwater experience
(re, |e €P)
Key Hazards KX
Teunami Deepwater Sosed
Previous From GBI: Numerous people struck by kayak (some injuries significant) Trapped under kayak by bungies Caught in rips while swimming Head injury from own kayak resulting in needing
Incidents to be helped up to breathe
plof3 A

A or
Activity Management Plan-SOT Surf kayaking, Boogie Boarding and Swimming at Waikawau beach. HI L LARY
Safety Management
Surf kayaking must only be done in area set out by instructor. Have designated zones for paddling in and out
Strategies to avoid clumping: - keep group well-spaced, but so they can still hear instructions.
- in dumpy waves, or over 1m faces, consider ‘Inshore Buddies’ to keep an eye on paddlers
- participants to: * keep watch out to sea frequently
Being Struck by a kayak * think about who they might hit if they catch a wave
* call out person’s name if on collision course
- instructor to monitor and give lots of coaching, especially early in the session
See over for Ratios table
Tidal drag from estuary in/out flow Run session at least 200m from estuary outflow and monitor group drift. See map on reverse
Isolation from water-based motorised rescue Conservative decision making. Assistance from Hillary Outdoors boat but this would take a long time.
Instructor to only paddle SOT with thigh braces, or decked kayak
Rescue involves putting instructor into danger e.g. rips, surf Swimming rescue — consider taking a spare PFD to give to a person in the water (avoiding direct contact)
Do not remove your own PFD to swim out through the surf unless surf lifesaving trained fit and have appropriate rescue gear.
Blown away by offshore winds Offshore wind limit is 10 knots at water''s edge, or forecast of over 25 knots during that day
Cc >
ee Hayden Devine, Centre Manager Date 7/05/26 Review in 1 year From date of approval | Signed SX a
p2of3 A

Activity Management Plan-SOT Surf kayaking, Boogie Boarding and Swimming at Waikawau beach. HILLARY
Average Set Wave Height* Ratio (including teachers) —
Oto We geen
Reto — =
Start at 1:6 participants. May move to 1:8
—= when:
eS? - Students competent at controlled
surfing and avoiding collisions
~ Tide is slack or incoming
— - Forecast wind less than 10kn
- Measured period more than 10s
— wy, 7
1:6 participants
Over
No
* set = the groups of bigger waves.
98% of all waves will be smaller than ASWH
p3of3 AMP

','KX',null,'Read from a scan of the paper copy','Data import'),
  ('AMP 14 Alpine Snow Sports Day','Alpine · Tongariro','14','Snow Sports Day','Skiing and Snowboarding within the Mt Ruapehu Ski areas. Lessons and packages provided by Whakapapa Ski Area','Whakapapa and Turoa Ski fields','N/A','Cafes','Cafes','Refer Instructor Handbook and CMS','No','Level 1','None','Refer Tier 2 Handbook
Industry standard helmets must be worn (hire if necessary)','T1 Fundamental and T2 Handbook','Weather report and RAL snow report
Driving summer and winter AMP 
Ski I/C leave ph number on Intentions board',null,'24 Previous Incidents on Q drive (13 snowboard, 11 ski) most involve cold, sunburn, dehydration or broken bones. 1 major broken femur 2010','Loaded from the Word file · approved 03/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 15 Alpine Camping Above Bush Line','Alpine · Tongariro','15','Camping
above bush line','Camping above bush line','Various areas. (Map of common used areas) Tongariro
Various areas. (Map of common used areas) Tongariro','Yes, Refer Map','None, LNT principles','Boil or Treat','Refer Instructor Handbook and CMS Tongariro','Yes DOC concession','Alpine Summer (L1)','Basic Fitness','PLB and/or Inreach and Cell phone to be carried in areas EAST of red line on map. Radio should still be carried','T1 Fundamental and T2 Handbook','Wind whips through Tama lakes and the ground is very sandy.',null,'Hypothermia 
Destroyed tents','Loaded from the Word file · approved 4/9/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 16 Surfing','Coromandel · Coromandel','16','Surfing','Surfing on surfboards within 100m from shore Camping v Toilets | campgro At campground',null,'v Toilets | campgro At campground','campgro At campground',null,'Access Permission Required? | DOC concession','Required? | DOC concession','Surf rescue qualification 1, 1 suf sports','Swim ability acquired','i ios 1-! i ici','in the water helping.','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

A “i Activity Management Plan - (activity) Loe.
HILLARY
ourDoors
Surfing == ation Walkawau beach CECE) ah
Waikawau ba at
Activity Description | Surfing on surfboards within 100m from shore Camping v Toilets | campgro At campground
DOC campground
und
Refer Instructor handbook and Crisis Management plan.
Emergency Response Access Permission Required? | DOC concession
Caney Wap Power boats can be launched at South end of Beach q
Hazard/Evacuation A
Tsunami Evacuation Map Instructor requirements Surf rescue qualification 1, 1 suf sports
Client competencies | Swim ability acquired
Specific Equipment i ios 1-! i ici
Pp gulpry Refer instructor handbook Surfing ratios 1-5 surfers with no more than 5 participants
Required Specific Policies | in the water helping.
Other resources and .
Surf forecast - https://www.swellmap.com/surf-forecasts/new-zealand/waikawau
|=
Key Hazards g -
Tsunami Deepwater Soeed
Safety Management
15 knot limits if offshore may have to call session off earlier depending on swell.
Boards can be affected by winds on shore and in the water, make sure if boards are lying on the beach they won''t get blown around
by wind
Call off session if average wave height is above 0.7m, Waves are smaller down the eastern end of the beach
Surfing must only be done in designated area set out by instructors’ leashes must be used at all times
Participants to:
- Stay well-spaced and away from other groups and swimmers
- keep watch out to sea frequently
- Think about who they might hit if they catch a wave
- Callout person''s name if on collision course
- Brief on handling board when walking through swell, to avoid board catching a wave and hitting the participant.
Instructor to monitor session and give lots of coaching especially early in session
Brief when surfing in on a wave students need to jump off the board before it gets to shallow, due to fins catching in the sand and
participant falling face first into the sand.
pilof3 A

BP)
A M t Activity Management Plan - (activity) Las.
HILLARY
ourDoors
Brief students how to get off the board safely when coming into shore- Don''t jump off, lay down on surfboard and slide off or crouch
down and hop off
Session should be run away from rips, (Can use small rips to aid students getting out if students have progressed to no being pushed
‘onto waves)
Brief students to stay calm and wait for rescue. (Instructor should be able to rescue at all time ie be on a board and scanning the
water or when running session in shallower water and small swell conditions and all participants can be standing if rescue is required
can just take a board from other participants in the water
Ensure that person who is in the water pushing their buddy can comfortably stand up if student who is pushing in the water was to be
swept out, brief they can hold onto their buddy''s board
Brief students to make sure the leash is never looped around their body especially when going through waves.
Leash entanglement
Participants pushing their surf buddy in the water must ensure leash is not going to catch one of their body parts once they push the
board.
Brief students where position themselves on board, Student progression to start on spilling waves then progress too green waves
Nose diving when surfing wave
Brief students to cover head with arms to be safe from the board in case of the board striking them in the head
Can be sharp and there is a chance of them cutting another participant so making sure path is clear when jumping of the board and
not going to hit anyone
Run session at least 200m along beach from estuary outflow and monitor group drift
Manage group around public, Busy period over summer need to consider our effect on the beach, Public likely to swim in front of
session during the busy period.
r
Hayden Devine from date of Cy
Approved by ’ 23/09/2025 lyear '' signed X\ ee
Centre Manager approval Sy
a"
p2of3 AMP

AMP Activity Management Plan - (activity) ales,
“A LEGEND ee
Tsunami inundation
¥. zones
Weilkeawem Bay ita
ti,
e\— = ) ae Tsunami safe zones
i''s da ZX\
Se
x ; “ER > a’ >
14 % <= Tsunami model
wien ys, XS. boundaries
wy, AS! , usta. d
GA, a Se ‘
Wells f Ee. \ Historic Shorelines
Creashtasen 2 : i % \ : ‘
y Peds / a
y / Fs d { ! — 2024
fh : Wa ae N — 2077
p3of3 AMP

','g -',null,'Read from a scan of the paper copy','Data import'),
  ('AMP 17 Alpine Grade 2 Mountaineering','ALPINE · Tertiary','17','Mountaineering on Grade 2 Routes','Climbing Grade 2 routes within Tongariro National Park with Tertiary Students','Tongariro National Park','Yes, on the Snow','LNT','Melt or carry','Refer Instructor Handbook and CMS Tongariro
Consider RED call due to nature or location of event.','DOC Concession','NZOIA Alpine 2 or L4 Alpine comp, or,
L3 Winter Alpine comp if working with Alpine 2',null,null,'T1 Fundamental and T2 Handbook','A very serious course that takes place in an environment where a mistake could cause serious harm.
Don Bogie Snow Anchor Report. Q:\5. Programme Resources\Mountain Alpine\5. anchors',null,'Wall collapse (small slide) onto two tents buried during the night. Had to be dug out.
Student tripped while jumping for a rope. Self arrested. Numerous incidents of ice/rock falling from pinnacles.
Non-OPC related: Client on NZAC course fell from grand-gulley and died of trauma. - Clients caught in avalanches','Loaded from the Word file · approved 23/06/2023 by Jono Maxwell, Centre Manager','Data import'),
  ('AMP 18 Alpine Skills and Tertiary','ALPINE · Tertiary','18','Alpine for Skills courses and Tertiary','Teaching skills (Including Glacier Travel) on Grade 1 or easier terrain with Tertiary or skills Students.','Tongariro National Park','Yes, on the Snow','LNT','Melt or carry','Refer Instructor Handbook and CMS Tongariro
Consider RED call due to nature or location of event.','DOC Concession','NZOIA Alpine 2 or Experienced NZOIA Alpine 1 with DM approval',null,'Refer Tier 2 handbook Avalanche page for equipment to be carried','T1 Fundamental and T2 Handbook
1:6 Ratio
Intentions to be communicated with ski areas via DM and WhattsApp if operating in Whakapapa or Turoa Ski areas
Avalanche matrix T2-Uncontrolled avalanche terrain everyone to carry avalanche equipment (Transceiver, probe, shovel) -exceptions approved by ARM 6 on pre approved route or for specific route','www.avalanche.net.nz
Refer AMP15 Camping above the Bushline for map of poor communication areas.',null,'Wall collapse (small slide) onto two tents buried during the night. Had to be dug out.
Student tripped while jumping for a rope. Self arrested. 
Student Slid 300m from Pyramid Peak','Loaded from the Word file · approved 21/8/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 21 Bush Local Bush (Tongariro)','Bush · Tongariro','21','Local Bush
(Any river travel NOT included)','Walking in local bush environments in area covered by OPC local map','Various','Yes, various','LNT principles','Yes, boil or treat','Refer Instructor Handbook and CMS Tongariro','Yes, Refer DOC Concession','On-track - Bush (L1)
Off-track - Tramp and Multi-night Camp (L2)','No Prerequisites','Current Hillary Outdoors Local Map','T1 Fundamental and T2 Handbook','There are GPS or InReach available for use if needed. DM may request you carry one due to lack of knowledge of an area or track or poor radio comms.',null,'Lost student (Certificate)
Instructors fall down small bluff
Emotional trauma (teacher)
Participant falling and impaling leg','Loaded from the Word file · approved 11/5/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 21 Coasteering Little bay to Waikawau (Coromandel)','Coromandel · Coromandel','21','Coasteering Little bay to Waikawau','Swimming Camping Waikawau bay Waikawau | Toilets | Bay DOC Campsite have public toilets',null,'Waikawau bay Waikawau | Toilets | Bay DOC Campsite have public toilets','Bay DOC Campsite have public toilets',null,'Plan','Required? | DOC Concession if travelling around into Waikawau Bay','L1 Coasteering Competency plus famil',null,null,'215m Swell any direction','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

A Activity Management Plan - Tier 3 HI LLARY
OUTDO ° RS
Activity21 Coasteering-Little Bay Updated 23/2/26 Little Bay to Waikawau bay
Tidal rock Scrambling and DOC Campsite at At Yes-Little Bay Carpark and Waikawau
Activity Description | Swimming Camping Waikawau bay Waikawau | Toilets | Bay DOC Campsite have public toilets
(South End) bay
Emergency Refer Instructor handbook and Access Permission Required? | DOC Concession if travelling around into Waikawau Bay
Response Emergency Response Plan
5 Hazard/ See attached maps for Tsuanami Instructor Requirements L1 Coasteering Competency plus famil
vacuation maps _| zones
Refer instructor Handbook for policies on equipment, methodology and
environment.
Gana Geutment Environmental limits:
Required Refer Instructor handbook Specific Policies 215m Swell any direction
<=1m Swell — Top section of Little Bay Coasteer
<= 30 kn winds
Other Resources and
notes
oo (Li >» [2
Key Hazards iV: 3) i= a J
Extreme Weather peep water Moving water Sharpobjects
Safety Management
‘Activity weather cut off: Swell-1.5m any direction.
The top peninsula of Little bay is L2 coaster. 1m
any direction top section cut off. Dm Approval can be run with additional support staff.
30kn winds
piof4 A

A “UT Activity Management Plan - Tier 3 HI LLARY
OuTDOORS
Instructor to watch features before committing students to feature. ~
Briefing feet up if appropriate or chance of foot entrapment.
Minimise | Surging Features Brief safe waiting zones for students
Consider position of maximum effectiveness — On land with throw bag or in water to tow students out.
Surge/swell onto shallow rocks Instructor to be familiar with trip and effects of swell on site. See coaster map.
Depends on tide and swell. Teach students proper techniques for landings. Sturdy, covered footwear must be worn.
Movement around rocks, barnacles and oysters. Briefing to fall back into water if the swell drops and leaves you high and dry — Coach feet first landing onto shore and
hands up till secure footing is made.
No jumping without instructor permission
Shallow rocky channels ‘
Shallow water entry to be briefed
Other users Manage group around public.
This is a public area with the associated risk of theft etc - lock vehicles
Large swell (Easterly/ North-east) surges onto Walk around channels if swell is excessive.
Norther Point. Suggestion to start from little bay and go only as far as swell and group permits
Steep ground on return track Handline in place to manage, instructor to brief hazard and manage students
A This has lots of small shallow entry jumps below 2m choose your route through here, Instructor to ensure appropriate
DiringIchooselvourchellenge landing site for students, there are also swell features to play in a low swell.
Aso Hayden Devine, Date 23/2/2026 | Review in 1 year From date of approval Signed SL >
y Centre manager => ——
p2of4 A

4 “IT” Activity Management Plan - Tier 3 HILLARY
OUTDOORS
ittl y
Little Bay Coasteer &
NEMA. ted. gaa
ets eet ea
: OST : A SSR) See wt
& fo Lea PSs io - ey i Gare v
mS : SEN a Cae
i | ‘J . 4 ot is & aS
’ wee \ gy Choose your challenge FEO x ] SU surce chamber
by 7 tay? ae ah Scramble and ~y a
hy wae. : n F Be Surge chamber—
Ps > . Rae } f he x " friendly
ne ; 2 a
é a
ie. ae
> “ ,
> p 4
t ra > " .
"i te + . >t,
©] Waikawau Ba * ‘ figoa5) : i
Y hy ~ 4 ONG Little Bay
te ei i 5 “ A ¢ »
p3of4 AM

AMP Activity Management Plan - Tier 3 RNY
OUTDOORS
Tsunami Safe Zones- Little Bay, Waikawau Ba’ ae
i ‘A LEGEND
is q
Apparent inundation N
Ear I extent of jan 2018 storm ft
ls 4 _—
\ — a
a te 3
Bt > & ecm iTerenisa q
~ Se He i
S See, |S { Le bh» ;
= Sie st ¢ NN ;
ee J one = Xs ‘Tsunami safe zones
- Oe =]
4) Ke, es en. os
Se ¢ oF COZ a1 i Historic shorelines i
Vers a
SU eee Vaetmmnsccye ©
la 22 aN
Lae ie 15 a NTS
, a q WS Y ; a saat Sack fi
“¥ re ‘Gaeta

~ : as ak teen ifs
f 5 ep fron Pon
sa fa) eae, gees

p4of4 AmP

','iV: 3) i= a J',null,'Read from a scan of the paper copy','Data import'),
  ('AMP 22 Bush River Travel (Tongariro)','Bush · Tongariro','22','Bush river travel','Travelling in local streams and rivers','Various sites','Local','LNT','Yes, Boil or Treat','Refer T2 Instructor handbook and CMS Tongariro','Yes, refer DOC Concession','L1 Bush and L1 River safety comp.
Taurewa Stream: L1 Bush + Taurewa Stream sign off','Basic fitness-be aware of water confidence','Helmets, Bush rope refer T2 Instructor handbook','T1 Fundamental and T2 Handbook
DM -Ring Genesis Control room if group is travelling in Mangatepopo out of earshot of dam siren e.g. below swimming hole -073847210','Areas may include: Mangatepopo, Taurewa, Tawhitikuri, Pukehinau, Okupata and Whanganui streams/rivers. Refer T2 Instructor handbook and MSC bush craft manual for river crossing information. This AMP does not include gorges. A gorge being an environment that cannot easily be escaped from if needed i.e. Mangatepopo Gorge between “Dingle Creek” and the Mangatepopo Intake
Tomo and large drop near to start of Dry Valley walk when commencing trip from O’Cave.',null,'Damaged knee, damaged ankle, slip on ford injuring back, Teacher slipped on rocks injuring head. Instructor fall off bluff. Graffiti to structures, falling into Tomos Various injuries from slipping over during stream-tailbone, head 2024-26','Loaded from the Word file · approved 11/5/2026 by Lee Vaughan,
 Centre Manager','Data import'),
  ('AMP 22 Snorkeling (Coromandel)','Coromandel · Coromandel','22','Snorkeling',null,'52"4¥ Bay, Stoney bay, Little Bay Updated by G swift','DOC campsites es, Toilets Doc campsites, Big Sandy','Doc campsites, Big Sandy',null,null,'A none','Snorkelling competency or DM approval','Acquire swim ability of clients',null,'‘ .','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

A AN
ivi -Ti HILLARY
Activity Management Plan- Tier 3 CuTnenes
Water
a Location | 52"4¥ Bay, Stoney bay, Little Bay Updated by G swift
DOC
Si iT li hi fi SH idal campsit
ivi norkelling close to shore away from swell or tidal it i
Activity Ig y Camping DOC campsites es, Toilets Doc campsites, Big Sandy
Description streams otherwi beach
se
carried
Emergency Refer Instructor Handbook and Crisis Management Access Permission
A none
Response Plan Required?
Hazard
Evacuations Refer Tsuanami Safe Zones attached below Instructor requirements Snorkelling competency or DM approval
maps
_ Ratio 1:10 +2
Specific No snorkelling in swell or chop over 0.5 or when there is a risk of being pushed
Equipment Refer tier 2 handbook Specific Policies ‘ .
A into rocks
Required . —
Footwear must be worm if not wearing fins
Other Client Competencies Acquire swim ability of clients
resources and | Marine life ID guides
notes
5, i
ORS > “Q-
Key Hazards Nar BS C)
ss Sharp Objects i
Extreme Weather Deepwater — Movingwater pov Social Temperature
Previous
Incidents Encounter with marine creatures, oyster/ kina cuts, lost and damaged equipment, ear injury
Safety Management
code (Maced i Management stew
Set boundaries
Admin Group separation Constant head counts
Consider establishing a buddy system
. _ Disclose risk of diving too deep is not allowed at this basic level
Admin Ear injury
plof2 A

AMP IN
Activity Management Plan- Tier 3 HI LLA RY
FR Ga

Loss/d f equipment Correct use of equipment
sefcamege oveaipmen Manage equipment issue and return
aye Hayden Devine, Centre Manager Date 7/05/26 Review in 1 year From date of approval | Signed WC
=e eT Ln ares l ; 1
Sa ow us a £
¥ See oo eS Pe a 3 iS
3 res. Sx Saw’ Py . "ip A j
cd Ow = eS : B 7, a. y
|’ Qe neha cay Oe
Sas f\ 4 Ce IG EYEA é
< «4 \! = GRAS Se ead
= e Tina! UR Sold oss
ov o ) a ; v se
2 hate : : A
g NS *) ee . :
ms ik ce & 4 « "Historic shorelines \
a : gt =" Fo : y
7 ‘ ¥3 d a ae an Rae SS !
a -¢ & “al Pi * ‘ px
: } He i s ¥ “ah
re fe '' Le aes
_ ; & 4 Ay. § eae
ime vi 9 a a
PZ ts ie | ag ae % ay :
fy: aR ys gs 3 .
p2of2 A h AP

','Nar BS C)','Encounter with marine creatures, oyster/ kina cuts, lost and damaged equipment, ear injury','Read from a scan of the paper copy','Data import'),
  ('AMP 23 Bush craft (Tongariro)','Bush · Tongariro','23','Bush craft','Bush craft activities including using tools such as knives, hatchets etc.','Various','-','LNT principles','Yes, boil or treat','Refer Instructor Handbook and CMS Tongariro','Yes, Refer DOC Concession','On-track - Bush (L1) 
Off-track - Tramp and Multi-night Camp (L2)','Demonstrated ability to listen to and follow safety instructions','Whittling knives, hatchet, bush saw','T1 Fundamental and T2 Handbook','Instructors must be familiar with equipment prior to use with group.
Resources: How to carve the bowl of a spoon
Greenwood carving with Mora knives',null,null,'Loaded from the Word file · approved 3/8/2026 by Lee Vaughan Centre Manager','Data import'),
  ('AMP 23 Sit on top kayak (Coromandel)','Coromandel · Coromandel','23','Sit on top kayak',null,'y Updated by G Swift','none carried Toilets Big Sandy Bay','Big Sandy Bay',null,null,'None','Level 1 kayak competency','Check swim ability of clients','Refer to tier 2 handbook Client Competencies Check swim ability of clients',null,'Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

A LS.
ivi -Ti HILLARY
Activity Management Plan- Tier 3 ourpoors
Water A Level 1 sea kayak areas
Sit on top kayak Location : y Updated by G Swift
2 3 Waikawau estuary
Activity Small journeys in sheltered water (Level 1 area) and 1 . . .
Description water ABL’s Camping none carried Toilets Big Sandy Bay
Emergency Refer Instructor Handbook and Crisis Management Access Permission None
Response Plan Required?
Hazard
Evacuations Refer to tsunami evacuation map attached Instructor requirements Level 1 kayak competency
maps
Specific
Equipment Refer to tier 2 handbook Client Competencies Check swim ability of clients
Required
Other Southerly swell generally results in good sea state 7 7 oe
resources and | North East swells can result in rough sea states. SbeciniclEolicies) Sheltered water ratio: 1:10+2
notes Nowcast Weather channel 19/20
RSS =
Toe se 7 k =
Key Hazards v SSE FX —
Extreme Weather Movingwater social tsunami Deep water
Previous GBI — Student caught in rip, towed back to shore by instructor.
Incidents
Safety Management
Vcode [Heed *d Managemenesemesy
Avoid channels in strong winds, maintain awareness of wind vs tide and select route accordingly. Instructor to
Strong wind position themselves between participants and danger.
Use sheltering terrain features to maintain sheltered water
Separation of group Instructor to manage group to keep them close
Briefing what to do if separated
Other water users Keep group contained around other users
Keep safe distance from other users
| Minimise | Injury from equipment Briefing on safe use of equipment and correct technique for loading and unloading of trailer
. Left side of little sandy has rocks, avoid launching there
Damage to equipment A
Correct use of equipment
plof2 A

AMP Loe
Activity Management Plan- Tier 3 HILLARY
By = — i | |) OTT Fara ae | |
iF COP Batce Vic ||
ha Bites | Yale te le Se ao poe a |
Cae ; ES RS SR a NN |
Ae ~ ANE ho ead: i Se 1 |
Peeks KV cae og NU pre owt dee
S Syed aS: \ YOR Fay.) | eh CIs et,
GMAe Bas ke " ay | a | \ eh OE ie fa NM, Pots my
y sa 7a " me \ \ 5 eae —_ (+S ee ; Oe i ey SEN :
owt Gt qi om ee xg ira \- SE LF JHA
ON oRy ge SOFT | + = Cy A
CO ic; ee ill a A te ee A ie A ot Nat
AM etna atk. JS | i MR. Se ae
ae see ad ier ite | Ue AN OS Gi
paint OG) ae ON eer a ee
shoe ee dis for ~~ \ Was i LST Ga ie
‘GobB oily RS 8 ial Lae Noein S NERS ONY | ae
s oe |. re
ai “4 = o ee
Pg Ome a 2 —— S 5 A
: sy Ps oe : & ~ a = “oN —_ ’
f . ‘ : yy = age :
‘ de My Se A . e x ; 4
( gpa x Oa
p2of2 : AMP

','v SSE FX —',null,'Read from a scan of the paper copy','Data import'),
  ('AMP 25 Bush Solo Overnight (Tongariro)','Bush · Tongariro','25','Solo Overnight','Solo overnight camping for survival skills or assessment','Local Bush','N/A','N/A','N/A','Refer Instructor Handbook and CMS Tongariro','Yes, DOC Concession','L2 Camping and Overnight competency','Have demonstrated ability to follow instructions and safety requirements','Spare equipment for participants','T1 Fundamental and T2 Handbook',null,null,'Lost student, much further off track than expected (2008)','Loaded from the Word file · approved 03/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 25 Coasteering Rowner Bay (Coromandel)','Coromandel · Coromandel','25','Coasteering Rowner Bay','Tidal rock Scrambling and Swimming Camping DOC Campsite at Water At Stony Toilets Campsite has public',', prior learnings from Great Barrier applied to generic hazard','DOC Campsite at Water At Stony Toilets Campsite has public','Campsite has public',null,'Réfer Instructor handbook and Emergency Access Permission Required? | DOC Concession','Required? | DOC Concession',null,null,null,'Environmental limits:','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

A Activity Management Plan - Tier 3 Lo
¥ 9 HILLARY
OUTDOORS
AMP 25 Coastecring-Rowner Bay Updated spare
Yes-Stony Bay DOC
Activity Description Tidal rock Scrambling and Swimming Camping DOC Campsite at Water At Stony Toilets Campsite has public
Stony Bay bay toilets
Emergency Response | Réfer Instructor handbook and Emergency Access Permission Required? | DOC Concession
Response Plan
Instructor Competency L2 Coasteering Competency
Hazard/ Evacuation maps_| See attached map for Tsunami safe zones
Client requirements Acquire Swim Competency
Refer instructor Handbook for policies on equipment, methodology
and environment.
See ene Refer Instructor handbook Specific Policies Environmental limits:
Swell-<=1.5m NE, <=1m N
Wind-<=20kn any direction
Other Resources and notes | Satellite reference map, Tsunami safe zones Stoney bay
@ kaw p> %
Key Hazards 3) SBS / 72
caremeweather peep water MOvingwater SharpObjects
Previous Incidents Nil from this location, prior learnings from Great Barrier applied to generic hazard
Safety Management
Code Hazard Management Strategy
Surge Chamber (Fisher and Paykel) Feature has a 25m cave in the back, feature to be avoided by jumping left of it.
Depends on tide and swell. Teach students proper techniques for landings. Sturdy covered footwear must
be worn. Full length wetsuit to be worn at all times
Movement around rocks, barnacles and oysters Briefing to fall back into water if the swell drops and leaves you high and dry — Coach feet first landing onto
shore and hands up tll secure footing is made.
Instructors must brief and supervise participants to only jump where they say it is OK.
Correct Jump technique or progression Instructor to coach participants on safe jump technique and check ability before jumps over 3m (arms
crossed over chest hold, PFD straps or down by sides) Disclose risk of landing badly.
See approved jumps sites over the page.
plof4 A

A Activity Management Plan - Tier 3 HI LLARY
OUTDOORS
‘Appropriate progression of height to gauge clients jumping and landing ability .
Brief shallow water entry technique. Eg belly flop, foot first banana jump
[Mnimse [siphon Can be easily avoided by walking away from the coast. Place to be avoided!
Big jump Manage students up. First and second jump ledges OK Ensure suitable progression as students need to
be able to jump out to clear a rock. Ensure instructor positioned at the jump location.
Brief a strong stance or group support/huddle if moving around during a larger swell period, as a small
Large Swell Period (increased wave power) amount of water can knock you off your feet. Consider a call of “big wave to be shouted for the students to
brace
Encourage all of the group to be watching out for larger swell sets and they can call “Big wave" too.
Instructor to watch features before committing students to feature.
Surging features Briefing feet up if appropriate or chance of foot entrapment.
Brief safe waiting zones for students
Consider position of maximum effectiveness — On land with throw bag or in water to tow students out
[ean] Landing for sea kayaks Rowner Bay Steep bouldery shore-land boats one at a time. Be in a position to manage kayaks with waves to shore.
Inner ear injuries Disclose during briefing. Plug both ears before big jumps if participants have a history of inner ear
injuries/infections
Loose equipment, unsecured e.g. Go Pros Remove all loose/flapping solid items from participants prior to jumps. Go Pro''s must on in a secure chest
or helmet mount, on a jump over 3m (not held in hands or tied to PFD’s).
Approved —_ Hayden Devine, Centre a . ST
ie Menaes Date 24/02/2026 Review in 1 year From date of approval Signed SN
p2of4 A

Dp LOX.
AM} Activity Management Plan - Tier 3 HILLARY
OUTDOORS
“ i, ©
: . a he . ss
a a ee A
“¥ “a ‘
A Sswi | Low & High -
t% r 7s £5, i
. > jump
, Fisher and Paykel
. Avoid big cave
" ump into im behind
at channel
Small shallow .
water jumps
e3
She el
. hae A
i we
’ its
ud s-
p3or4 AMP

AMP Activity Management Plan - Tier 3 HI LLA RY
our eors
Tsunami Safe Zones Stony bay
— a
a Te Ye ‘Tsunami inundation
Hs F Run zones
933
-. »
ai eS om Tsunaml safe ones
* <
: " ‘Tsunami model
2 boundaries:
Historic shorelines.
: » — 2017
i 4 — 2012
Y,, Wa
_K <a §
: oe gee ee Ae.
: ee % A
ze ine Z P °
j x 5
p4of4 AmP

','3) SBS / 72','Nil from this location, prior learnings from Great Barrier applied to generic hazard','Read from a scan of the paper copy','Data import'),
  ('AMP 26 Coasteering Otautu Bay (Coromandel)','Coromandel · Coromandel','26','Coasteering Otautu Bay',null,'Y Updated by Jai CH','No Toilets LNT','LNT',null,'Plan Access Permission No','No','Coasteering Competency plus famil',null,null,'Required <= 1.5m Swell','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

A VIAN
‘ivi - Ti HILLARY
Activity Management Plan- Tier 3 brriaietis
Water . . Otautu Bay- Colville :
26 Coasteering- Otautu Bay Location Y Updated by Jai CH
Activity Tidal Rock Scrambling and Swimming Camping No Toilets LNT
Description
Emergency | gefer instructor handbook and Emergency Response Plan Access Permission No
Response Required?
Hazard
Evacuations See Tsuanami Safe Zones Instructor requirements | Coasteering Competency plus famil
maps
Refer Instructor Handbook for policies on equipment, methodology and environment
Specific _ Environmental Limits:
Equipment Refer Instructor Handbook. Specific Policies
Required <= 1.5m Swell
<= 30kn winds
Other - :
resources and | Walk around headland to avoid tapu area Cliente Ompetericies) Consider swim test
notes
ee ‘ R.
ar = BOR
Key Hazards } 3 / /
Extreme Weather peep water Movingwater Sharp Objects |
Previous
Incidents
Safety Management
[| code | Hazard Management Strategy
a Sturdy, covered footwear must be worn. Long wetsuit to be worn. Low tide has more exposed barnacles and oysters to climb
onand around
Admin _ | Shallow water/ tide affected Instructor to have checked depth before jumping, various jump spots at different tides, instructor judgement to be used on
jumps under 3m.Teach students proper techniques for landings.
Only to be used at low to mid tide
, ; , ; Instructors must brief and supervise participants to only jump where they say it is OK. Instructor to coach participants on safe
Admin Col t tech or progression
mi rrect jump technique or progressioy jump technique and check before jumps over 3m (arms crossed over chest hold, PFD straps)
Disclose during briefing. Plug both ears before big jumps if participants have a history of inner ear injuries/infections)
piof4 A

Activity Management Plan- Tier 3 HILLARY
Remove all loose/flapping solid items from participants prior to jumps. Go Pro’s must on in a secure chest or helmet’ mount,
not held in hands or tied to PFD’s
This is a public area with the associated risk of theft etc - lock vehicles
oe)
Approved Hayden Devine, Center ae NG 7
by Manager Date 23/02/2026 Review in 1 year From date of approval | Signed Se a
prod AMP

Activity Management Plan- Tier 3 HILLARY
Otautu Bay Coasteer
. *
h , 7 7
sg ri ow
% + “EE Thy
Sump - low to mid tide
'', L
a yy , é
avoid rock ie Bs
{ Tapu area do not climb
} 2 over
t |
p3of4 AMP

AMP LO
er _— HILLARY
Activity Management Plan- Tier 3 ourpears
Otautu Bay Tsunami Safe Zones
SS ~Y RS »— Ta Te ee Sy A tesend
st SS gee ee 2 oe TCS ae a
% DBs, / fees Ni ys We ae ay ma _ pean
a PEO Se Se ~ S Bae haze
a 3 Za WO Gy BO
| Nes gen Ge \ w ; Ce ek a
\ y fies eat te ee me Mee
\ arti {iguana * Tsunami safe zones
ee X A ¢ mS es
ne $ rand
am, j : a \ a Historic shorelines
= ee,
ag » bee se 5 84 —2017
; q ‘ HENS
“f : f Nae
e/ % | 4 4 Fayomg 2009
< « Sea — 2007
? or. 3 “Ty
ry so 7 | — 2002
) em rea eae oaa@
y ('' : = Y. ™ -
kg cS 2 My \, Ss y,
. io SO % ;
SS } < (ara oe =
ee ie sare
\e oi Ce
Nig < y eed ”
‘| pel ene, «
Fe Wey
RS vige é a
a= Plt _ ms _
p4of4 AmMP

','} 3 / /','Safety Management','Read from a scan of the paper copy','Data import'),
  ('AMP 26 Puerora Tramping (Tongariro)','AMP 26 – Bush Pureora Tramping · Tongariro','26','Bush-Pureora Tramping','Multi day tramping on tracks in Pureora Forest Park','Pureora forest Park','Yes, various','LNT principles','Yes, boil or treat','Refer Instructor Handbook and CMS Tongariro','Yes, Refer DOC Concession','L2 Bush',null,'InReach and PLB to be carried by instructor
InReach and PLB to be carried by instructor','T1 Fundamental and T2 Handbook','In high rainfall track out to SH32 from Waihaha hut may be difficult to negotiate.',null,null,'Loaded from the Word file · approved 03/11/2026 by Lee Vaughan Centre Manager','Data import'),
  ('AMP 27 Bush Overnight Camping (Tongariro)','Tier 3 · Tongariro','27','Bush Overnight Camping','Camping overnight in tents, shelters or huts with groups.','Various','Various','Doc campsites or LNT','Doc campsites or LNT principles','Refer to tier 2 handbook and crisis management plan','DOC concession or private land access permission','L1 Overnight comp
Appropriate Bush comp for terrain e.g. L1 bush easy access to tracks L2 off track','none','Refer to tier 2 handbook','Child Protection Policy',null,null,'Students changing tents during the night (mixing gender), Students having Intimate relations in overnight situation (Tongariro 2024), Instructor using noise cancelling headphones to get sleep, Gear floating away from beach Poor toileting practice – toilet paper and faeces close to stream and campsite (previous incidents from GBI) Burns from knocking pots over or grabbing hot pot handles. Sprains and injuries from unsupervised play around campsite.','Loaded from the Word file · approved 11/5/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 27 Waka Taurua (Coromandel)','Coromandel · Coromandel','27','Waka Taurua','hulls connected to form a 12-person catamaran Camping Toilets Big sandy To be carried',null,'Toilets Big sandy To be carried','Big sandy To be carried',null,'Access Permission Required?','Required?','Waka Taurua Competency level 2',null,'below) - ele zone, Wind less that 15knots, swell','"','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

B)
A iv | t Activity Management Plan - (activity) Las.
HILLARY
ouTDooRS
Waka Taurua level 1 and 2 Stored and launched at big sandy see map
below for zones waka can be paddled (Note | Updated by
zones waka not able to enter level 3 and 4 zones)
Waka voyages in Level 1 and 2 Zones with 2 x waka
Activity Description | hulls connected to form a 12-person catamaran Camping Toilets Big sandy To be carried
(Waka Taurua)
Refer to Instructor handbook and Crisis aan + Doc concession, Private land permission for storing and
Emergency Response Access Permission Required?
management plan cleaning waka
See map below for suitable landing and anchoring
Hazard/Evacuation .
Maps zones Instructor requirements | Waka Taurua Competency level 2
Tsunami map
- Spare Steering hoe - Level 1 zone: wind up to 20 knots, swell up
- Towline attached to waka (see photo to 1.5m -
specific Equipment below) - ele zone, Wind less that 15knots, swell
i ess than 1m
Required - 2xanchors Specific Policies _ "
- Above conditions dictate where waka can go cut
offs at the water’s edge if conditions change during
the session powered support vessel must
accompany
Other resources and | Wash down of waka and trailer happen at big sandy beach at Tiny’s house, please ensure we use his bore water not tank water. Tap on the roadside
notes | side of his house. All other gear to be brought back to centre to be washed and stored
w= UF RR 7/2
~~ qe PM) S &
Key Hazards &3 f J@
Moving water Extreme Weather Remote Social Tsunami Deep water
Strong winds Use above matrix to dictate where and when to paddle the waka, Southerly wind directions generally sheltered vs northerly which come
straight into big sandy
plof5 AM P

AP
AM t Activity Management Plan - (activity) Las.
HILLARY
ouTDooRS
Minimise Use matrix above to dictate where and when to paddle the waka, during larger swell northerly you will be unable to launch and land waka at

Large swell big sandy due to dumpy surf conditions on the beach. During a northeast or easterly swell will typically be able to launch the waka and be

able to stay in sheltered water in level 1 terrain
5 No place to land the waka on the coast in the level 2 zones (Powered support vessel can tow waka out of these situations), Can land at little

Remote coastline
sandy or Carey Road

Rough water

causing sea Monitor, ensure plenty of fluids to avoid dehydration. Sea sick tablets in first aid kit.

sickness

Clients hit by Ensure when loading and unloading waka that the clients don’t get between the waka and the trailer, When moving the waka ensure all

waka or trailer participants are clear of the wheels (Can be easy for feet to get run over)
When transporting waka ensure that you have people on bow and stern of both hulls as they can get low to the ground during steeper

Damage to waka | sections of the journey, On the water ensure you are paddling well away from any rocks and as you come into the beach travel slowly and
stop waka before you hit the beach. If lifting the waka use as many people as possible minimum 8 people

Incorrect 7 . ant ‘ A :

‘Anchoring and When anchoring waka use both anchors and ensure you give enough scope, 3;1 and the minimum. When attaching to the mooring attach via

4 B the rear kiato.

Mooring waka
Ensure that you stay clear of boat traffic (busy period in December Christmas holidays)
Stay well clear of working vessels i.e. mussel barge and cray boats.
No students standing up on waka unless it is stationary.
Participants must always wear closed toed shoes
Grass very soft by the waka especially in winter consider parking across the road when grass is soft

f
Hayden Devine from date of AN io
Approved by v ’ 23/9/25 1 year f VS
Center Manager approval <=
p2of5 AMP

A “i Activity Management Plan - (activity) Loe.
HILLARY
ourDoors
L\T
( x |
| aa
f, i = «4
iN oy
fj ie ‘ a
f Q z
62. conan es id i
Clip both biners t )
to the boat Ss
towline loop. f
aaa a
l fA ;
an aay A
£0) A) pat ‘
ol a F
OO @ te
ale Ly
se 0)
4 OF re
MinH
@ «|
ae la
{) <0)
Lf we Picture = Towline rigged ready to
deploy to powerboat for tow.
Towline lives attached by 2 slings to
p3ofs Kiato but stored in bag on floor, ready
to be set up as pictured 4

AMP Activity Management Plan - (activity) a
HILLARY
| | | L. | , spouse
See eee eee
| wf || |_| | | |
ne — 5 - po
<a We, SPE es | | | | |
| ae Ere a 7S | | | | |
| aE 0 Tor Oe {tipi
eS Se he eee Su pha b> ———}—— |
Bh py 2 ee
Se =. ai an
ee) =, ae
| =e Se Sai RS, Alina. Be. SP teh (s: Leathe “<a | |
PRS Vie eo ee ae eee a: beet S |
meSS es be ote Di ae
NR ete a CRI er Ro ae Be ea \
\ AG OF A Tee WN
| \ ey A rd Daaage ag me ass Sales |
_ CN Pe ae PO ee AO Reg a ET 1 SA Ns
ON <2 8 tps S&S
7 T haves (OF i) iearomanani= Ce Sreninevlan’ Soy ih ect eee NS
| Neo I hae: BO ied a oe eet NS a CS nine ge eae =o. aN
NR eer cere REGE Sin A Gee
; | ON ier Segal? Sey Fo) Me ee es
| | | Ne Bor AA sie iC: ae Sey
a= CL PIS FI gi a A RA RES ee
7 TTB SEN | SU SN Be A
ee Ss eRe DL Bek Ee a 2 OS CMY A 2
1 1 = es 1 Tier os me ie) ee A | NE LTR AO aa crm4
p4of5s
AMP

AMP Activity Management Plan - (activity) ‘i LON
“4 : F AF - ; Paes
eer ov dl oo
Ve ™ 4 t Rah oe ‘Poy.
5 Ae ‘ae ey a, Geil ph i “
e £ é 5 3 f Doge 2 b>
4 4 " Li \a ae , j U
aaey
a
p5sofs

','&3 f J@',null,'Read from a scan of the paper copy','Data import'),
  ('AMP 28 Advanced Snorkel','Coromandel · Coromandel','28','Advanced Snorkel','"°Y ine wi ic Free diving, away from sw Camping NA Toilets ven To be carried','7 ¥ Updated by Caitlin Gilles,','NA Toilets ven To be carried','ven To be carried',null,'Crisis Management plan Agaccs Romulan No access required',null,'L2 Snorkelling/Advanced Free Dive Competency','Acquire swim ability of clients','02 with group, first aid for cuts and scrapes, 2 floats, Dive','Swell-<=0.4m.','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

)
A t | t Activity Management Plan — Freediving LOX.
~ HILLARY
‘ourpoors
Water + . Port Charles sheltered bay, Kawetoto
=| Location 7 ¥ Updated by Caitlin Gilles,
28 Adv Snorkel / Basic Free-dive Reef (Waikawaul, Black Rock pdated by itlin Gillespe
‘Adv Snorkelling with basic free diving, away from swell or Leave no
Activity Description "°Y ine wi ic Free diving, away from sw Camping NA Toilets ven To be carried
tidal streams Trace
Emergency Response Crisis Management plan Agaccs Romulan No access required
gency Resp ‘ Le Required? q
Hazard/Evacuation . 7
Maps See Tsunami Safe Zones Instructor requirements | L2 Snorkelling/Advanced Free Dive Competency
Client competencies | Acquire swim ability of clients
. - - MAX DEPTH: 4m , MAX RATIO: 1:10+2
Specific Equipment 02 with group, first aid for cuts and scrapes, 2 floats, Dive |
Environmental limits:
Required Flag Specific Policies
Swell-<=0.4m.
Wind - <=10kn
Other resources and . ,
notes’ Marine life ID guides/slates; PADI Advanced Snorkeller/Basic Free Diving Instructor Guide; Resource teaching sheet
& bs +. %
Key Hazards ] v
y sa +)
Extreme Weather Deepwater Temperature Tsunami
Previous Incidents Encounter with marine life, oyster/kina cuts, lost and damaged equipment, ear injury (GBI)
Safety Management
Code Hazard Management Strategy
Instructor to brief importance of NOT hyperventilating before freediving (at any depth) to minimize cause of shallow water black out.
Shallow water blackout/Hypoxia Making sure recovery breaths and time (2-3mins on surface before repeat dive) is done properly to avoid CO2 build up in system. 02
is with group as emergency. Instructor will also have weights and fins for when/if needed. BTT technique is known.
Instructors to check tides and weather before heading out. Don’t operate in swell bigger than 0.4m and 10knots of wind, or move toa
different area.
a 6 r Enforce pairs 1:1 or 3’s. 1 up 1 down rule. Constant head counts and system for accounting for all divers. Dive flag will be set up to
we roup separation also alert other users of the area that people are diving
Floats set up for students to use for support during recovery if needed
Instructor to brief clients about why the snorkel must come out of the mouth before diving down to close off water pathway to the
Minimise Swallowing water
lungs when underwater.
Ear issues — barotrauma, forced equalization, middle ear Instructors must brief and get students to practice equalizing on land before getting into the water. Refer to Instructor guide about
squeeze different ways this can occur or be taught.
piof2 A MP

AMP Activity Management Plan — Freediving aN
HILLARY
bearddad te
c ¢ Sturdy, covered footwear must be worn on the walk out there. Long wetsuit to be worn, low tides have more exposed rocks for
‘uts and scrapes entering and exiting the water.
return
Graeme Swift from date of }
Approved by 24/02/2026 1 Year LS
Safety manager /02/ approval
NEE hes W/ Bees
ay Ss ss ees
RS 4 [pk
as ia
heey A 2
boat | 4 é Fess 4
tas f BSR A
RAS y pares si 5 é
ASR Es 5 colty Be ne a Nn a
ae Sa aS gait ree 4 eee
ot CAG Beton, “ie ie aay ea :
ag an be, <P
ot % ee Pee ee LN Pa
5 A B- 4 mF RAE EN J
Ph 8A a 8 ah ese fe Be 1 Be ea) —
ss Se Se ad ‘ells pe See wee = 7. ie” rors
Ce BS gee Tb ae . ra \
ee Ree. RRS Pie yee ee HAN
Big Sandy/Port Charles Black Rock Kawetoto Reef-Waikawau
Tsunami safe zones
p2of2 AMP

','] v','Encounter with marine life, oyster/kina cuts, lost and damaged equipment, ear injury (GBI)','Read from a scan of the paper copy','Data import'),
  ('AMP 29 Coasteering -Black Rock','Coromandel · Coromandel','29','Coasteering -Black Rock','— Tidal rock scrambling and swimming Camping no Toilets LNT Water no','— Black rock Updated by Jai CH','no Toilets LNT Water no','LNT Water no',null,'plan | Access Permission Required?','Required?','Level 2 Coasteering competency plus site famil.','Consider swim test','= =','ae','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

LAY
A vu Activity Management Plan - (activity) LOX.
HILLARY
‘ourpoors
Coasteering - Black rock Location — Black rock Updated by Jai CH
Activity Description — Tidal rock scrambling and swimming Camping no Toilets LNT Water no
Emergenc'' -
82ne¥ | eter instructor handbook and emergency response plan | Access Permission Required?
Response
Hazard/Evacuation . - a
y Maps 5¢¢ Tsunami safe zones Instructor requirements | Level 2 Coasteering competency plus site famil.
Client competencies | Consider swim test
Refer instructor handbook for policies on equipment,
methodology and environment
Specific Equipment = =
B oeemirea Refer instructor handbook Environmental limits:
equine Specific Policies ae
<=1m Swell any direction
<=20 kn winds any direction
Other resources .
Satellite reference map
and notes
Do *
& Ez Pp %
Key Hazards 63 BSS ®
SS rR
Extreme Weather Deepwater Movingwater SharpObjects |,
Previous Incidents Jan 2026 — Instructor pulled loose rock and fell 2m on West side of Jump alley
Safety Management
Code Hazard Management Strategy
Leg trapping feature Avoid students going into feature, can use surge feature Infront of the leg trapper but instructor must spot the feature
Minimise Depends on tide and swell. Teach students proper techniques for landings. Sturdy covered footwear must be worn. Full length wetsuit
to be worn at all times. Briefing to fall back into water if the swell drops and leaves you high and dry - Coach feet first landing onto
Movement around rocks, barnacles and oysters. shore and hands up till secure footing is made.
Minimise instructors must brief and supervise participants to only jump where they say it is OK. Instructor to coach participants on safe jump
Correct Jump technique or progression technique and check ability before jumps over 3m (arms crossed over chest hold, PFD straps or down by sides) Disclose risk of landing
jump ique or progressi badly. See approved jumps sites over the page. Appropriate progression of height to gauge clients jumping and landing ability Brief
shallow water entry technique. Eg belly flop, foot first banana jump
Brief a strong stance or group support/huddle if moving around during a larger swell period, as a small amount of water can knock you
Large Swell Period (increased wave power) off your feet. Consider a call of “big wave” to be shouted for the students to brace. Encourage all of the group to be watching out for
larger swell sets and they can call “Big wave” too.
piof4 AMP

APD
AM t Activity Management Plan - (activity) LOX.
HILLARY
‘ourpoors
Minimise surging features Instructor to watch features before committing students to feature. Briefing feet up if appropriate or chance of foot entrapment. Brief
"Bing safe waiting zones for students Consider position of maximum effectiveness — On land with throw bag or in water to tow students out.
Minimise Manage students up and around different jumps. Start with a small jump to get proper technique before moving to the bigger jumps.
Ensure instructor is in a suitable position before jumps occur. Instructor to check depth of jump to make sure it is safe for anything over
Jump alley 3M. On the underpass side of jump alley two appropriate ledge jumps have been identified during staff training 2026, additionally the
higher section of the opposite side (non underpass side) of jump alley is closed to both students and staff no jumps or scrambling is
permitted here due to crumbly rock.
Minimise Underpass is only useable during small swell not doable at high tide. Exit needs managing for one steep section that could be
The underpass
challenging for some students
B) inner ear injuries Disclose during briefing. Plug both ears before big jumps if participants have a history of inner ear injuries/infections
Remove all loose/flapping solid items from participants prior to jumps. Go Pro’s must on in a secure chest or helmet mount, on a jump
Loose equipment, unsecured e.g. Go Pros over 3M (not held in hands or tied to PFD’s)
Hayden Devine from date of (>
Approved by y 23/02/2026 1year '' W\
Centre Manager approval No se
—
p2of4 AMP

A Activity Management Plan - (activity) Lae.
HILLARY
ete yt 7 Tiga 7 "7 ; _ ourpoors
wy TRS if ip oe a) LE ae in
| tare, oF » 5 7m PF th ‘ eS ’
Ron WAY, yf 4 iy) a ot ® A Rraeke 3 +. Ns
rt ye SD bs y epesuee features " .
= rd a ees *
By Me oe ‘
4 ei ee | .
: ‘ , ae $57 te vk, < “ *
i a” ag * ¢ As a).
. a “
r — : ’
- SS | Multiple small jumps a.
4 ny, a ef ay Sand surge features ei rae °
; ~ Daal + ah) pd FR
a GAR "thea ceie
zone 4 Ya oy ay Met dp Pag FSS Ne
a (>) Sasa ee a aaheae
7 ‘ ’ ; Oe iN a re) te ae
_ ee a arett, Lee gee un te vm
Re ti 8 eee. i, Na
| LT ~~ ¥ Dee trl
oan oS 1A re 5, t “ sy,
Ae A ty Ps 2 aint
Sen 5 Cre . aes
Mae S| ¢ * >
ve? Lo * 4p
— “sj !
rit i Pa
smaljump ed
“Ea '' : ‘y
jump out and a = .
P Pe) away, >. ee ee
&™ rehiG. y'' = e
eo Ph oy HA ee
ie if > a ae > =!
go!
“} —
p3of4 J

A Activity Management Plan - (activity) aN
I - @® LEGEND HILLARY
£ \ bearddad te
NSS ) Tsunami inundation

ox =

NS te. ake A fa

( : om.) - on «e <=

(. o— 7

Re wap $ Tsunami safe zones

ey BR

AES Py J 7s ae

Oe

ON ge yale

. ate teh \ Py “ 2 | Tsunami model

pee s rf boundaries

eae. 8, : )

bs Pee 2 :

Sea oe , Historic Shorelines

if > ~— or Po ;

ay yee , Ramacum — 2024

i es - 4 .. seer

di ‘a N Re me FN oe — 2079
p4of4 AMP

','63 BSS ®','Jan 2026 — Instructor pulled loose rock and fell 2m on West side of Jump alley','Read from a scan of the paper copy','Data import'),
  ('AMP 30 Local Bush','Coromandel · Coromandel','30','Local Bush',null,'Uillary Outdoors property Updated by G Swift',null,null,null,null,'N','L1 bush comp','None','Local map Specific Policies Refer to Tier 2 handbook','Refer to Tier 2 handbook','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

A AN
Activity Management Plan- Tier 3 HILLARY
ouTDOORS
Activit ''
30 y Local Bush Location | Uillary Outdoors property Updated by G Swift
Activity Walking in local bush, property owned by Hillary c . Y . LNT Toilet LNT principl
Description Outdoors. Excluding abseiling and climbing activities amping es, various voles Olas principles
Emergency Refer to tier 2 handbook and crisis management Access Permission N
A lone
Response book Required?
Hazard
Evacuations Instructor requirements L1 bush comp
maps
Specific
Equipment Local map Specific Policies Refer to Tier 2 handbook
Required
Other Client Competencies None
resources and
notes
ORD | ®
op Pe Qt]. ee x
Extreme Weathe i i i .
Key Hazards rem: r Fire Height Rock/Ice fall Social temperature MOvingwater Deepwater Toxins
Previous
Incidents Lost Students and groups, Stings from bees and plants, participant falling and impaling leg (previous incidents Tongariro) , COR Handlines needed from student trips on steep ground
Safety Management
Deep water in swimming hole Closely monitor students when they are swimming
Steep terrain Disclose hazards and spotting if necessary.
Instructor to position themselves well and manage group appropriately
Slippery rocks/boulders Disclose hazard to students, manage group appropriately. Brief to stand between rocks to avoid slipping.
5 jl Check medical forms prior to trip. Avoid area if needed. Obtain info from other staff especially in warmer months about location
Admin Insect and plant stings 7 7
of any known spots. Provide medical help as needed.
piof2 A

A VN
Activity Management Plan- Tier 3 HI L LARY
Tellstudents not to touch any ofthe traps unless instructed to
Disclose to students they may see dead pests on our bush walk, consider educating them on trapping
Environmental damage Educate student on Kauri dieback and make sure shoes are disinfected before entering the bush.
CYNE Hayden Devine, Centre Manager Date 05/05/26 Review in 1 year Fic Get Gti Signed TSN ?
d by approval == al
p 2 of 2 A

','rem: r Fire Height Rock/Ice fall Social temperature MOvingwater Deepwater Toxins','Lost Students and groups, Stings from bees and plants, participant falling and impaling leg (previous incidents Tongariro) , COR Handlines needed from student trips on steep ground','Read from a scan of the paper copy','Data import'),
  ('AMP 31 Cave Okupata Cave (Tongariro)','Cave · Tongariro','31','Okupata Cave','Cave exploration or initiative activities within mapped area of cave. No rope work as standard.','Pukehinau Road - BH34 180755','Pokaka Mill, Pukehinau Rd end','Yes','Yes, Boil or treat','CMS – use high water exit in any flooding event – preplan for evacuation for DM','Yes – DOC concession limits clients to 5000 per year and max of 30 in cave at one time. Co-ordinate with other groups and DM. Concession limit of 250 vehicle movements per year on John McDonald and Pukehinau Road.','L1 Cave Competency',null,'All instructor/group equipment in Tier 2 must be available at Cave entrance.
If progressing past Knee Deep Pool then this must be at intersection of streams at Knee Deep pool','Ratio 1:10 +2- Standard Programmes
 1:13+2 – AGS Programmes 
DM approval must be received in order to leave client alone at Cave entrance. They must be comfortable, have a designated waiting area and have access to communication device and know how to use it.
DM to authorise access immediately prior to entering, and be informed upon exiting cave
Additional authorisation required from DM for access into Upstream Area or below Knee Deep Pool','Do not brief your group in the large cave entrance to minimise exposure to less stable rock. Consider partial brief by river outside then more information when down at the river level. Entrance looked at April ‘23 and deemed ok to use after closure but do not spend lots of time in this area. 

Jan 24-Loose rocks in Escape Route just before Glow-worm grotto-keep to small channel on left, unstable rocks on larger channel to the right.

Photos stored in Qdrive/ Programme Resources\Caving\Okupata\ OR
 https://hillaryoutdoors.sharepoint.com/:f:/s/HillaryOutdoorsTNGData/EhSUn1_mNUZCmQlFzvQSk6MBU8LrbxB80Y4sqyyatYOBGQ?e=gqdFu6 
(opens sharepoint link) Other maps info/interp and ideas also in this file

Flow downstream of Okupata Intake- https://www.genesisenergy.co.nz/about/generation/rivers-lakes-and-rainfall/tongariro-power-scheme',null,'May 2002 - minor concussion 2012 - Student fell in siphon river right of waterfall 2013 – 2x participants lost in cave 2013 – Knee Dislocations
2015 – Student stuck in Pooh-Bears-Crack for 1 hour 45 mins 2016 & 2022 – client stuck 20+ mins 2024 Students missing from group for 20mins, found sitting outside at entrance 2024- large loose rock dislodged when pulled on','Loaded from the Word file · approved 11/5/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 31 Orienteering (Coromandel)','Coromandel · Coromandel','31','Orienteering',null,'O75" ane Port Chanes area Updated by','NIA Toilets On site','On site',null,null,null,'L1 Risk Management, Communication, Facilitation','Able to be trusted unaccompanied','Orienteering maps Client Competencies Able to be trusted unaccompanied','None','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

A LOX.
‘ivi - Ti HILLARY
Activity Management Plan- Tier 3 brriaietis
. . On site and Port Charl
31 Orienteering Location | O75" ane Port Chanes area Updated by
Activity U , ; On site, : ,
vit) ocal orienteering course, unaccompanied by adults. | Camping NIA Toilets On site
Description carried
Emergency | Refer to tier 2 handbook and crisis management book Access \Rermiss ion
esponse Required?
Hazard
Evacuations Tsunami hazard map attached Instructor requirements | L1 Risk Management, Communication, Facilitation
maps
Specific
Equipment | Orienteering maps Client Competencies Able to be trusted unaccompanied
Required
Other Specific Policies None
resources and
notes
‘4 Ys)
BR Cy Tp
Key Hazards - Ps 0)
Social i
Speed Tsunami
Previous Not returning on time, Controls interfered with, Slips and falls (Previous incidents on GBI)
Incidents
‘Safety Management
Code | Hazard Management Strategy
Set clear boundaries and brief what to do if students get lost
Thorough navigation briefing and map reading session before hand
Getting lost Keeping together in their allocated groups
Students need to know clear meeting points where the instructor can be always reached throughout the activity. The instructor
needs to maintain supervision, e.g. the instructor cannot be located at Coromandel centre and students operating at the
opposite end of the rogaine boundaries.
Road traffic Participants to be briefed to check before crossing roads and where to walk on narrow gravel roads
[Minimise | slips and trips Warning students’ gravel is slippery
Ensure students stay off private property
Other users of site and local residents Be respectful to members of the public and residents
Be aware of stranger danger, return to instructor if feeling unsafe
piof2 A

AMP Lor.
Activity Management Plan- Tier 3 HILLARY
ae P. ies ae oe TEGEND
Sa. 1S laa ton
Ni % +42) arr ¢ » 4 |
& a 2) 5 i ey = Sa, + ae ey a fsunami safe zones:
fl 4 f) j - oi
_— es . % boundaries
¥ ar. [ ; ie
Pl E ht eT N “oy Aa 7
gf eT aoe. ae #5 017
tm ‘ Z a =
= 4 pe: ear e:
r =
= % i tee
> @
pip aa
fe ——,
a - , £
ae * a
p2of2 AMP

','- Ps 0)','on GBI)','Read from a scan of the paper copy','Data import'),
  ('AMP 32 Bush Overnight camping (Coromandel)','Coromandel · Coromandel','32','Bush Overnight camping',null,null,'USEC) S Swift','Doc campsites or LNT',null,null,'Response Required?','9 p','none','Refer to tier 2 handbook Specific Policies Child Protection policy','Child Protection policy','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

A TAN
Activity Management Plan- Tier 3 HILLARY
OUTDOORS
. : Vari
Bush 32 Overnight Camping USEC) S Swift
c. Doc
Activity ‘amping overnight in tents, hammocks, shelters or campsite .
Description huts Various sorLNT Toilets Doc campsites or LNT
principles
Emergency Refer to tier 2 handbook and crisis management plan LNSEOSS eimission DOC concession or private land access permission
Response Required?
Hazard a
L1 Overnight com
Evacuations Refer to tsunami hazard map Instructor requirements 9 p
ma L2 Bush endorsement
ps
Specific
Equipment Refer to tier 2 handbook Specific Policies Child Protection policy
Required
Other Client Competencies none
resources and
notes
cs l= OS a r~ */ yy
- =| \e = rseny | “7
Key Hazards x —~ SY Re / 6 /
Toxins Deepwater _ Extreme Weather fee Movingwater fo" ShamObiects — sociat temperature Tsunami
Previous a ai - i i se
Incidents Students changing tents during the night (mixing gender), Gear floating away from beach Poor toileting practice — toilet paper and crap close to stream and campsite (pervious incidents from
Safety Management
Tsunami Leave radio and/or cell phone on at night. . If sea level changes suddenly (up or down) go to high ground. Refer to tusnami
evacuation map
. , Instructors to position tent close enough to students to hear anything unusual. Think about where students position their tents
Admin | Emotional trauma - ‘ identi sanchi H
in accordance to various gender tents, try to identify student relationships or past history.
Water borne illness Water to be treated or boiled before consumption
Environmental damage Avoid camping near high density areas of kauri trees
i
wee Hayden Devine, Centre Manager Date 05/05/26 Review in 1year From date of approval | Signed SX ee
p 1of 2 A

AMP LO.
Activity Management Plan- ‘— : _ ; en
ah Ses. G eg NL 4
23 ry 2 | , i 7X t >
ge f 1 [= <a es eK
” A ot oun > | _ Hic shorelines eS
4 oe fre - 3 2 “se Sm. Pee Sea
; » = eM 8
at Ps > Gis
: eae x ae ea
® ane Y he! ae .
fs, aS 4 bes os 4
Aa tg) ;
ae \4
a,
as a ”
t
a.
4 ors | Be
f j
) a ea) es
sS
*
p2of2 AMP

','x —~ SY Re / 6 /',null,'Read from a scan of the paper copy','Data import'),
  ('AMP 32 Cave Pukehinau Cave (Tongariro)','Caving · Tongariro','32','Pukehinau Cave','Caving within the Pukehinau Cave','Pukehinau Road. BH34 175756','At roadend','Yes','Yes – boil or treat','Refer Instructor Handbook and CMS Tongariro','Yes, DOC concession, limit of 250 vehicle movements per year on John MacDonald and Pukehinau Road.','Must be aware of and understand flooding risk and hydrology of site 
L1 competency or DM approval','Establish confidence in caves','Helmets and torches.','T1 Fundamental and T2 Handbook
Radio in before heading into cave, Radio in after exiting.','Student can get very wet and very cold. Consider having method of warming very handy.
If doing double cave, good idea to do Okupata cave first and save this until last so they can finish wet.',null,'Very cold, wet participants. Participants refusing to do squeezes. Rock fall in stream-way (2014)','Loaded from the Word file · approved 03/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 33 Bush Long Programme Camping','Coromandel · Coromandel','33','Bush Long Programme Camping',null,null,'overnight in tents, hammocks, shelters or Doc','Doc campsites or LNT',null,null,'Response Required?','9 p','none','Refer to tier 2 handbook Specific Policies Child Protection Policy','Child Protection Policy','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

A TAN
Activity Management Plan- Tier 3 HILLARY
OUTDOORS
. . Various
Bush 33 Long Programme Overnights tocaton Ge) S Swift
_— Camping overnight in tents, hammocks, shelters or Doc
Activity P : campsites 4
Description huts with groups on Multi week programmes with Various or LNT Toilets Doc campsites or LNT
adventurous journeys over multiple nights. principles
Emergency Refer to tier 2 handbook and crisis management plan LNSEOSS eimission DOC concession or private land access permission
Response Required?
Hazard a
A q L1 Overnight com
Evacuations Refer to Tsunami hazard map Instructor requirements 9 p
ma L2 Bush endorsement
ps
Specific
Equipment Refer to tier 2 handbook Specific Policies Child Protection Policy
Required
Other Client Competencies none
resources and
notes
- | \@ wo rseny | t
Key Hazards x — y B= sh f o
Toxins Deepwater "*teme Weather Fire Movingwater Remote jamoviects Social Temperature Tsunami
Previous Students changing tents during the night (mixing gender), Students having Intimate relations in overnight situation (Tongariro 2024), Instructor using noise cancelling headphones to get sleep,
Incidents Gear floating away from beach Poor toileting practice — toilet paper and faeces close to stream and campsite (previous incidents from GBI)
Safety Management
Tsunami Leave radio and/or cell phone on at night. If sea level changes suddenly (up or down) go to high ground (refer to tsunami
evacuation map.
Instructors to position their tent in-between the tents of various genders, close enough to students to hear anything unusual.
‘Admin Emotional trauma (Instructor to use judgement when determining their proximity to student tents, ensuring they are as close as is possible to
adequately monitor groups behaviour overnight). Instructors to ensure students are settled quietly in tents, and able to be
monitored before going to sleep in own tent. Refer to Group Community agreement if close relationships are apparent.
Water borne illness Water to be treated or boiled before consumption
Admin/ Closed toe shoes to be worn when using cookers. Suitable area designated out of traffic flow for cooking area. Students to be
Cookers-burns i ij "
PPE supervised when using cooking equipment.
Overhead hazards ‘Area for camping to be checked for overhead hazards, epiphytes and dead branches before establishing.
Flooded campsite Be aware of forecast and select campsite based on forecast effect on streamways and potential to flood site.
Environmental damage ‘Avoid camping near high density areas of kauri trees
Tale —folow LNT princes. Tolletng Som from water source. Use pack out polcy thi cannot be achieved or at high
p 1of 2 A

AMP Los
Activity Management Plan- Tier 3 HILLARY
a
Date 05/05/2026 Review in 1 year From date of approval
Oot sito) on NR [puso - |
€ ae) we. a ed, a)
a) fi ‘ , > (eee ot
> 2» ee LL ALS we
A OT ci id cs :
EAE SN ee a |
bs : yf pe Sm | =e of ,
7 . eee , ge RS
Bes, 4 eS
é % ) ; ‘ a 6 ‘ i
j a & F ey be
oy
hie,
y a Nines “ ae
LZ _ a ‘

p2of2 ® Dp

','x — y B= sh f o','from GBI)','Read from a scan of the paper copy','Data import'),
  ('AMP 40 Rock Tangiaro Abseil','Coromandel · Coromandel','40','Rock Tangiaro Abseil','35m abseil down slabby rock in stream bed “camping | no, totts | no | Water Yes- Boil or treat',null,'no, totts | no | Water Yes- Boil or treat',null,null,'Refer Instructor Handbook and CMS Coromandel Access Permission Required? eo','Required? eo','Abseil u plus Famil to rig abseil only, Rock L2 to Rig abseil',null,null,'T1 Fundamental and T2 Handbook','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

A ivi - Lo
Activity Management Plan - Ropes HILLARY
GR 203 524 (about 20min walk fi Updated Sash Nukada
. . P about 20min walk from pdate
Rock 40 Tangiaro Abseil Bocation the centre, follow “Pig Line” by 6/12/2024
Activity Description 35m abseil down slabby rock in stream bed “camping | no, totts | no | Water Yes- Boil or treat
Emergency Response Refer Instructor Handbook and CMS Coromandel Access Permission Required? eo
Hazard/ Evacuation maps Instructor Requirements Abseil u plus Famil to rig abseil only, Rock L2 to Rig abseil
for retrieval
Cpactiile Ecuipmend ee Specific Policies T1 Fundamental and T2 Handbook
‘equired
Re-direct has been removed and there is now a handline for the last ledge.
Other Resources and notes
CG ID
Key Hazards FRR GB
Sociat Rock/Icefall Height Extreme Weather
Previous Incidents Student stuck on mid-abseil ledge, staff had to Ab down, cut student free and lower.
Safety Management
a
High water levels Do not use abseil site
Brief students to stay on the dry grep rock
Slipping on slimy rock
Staff to periodically check the first step and scrub the slime off if necessary
Brief students about the two steep steps (reinforce good abseil technique)
Lose sight of abseiler momentarily when they are on the two steps
Ensure participants keep helmets on when at bottom.
Potential for pendulum on second step Brief to clip the abseil and client safety ropes into the re-direct bolt
Steep final section on approach track Consider use of handline
Clients not able to get off rope Ensure your clients are briefed on how to get out of the system when they reach the bottom (before
they leave the top)
Difficult to re rig and pull down. When de rigging abseil
CCLTEE . Hayden Devine, Centre Date 05/05/26 Review in 1 year from date of approval
y Manager SS
piofi A

','FRR GB','Student stuck on mid-abseil ledge, staff had to Ab down, cut student free and lower.','Read from a scan of the paper copy','Data import'),
  ('AMP 41 Rock Whakapapa Area Crags','Ropes · Tongariro','41','Whakapapa Area Crags','Rock Climbing and Abseiling at crags in the Whakapapa area. Crags covered by this AMP are Whakapapa Gorge, Halfmoon, Meads Wall and Pehi’s Crag','Various, Whakapapa Area','Yes','Iwikau Village','Iwikau Village','Refer Instructor Handbook and CMS Tongariro','Yes, Refer DOC Concession','Top-roping on Meads Wall North End, Halfmoon, Whakapapa Far Right Wall - L1 Rock Competency 
Top-roping at Pehi’s Crag - L2 Rock Competency 
Sport lead climbing - L3 Rock or NZOIA Rock 1 with sport endorsement
Trad leading - L4 Rock or NZOIA Rock 2','Back up belayers must be used unless competent. Backup belayer must have secondary form of belay e.g. prusik or belay device',null,'T1 Fundamental and T2 Handbook','It is quite common for other people to be in these areas. People have been known to walk over the top of Meads Wall with no protection.
Pehi''s now has three climbs with double ring bolt anchors; Tawhitikuri (13), Kumara Patch (12) and Kumara Chip (12).
Loose rock from Top of Whakapapa crag pushed off- created loose rock at bottom of crag',null,'2009 Rockfall at Meads Wall. 2014 and 2022 Graffiti on rocks at Meads Wall. 2013 Falling rock badly hurting leg walking to Pehi’s Crag','Loaded from the Word file · approved 11/5/2026 by Lee Vaughan,
 Centre Manager','Data import'),
  ('AMP 42 Rock Lower Rock Wall','Ropes · Tongariro','42','Lower Rock Wall','Top-roping and abseiling using fixed anchors and trees. Also includes bouldering.','MOW BH34 208744','MOW','MOW','MOW','Refer Instructor Handbook and CMS Tongariro','No','Rock (L1)','None','Slings for anchor points, long rigging rope','T1 Fundamental and T2 Handbook','Check trees prior to use. Some are not healthy enough for use as anchor, especially on left hand end.',null,'Grazed knee – lost footing on slippery surface of wall (2024)','Loaded from the Word file · approved 03/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 43 Rock Meads Wall Traverse','Alpine Rock · Tongariro','43','Meads Wall Traverse','Rock traverse across the top of Meads wall','Meads wall, Iwikau','Yes, down below Whakapapa crag','Iwikau','Iwikau','Refer Instructor Handbook and CMS Tongariro','Yes, refer DOC concession','L2 Meads Wall Traverse comp = Management of Clients 
L3 Meads Wall Traverse comp = Rigging',null,'3 * 50 metre ropes
Two trad racks
 30 screw gate karabiners','T1 Fundamental and T2 Handbook','Not a first day activity
Experienced instructor solo or two instructors
Choose group carefully, not an activity for all groups',null,'2015 Client returned to the top unsupervised and not connected to the rope.','Loaded from the Word file · approved 03/11/2026 by Lee Vaughan,
 Centre Manager','Data import'),
  ('AMP 44 Rock Meads Wall Loop','Alpine Rock · Tongariro','44','Rock Meads Wall Loop','Rock traverse loop on left hand end of Meads wall','Meads wall Iwikau, Mt Ruapehu GR 210538','Yes, down below Whakapapa crag','Iwikau','Iwikau','Refer Instructor Handbook and CMS Tongariro','Yes, refer DOC concession','L1 Meads Wall traverse Comp = Managment of clients
 L2 Meads Wall traverse Comp = rigging','Demonstrated ability to follow key safety instructions','1 x 50 metre rope (for loop), 1 x 25m rope (for approach), 1 x 25m rope (different colour for instructor line)
 24 screw gate karabiners 
3 quads
#3 (blue), #2 (yellow) and #0.5 (purple) cams','T1 Fundamental and T2 Handbook','See separate Meads Wall Loop document for rigging requirements',null,'2015 Client returned to the top unsupervised and not connected to the rope.(on full traverse)','Loaded from the Word file · approved 03/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 45 Rock Mangatepopo Area Crags','Ropes · Tongariro','45','Mangatepopo Area Crags','Lead climbing, top roping and abseiling using natural protection and some fixed anchors.','Middle Earth, Lower Tuwharetoa areas, 
Houtu, Armchair & Te Arawa crags','500m and out of sight of Great Walk tracks.','Carpark, Mangatepopo Hut, Soda Springs','Mangatepopo Hut- Boil or treat, carry
Mangatepopo Stream may contain Giardia','Refer Instructor Handbook and CMS Tongariro','DOC concession','Top-roping at Middle Earth - L2 Rock Competency Trad leading - L4 Rock or NZOIA Rock 2',null,null,'T1 Fundamentals and T2 Handbook','Rock crag guides SMS Active/AMPs-Tongariro/Rock crag guides',null,null,'Loaded from the Word file · approved 03/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 46 Rock Self-directed Abseil','Ropes · Tongariro','46','Self-directed abseil','Clients set up and run an abseil under supervision of instructor','Resource Centre or MOW','N/A','Resource Centre, MOW','Resource Centre, MOW','Refer Instructor Handbook and CMS Tongariro',null,null,null,'Gear for participant safety','T1 Fundamentals and T2 Handbook','Great activity for leadership students or corporate clients. Works best with some prior teaching',null,'Broken ankle abseiling off the mezzanine floor in Resource Centre. Improper belaying by clients due to lack of instructor supervision','Loaded from the Word file · approved 28/7/25 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 47 Rock Taranaki Falls Abseil','Ropes · Tongariro','47','Taranaki Falls Abseil','Abseiling down cliff face beside waterfall. Abseil set-up using natural protection gear placements.','Wairere Stream BH34 214581','Yes, 500m and out of sight of great walk track','Yes- Taranaki Falls','Yes- Boil or treat','Refer Instructor Handbook and CMS Tongariro','Yes, refer DOC Concession',null,null,null,'T1 Fundamental and T2 Handbook','You cannot see the bottom of the abseil from the top.
Ensure your students can get out of the system when they reach the bottom (before they leave the top)
This is not a beginner abseil site, consider not doing with new group. (It has poor entry angle, lack of visibility and a free-hang.)',null,'2009 – Belay line lowered to ground while student still on abseil
Members of the public stepping over / around anchors.
Numerous occurrences of rope damage
Pendulums from weird site selections resulting in inversions near the waterfall.','Loaded from the Word file · approved 03/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 48 Rock Pukehinau Abseil','Ropes · Tongariro','48','Pukehinau Abseil','Abseiling cliff above old Pokaka Mill site','Pokaka Mill site BH34 171751','Yes','Yes','From Pukehinau stream','Refer Instructor Handbook and CMS Tongariro','Yes, refer DOC Concession','L1 Abseil competency','No prerequisites',null,'T1 Fundamental and T2 Handbook','Height of abseil 28 metres
Other users possible at site (BMAC or NZDF)',null,'Rope damage due to belay rope running over abseil rope
Dropped equipment (thermos & packs) numerous times
Clients scratching names into wall at bottom. Rope burn from static rope running over hands','Loaded from the Word file · approved 11/5/2026 by Lee Vaughan Centre Manager','G Swift'),
  ('AMP 50 Rock High Ropes Course','Ropes · Tongariro','50','High Ropes Course','Various activities within the High Ropes course.','Tawhitikuri Site','Local','YDC','YDC','Refer Instructor Handbook and CMS Tongariro
Refer Instructor Handbook and CMS Tongariro',null,'L1 or L2 High Ropes Course Competency','Clients to demonstrate belay technique prior to Climbers being exposed at height','Karabiners and Helmets from locker. All other gear including rescue available in HR shed','T1 Fundamental and T2 Handbook
Back up belayers to be used unless competent. Backup belayer must have a secondary form of belay e.g. prusik or belay device
Ladders must be secured when in use with groups
Instructor must communicate with DM before working solo at height. I.e. doing a cord retrieval.','Rope washer available for cleaning dirty ropes especially in winter. Hour Glass, Burma Brdge, Rock Hold Pole Closed',null,'Accidental clipping to cables, Instructor inattention to bad belaying, Structure Failure due to storm, Whiplash on Big Swing. 2013 Instructor falling from top of Giants Ladder, not correctly attached when abseiling off. Instructor inattention to correct attachment. 2023 Instructor left retrieval rope attached to client on Big Swing. Hair, clothing caught in belay devices- various','Loaded from the Word file · approved 11/5/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 51 Rock Indoor Climbing Walls (Tongariro)','Ropes · Tongariro','51','Indoor Climbing Walls','Rock climbing and bouldering on the resource centre rock walls (old and new walls, and upstairs bouldering cave)
Also for Turangi, Taupo and other indoor climbing walls','Resource Centre, Turangi Wall, Taupo Wall
Resource Centre, Turangi Wall, Taupo Wall','N/A','At venue','At venue','Refer Instructor Handbook and CMS Tongariro',null,'Rock (L1) Top rope, Rock (L3) Lead climbing','No Prerequisites','Bouldering pads when bouldering up (not for low level traversing just off the ground) or using old wall.','T1 Fundamental and T2 Handbook
Back up belayers to be used unless competent. Backup belayer must have a secondary form of belay e.g. prusik or belay device
Climbing wall to be locked when not actively supervised by an Instructor','Old climbing Wall Currently closed until belay inspected
No bare feet or socks on the wall or pads. Use climbing shoes or clean sneakers on the wall.',null,'2012 - Tertiary students using retired ropes 2011 - Student caught on bolt hangers Climbing unbelayed Eddy belay devices threaded incorrectly','Loaded from the Word file · approved 7/9//2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 51 Rock Waitomo Crags (Tertiary)','Tier 3 · Tertiary','51','Waitomo Area Crags','Lead climbing on boltsm limited trad. Top roping. Bouldering.','Pakeho Crag & Airstrip Bouldering
Pakeho Crag & Airstrip Bouldering','None. Hamilton Tomo Group (HTG) Hut at Waitomo.','@ car parks','None','Refer Instructor Handbook and CMS Tongariro','Pakeho – Yes. Register at least 48 hrs before for permission.Pakeho Crag Registration
And donate at Donate to Pakeho | Aotearoa Climbing Access Trust (maybe $10/person/day)
Airstrip – Yes. Call Ben & Bex Stubbs 07 878 7426 (or 021 042 1124) at least 24 hours prior. Also take money for koha (maybe $5/person/day?).','Top-rope/abseil - Ropes and Anchors L2 or NZOIA Rock 1
Sport leading - Rock L3 or NZOIA Rock 1 with SCE
Trad leading – Rock L4 or NZOIA Rock 2',null,'Bouldering mats for Airstrip','T1 Fundamental and T2 Handbook','Pakeho – Lots of very easy climbs. Very well bolted, usually chain and steel snaplink at top. Cell phone coverage. Some loose rock on left side of Main cliff. Access to anchors difficult in places to set top rope. Lots of crack’s, potential venue for trad climbing as well. 
Airstrip bouldering – A great half-day bouldering can be had at the Totem Area. Also De-Fenses Boulders and The Greek Gods are close by and good with groups. Remind students not to wander off-track (tomos) and to use spotters (and to spot properly).',null,null,'Loaded from the Word file · approved 16/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 52 Rock South Waikato Crags','Tier 3 · Tongariro','52','South Waikato Area Crags','Lead climbing on bolts. Top roping. Bouldering.',null,'@ Wharepapa South School. Also Hamilton Tomo Group (HTG) Hut at Waitomo.','Car parks @ Waipari, Castle Rock, Pakeho','None','Refer Instructor Handbook and CMS Tongariro.','Yes for all crags (except Waipari, but still good to call ahead and let them know we have a group coming). Check ACAT website for most up to date access info.
Waipari – Merry & Emma Schimanski 021 039 5593
Castle Rock – Sheena Warren, please email at least day prior wharepaparock@gmail.com $9/student
Sheridans - send a text to 027 527 1744 with (a) your full name and place of residence, (b) number in party, (c) your phone number and another form of contact, e.g. email, etc. If no text is received you will be asked to leave. Everyone needs to bring a second pair of shoes for biosecurity reasons.
Shawthings - Stephen Shaw 021 742 988
Airstrip – Ben & Bex Stubbs 07 878 7426 (or 021 042 1124) at least 24 hours prior. Also take money for koha (maybe $5/person/day?). 
Pakeho – Yes. Email Glowing Adventures at least 48 hrs before for permission. pakehocrags@glowing.co.nz Crag currently closed','Rock L3/NZOIA Rock 1 with sport endorsement or higher for sport lead climbing.
Rock L4/NZOIA Rock 2 for trad leading.',null,'Binoculars.
Stick clip for Castle Rock and some climbs at Waipari.
Bouldering mats for Airstrip.
Second pair of shoes for Sheridans.','T1 Fundamental and T2 Handbook','Pakeho – CRAG CURRENTLY CLOSED. Lots of very easy climbs. Lots of crack’s, potential venue for trad climbing as well. 
Airstrip bouldering – A great half-day bouldering can be had at the Totem Area. Also De-Fenses Boulders and The Greek Gods are close by and good with groups. 
Topos for all areas on www.thecrag.com',null,null,'Loaded from the Word file · approved 26/06/2024 by Jono Maxwell','Data import'),
  ('AMP 54 Rock Kawakawa Bay Crag','Ropes · Tertiary','54','Kawakawa Bay Crag','Lead climbing, top roping and abseiling using natural protection and some fixed anchors','Kawakawa Bay, Lake Taupo
Kawakawa Bay, Lake Taupo','Yes','yes','Yes Treat/Boil','Refer Instructor Handbook and CMS Tongariro','Refer, DOC Concession – Be aware of private land boundaries (everything past Capt Caveman)','Top-rope/abseil - Ropes and Anchors L2 or NZOIA Rock 1
Sport leading - Rock L3 or NZOIA Rock 1 with SCE
Trad leading or multi-pitch – Rock L4 or NZOIA Rock 2',null,null,'T1 Fundamental and T2 Handbook','Good site to teach Certificate and Diploma students.',null,'2016 - Instructor fall while top rope climbing, belayed by student, hit leg on ledge, broken ankle.','Loaded from the Word file · approved 16/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 55 Rock Kinloch 1.2 Crag','Rock Climbing · Tertiary','55','Kinloch 1.2 Crag','Lead climbing, top roping and abseiling using fixed anchors','Whangamata Bay, Lake Taupo','No','No',null,'Refer Instructor Handbook and CMS Tongariro','No','Top-rope/abseil - Ropes and Anchors L2 or NZOIA Rock 1
Sport leading - Rock L3 or NZOIA Rock 1 with SCE
Trad leading – Rock L4 or NZOIA Rock 2','Basic fitness level',null,'T1 Fundamental and T2 Handbook','30min walk from Kinloch town. New site so beware of loose rock. 
Good site to teach Tertiary, and for tertiary instruction of local Taupo school groups. 
Much quicker, easier and safer to lead the climbs than try and set up safeties from the top of the cliff. Watch for sharp rock and pendulums
 Topo at Kinloch 1.2, Sport climbing | theCrag',null,'2026 – Two brand new ropes had core shots.','Loaded from the Word file · approved 16/11/2026 by Lee Vaughan, Centre Manger','Data import'),
  ('AMP 56 Rock Dunedin Crags','Ropes · Tertiary','56','Dunedin Crags','Lead climbing on bolts (caves area) and trad (Sunnyside, main cliff)
Multi pitch climbing at Port Chalmers Quarry','Long Beach (Sunnyside, Main Cliff, Caves area)
Port Chalmers Quarry
Long Beach (Sunnyside, Main Cliff, Caves area)
Port Chalmers Quarry','No (Dunedin Holiday Park)','Yes','No','Refer Instructor Handbook and CMS Tongariro','No.','Sport leading - Rock L3 or NZOIA Rock 1 with SCE
Trad leading – Rock L4 or NZOIA Rock 2',null,null,'T1 Fundamental and T2 Handbook','Sunnyside at Long Beach great for trad leads. Can go to main cliff for "Meals on Wheels" (13), good easy trad, watch for loose rock. 
Caves area is good for sport leads (beware loose blocks) and bouldering.
Long Beach has great 3 pitch climb "The Great Escape" (16). 
After 3 days of torrential rain, all areas were climbable within hours. The caves area and pitch 1 of Great Escape can seep a little, but all good to go. Sunnyuside gets sun around 10am then dries super quick.',null,null,'Loaded from the Word file · approved 16/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 57 Rock Timaru Crags','Ropes · Tertiary','57','Timaru Crags','Lead climbing, top roping and abseiling using natural protection and some fixed anchors','Spur Road & Ht Horrible
Spur Road & Ht Horrible','No (Timaru Top 10)','No','No','Refer Instructor Handbook and CMS Tongariro','No. Please check during lambing season.
Spur Road - Ben & Kate Johnson 03 686 0579, 021 441 390
Mt Horrible - Geoff Hayward 027 497 5039','Top-rope/abseil - Ropes and Anchors L2 or NZOIA Rock 1
Trad leading – Rock L4 or NZOIA Rock 2',null,'Bring lots of rigging ropes for anchors (off tree roots)
Trad placements here lends itself to cams more than nut','T1 Fundamental and T2 Handbook','Good site to teach Diploma students.trad climbing',null,'.','Loaded from the Word file · approved 16/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 58 Rock Sebastopol Bluffs','Ropes · Tertiary','58','Sebastapol Bluffs','Multi-pitch lead climbing and abseiling. Mostly sport/bolted with very limited trad.','Stebastapol bluffs, Mt Cook villages
Stebastapol bluffs, Mt Cook villages','At DOC White Horse Campground (5min drive)','No','no','Refer Instructor Handbook and CMS Tongariro','N/a','Multi-pitch lead climbing– Rock L4 or NZOIA Rock 2',null,null,'T1 Fundamental and T2 Handbook','Good site to teach Diploma students multi-pitch sport climbing. Use Red Arete Area (3 x two pitch climbs side by side) and Crimea Wall (3 x two pitch climbs side by side)',null,null,'Loaded from the Word file · approved 16/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 59 Rock Tukino','Tier 3 · Tertiary','59','Tukino Crags','Lead climbing, sport and trad. Multi-pitch climbing.','Tukino
French Buttress
Master Angus
Mangatoetoenui
Rehab wall
Tukino
French Buttress
Master Angus
Mangatoetoenui
Rehab wall','Yes-Mangatoetoenui area, Tukino TASC Lodge.','N/A','Yes','Refer Instructor Handbook and CMS Tongariro','DOC Concession','Sport leading - Rock L3 or NZOIA Rock 1 with SCE
Trad leading and multi-pitch– Rock L4 or NZOIA Rock 2',null,'.',null,'French Buttress has three 2-pitch climbs beside each other (what out for loose rocks). Rehab wall (left hand end and middle of cliff) is best for trad leads',null,'2025- Student misreading topo and not being prepared for mixed sport natural trad climb at Rehab wall','Loaded from the Word file · approved 16/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 61 Water Lake Otamangakau Water Activities','Water · Tongariro','61','Lake Otamangakau','Sit on tops, sea kayaks, canoes, raft building on Lake Otamangakau and Lake Te Whaiau
Does not include the Wairehu Playwave','Lake Otamangakau and Lake Te Whaiau','Yes. NO FIRES ON GENESIS LAND','Long Drop at Otamangakau boat ramp. Otherwise LNT principles','Yes- Carry, Boil or Treat','Refer Instructor Handbook and Crisis Management Plan.docx','No. Lake is managed by Genesis Energy','Various depending on craft. Refer T2','Establish water confidence of participants','Poo Tube on Island and Canal campsite','T1 Fundamental and T2 Handbook
Bridge jump depth must be checked with weighted throwbag prior to activity-Greater than 2m depth required','With the bridge jump it easier to swim downstream with the current and get out on river right just after the passing under the bridge',null,'Boats blown away. Disgruntled fishermen. Hypothermic students. Awkward/sore landings from bridge jump – one bad landing from bum shuffling off Injuries from standing up in craft which was then pulled up on bank','Loaded from the Word file · approved 4/20/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 62 Water Lake Taupo Activities','Water · Tongariro','62','Lake Taupo','Sea Kayaking, Sit on Tops and Canoeing on Lake Taupo','Various around Lake Taupo','No',null,'Lake- Boil or treat','Refer Instructor Handbook and CMS Tongariro
Coastguard Channel 61 / TAU MAR radio channel','Hillary Outdoors has permission to use Taupo boat ramps without a permit. Be time efficient.','Sheltered Water: L1 Kayak/Canoe
Exposed Water: L2 Flatwater','Establish water confidence','Flare kit for exposed water','T1 Fundamental and T2 Handbook-(lake policies for sheltered water and Ocean-kayaking for exposed water
Wind consistently over 15kN and chance of being blown onto hazard (including being blown away from safe landing sites) need powered support vessel.','Check Taupo Marine forecast 
Use of marine vhf channels (except in an emergency) requires the user to hold a marine vhf operators certificate
Main bays Such as Waihi, Stump, Kinloch and Whakaipo Bays are L1 sheltered Water. However note that in a strong onshore winds these bays can quickly become L2 exposed water even if they are inside the sheltered water “line”. 
For Motuoapa Peninsula trip, sheltered in the bay in SW/W winds in the bay but exposed around peninsula in these conditions. Lake level @ 357masl = easy float through the lagoon ( www.mercury.co.nz/lakelevels ) Lake level 356.2masl = Marginal floating across lagoon, hard work in doubles. Any lower than this is a wade.
.Waihi bay-some shelter past Waihi Village in W/NW winds but wind can funnel through the main bay 
Kurutau, Whareroa to Te Hapua Bay-good shelter under cliffs in SW to NW winds, some exposure across Whareroa Bay. Winds have been known to gust at head of Te Hapua Bay in these conditions.',null,'Group of sea kayakers were blown off shore, ended up in the water and had to be rescued by the Coastguard (Waihi Bay)
Canoes struggling into wind on return trip. Very overdue, Coastguard involved (Stump Bay)
Rear of vans being hit by Sea Kayaks while turning/reversing.','Loaded from the Word file · approved 11/5/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 63 Water Kayaking G2-3 Tarawera Slalom site','Water · Tertiary','63','Water Kayaking G2-3 Tarawera Slalom site','Tarawera river
White water kayaking on the Tarawera Slalom Site','Kawerau
Kawerau','Kawerau Scout hall','Scout hall at Site','N/A','Refer Instructor Handbook and CMS Tongariro.','No','NZOIA Kayak 1 or level 3 competency',null,'Cell phone for communication- Coverage at site','T1 Fundamental and T2 Handbook
Offsite programme form','For Scout hall bookings call Michelle on 0272864881.
For flow use the Bay Of Plenty Regional Council environmental data web portal map on- https://envdata.boprc.govt.nz/data/map or https://flowrate.co.nz/river/tarawera-river/awakaponga 
Slalom site has great eddies to practice making more difficult moves on grade 2 white water.
Bottom of Slalom site is a good venue for a river rescue session.',null,null,'Loaded from the Word file · approved 12/10/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 64 Tongariro River - SOT, Inflatable','Water · Tongariro','64','Tongariro River- SOT, Inflatable','Sit-on-top kayaking and Inflatable kayaking on the grade two section of the Tongariro River.','Grade 2 section of the Tongariro River','N/A','Red Hut, Blue Pool and Tongariro Domain.','Lots - Boil/Treat','Refer Instructor Handbook and CMS Tongariro.','Yes, DOC concession required.','Trip leader = Kayak Grade 2 - Trip Leader (L2). Instructor = Kayak Grade 2 (L1)',null,'Whitewater helmets must be used. Whitewater PFD NZS type 406 must be used. Two waterproof radios for use on the river, stored under pigeon holes in office. Cell phone and PLB to be carried.','T1 Fundamental and T2 Handbook. Ratio 2:10+1 or 3:20+2 (2 instructors must meet the requirements above). Maximum 2 groups. Ratio 1:10, Kayak Grade 2 - Trip Leader (L2) if staying at Redhut pool. All participants must be within sight of an instructor at all times. Instructors on the river trip must nominate a Trip Leader. Instructors must have a system to communicate between each other at all times (hand or paddle signals). A radio on simplex channel must be carried by each instructor. This trip must be approved by the DM before morning meeting to give them time to think and organise. All clients must have demonstrated competency for the selected vessel prior to proceeding down river. All staff to carry a cell phone while on the river and ensure that the DM has the phone number.','Flow phone (07) 3868113 or www.genesisenergy.co.nz for levels.','Extreme weather, Temperature, Moving water, Speed','Raft hooked up in a strainer, and pinned on rock below Surprisingly Big Rapid. Fishermen wanted to beat up group and instructor after a wrap caused all crew to swim rapid and end up in a pool. Bruises from swimming rapids, student going down channel on Silly Pool. Strong winds affecting group and picking up a maverick and hitting someone (2023). Cave jacket being used, caught in maverick jacket, had to be cut out from craft (2023). Shoulder injury from paddle hitting shallow rock (2023).','Loaded from the Word file · approved 28/7/2025 by Lee Vaughan, Centre Manager','G. Swift'),
  ('AMP 65 Water Tongariro River Delta','Water · Tongariro','65','Tongariro River Delta','River travel down the Tongariro River and across Lake Taupo to Tokaanu','Lower Tongariro River Grade 1 section Grace Rd to Lake Taupo','N/A','Tokaanu Boat ramp','Boil or Treat','Refer Instructor Handbook and CMS Tongariro. 
Coastguard Channel 61 / Hillary Radio channel 9','Yes, DOC concession required.','Sea Kayak
Trip leader – L3 Sea Kayak or L2 Open water for sea Kayak + G2 Trip Leader or Equivalent 
Instructor - L2 Open Water Sea Kayak + L1 River Safety
Assistant - L1 Flat Water Sea Kayak + L1 River Safety

Canoe
Trip leader - L3 Grade 1+ Canoe or Equivalent 
Instructor - L2 Open Water Canoe + L1 River Safety 
Assistant - L1 Flat Water Canoe + L1 River Safety 

SOT kayaks or Mavericks
Trip leader G2 Trip Leader or Equivalent 
Instructor - L1 Flat Water Kayak + L1 River Safety
Assistant - L1 Flat Water Kayak + L1 River Safety',null,'Canoes must have Flotation 
Cell Phone and PLB to be carried','T1 Fundamental and T2 Handbook.
Sheltered Water is covered by T2 Lake, Exposed Water is covered by T2 Ocean
1:5 Boats Ratio 
All participants must be within sight of an instructor at all times
Instructors on the river trip must nominate a trip Leader
Instructors must have a system to communicate between each other at all times (hand or paddle signals. A radio on simplex channel must be carried by each instructor
This trip must be approved by the DM before morning meeting to give them time to think/organise.
All staff to carry a cell phone while on the river and ensure that DM has phone numbers
Wind max force 2 =< 12km/h for mavericks or Sit on Tops for Lake travel','Grace Rd – Not Always 2wd friendly 
Flow phone (07) 3868113 or www.genesisenergy.co.nz for levels
Check Taupo Marine forecast 
Use of marine vhf channels (except in an emergency) requires the user to hold a marine vhf operators certificate',null,'Canoes struggling into wind on return trip.','Loaded from the Word file · approved 03/11/2026 by Lee Vaughan,
Centre Manager','Data import'),
  ('AMP 66 Water Kayaking G2 Aniwhenua','Water · Tertiary','66','Kayaking – Aniwhenua','Grade 2 kayaking on the Rangitieki River from Aniwhenua power station to Galatea Road','Rangitaiki River GR BF39 317548 
Take-Out 342577
Rangitaiki River GR BF39 317548 
Take-Out 342577','Black Road Reserve','Black Road Reserve','Black Road Reserve','Refer Instructor Handbook and CMS Tongariro.','No','Kayak 1 or level 3 Competency',null,'Cell Phone must be carried.
PLB must be carried by the instructor in last boat.','T1 Fundamental and T2 Handbook','Length 8km-3 Hours
Flow guage - Flowrate – Rangtaiki river @Waiohau-https://flowrate.co.nz/river/rangitaiki-river/waiohau NIWA Rotorua (07) 3461950 Ask for the flow below Aniwhenua Dam
Good beginner to intermediate run. Excellent wave for learning to surf, good clean eddies.
First major rapid ‘Humpty Dumpty’ is long
New steps and handrail to access down – don’t need to lower kayaks.',null,'2012 – From WWNZ-Two kayakers caught in tail race bay after launching from structure-BoP Electricity banned launching from structure. Use rocks to launch off and consider using some protection, e.g. carpet.
???? – Boats dropped from above power station. ???? – Back injury from hitting shelf when running waterfall','Loaded from the Word file · approved 12/10/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 68 Water Canoe G2 Tongariro (Tongariro)','Water · Tongariro','68','Canoe – Grade 2 Tongariro River','Canoeing on the Tongariro River- Red Hut/Major Jones to SH1 bridge','Tongariro River – Blue Pool - Turangi','No','At Blue Pool, Red Hut and in Turangi','Yes','Refer Instructor Handbook and CMS Tongariro.','Yes, DOC concession required','NZOIA Canoe 1 or L2 competency and DM approval','Establish water confidence. Have participated in flat water session prior.','Refer T2 Handbook
Cell phone and PLB to be carried','T1 Fundamental and T2 Handbook
Up to Grade 2 Ratio 1:4 boats
River not to be used if a chance flow will go over 40cumecs','Refer AMP 64 Water Tongariro River SOT Inflatable for some minor hazards that exist for school programmes using the river. 
Flow Gauge - Genesis Energy Flowphone (07) 3868113 or www.genesisenergy.co.nz',null,null,'Loaded from the Word file · approved 03/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 68 Water Kayaking G4 Kaituna (Tertiary)','Water · Tertiary','68','Kayaking – Grade 4','Kaituna River
 White Water Kayaking at Okere Falls G4','Kaituna River, Okere Falls, Lake Rotoiti','No','At PowerStation carpark','No','Refer Instructor Handbook and CMS Tongariro.','No','NZOIA Kayak 2 or L3 Kayak competency and DM approval',null,'Refer T2 Handbook','T1 Fundamental and T2 Handbook','Put in at Slalom course. Take out after bottom hole. Grade 3 if put in below Tutea Falls(follow walking track to viewing point at bottom of falls.)
 Useful for advanced students and good intermediate below Tutea. Good eddies pool drop style. 
Slalom course can be intimidating for beginner students. Above and below bridge is great for intermediate slalom. More user friendly between 200-600 on gates
Read flow on gates at outflow from lake-good flows for students 200-600 . (300-400 ideal first run)
Rescues can be difficult at higher flows (400-600) with water in most pools still flowing through.
Can walk boats back up road for shuttle (10 min).
Last chance eddy has a get out before arriving at Tutea falls, after this committed to running.',null,'Anecdotal- Students swimming in Abyss have resulted in long swims or raft evacuations. Boats have gone over Trout Pool Falls after being unable to recover before this was reached at higher flows.','Loaded from the Word file · approved 26/06/2023 by Jono Maxwell, Centre Manager','Data import'),
  ('AMP 69 Water Kayaking Mohaka G2','Water · Tertiary','69','Kayaking– Mohaka River','Grade 2 White Water Kayaking on the Mohaka River from McVicars Road to Everett’s Campsite','McVicars Road GR BJ38 139562
Glenn-Falls Campsite GR BH38 174611 Everetts Campsite Gr BH38 207676','At Campsites','At campsites','At Campsites','Refer Instructor Handbook and CMS Tongariro.','No','Kayak Skills (L3)',null,'Cell Phone must be carried
PLB must be carried by the instructor in the last boat.','T1 Fundamental and T2 Handbook','Flow Gauge - online - http://www.hbrc.govt.nz/Services/Environment/Water/Pages/River-Flows.aspx
Lots of trees in water from logging and willows on the banks be aware of where water flow is going.
Good introductory run for grade 2. Each run Fishermans and Bridgets takes around 3-3 ½ hours',null,'Jan 2013- three students caught in trees two swum, one rescued from bank. See map for position of hazard.','Loaded from the Word file · approved 26/6/23 by Jono Maxwell – Centre Manager','Data import'),
  ('AMP 71 Water Tawhai Falls Jump','Water · Tongariro','71','Tawhai Falls Jump','Jump off Tawhai Falls above 3m at approved jump site','Whakapapanui river at Tawhai Falls','N/A','No','Yes','Refer Instructor Handbook and Crisis Management Plan','Yes, DOC Concession',null,null,'Life- Jackets, Instructor sling, Throwbag','T1 Fundamental and T2 Handbook','Use Scaffolded approach: swim in the Tawhai falls pool, brief and jump from <3m rock, brief and jump from Approved Jump-site only.
Challenge by choice',null,'2015 Client fell badly causing damage to inner ear.
Students landing badly from top. Sore bums/backs','Loaded from the Word file · approved 03/11/2026 by Lee Vaughan,
Centre Manager','Data import'),
  ('AMP 72 Water Whanganui River Travel','Water · Tongariro','72','Whanganui River','River travel on the Whanganui River between Taumarunui and Whanganui using Canoes or Sea Kayaks','Whanganui River','Yes – booking required for huts during peak season','yes','At campsites (needs to be Treated or boiled)','Refer Instructor Handbook and CMS Tongariro','Yes, refer DOC concession. Booking Required','L3 Moving Water Canoe (or equivalents/logged Canoe experience)
Instructor- L2 Open Water Canoe personal skills + L1 River Safety','Establish Water Confidence','Refer T2, PLB. Inreach or Satellite Phone, Repair Kit
Radios for Instructor to Instructor coms on Simplex
Appropriate buoyancy in canoes. (Could be well secured gear barrels)','T1 Fundamental and T2 Handbook.
Trip Flow matrix-Cut off flows for trips-Te Maire (>2100mm), Ohura R @Tokorima (>4100mm) Wades Landing (>3100mm), Pipiriki (>5100mm) - Saved on Q drive.Whanganui River Flow Guidelines.docx
Communication and route plan to be organised with DM and stated on the Offsite Programme Plan or specific program plan and communications plan','DOC Whanganui website. NZRCA Guide to the Whanganui River. Bookings required during great walk season.
Local interp, river level information and catchment map found on Q-drive.',null,'2021 & 2022- Student pinned canoe on log in flow 2022- Off water at end of twilight x2 June 2022','Loaded from the Word file · approved 03/11/2026 by Lee Vaughan
 Centre Manager','Data import'),
  ('AMP 73 Water Kayak Piriaka','Tier 3 · Tertiary','73','Kayaking – Piriaka','G2 White Water Kayaking on Whanganui River between Piriaka and Taumarunui','Put in - Piriaka 
Take out - Taumarunui','no','no','no','Refer Instructor Handbook and CMS Tongariro',null,'Kayak Skills (L3)',null,null,'T1 Fundamental and T2 Handbook','Put in Piriaka power station. Take out river left before 2nd bridge. Drive past camp ground before bridge.
Take out has big safe eddy for rolls etc
Lots of rocks to eddy behind at low flow. Don’t get too scary at high flows',null,null,'Loaded from the Word file · approved 26/6/23 by Jono Maxwell, Centre Manager','Data import'),
  ('AMP 74 Water Kayaking Waikato Reids Farm','Tier 3 · Tertiary','74','Kayaking – Waikato (Reids Farm)','G2 Kayaking on the Waikato River from Control Gates to Reids Farm Slalom Course','Waikato River (Reids Farm)','Yes','yes','N/A','Refer Instructor Handbook and CMS Tongariro','no','NZOIA Kayak 1 or equivilant',null,null,'T1 Fundamental and T2 Handbook','Water levels can vary by over 1.5 m. Very low level <80 cumecs there are more powerful eddies on far right channel, and finish below islands on left. Water levels >280 means area is washed out and semi useful.
Get out sight for on river left 50m below islands. Slippery, but can walk back to lagoon. Next take out 150m down on left but trees in way.',null,null,'Loaded from the Word file · approved 27/6/23 by Jono Maxwell, Centre Manager','Data import'),
  ('AMP 75 Water Pukehinau Stream Travel','Water · Tongariro','75','Pukehinau stream travel','Sitting on a tyre inner tube or swimming and floating from the start of the Pukehinau Gorge, to the take out 300m before the Pukehinau Cave. Grade one rapids and flat water.','Pukehinau Stream
GR 168752 - GR 174756','Pokaka Mill, Pukehinau Rd end','Yes','Yes- boil or Treat','Refer Instructor Handbook and CMS Tongariro','DOC concession required',null,null,'Wetsuit, thermals, windproof jacket, Helmet, PFD
PLB
Inner tubes and spare (if using)','DM to authorise access immediately prior to entering, and be informed upon exiting stream.','Pukehinau stream is a very cold environment
Blue Duck season end of November to mid December
Take a spare tube – high potential for a puncture',null,'Cold students, sticks and lots of punctured tubes especially when the water is low, bumps and bruises','Loaded from the Word file · approved 03/11/2026 by Lee Vaughan,
 Centre Manager','Data import'),
  ('AMP 76 Water Kayaking Murchison G2-3','Tertiary','76','Water Kayaking Murchison G2-3','White water kayaking on runs based around Murchison','Murchison','N/A','N/A','N/A','Refer Instructor Handbook and CMS Tongariro.','No',null,null,'Cell phone for communication-
PLB., Inreach','T1 Fundamental and T2 Handbook
Offsite programme form','Flow Guage - Buller river-http://www.tasman.govt.nz/environment/water/rivers/river-flow/riverflow-275/
Flowphone-03 543 8555-Buller River Flow at Longford (6/10/22 info from NZ Kayak School- gauge reading 30 cumecs under real flow i.e 100cumecs=130cumecs. Matakitaki gauge not reliable for real river flows use visual for Matakitaki)
Buller River up to 150 cumecs for working with groups.
Other river runs visual gauge
Buller River big volume characteristic, easy to have group separate. Long way to next eddy at times.
Staff at kayak school good resource for state of runs in the area. (12/9/2025- no significant hazards to update)
 Mangles run great if Buller River above 150 cumecs. Middle Matakitaki can be run at most flows as well.',null,'2002- Polytech -Fatality kayaker caught on strainer and drowned – Earthquake section Buller R see attached findings from WWNZ.','Loaded from the Word file · approved 12/9/2025 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 77 Water Upper Mangatepopo Steep Creek Trip','Tier 3 · Tongariro','77','Upper Mangatepopo Steep Creek Trip','Hike into the Upper Mangatepopo from Highway 47. Walking, swimming, climbing, jumping downstream. There are a number of 2-3m jumps and rapids to swim with an optional 7m jump, get out or abseil 20m, then bush bash 1hr back out to SH47. 

NOTE: 20m Abseil has a separate AMP','Above the Mangatepopo bridge on State Highway 47-Park at culvert 189','No','No','Yes- Boil or treat','Refer Instructor Handbook and CMS Tongariro.','No','Trip Leader - L3 Upper Mangatepopo Trip Leader
Trip Assist - L2 Upper Mangatepopo assist
Ratio 2:10+2 or 3:20 + 2
Note: For the Abseil, L2 Rock and the Falls Endorsement is required',null,'Throw bag, short sling around instructors waist, PLB, Dive mask, stove kit (Consider for cold days), Student Harnesses, Instructor Harnesses, Canyon Map','T1 Fundamental and T2 Handbook
For a group of known competence. 
Consider group experience before using as a first day activity','Canyon hazard map 
Gauge installed under SH bridge-establish flow before starting trip.
New Flagged route around 7m jump- use to get visual gauge on flow on way into start of trip.(see picture below for flow level.)',null,'Student sustained a minor back injury while climbing out of the stream at the entry/exit point between main waterfalls.
Student and Instructor slipped down Drop 4 – Went very deep','Loaded from the Word file · approved 11/5/26 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 79 Water River rescue Grade 2 Tongariro','Water · Tongariro','79','River Rescue– Grade 2 Tongariro River','River rescue for skills or assessment incl:River crossing, river swimming, throwbagging, shallow water entry.','Tongariro River – Blue Pool/Red Hut/ Major Jones sites','No','At Blue Pool, Red Hut and in Turangi','Yes','Refer Instructor Handbook and CMS Tongariro.','Yes, DOC concession required, Record Use of Blue Pools Road for Ngati Tuwharetoa Concesssion','NZOIA Kayak 2, L4 Kayak comp or NZOIA Kayak 1 or L3 River Rescue competency.',null,'Refer T2 Handbook-Boat for rescue not required if not instructing clients in boats.','T1 Fundamental and T2 Handbook River policies','Refer AMP 64 Water Tongariro River SOT Inflatable/ 70 kayaking – Grade 2 Tongariro R for some minor hazards that exist for school programmes using the river. 
Flow Gauge - Genesis Energy Flowphone (07) 3868113 or www.genesisenergy.co.nz
Key River Rescue Instructional points and Lesson outline in: River Rescue Instructional Points (Training and teaching/Instructing and assessment resources)',null,'None of note at Hillary Outdoors, however, there have been numerous incidents when practicing for rescue within the industry. It is important to look after the rescuers.','Loaded from the Word file · approved 11/5/26 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 81 COR Support Boats','Coromandel · Coromandel','81','COR Support Boats','Driving outboard powered support boats | camsing | wa | totts | wa | water | Carry water supplies','Northern Coromandel',null,null,null,'Handbook and Emergency Response Plan Access Permission Required? None','Required? None','Kaitiaki - Level 2 -over 15Kn or > 1.5m swell',null,'Refer instructor handbook and Safe Operational oy a and environment','Required Plan','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

4 Activity Management Plan - Tier 3 HI LLA RY
OUTDOORS
Updated G Swift 4
Activity 81 COR-Support Boats iy wil Location Northern Coromandel
Activity Description Driving outboard powered support boats | camsing | wa | totts | wa | water | Carry water supplies
Refer Safe operaqtional Plan, Instructor po 4
Emergency Response Handbook and Emergency Response Plan Access Permission Required? None
Maritime NZ Certificate of Competency-
Kaitiaki- Level 1 — under 15 Kn up to 1.5m swell
Instructor Requirements Kaitiaki - Level 2 -over 15Kn or > 1.5m swell
Hazard/ Evacuation maps_ | Refer Tsuanami Evacuation Zones Manaia- Level 2 - < 30Kn and/or <2m Swell
Client Requirements
Clients should be briefed according to safety brief in SOP
es . Refer Instructor handbook for policies on equipment, methodology
Specific Equipment Refer instructor handbook and Safe Operational oy a and environment
P Specific Policies
Required Plan
Safe Operational Plan and Maritime NZ approved training plan
eS ¥ rf} ] >
Key Hazards B a
Extreme Weather Deepwater MOVingwater Sneed tsunami Remote
Incidents from GBI: Damage to prop from hitting bottom Damage to inflatable pontoons from hitting wharf
Perera Loss of steering Boat drifted loose from painter pontoon
revious Incidents Difficult to start Manaia grounded at Bradshaw’s and BBQ Bay by
Damage to skeg when putting away outgoing tide
Safety Management
Skipper must maintain an appropriate lookout at all times, and know give way rules. Apply all Sknot speed
Collision with shore or other vessel restriction rules.
Check charts for shallow areas, visually check for rocks. Paddle out to where water is deep enough before starting
motor
piof3 A

A “IT” Activity Management Plan - Tier 3 HILLARY
OUTDOORS
Avoid travelling at speed where shallow water could be encountered. 5 knots if within 5m depth Little Sandy Bay
known to be shallow at low tide under 0.5m and stays shallow for awhile
Ensure engine is off or in neutral when coming alongside a swimmer. Boat must be travelling slowly or water
Unguarded propeller speed can turn prop fast
Ensure passengers are seated properly when underway
Driver thrown from boat Always driving at a controlled speed for the conditions. Always wear kill cord
Water Environment _ PFDs to be worn at all times. Check weather forecast and wind direction before departure, keep weather eye out
Weather / wind conditions change quickly Understand and check influence of tide, tidal streams, and currents
Kaitiaki recommend at least 2 people on board in winds over 25 knots.
Overloaded Boat Maximum loading for Kaitiaki is 8 people including the skipper, for Manaia is 15 people including skipper.
Recommended loading is 6 and 13
Skippers trained in navigation. Chart and torch availabl
Loss of visibility due to nightfall, fog, rain. “pers trained in Navigation, Gham ang roren avatar’ ,
. fs oe Kaitiaki - Plan voyage to not require travel at night, if caught out at night ensure other vessels can see torch
Admin No nav lights on Kaitiaki . ;
Travel slowly if caught out at night
Equipment not secure in boat Drive conservatively, ensure equipment is well secured
[Pee | Equipment or fuel insufficient Complete pre-departure checks as per SOP — radio, flares, spare paddles, throwbag, tool kit, torch, spare pullstart
etc
Vessel poorly maintained Complete monthly checks and yearly service, as per SOP
Refilling fuel containers Always remove fuel tank from vessel when refuelling Kaitiaki
8 Use a funnel and fill carefully Have absorbent material on hand to soak up spills
Vessel and wildlife together in close proximity Allow wildlife its own space e.g. let dolphins / whales approach the vessel, rather than approaching them
Crayfish pots and mussel farms Watch for crayfish pots large clusters around Stoney bay and towards Rowner bay, If travelling within 200m of
Admin] mussel farms keep below Sknots, also watch for ropes coming parallel from the farm
. Sek a)
Approved Hayden Devine, Centre Date 05/05/2026 Review in 1 year From date of approval Signed S SS =
y managers ee
p2of3 A

AMP Activity Management Plan - Tier 3 HI LLARY
OUTDOORS
Hillary Outdoors Coromandel- Manaia Operational Limits
watts wey annie nee sore re area Port Cha ses to Waikawau Bay The normal operating limits are on the eastern side of Coromandel, Sugar Loaf rocks, in the North to
and Papaarohoa to Coromandel town. No operation of Kaitiaki outside of these identified Anareke Point in the south. On the Western side from Urarima Stream (1.5km North of Waiaro) to
areas: Papaaroha. Support boats may be taken outside of ‘normal limits’ (blue zone) with explicit
eaniiieiaiiaa permission on the day from the Duty Manager. Normal operation will be less than 1 nautical mile
appre from shore, with Duty Manager approval can operate more than one mile but no more than two
eee miles offshore. Under no circumstances is it permitted to operate outside of the limits detailed
a % — - below.
rs sy got: a ot) ee ee
=a BK The F = 8 ao ana 7"
; CGE Se yee oN \ . : Se
Pe 2): 2e Ol die > °< . 7
Se ae.
+ Garr >> BST
heck De
/| ; - “Ase aa A Acc nal
—— AES Mee? } oT zi
: i — Dy aed ‘ " 7 “I Maca
Bs AY | “a yp N So =
“ “et t nf son i 2
yl 5 Dek . “WI AS wore A")
Y ee z sl 4 i. e a ed
‘ kas eet Si : = 553 = AT 6
3 Oe | Ne
of eae oe POC SE LB te
Nai Boe fo TP See LD eee
| | camo on Rete. (; ne Bae oy:
re 3 . Sy ae = rar
of + (SR - So) | fe Se Yale MES {
DM Approval ih! e & acs ‘ky ee pees “HO P| f
ot Ni | gl |S sre ‘ aed 4 SC Sue
F ae ‘ '' (a*) a ° Mitre | ( See
Coss ON LL. Amt PES. Bent 2 pele > Ss
See Ee... | Whi Fh E if Zi. ae
paora AMP

','B a',null,'Read from a scan of the paper copy','Data import'),
  ('AMP 82 Driving (Coromandel)','Coromandel · Coromandel','82','Driving',null,null,'NIA NIA vellats NIA',null,null,null,'Response plan Required?','Appropriate licence for vehicle',null,'Specific Policies T1 and T2 handbook','T1 and T2 handbook','Read from a scanned copy, so the wording may be rough and the hazard table is not complete. Send the Word version to load it properly.

A AN
Activity Management Plan- Tier 3 HILLARY
OUTDOORS
ee Northern C del and envi
Activity Driving Hillary Outdoors vehicles with or without . .
Description students on all roads used by Hillary Outdoors camping NIA NIA vellats NIA
Emergency Refer instructor handbook and crisis management Access Permission
Response plan Required?
Hazard
Evacuations Instructor requirements Appropriate licence for vehicle
maps
Specific
Equipment Specific Policies T1 and T2 handbook
Required
Hillary Outdoors Drug & Alcohol policy
Other * Hillary Outdoors Driving Policy . .
resources and | + Handbook - transportation GLais GempaTELS None
notes + Road Code
+ Break down checklist
\ IO
oqo
Key Hazards €?) 5 . ey
Rock/Icefalt Extreme Weather
Speed
Previous Near miss on Caves Rd (Tongariro) between two vans, Clients hanging off trailer while being moved, trailer dropping of road to avoid oncoming traffic, trailer coming off - not attached properly
Incidents (Previous near misses from Tongariro and GBI)
Safety Management
V cose [rarer «dM gememestmtegy
Collisions on narrow or poor condition roads Drive slowly and be prepared to stop at any time
Steep drop offs Take it slow! Be aware of downhill road edge after rain, edge softens and is prone to give way
Steep roads and brake fade Use engine braking wherever possible, lower gears. Control speed.
Driver unfit to drive due to being too tired, poor health, under the | POn’t drive. Contact DM.
influence of drugs and/or alcohol Refer to the “Drug and Alcohol policy”
Injuries while dealing with the changing of tyres Refer to individual vehicle checklist;
- Wear hi viz vests
p 1of 2 A

A or
Activity Management Plan- Tier 3 HI L LARY
~ Take keys out of ignition and into pocket of person doing the work om
- Put the handbrake (and chock if necessary)
- Consider radioing for assistance if required
Sign vehicle out correctly
Unsafe vehicle driven Report damage immediately.
Maintenance to remove keys of vehicles not in use
Current WOF or COF.
- 7 RUC checked Vehicle checks
Poor vehicle condition
Refer to vehicle check lists
Report damage ASAP to maintenance
Children on roads and carparks around Hillary Outdoors. Hitting Drive slowly Check behind vehicle before backing Back out slowly!
structures
Rockfall onto roads Be wary driving during or after heavy rain
Unattended students in vehicles Ensure keys are removed. Refer to supervision policies in Instructor Handbook.
JaMInE | Handbrake not holding Check holding of handbrake before leaving vehicle. Leave in gear if appropriate. Ensure handbrake on tight before leaving
vehicle when parked on hill.
Excessive wear on engine / gearbox/ clutch and other vehicle parts. _| Refer Maintenance for correct engine/stop/start procedures
Wash down vehicle after parking by coast
Admin | Ocean Spray causing vehicle rust
Clean vehicle inside if driving salty passengers
i, 5
a Hayden Devine, Centre Manager Date 05/05/26 Review in 1 year From date of approval | Signed SSL ed
p2of2 A

','€?) 5 . ey',null,'Read from a scan of the paper copy','Data import'),
  ('AMP 82 Other Swimming Pool (Tongariro)','Other · Tongariro','82','Swimming Pool
(for kayak rolling)','Swimming pool and designated activities: Swimming and kayak rolling.','Tawhitikuri, Resource Centre','N/A','Yes','Yes','Refer Instructor Handbook and CMS Tongariro','No','Staff induction Training',null,null,'T1 Fundamental and T2 Handbook','Hazards other than those listed do exist. Refer over page, pool rules for management strategies
Induction training to cover pre-session checks and security
Pool gets checked every morning that Maintenance is on site.',null,null,'Loaded from the Word file · approved 03/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 83 Other Competitive Events','Tier 3 · Event','83','Competitive Events','Structured competitive activities including running, raft building, team challenges etc.','Tongariro Centre
Tongariro Centre','n/a','n/a','n/a','Refer instructor handbook and CMS Tongariro.
Event may have specific communication plans or contingency response plans. Refer Instructor briefing','Refer Event Details',null,null,'Refer Instructor handbook. Some of this equipment may be left behind, and other gear taken, as the activity requires. Refer to Event briefing for gear requirements for clients','T1 Fundamental and T2 Handbook','Other AMPs may also be relevant to the activity e.g. High Ropes. These AMPs will be provided in the instructor activity notes.',null,'Competitors driving themselves too hard. Instructors left behind by the group. Rockfall. Poor belaying due to going too fast. Hypo-natraemia (insufficient electrolytes). Broken ankle. Broken Leg. Fall to road from incorrect operation of flying fox activity. Instructor left behind by group after not maintaining own hydration & energy, then handing over control of point scoring ability (GPS).','Loaded from the Word file · approved 4/9/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP 87 Supervising Instruction Events','Supervising Instruction Events · Event','87','Supervising Instruction Events','Certificate and Diploma students instructing local school students for short instructional events in bush, rock/abseil, alpine and flatwater kayaking','Can include but not limited to;
Bush – Taurewa Loop, Lake Rotopounamu, Opepe Reserve, W2K, K2K
Rock – Halfmoon, Whakapapa, Meads, Kinloch, local climbing walls
Kayak – Local lakes, Waihi Bay, Stump Bay, Taupo waterfront, Acacia Bay, Kinloch
Alpine – Whakapapa Ski area and immediate surrounds
Can include but not limited to;
Bush – Taurewa Loop, Lake Rotopounamu, Opepe Reserve, W2K, K2K
Rock – Halfmoon, Whakapapa, Meads, Kinloch, local climbing walls
Kayak – Local lakes, Waihi Bay, Stump Bay, Taupo waterfront, Acacia Bay, Kinloch
Alpine – Whakapapa Ski area and immediate surrounds
Can include but not limited to;
Bush – Taurewa Loop, Lake Rotopounamu, Opepe Reserve, W2K, K2K
Rock – Halfmoon, Whakapapa, Meads, Kinloch, local climbing walls
Kayak – Local lakes, Waihi Bay, Stump Bay, Taupo waterfront, Acacia Bay, Kinloch
Alpine – Whakapapa Ski area and immediate surrounds',null,null,null,'Refer Instructor Handbook and CMS Tongariro','Refer to site specific T3 AMPs','Bush – NZOIA Bush Leader or L2 Bush Comp
Rock – NZOIA Rock 1 or L2 Rock Comp
Kayak – NZOIA Kayak Leader or L1 Flatwater with river safety
Alpine- NZOIA Alpine 1 or L2 Alpine Winter','Basic fitness',null,'Maximum staff to model client ratios
Bush – 1 staff: 20 clients
Rock/abseil – 1 staff:16 clients
Kayak – 1 staff:10 clients
Alpine – 1 staff:10 clients
(Note this differs from ratios in Tier 2 Handbook. In these situations we have Tertiary Student Instructors who are competent in the environment helping to instruct and manage clients)
T1 Fundamental and T2 Handbook
Site specific T3 AMPs must be used in conjunction with this AMP',null,null,'Sept 2026 – client split head after paddle hit his head, not wearing helmets playing paddle games on shore.','Loaded from the Word file · approved 16/11/2026 by Lee Vaughan, Centre Manger','Data import'),
  ('AMP Bush Tertiary','Bush · Tertiary',null,'Tertiary Bush','Tramping on and off track','Various
Various','Yes, various','LNT principles','Yes, boil or treat','Refer Instructor Handbook and CMS Tongariro','Yes, Refer DOC Concession','On-track - Bush (L1) or NZOIA Bush Leader 
Off-track - Tramp and Multi-night Camp (L2) or NZOIA Bush 1','No Prerequisites',null,'T1 Fundamental and T2 Handbook','There are GPS or InReach available for use if needed. DM may request you carry one due to lack of knowledge of an area or track or poor radio comms.',null,'Lost student (Certificate)','Loaded from the Word file · approved 16/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP Rock Wharepapa South','Tier 3 · Tertiary',null,'Rock Wharepapa South','Rock climbing, sport lead and top rope','Waipari, Castle Rock, Shaw Thing and Sheridan crags, South Waikato.
Waipari, Castle Rock, Shaw Thing and Sheridan crags, South Waikato.','Yes-Wharepapa South school.','N/A','Yes','Refer Instructor Handbook and CMS Tongariro','Yes for all crags (except Waipari, but still good to call ahead and let them know we have a group coming)','Top-rope/abseil - Ropes and Anchors L2 or NZOIA Rock 1
Sport leading - Rock L3 or NZOIA Rock 1 with SCE',null,'Extendable stick clip (we bought on e and lives in tertiary gear shed), first bolt quite high in this area, particularly at Castle Rock','T1 Fundamental and T2 Handbook','All crags are on working farms. 
Waipari - Some good easy climbs. Watch out for ledge on slug wall. Need to pay fee to COW (Community of Waipari).
Castle Rock has pull cords setup for easy access. Need to pay fee per student per day.
Shaw thing crag: River wall has some easy slabs, 10 minute walk from car park to camp site.
Need second pair of shoes for Sheridan (need to change footwear)',null,'None','Loaded from the Word file · approved 16/11/2026 by Lee Vaughan, Centre Manager','Data import'),
  ('AMP Tertiary Snow Sports','Alpine · Tertiary',null,'Tertiary Snow Sports','Skiing and Snowboarding within the Whakapapa Ski area. Lessons provided by Whakapapa Ski Area','Whakapapa
Whakapapa','N/A','Cafes','Cafes','Refer Instructor Handbook and CMS','No','Level 1','None','Refer Tier 2 Handbook
Industry standard helmets must be worn (hire if necessary)','T1 Fundamental and T2 Handbook','Weather report and Whakapapa snow report
Driving summer and winter AMP',null,null,'Loaded from the Word file · approved 16/11/2026 by Lee Vaughan, Centre Manager','Data import')
) as v(name, folder, num, title, activity_description, location, camping, toilets, water, emergency_response, access_permission, instructor_requirements, client_competencies, specific_equipment, specific_policies, other_resources, key_hazards, previous_incidents, summ, by)
join activities a on a.name = v.name
on conflict (act_id) do nothing;

commit;

-- what landed:
select (select count(*) from activities) as activities, (select count(*) from amps) as amps;
-- expect activities = 80, amps = 80
