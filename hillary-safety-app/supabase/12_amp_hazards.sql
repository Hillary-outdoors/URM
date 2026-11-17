-- URMA · step 12 · The hazard table inside each AMP
-- Safe to run again. Paste the whole file into Supabase > SQL Editor and press Run.

begin;

insert into amp_hazards (amp_id, sort_order, control, activity_part, hazard, management_strategy)
select m.id, v.so, v.control, v.part, v.hazard, v.strategy
from (values
  ('AMP 1 ABL Low Ropes Course',10,'Minimise','Prouties Landing – Swinging between two platforms at ground level','Falling','Participants to keep feet out of loop at end of rope. Spotters to arrest swing.'),
  ('AMP 1 ABL Low Ropes Course',20,'Minimise','Prouties Landing – Swinging between two platforms at ground level','Rope burn','Disclose risk. Participants to let go and land safely on feet.'),
  ('AMP 1 ABL Low Ropes Course',30,'Minimise','Trust Fall - falling backward off platform being caught by rest of team.','Falling','Minimum 8 spotters. Spotters to have arms zipped with spotters opposite, palms facing up, knees flexed, foot closest to faller extended backwards with head back. Remove watches etc. The faller should maintain a rigid body and be guided to ensure they fall in line with the spotters. Ensure take off site is no higher than shoulder height of participants. Good system of communication between spotters and faller so faller doesn’t fall prematurely. Good progression beforehand. Helmets are not to be worn.'),
  ('AMP 1 ABL Low Ropes Course',40,'Minimise','Trust Fall - falling backward off platform being caught by rest of team.','Moving Limbs','The faller should have arms folded in front with fingers interlocked, “bumpers up” to prevent injury to spotters.'),
  ('AMP 1 ABL Low Ropes Course',50,'Minimise','Swinging Log','Swinging log','Disclose to participants, Brief not to move between log and upright poles during activity'),
  ('AMP 1 ABL Low Ropes Course',60,'Minimise','Flea Jump - jumping between two platforms waist height','Slippery surfaces','Disclose risk and ensure spotters and jumper are aware of slippery surfaces. Spotters are in position for backwards slips'),
  ('AMP 1 ABL Low Ropes Course',70,'Minimise','Spiders web','Injury caused by falling or lifting','Instructor to brief students adequately on spotting and lifting techniques'),
  ('AMP 1 ABL Low Ropes Course',80,'Minimise','Whale Watch – balancing platform at Taurewa','Heavy platform','Disclose risk of feet being crushed. Brief not to be silly and jumping about. Blocks of wood to be replaced upon completion of task'),
  ('AMP 1 ABL Low Ropes Course',90,'Minimise','Tyre Pyramid – Stacking tyres activity','Heavy tyres','Disclose risk, teach safe lifting techniques. Consider,1 person to lift tyre 1, 2 for tyre 2, 3 for tyre 3 and so on. Disclose risk of trapping fingers between tyres and upright.'),
  ('AMP 1 ABL Low Ropes Course',100,'Minimise','Thread the needle – Climbing pole to get tyre over the top.','Tyre being dropped','Disclose risk'),
  ('AMP 1 ABL Low Ropes Course',110,'Minimise','Thread the needle – Climbing pole to get tyre over the top.','Students at height','Ensure anyone more than 1m off ground has adequate spotters'),
  ('AMP 1 ABL Low Ropes Course',120,'Minimise','General','Wire Cables and eyebolts around ground level','To be highlighted upon entering the area. No running.'),
  ('AMP 1 ABL Low Ropes Course',130,'Minimise','General','Falling / slipping','Correct spotting technique to be used. Disclose risk of leaning back when on elements; spotters to be placed appropriately. Safe technique disclosed for landing on ground e.g. step down don’t fall'),
  ('AMP 1 ABL Low Ropes Course',140,'Minimise','General','Structure – hard / slippery surfaces','Disclose risk of hard objects, slippery surfaces, bolts, splinters, wires etc.'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',10,'Minimise','ORIENTEERING - Rogaine style orienteering around Tawhitikuri site','Lost student','Student instructed not to travel more than 10m off track or road, Students to stay put and blow whistle if unsure of their location, Students to be given a specific return time to the Resource Centre'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',20,'Minimise','ORIENTEERING - Rogaine style orienteering around Tawhitikuri site','Unaccompanied students','Students instructed to be aware of traffic on road. In case of emergency, students instructed to return to Resource Centre as quickly as possible'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',30,'Minimise','URBAN CAVING - Crawling through a storm water drain under driveway at MOW','Injury from metal plate falling','Instructor to ensure safe removal and replacement of metal plate (at uphill end of drain). Use two participants per handle to move heavy metal plate.'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',40,'Minimise','URBAN CAVING - Crawling through a storm water drain under driveway at MOW','Injury from hitting head on cave roof','Participants to wear helmets for the duration of the activity'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',50,'Minimise','URBAN CAVING - Crawling through a storm water drain under driveway at MOW','Injury from gravel and foreign object in drain','Encourage students to wear long pants. Check, and remove rubbish if necessary.'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',60,'Minimise','ELECTRIC FENCE - 

Climb over a low fence','Injury caused by falling or lifting','Instructor to brief clients adequately on spotting and lifting techniques, Ensure site is clear of trip hazards before commencing activity.'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',70,'Minimise','ALCATRAZ - Participants climb over high wall and lower safely to other side','Falling from height','Instructor to brief students adequately on spotting. Students to use platform on back while providing support, not to straddle the wall'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',80,'Minimise','ALCATRAZ - Participants climb over high wall and lower safely to other side','Lifting','Brief participants on how to lift. Check med forms for any existing back problems.'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',90,'Minimise','CRATE CROSSING - Using milk crates to cross Mangatepopo Ford','Vehicles','If gate is unlocked/open instructor and group to be aware of vehicles. Make group visible from road.'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',100,'Eliminate','CRATE CROSSING - Using milk crates to cross Mangatepopo Ford','Flooding','Activity not to be done when weather state is Red due to rain.'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',110,'Minimise','CRATE CROSSING - Using milk crates to cross Mangatepopo Ford','Slippery surfaces','Instructor to disclose risk.'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',120,'Minimise','SPIDERS WEB - Participants get passed through large web made from elastic','Injury caused by falling or lifting','Instructor to brief students adequately on spotting and lifting techniques'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',130,'Minimise','SWAMP ACTIVITIES - planks of wood used to get from one place to another','Planks','Brief students on safe use of planks including not throwing or swinging. Appropriate footwear must be worn.'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',140,'Minimise','SWAMP ACTIVITIES - planks of wood used to get from one place to another','Cold','Students can get very wet if falling into water. Minimum equipment as per T2 handbook. Consider not doing if weather is bad.'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',150,'Minimise','GENERAL ACTIVITIES - such as magic hat, tag, marshmallow squares, shrinking island etc.','Falling','Correct spotting technique to be taught'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',160,'Minimise','GENERAL ACTIVITIES - such as magic hat, tag, marshmallow squares, shrinking island etc.','Falling','Correct spotting technique to be taught'),
  ('AMP 2 ABL Local Initiatives (Tongariro)',170,'Minimise','GENERAL ACTIVITIES - such as magic hat, tag, marshmallow squares, shrinking island etc.','Emotions','Instructor to select activity for group based on group ability. Proper progression to be run before doing activity. Challenge by choice to be operating. Instructor to think about amount of physical touching.'),
  ('AMP 3 Pool Tyrolean',10,'Minimise',null,'Moving pulley- finger injury','Brief to keep hands away from pulley when moving along rope, consider gloves if being run as a competitive event'),
  ('AMP 3 Pool Tyrolean',20,'Minimise','Falling onto concrete','Spotters to be in place when client is getting attached/detached from pulley
Clients to be checked for correct connection and harness prior to moving across tyrolean','   '),
  ('AMP 3 Pool Tyrolean',30,'Minimise','Falling onto concrete','Tyrolean rope system to be inspected and passed as correct by instructor before use. Instructor to call stop if system needs attention during activity.','   '),
  ('AMP 3 Pool Tyrolean',40,'Minimise','Rope burn','Encourage clients to wear long clothing if looping limbs over rope for support.','   '),
  ('AMP 3 Pool Tyrolean',50,'Minimise','Injury through competitive element','Have a systematic check of harness and connection and approval from instructor before client moves across rope.','   '),
  ('AMP 4 ABL Flying Fox',10,'Minimise',null,'Injury from falling','Instructor to visually check Flying Fox before use and check harness and karabiners every time'),
  ('AMP 4 ABL Flying Fox',20,'Minimise',null,'Flying Fox participant stranded with possibility of Suspension Trauma','Rescue kit checked for state of readiness before activity commences and instructor trained in its use'),
  ('AMP 4 ABL Flying Fox',30,'Minimise',null,'Participant or observer tangled in Flying Fox retrieval rope','Ensure effective rope management is in place, while participant is both flying and being retrieved
Make sure the rope is released correctly as participant leaves platform – refer near miss 2005. Make sure no one is in hazard zones, including spotter on road. Refer pg.2 of this AMP.'),
  ('AMP 4 ABL Flying Fox',40,'Minimise',null,'Participant tangled with pulley/cable','Make sure hair/clothing/hands are away from hazard through briefing and or checking'),
  ('AMP 4 ABL Flying Fox',50,'Minimise',null,'Hitting head on cable, tyres when stopping','Clients to wear helmets during ride on flying fox.'),
  ('AMP 4 ABL Flying Fox',60,'Minimise',null,'Participants dragging on / hitting the ground','Ensure participants do not run or jump off the Flying Fox platform. Brief the students to weight the cable before going by walking a far as possible down the wooden ramp. Participants to be connected as high as possible onto the anchor chain.'),
  ('AMP 4 ABL Flying Fox',70,'Minimise',null,'Traffic or pedestrians on road','Ensure chain across road while Flying Fox in use. Ensure lookout is posted down on the road corner'),
  ('AMP 4 ABL Flying Fox',80,'Minimise',null,'Road chain left across road.','Remove chain when Flying Fox not operating'),
  ('AMP 10 XL SUP',10,'Minimise',null,'Wind','Plan trip around wind direction Damage to SUP Keep SUP away from sharp objects Store out of direct sunlight and deflate slightly Injury from equipment Brief students on correct use of paddles At least 4 people to carry SUP [ Minimise | Tide in estuary Plan trip around tide times piof3 A AMP Loe Activity Management Plan- HILLARY ence Hayden Devine, Centre Manager | Date 23/02/2026 | Reviewin 1 year From date of approval Signed WC - fay) nae NN # a OT FF are ees, (I ie, . SS _| Rae ey ee ge = Yom ” Se eh ere at, ee eh ian or ; > | We ee ee) | \ sal mo) : ns au SRS ace CEES | aan MOE Se Te WS ae eee i EARS CS real \ te 2 NR i cee Pid ee, Vm ee ara | eee EN ae fee oye Se Ui \ Teg: eo ms oo ee Tag | trai wae BAG 2B SS Re A x Ra”) a A AN RS ae x ee FpSRAZY % | \— A NET AL ar BE DOT Td Seman > en a oe Vee Lo) le Ee f‘) Mah etd iy < ae SN RA: V/s f Lids <a.t i ot i fe be ea LM : Bae siya ae PN ('),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)',10,'Minimise','Generic','Steep descent','Make sure all participants understand consequence of a fall. 
Keep group together and they must travel slowly.
Consider instructor in front to monitor conditions and if there is a chance that someone may move too fast, the instructor must be in the front
Regular communication with full group
Consider helmets and protective clothing
Ensure packs are fitted properly to avoid unexpected movement
Gloves recommended to be worn when descending Scree slopes (ie, Red Crater)'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)',20,'Minimise','Generic','Loose rock from above','Helmets on for Grand Gulley on Pukekaikiore. Consider helmets elsewhere. Disclose hazard; make sure no one climbs above others. (Zigzag). Watch for other users above and below. Keep group tight and keep eyes on terrain above. Where possible use informal tracks away from the main tourist routes'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)',30,'Minimise','Generic','Extreme weather conditions','Wear appropriate clothing. Take lots of spare and wind proof layers.'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)',40,'Minimise','Generic','Volcanic eruption','Stop, watch for burning ash and flying rocks. Run away from the path of fast-moving burning clouds. Otherwise find shelter behind something - banks, ridges or in hollows. Don’t turn away from flying rocks unless you are sure they won’t hit you. Evacuate out of the hazard zone and away from the eruption site. Contact Hillary base for further advise. DM will seek advice from relevant authorities'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)',50,'Minimise','Generic','Lahar','If a Lahar occurs or the early warning detection system is heard go to higher ground contact base. DM approval is required for movement. DM will seek advice from relevant authorities.'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)',60,'Minimise','Generic','Dehydration','Lots of water is to be carried within the group. Consider 2 litres each'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)',70,'Minimise','Generic','Nightfall','In summer with longer daylight hours, turnaround time could be pushed out from 2.00pm to 3.00pm. Approval should be sought from the DM 
Make sure there are enough torches in group for night travel'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)',80,'Minimise','Generic','Cultural awareness','Respect Tangata Whenua values and avoid the summit areas of Tongariro, Ngauruhoe, and the major peaks on Ruapehu. (Marked blue on the map)'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)',90,'Minimise','Generic','Members of public calling 111','Even though this is good, it can confuse the rescue process. 
Advise public of our system that we have own crisis management system that involves local police and SAR'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)',100,'Minimise','Generic','Informal tracks being created','Use route variation where possible. Use stream bed when accessing from track to base of Pukekaikiore. (see map)'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)',110,'Minimise','Tongariro South Ridge','50m above Sth crater exposed step around a corner','Either choose a different route or spot participants around corner'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)',120,'Minimise','Tongariro South Ridge','Height exposure on ridge line','Can take easier routes below the actual ridge top.'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)',130,'Minimise','Tongariro South Ridge','Strong winds blowing over ridge','If too strong retrace steps or descend all into Sth crater at the 1st saddle'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)',140,'Minimise','Tongariro South Ridge','Old snow patches until mid summer','Avoid dangerous run-out; consider cutting steps.'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)',150,'Minimise','Mt Ruapehu','Snow slopes','Use rock routes rather than snow if it is firm
Ensure hand and head protection if sliding
Consider ice axes and brief on use.
Always ensure a safe run out'),
  ('AMP 11 Alpine Summer Alpine Scrambling TNP (Tongariro)',160,'Minimise','Mt Ruapehu','Waterfall holes / Snow bridges / Crevasses / Caves','Use rock routes rather than snow in these areas
Instructor to seek current knowledge on location and magnitude of any known holes or bridges from other staff. Do not go into these areas.'),
  ('AMP 12 Alpine Winter General (Tongariro)',10,'Minimise',null,'Range of abilities on rough terrain creating group diversification and additional risk for safe travel','Individualise care for specific students. Use variety of travel techniques such as cutting steps, hand lines, confidence roping, belay and mutual support. Choose different route.'),
  ('AMP 12 Alpine Winter General (Tongariro)',20,'Minimise',null,'Cold leading to hypothermia or frost bite. Putting whole group at risk','Ensure adequate clothing carried for worst possible conditions of the day. Have available spare clothing, mitts, hot drinks and shelter, foam mat, food'),
  ('AMP 12 Alpine Winter General (Tongariro)',30,'Minimise',null,'Group or individuals caught in avalanche','Check avalanche forecast. Plan with the 5 A’s:
Aspect; Altitude: Angle; Anchoring; Appearance
Everyone in group to have avalanche equipment with them in uncontrolled avalanche terrain- Transceiver, probe, shovel'),
  ('AMP 12 Alpine Winter General (Tongariro)',40,'Minimise',null,'Volcanic eruption','Stop, watch for burning ash and flying rocks. Run away from the path of fast-moving burning clouds. Otherwise find shelter behind something - banks, ridges or in hollows. Don’t turn away from flying rocks unless you are sure they won’t hit you. Evacuate out of the hazard zone and away from the eruption site. Contact Hillary base for further advise. DM will seek advice from relevant authorities'),
  ('AMP 12 Alpine Winter General (Tongariro)',50,'Minimise',null,'Lahar','If a Lahar occurs or the early warning detection system is heard go to higher ground contact base. DM approval is required for movement. DM will seek advice from relevant authorities.'),
  ('AMP 12 Alpine Winter General (Tongariro)',60,'Minimise',null,'Heat problems: dehydration, sunburn, hyperthermia','Ensure adequate supply of sun screen available all day. 
Monitor and encourage fluid intake
Ensure wearing of sunglasses in bright / snow conditions'),
  ('AMP 12 Alpine Winter General (Tongariro)',70,'Minimise',null,'White out conditions creating difficult navigation with terrain choice; route; time commitments; emotional comfort of students.','Have map, compass and the ability to use them in these conditions. Consider altimeter and GPS'),
  ('AMP 12 Alpine Winter General (Tongariro)',80,'Minimise',null,'Sliding due to poor boot traction','Use leather mountain boots with good soles. Be prepared to cut steps or use alternative terrain.'),
  ('AMP 12 Alpine Winter General (Tongariro)',90,'Minimise',null,'Unsecure and un-proportional loading of packs causing balance and movement problems','Ensure packs loaded evenly and everything secure, preferably on the inside.'),
  ('AMP 12 Alpine Winter General (Tongariro)',100,'Minimise',null,'Foot problems','Be mindful of blister development, ensure good fit of boots, try to keep feet dry'),
  ('AMP 12 Alpine Winter General (Tongariro)',110,'Minimise',null,'Unable to access students or an area quickly in firm or icy conditions','Instructor carry crampons on snow days.'),
  ('AMP 12 Alpine Winter General (Tongariro)',120,'Minimise',null,'Hard snow or darkness','2:00 pm, turn-around time at the latest. Carry torch'),
  ('AMP 12 Alpine Winter General (Tongariro)',130,'Minimise',null,'Injury due to crampons','Assess group for suitability for introductory crampon activities. Disclose risk of injury. Ensure good progression for groups using crampons. Crampons only to be used in easy terrain by non-skill courses.'),
  ('AMP 12 Level 3-4 Sea Kayaking Coromandel (Coromandel)',10,'Admin/PPE',null,'Strong winds','Avoid channels in strong winds, maintain awareness of wind vs tide and select route accordingly. Instructor to position themselves between participants and danger. Consider calling a support boat to shadow if the groups is struggling and/or can be blown into hazard. (see policy)'),
  ('AMP 12 Level 3-4 Sea Kayaking Coromandel (Coromandel)',20,'Admin',null,'Tidal Currents','Difficult to paddle in at times of peak flow and/or head winds. Keep group tight and monitor other traffic. 
Expected areas of tidal currents on northern tip of peninsula from Sugarloaf rocks to Port Jackson. (3.5knts)
Some tidal currents felt around North of Poley Bay'),
  ('AMP 12 Level 3-4 Sea Kayaking Coromandel (Coromandel)',30,'Isolate',null,'Wind downdrafts/gusts','Strong winds from any offshore direction can dump down on top of groups at 30knts plus.
If high level winds are 20 knots or over, stay off water.
This is seen in strong SW winds around the Port Charles, Little Sandy and Waikawau Bay areas'),
  ('AMP 12 Level 3-4 Sea Kayaking Coromandel (Coromandel)',40,'Admin/ Isolate',null,'Poley bay to Fletchers – exposed Coast','Long stretch of coast without landing, very exposed to any wind or swell.
InReach and PLB must be carried. Suitable for reasonably calm weather only (depending on client group) 
Clients must have: 
Demonstrated ability to handle rough water and paddling for several hours at a time 
Rescue training'),
  ('AMP 12 Level 3-4 Sea Kayaking Coromandel (Coromandel)',50,'Admin/PPE',null,'Rough water causing sea sickness','Monitor, ensure plenty of fluids to avoid dehydration, tow kayak to get to calm water faster. Paddle further away from cliffs to reduce clapitus (messy chop) 
Consider advising sea sickness tablets'),
  ('AMP 12 Level 3-4 Sea Kayaking Coromandel (Coromandel)',60,'Admin',null,'Unexpected/awkward Surf or Beach Landings','Consider position of maximum effectiveness. Establish non-verbal comms with group and signals and reducing number of boats landing at any one time. Define waiting area (NOT in surf zone), Consider Helmets – Instructor to be ready to paddle back out as needed. 
Consider using competent students to assist with landing.
Rudders to be pulled up to prevent damage.'),
  ('AMP 12 Level 3-4 Sea Kayaking Coromandel (Coromandel)',70,'Admin',null,'Awkward Landing at Rowner Bay','Rowner Bay has very large boulders with a beach that can be dumpy with sweel, prior to landing students must be brief on the landing plan, Important to students to have proper footwear and use teamwork to get boats off the water. Instructor to consider landing first at position of maximum effectiveness.
Consider taking weight out of boats prior to moving if expedition and utilising lots of hands to move double boats'),
  ('AMP 12 Level 3-4 Sea Kayaking Coromandel (Coromandel)',80,'Admin/ PPE',null,'Rock Gardening / Caves','Clients to be wearing appropriate shoes if potential for capsize. 
Instructors to use judgement around suitability of feature and client skill level and if helmets are to be worn. 
Consider one student boat at time with a safe waiting area outside of the feature.
Consider paddling backwards into caves 
Keeping attention to incoming swell and watch trend of waves in feature before entering.'),
  ('AMP 12 Level 3-4 Sea Kayaking Coromandel (Coromandel)',90,'Admin',null,'Boat Traffic','Instructors to brief their group on paddling as a pod when in areas of increased boat users. Consider environmental conditions when around anchored boats to avoid damage.
Consider logging a trip report'),
  ('AMP 12 Level 3-4 Sea Kayaking Coromandel (Coromandel)',100,'PPE',null,'Damage to boats','Instructor to carry repair kit for basic repairs'),
  ('AMP 14 Alpine Snow Sports Day',10,'Minimise',null,'Volcanic eruption','Stop, watch for burning ash and flying rocks. Run away from the path of fast-moving burning clouds. Otherwise find shelter behind something - banks, ridges or in hollows. Don’t turn away from flying rocks unless you are sure they won’t hit you. Evacuate out of the hazard zone and away from the eruption site. Contact Hillary base for further advise. DM will seek advice from relevant authorities'),
  ('AMP 14 Alpine Snow Sports Day',20,'Minimise',null,'Lahar','If a Lahar occurs or the early warning detection system is heard go to higher ground contact base. DM approval is required for movement. DM will seek advice from relevant authorities.'),
  ('AMP 14 Alpine Snow Sports Day',30,'Minimise',null,'Cold Leading to Hypothermia or frost bite','Ensure appropriate clothing/equipment is worn/ for weather conditions. Instructor to carry spare mitts, hat, and warm clothing'),
  ('AMP 14 Alpine Snow Sports Day',40,'Minimise',null,'Sunburn, Dehydration, Snow blindness','Promote use of sunscreen. Encourage fluid intake. Ensure sunglasses or goggles are worn. Instructor to carry spare glasses. Instructor may be working down low below inversion cloud while clients are working above inversion cloud exposed to bright sun. Don’t forget about them!'),
  ('AMP 14 Alpine Snow Sports Day',50,'Minimise',null,'Skiing/boarding inappropriate terrain for ability, causing Injury','Instructor to brief students on terrain suitable for ability levels. All students to participate in lessons
No unsupervised skiing/boarding for beginners before lessons'),
  ('AMP 14 Alpine Snow Sports Day',60,'Minimise',null,'Wrist Injury (snowboarding)','Instructor to ensure students (snowboarding) have wrist guards when leaving rentals'),
  ('AMP 14 Alpine Snow Sports Day',70,'Minimise',null,'Head Injury','All clients and staff to wear Industry standard helmets. (Provided to clients by RAL as part of package)'),
  ('AMP 14 Alpine Snow Sports Day',80,'Minimise',null,'Lost student','Inform students of boundaries and meeting times. Ensure students and instructor are riding terrain accessed by same lift.'),
  ('AMP 14 Alpine Snow Sports Day',90,'Minimise',null,'Parents being informed of accident by Ski Patrol before Hillary Outdoors have knowledge of it','Student to wear identifiable arm band'),
  ('AMP 14 Alpine Snow Sports Day',100,'Minimise',null,'Chairlift related injuries, incidents','Instructor to brief students before riding any chairlift.'),
  ('AMP 15 Alpine Camping Above Bush Line',10,'Minimise',null,'Volcanic eruption','Stop, watch for burning ash and flying rocks. Run away from the path of fast-moving burning clouds. Otherwise find shelter behind something - banks, ridges or in hollows. Don’t turn away from flying rocks unless you are sure they won’t hit you. Evacuate out of the hazard zone and away from the eruption site. Contact Hillary base for further advise. DM will seek advice from relevant authorities'),
  ('AMP 15 Alpine Camping Above Bush Line',20,'Eliminate',null,'Lahar','Camping needs to be done in approved campsites. No camping in major lahar paths (see Volcanic Hazard map) at any Volcanic alert level. No camping in any possible Lahar paths at VAL 2 or above. If a Lahar occurs or the early warning detection system is heard go to higher ground contact base. DM approval is required for movement. DM will seek advice from relevant authorities.'),
  ('AMP 15 Alpine Camping Above Bush Line',30,'Minimise',null,'Fatigue','Make sure everybody eats and drinks, stop early to make camp, especially in winter since it gets dark around 6.30 pm and can get very cold around 4.00pm'),
  ('AMP 15 Alpine Camping Above Bush Line',40,'Minimise',null,'Instructor exhaustion','Eat lots, keep drinking. Make sure personal kit is top quality. 
Get fit and trained for worse case scenarios. Contact DM for help if necessary.'),
  ('AMP 15 Alpine Camping Above Bush Line',50,'Minimise',null,'Poor Radio Comms','Carry Inreach and have a checking in plan with the DM when in Eastern areas. See map below for known dead spots and Approximate East West divide.'),
  ('AMP 15 Alpine Camping Above Bush Line',60,'Minimise',null,'Strong winds damaging tents','Do not camp out of the bush or scrub in periods of strong wind warnings. Find campsites in bush or scrub
Make sure all guy ropes pegged out tight and tent is tight and pitched in the most aerodynamic position
Gusty sites are harder on tents than a strong blow from a constant direction
Have a back up escape plan if weather gets too extreme. 
Often better to stay in a broken tent that is giving protection from the wind than moving.
Have knowledge of local effects of weather systems e.g. katabatic, increased wind speeds etc'),
  ('AMP 15 Alpine Camping Above Bush Line',70,'Minimise',null,'Breaking access rules','Instructor must know exactly where and where not to camp. 
Camps must be over 500 metres from a track and out of sight of the Great Walk track, And 200m & out of sight from any other track'),
  ('AMP 15 Alpine Camping Above Bush Line',80,'Minimise',null,'Fire','Cook in an area away from flammable material like dry tussocks and other vegetation. No cooking in tents
No Fires at all times especially when within prohibited area such as Tongariro National Park'),
  ('AMP 15 Alpine Camping Above Bush Line',90,'Minimise',null,'Environmental – Waste left in mountains','All wastes removed from the mountains and disposed appropriately.'),
  ('AMP 17 Alpine Grade 2 Mountaineering',10,'Admin',null,'Participant Falling due to 
Failing to walk correctly or tripping on crampons
Failure of the snow
Failure of axe or crampon placements
Being pulled off by climbing partner','Disclose risk
Teaching in a sequence, teach proper walking and climbing techniques
Participants must be taught how to arrest a fall when travelling as a team on a ridge.
Runners to be placed to minimise fall distance and hitting objects'),
  ('AMP 17 Alpine Grade 2 Mountaineering',20,'Admin
PPE',null,'Instructor falling','Where possible be attached to an anchor.
Instructor must be attached to an anchor when changing mindset from climbing to teaching or dealing with clients on steep terrain where sliding could cause an injury.'),
  ('AMP 17 Alpine Grade 2 Mountaineering',30,'Admin
PPE',null,'Cold 
Hypothermia
Injury to clients','All personal clothing to be checked and must be fit for purpose
Method of re-warming to be carried by all participants
Consider wearing gloves when handling any metal on the mountain'),
  ('AMP 17 Alpine Grade 2 Mountaineering',40,'Admin',null,'Ice / Rockfall','Be aware that this happens often in Tongariro National Park especially when the sun hits the peaks of the Pinnacle Ridge.
Stop only in areas where this risk is not present'),
  ('AMP 17 Alpine Grade 2 Mountaineering',50,'Admin',null,'Avalanche','Disclose risk 
If unavoidable, travel through this terrain in a way to minimise exposure to the risk
Slopes should be assessed before digging platforms/pits where avalanche conditions exist'),
  ('AMP 17 Alpine Grade 2 Mountaineering',60,'Admin',null,'Anchor failure
Variable snow
Poor anchor','Snow anchor are built in accordance to guidelines set out in the Don Bogie report.
Participants taught to build anchors in a variety of conditions and instructors to check anchor placements before use.'),
  ('AMP 18 Alpine Skills and Tertiary',10,'Minimise',null,'Participant falling due to 
Failing to walk correctly or tripping on crampons
Failure of the snow
Failure of axe or crampon placements','Disclose risk
Teaching in a sequence, teach proper walking and climbing techniques
Participants must be taught how to arrest a fall when travelling as a team on a ridge.
Runners to be placed to minimise fall distance and hitting objects'),
  ('AMP 18 Alpine Skills and Tertiary',20,'Minimise',null,'Cold 
Hypothermia
Injury to clients','All personal clothing to be checked and must be fit for purpose
Method of re-warming to be carried by all participants
Consider wearing gloves when handling any metal on the mountain'),
  ('AMP 18 Alpine Skills and Tertiary',30,'Minimise',null,'Ice / Rockfall','Be aware that this happens often in Tongariro National Park especially when the sun hits the peaks of the Pinnacle Ridge.
Stop only in areas where this risk is not present'),
  ('AMP 18 Alpine Skills and Tertiary',40,'Minimise',null,'Avalanche','Disclose risk 
Everyone in group to have avalanche equipment with them in uncontrolled avalanche terrain Transceiver, probe, shovel
If unavoidable, travel through this terrain in a way to minimise exposure to the risk
Slopes should be assessed before digging platforms/pits where avalanche conditions exist'),
  ('AMP 18 Alpine Skills and Tertiary',50,'Minimise',null,'Volcanic eruption','Stop, watch for burning ash and flying rocks. Run away from the path of fast-moving burning clouds. Otherwise find shelter behind something - banks, ridges or in hollows. Don’t turn away from flying rocks unless you are sure they won’t hit you. Evacuate out of the hazard zone and away from the eruption site. Contact Hillary base for further advise. DM will seek advice from relevant authorities'),
  ('AMP 18 Alpine Skills and Tertiary',60,'Minimise',null,'Lahar','If a Lahar occurs or the early warning detection system is heard go to higher ground contact base. DM approval is required for movement. DM will seek advice from relevant authorities.'),
  ('AMP 18 Alpine Skills and Tertiary',70,'Minimise',null,'Anchor failure
Variable snow
Poor anchor','Snow anchor are built in accordance with current industry best practice.
Participants taught to build anchors in a variety of conditions and instructors to check anchor placements before use.'),
  ('AMP 18 Alpine Skills and Tertiary',80,'Minimise',null,'Heat problems: dehydration, sunburn, hyperthermia','Ensure adequate supply of sun screen available all day. 
Monitor and encourage fluid intake
Ensure wearing of sunglasses in bright / snow conditions'),
  ('AMP 18 Alpine Skills and Tertiary',90,'Minimise',null,'White out conditions creating difficult navigation with terrain choice; route; time commitments; emotional comfort of students.','Have map, compass and the ability to use them in these conditions. Consider altimeter and GPS'),
  ('AMP 18 Alpine Skills and Tertiary',100,'Minimise',null,'Unsecure and un-proportional loading of packs causing balance and movement problems','Ensure packs loaded evenly and everything secure, preferably on the inside.'),
  ('AMP 21 Bush Local Bush (Tongariro)',10,'Minimise',null,'Hunters','Keep making lots of noise especially in hunting season. Obtain info from and inform them of your intentions if you meet.'),
  ('AMP 21 Bush Local Bush (Tongariro)',20,'Minimise',null,'River crossings and stream travel','Refer to AMP 22 Bush River Travel'),
  ('AMP 21 Bush Local Bush (Tongariro)',30,'Minimise',null,'Cliffs along edge of Mangatepopo River','Local knowledge and navigation skills very important.'),
  ('AMP 21 Bush Local Bush (Tongariro)',40,'Minimise',null,'Poisons (1080, Cyanide etc.)','Brief participants on the hazards of poisons. Be aware of local advisory/poison summary from DOC'),
  ('AMP 21 Bush Local Bush (Tongariro)',50,'Minimise',null,'Insect stings','Check medical forms prior to trip. Avoid area if needed. Brief students about what to do if a wasp nest is encountered. Obtain info from other staff especially in warmer months about location of any known spots. Provide medical help as needed.'),
  ('AMP 21 Bush Local Bush (Tongariro)',60,'Minimise',null,'Poor Radio comms','Poor radio comms exists in valley floors on the repeater channel. Areas known to be affected are: Mangetepopo Stream, Taurewa Stream, Okupata Stream, Slope leading to Grants East Camp, Wanganui River'),
  ('AMP 21 Bush Local Bush (Tongariro)',70,'Minimise',null,'Forestry in local area','Instructor to gather local information before heading into known forestry areas. Listen carefully for forestry machinery – especially chainsaws.

Refer to Current Hilary Outdoors Local Map for access information (Found on Staff Room Wall and Printer)'),
  ('AMP 21 Coasteering Little bay to Waikawau (Coromandel)',10,'Minimise',null,'Surging Features Brief safe waiting zones for students','Consider position of maximum effectiveness — On land with throw bag or in water to tow students out. Surge/swell onto shallow rocks Instructor to be familiar with trip and effects of swell on site. See coaster map. Depends on tide and swell. Teach students proper techniques for landings. Sturdy, covered footwear must be worn. Movement around rocks, barnacles and oysters. Briefing to fall back into water if the swell drops and leaves you high and dry — Coach feet first landing onto shore and hands up till secure footing is made. No jumping without instructor permission Shallow rocky channels ‘ Shallow water entry to be briefed Other users Manage group around public. This is a public area with the associated risk of theft etc - lock vehicles Large swell (Easterly/ North-east) surges onto Walk around channels if swell is excessive. Norther Point. Suggestion to start from little bay and go o'),
  ('AMP 22 Bush River Travel (Tongariro)',10,'Minimise','Taurewa Stream','Short climbs / Lowering','Climbs require rope management and spotting. Instructor should either be in the front if descending the stream or in direct contact with students at the front to prevent group from walking off edges. Consider lowering groups with rope when descending stream. Helmets to be worn when in the stream way'),
  ('AMP 22 Bush River Travel (Tongariro)',20,'Minimise','Taurewa Stream','Rock pile scrambles','Spotting, if necessary, especially on way up stream'),
  ('AMP 22 Bush River Travel (Tongariro)',30,'Minimise','Okupata stream incl dry valley and Pukehinau stream','Holes in valley floors / tomos','Disclose risk, be at front if unsure'),
  ('AMP 22 Bush River Travel (Tongariro)',40,'Minimise','Pumice Caves','Steep sections including waterfall and bluffs','Instructor to ensure they are at front, refer map'),
  ('AMP 22 Bush River Travel (Tongariro)',50,'Minimise','Pumice Caves','5m high bluff 200m downstream from conical hill track','Pass on true right, keep participants away from edge. It overhangs!'),
  ('AMP 22 Bush River Travel (Tongariro)',60,'Minimise','Pumice Caves','Environmental damage to caves','Disclose hazard, make sure participants don’t dig away at the walls. Self-imposed access restriction: One trip per instructor per year'),
  ('AMP 22 Bush River Travel (Tongariro)',70,'Minimise','Whanganui River Headwaters','Whanganui waterfall','Climb on true right, steep climb through bush may require spotting'),
  ('AMP 22 Bush River Travel (Tongariro)',80,'Minimise','Whanganui River Headwaters','Exhaustion','Lots of food, regular stops, overnight kit. Strong group takes 11-12 hours to reach the tussock'),
  ('AMP 22 Bush River Travel (Tongariro)',90,'Minimise','Whanganui Intake Crossing','Intake Operations.','Prior to the event of a sudden rise in water level associated with the operation of this structure a siren will sound for two minutes. When you hear this siren move immediately to safety.'),
  ('AMP 22 Bush River Travel (Tongariro)',100,'Eliminate','Whanganui Intake Crossing','Operational areas.','No access into any of the operational areas of the Whanganui intake without Genesis Energy and DM approval. (Marked as purple on map.)'),
  ('AMP 22 Bush River Travel (Tongariro)',110,'Minimise','Whanganui Intake Crossing','Property Access','Follow the mapped route (Red track on map) Cross below the Netting filled with rocks and do not walk on it! This will avoid any private property and will prevent from going onto the Whanganui Intake Structure.'),
  ('AMP 22 Bush River Travel (Tongariro)',120,'Minimise','Whanganui Intake Crossing','Beehives','May be present in the area at any time. Disclose hazard to clients and make appropriate route selection to avoid the hives. Possible location marked on map.'),
  ('AMP 22 Bush River Travel (Tongariro)',130,'Minimise','Whanganui Intake Crossing','Vehicles on the road.','Instructor to ensure that the group is visible on the road and walking together as a group.
For all inquiries refer DM who can contact Genesis Energy on (07) 384 7200'),
  ('AMP 22 Bush River Travel (Tongariro)',140,'Minimise','Mangatepopo upstream of gorge','5m drop into gorge at bottom of “Dingle Creek”','Instructor to be at front. Bush bash up true right of river approx 100m to keep clear of waterfall'),
  ('AMP 22 Bush River Travel (Tongariro)',150,'Minimise','Mangatepopo upstream of gorge','Narrow slot 1/3 of way upstream (A on map)','Approach on true right – climb up onto slippery clay ledge, use handline to cross and spot downstream, run out into a deep pool'),
  ('AMP 22 Bush River Travel (Tongariro)',160,'Minimise','Mangatepopo upstream of gorge','Railway iron in river under dangerous bridge','Disclose hazard, in low water levels it can be passed on true right'),
  ('AMP 22 Bush River Travel (Tongariro)',170,'Minimise','Mangatepopo upstream of gorge','Rapids / Fast moving water','Spot from downstream; if you can’t stand in the flow consider another crossing point.'),
  ('AMP 22 Bush River Travel (Tongariro)',180,'Minimise','General','Cold water','Use appropriate river crossing technique, especially cold in Pukehinau, Okupata and Mangatepopo streams'),
  ('AMP 22 Bush River Travel (Tongariro)',190,'Minimise','General','Steep terrain / Short climbs / waterfalls','Disclose hazards and spotting if necessary (teach), Instructor to be at front of group to manage'),
  ('AMP 22 Bush River Travel (Tongariro)',200,'Minimise','General','Slippery rocks / boulders / terrain','Brief to stand between rocks to avoid slipping, climb over boulder don’t jump from one to another, spotting if necessary, go slower'),
  ('AMP 22 Bush River Travel (Tongariro)',210,'Minimise','General','Environmental damage','Keep to stream-way to avoid damage to banks, consider doing during drier periods/seasons,'),
  ('AMP 22 Bush River Travel (Tongariro)',220,'Minimise','General','Scaring Blue ducks and chicks','Avoid pushing into the territory of other ducks, Avoid separating chicks from adults. Get one person around the ducks to prevent them going too far, then move group past. Blue ducks could be on any of the local streams.'),
  ('AMP 22 Bush River Travel (Tongariro)',230,'Eliminate','General','Genesis Energy Structures','No access into any of the operational areas on any structures without Genesis Energy and DM approval.'),
  ('AMP 23 Bush craft (Tongariro)',10,'Minimise',null,'Sharp blades','Establishing clear rules to using knives (instructor must be familiar with tools and methods)
Marking out clear boundaries around person handling knife (e.g. “blood circle”)
Knives should be kept sharp'),
  ('AMP 23 Bush craft (Tongariro)',20,'Minimise',null,'Splinters','Brief participants about hazard.'),
  ('AMP 23 Bush craft (Tongariro)',30,'Minimise',null,'Misuse of equipment','Participants must be supervised during activity.
Knives must be carried by instructor (both before and after activity).
Consider only doing activity with reliable groups'),
  ('AMP 23 Bush craft (Tongariro)',40,'Minimise',null,'Burns','Participants must be supervised during fire lighting.
Accelerants must not be used without instructor approval.'),
  ('AMP 23 Bush craft (Tongariro)',50,'Minimise',null,'Environmental damage','Participants must be briefed and supervised during collection of materials.
Fires must be adequately put out before leaving the site.
Method of extinguishing fires must be on hand.
Fire ban restriction information must be accessed and adhered to prior to activity.'),
  ('AMP 23 Sit on top kayak (Coromandel)',10,'Minimise',null,'Injury from equipment Briefing on safe use of equipment and correct technique for loading and unloading of trailer','. Left side of little sandy has rocks, avoid launching there Damage to equipment A Correct use of equipment plof2 A AMP Loe Activity Management Plan- Tier 3 HILLARY By = — i | |) OTT Fara ae iF COP Batce Vic ha Bites | Yale te le Se ao poe a Cae ; ES RS SR a NN Ae ~ ANE ho ead: i Se 1 Peeks KV cae og NU pre owt dee S Syed aS: \ YOR Fay.) | eh CIs et, GMAe Bas ke " ay | a | \ eh OE ie fa NM, Pots my y sa 7a " me \ \ 5 eae —_ (+S ee ; Oe i ey SEN : owt Gt qi om ee xg ira \- SE LF JHA ON oRy ge SOFT | + = Cy A CO ic; ee ill a A te ee A ie A ot Nat AM etna atk. JS | i MR. Se ae ae see ad ier ite | Ue AN OS Gi paint OG) ae ON eer a ee shoe ee dis for ~~ \ Was i LST Ga ie ‘GobB oily RS 8 ial Lae Noein S NERS ONY | ae s oe |. re ai “4 = o ee Pg Ome a 2 —— S 5 A : sy Ps oe : & ~ a = “oN —_ ’ f . ‘ : yy = age : ‘ de My Se A . e x ; 4 ( gpa x Oa p2of2 : AMP'),
  ('AMP 25 Bush Solo Overnight (Tongariro)',10,'Minimise',null,'Client becoming disorientated / lost','Set boundaries at site, ie. Max distance / time to travel.
Have a major land feature .ie. Track, nearby so can be handrailed to safe point where instructor is, or can relocate
Instructor to have set time for check in with participants'),
  ('AMP 25 Bush Solo Overnight (Tongariro)',20,'Minimise',null,'Terrain hazards i.e. cliffs/bluffs, tomos, rivers etc.','Set boundaries at site. Instructor to ensure no known terrain hazards are present in the area.'),
  ('AMP 25 Bush Solo Overnight (Tongariro)',30,'Minimise',null,'Cold / Hypothermia','Ensure all participants are well enough equipped for the night, both clothing and shelter
Participants are to know how to get to instructor if needed
Instructor to have spare equipment for cold students if needed. Shelter, Warm food/drink'),
  ('AMP 25 Bush Solo Overnight (Tongariro)',40,'Minimise',null,'Damage to bush from fires or Bivouac building.','Refer LNT, DOC environmental care code. Local Fire Bans
Ensure participants understand safe solo fire use or do not use
Brief that in real situation you would use green trees but in practice use dead/brown wood'),
  ('AMP 26 Puerora Tramping (Tongariro)',10,'Eliminate/Minimise',null,'River crossings and stream travel','Assess hazards involved, be prepared to retreat or wait for river levels to drop before committing to crossing any water ways. Use appropriate river crossing techniques for speed and depth of water'),
  ('AMP 26 Puerora Tramping (Tongariro)',20,'Minimise',null,'Hunters','Keep making lots of noise especially in hunting season. Obtain info from and inform them of your intentions if you meet.'),
  ('AMP 26 Puerora Tramping (Tongariro)',30,'Minimise',null,'Steep and rough tracks','Instructors to be aware of areas of steep ground management especially track into and out of Mangatu Stream.'),
  ('AMP 26 Puerora Tramping (Tongariro)',40,'Minimise',null,'Poisons (1080, Cyanide etc.)','Brief participants on the hazards of poisons. Be aware of local advisory/poison summary from DOC'),
  ('AMP 26 Puerora Tramping (Tongariro)',50,'Minimise',null,'Loss of track','Areas where track re routes around tree fall can be easily lost. Ensure group is aware of manging this.'),
  ('AMP 26 Puerora Tramping (Tongariro)',60,'Minimise',null,'Insect stings','Check medical forms prior to trip. Avoid area if needed. Obtain info from other staff especially in warmer months about location of any known spots. Provide medical help as needed.'),
  ('AMP 26 Puerora Tramping (Tongariro)',70,'Minimise',null,'Poor Radio comms','Poor radio comms. Instructors to ensure groups are carrying PLB and InReach devices for primary comms.'),
  ('AMP 27 Bush Overnight Camping (Tongariro)',10,'Eliminate',null,'Lahar- Volcanic eruption event','No camping in major Lahar paths. (Refer volcanic hazard map) If camping in Wairere valley leave radio and/or cell phone on at night'),
  ('AMP 27 Bush Overnight Camping (Tongariro)',20,'Minimise',null,'Emotional trauma','Instructors to position tent close enough to students to hear anything unusual. Think about where students position their tents in accordance to various gender tents. Instructors to ensure students are in tents, and able to be indirectly supervised before going to own tent. Try to identify student relationships or past history, refer to group community agreement if needed.'),
  ('AMP 27 Bush Overnight Camping (Tongariro)',30,'Minimise',null,'Water borne illness','Water to be treated or boiled before consumption'),
  ('AMP 27 Bush Overnight Camping (Tongariro)',40,'Minimise',null,'Cookers-burns','Closed toe shoes to be worn when using cookers. Suitable area designated out of traffic flow for cooking area. Students to be supervised when using cooking equipment.'),
  ('AMP 27 Bush Overnight Camping (Tongariro)',50,'Minimise',null,'Overhead hazards','Area for camping to be checked for overhead hazards, epiphytes and dead branches before establishing.'),
  ('AMP 27 Bush Overnight Camping (Tongariro)',60,'Minimise',null,'Flooded campsite','Be aware of forecast and select campsite based on forecast effect on streamways and potential to flood site.'),
  ('AMP 27 Bush Overnight Camping (Tongariro)',70,'Minimise',null,'Environmental damage','Apply LNT principles for camping on durable surfaces, minimise impact if camping at informal site'),
  ('AMP 27 Bush Overnight Camping (Tongariro)',80,'Minimise',null,'Environmental waste','Toileting – follow LNT principles. Toileting 50m from water source. Use pack it out policy if this cannot be achieved or at high use sites.'),
  ('AMP 28 Advanced Snorkel',10,'Minimise',null,'Swallowing water','lungs when underwater. Ear issues — barotrauma, forced equalization, middle ear Instructors must brief and get students to practice equalizing on land before getting into the water. Refer to Instructor guide about squeeze different ways this can occur or be taught. piof2 A MP AMP Activity Management Plan — Freediving aN HILLARY bearddad te c ¢ Sturdy, covered footwear must be worn on the walk out there. Long wetsuit to be worn, low tides have more exposed rocks for ‘uts and scrapes entering and exiting the water. return Graeme Swift from date of } Approved by 24/02/2026 1 Year LS Safety manager /02/ approval NEE hes W/ Bees ay Ss ss ees RS 4 [pk as ia heey A 2 boat | 4 é Fess 4 tas f BSR A RAS y pares si 5 é ASR Es 5 colty Be ne a Nn a ae Sa aS gait ree 4 eee ot CAG Beton, “ie ie aay ea : ag an be, <P ot % ee Pee ee LN Pa 5 A B- 4 mF RAE EN J Ph 8A a 8 ah ese fe Be 1 Be ea) — ss Se Se ad'),
  ('AMP 29 Coasteering -Black Rock',10,'Minimise',null,'Depends on tide and swell. Teach students proper techniques for landings. Sturdy covered footwear must be worn. Full len','to be worn at all times. Briefing to fall back into water if the swell drops and leaves you high and dry - Coach feet first landing onto Movement around rocks, barnacles and oysters. shore and hands up till secure footing is made.'),
  ('AMP 29 Coasteering -Black Rock',20,'Minimise',null,'instructors must brief and supervise participants to only jump where they say it is OK. Instructor to coach participants','Correct Jump technique or progression technique and check ability before jumps over 3m (arms crossed over chest hold, PFD straps or down by sides) Disclose risk of landing jump ique or progressi badly. See approved jumps sites over the page. Appropriate progression of height to gauge clients jumping and landing ability Brief shallow water entry technique. Eg belly flop, foot first banana jump Brief a strong stance or group support/huddle if moving around during a larger swell period, as a small amount of water can knock you Large Swell Period (increased wave power) off your feet. Consider a call of “big wave” to be shouted for the students to brace. Encourage all of the group to be watching out for larger swell sets and they can call “Big wave” too. piof4 AMP AM t Activity Management Plan - (activity) LOX. HILLARY ‘ourpoors'),
  ('AMP 29 Coasteering -Black Rock',30,'Minimise',null,'surging features Instructor to watch features before committing students to feature. Briefing feet up if appropriate or ','"Bing safe waiting zones for students Consider position of maximum effectiveness — On land with throw bag or in water to tow students out.'),
  ('AMP 29 Coasteering -Black Rock',40,'Minimise',null,'Manage students up and around different jumps. Start with a small jump to get proper technique before moving to the bigg','Ensure instructor is in a suitable position before jumps occur. Instructor to check depth of jump to make sure it is safe for anything over Jump alley 3M. On the underpass side of jump alley two appropriate ledge jumps have been identified during staff training 2026, additionally the higher section of the opposite side (non underpass side) of jump alley is closed to both students and staff no jumps or scrambling is permitted here due to crumbly rock.'),
  ('AMP 29 Coasteering -Black Rock',50,'Minimise',null,'Underpass is only useable during small swell not doable at high tide. Exit needs managing for one steep section that cou','The underpass challenging for some students B) inner ear injuries Disclose during briefing. Plug both ears before big jumps if participants have a history of inner ear injuries/infections Remove all loose/flapping solid items from participants prior to jumps. Go Pro’s must on in a secure chest or helmet mount, on a jump Loose equipment, unsecured e.g. Go Pros over 3M (not held in hands or tied to PFD’s) Hayden Devine from date of (> Approved by y 23/02/2026 1year '' W\ Centre Manager approval No se p2of4 AMP A Activity Management Plan - (activity) Lae. HILLARY ete yt 7 Tiga 7 "7 ; _ ourpoors wy TRS if ip oe a) LE ae in tare, oF » 5 7m PF th ‘ eS ’ Ron WAY, yf 4 iy) a ot ® A Rraeke 3 +. Ns rt ye SD bs y epesuee features " . = rd a ees * By Me oe ‘ 4 ei ee | . : ‘ , ae $57 te vk, < “ * i a” ag * ¢ As a). . a “ r — : ’ - SS | Multiple small jumps a. 4 ny, a ef ay Sand surge features ei rae °'),
  ('AMP 31 Cave Okupata Cave (Tongariro)',10,'Elimination
Minimise',null,'Higher than normal water level','Refer to map
 Red zones close at 2.0 Update on map, addition of red area around siphons.
 Yellow zones close at 3.0
 Green zones close at 4.0 (Cave is closed)'),
  ('AMP 31 Cave Okupata Cave (Tongariro)',20,'Minimise',null,'Siphon at waterfall','Siphons form on the river left and right of the rock at the water fall 
Consider spotting or manage group around hazard'),
  ('AMP 31 Cave Okupata Cave (Tongariro)',30,'Minimise',null,'Access Road','Observe 30km advised speed limit or slower as appropriate to conditions
Be prepared to stop quickly at all times
Refer to AMP 81 Driving'),
  ('AMP 31 Cave Okupata Cave (Tongariro)',40,'Minimise',null,'Upstream entrance
Knee Deep Pool Area','These areas may be entered with additional DM approval
These areas are Red zones
Refer to map extension ( QDrive:\\05.Programme Resources\Caving\Okupata\Main Cave and Downstream Areas )'),
  ('AMP 31 Cave Okupata Cave (Tongariro)',50,'Minimise',null,'Emotional issues','Don’t push people too hard. Check out any severe claustrophobics within the group before heading to the cave. Refer to T2 for policies for leaving people unsupervised'),
  ('AMP 31 Cave Okupata Cave (Tongariro)',60,'Minimise',null,'Slippery rocks / logs in entrance area','Brief students to stand between rocks and in water to avoid slipping. Climb over bigger rocks don’t jump from one to another, go slow.'),
  ('AMP 32 Cave Pukehinau Cave (Tongariro)',10,'Eliminate/Minimise',null,'High water levels / Flooding','Very easy option for retreating from this cave. Go back out the main entrance where you came in. Also refer T2 for more flooding policy'),
  ('AMP 32 Cave Pukehinau Cave (Tongariro)',20,'Minimise',null,'Cold Water','Participants to be briefed to stay out of water as much as possible. Push back to ceiling when travelling through low sections.'),
  ('AMP 32 Cave Pukehinau Cave (Tongariro)',30,'Minimise',null,'Low / tight / wet areas','Disclose to participants. Challenge by choice to be operating.'),
  ('AMP 32 Cave Pukehinau Cave (Tongariro)',40,'Minimise',null,'Stream-way outside cave','Disclose to participants. Briefed to stay put and wait for further instruction from instructor after exiting cave.'),
  ('AMP 32 Cave Pukehinau Cave (Tongariro)',50,'Minimise',null,'Blue Ducks','Ducks can exist in the stream-way outside the cave. If seen, keep group well clear to minimise separating adults from chicks'),
  ('AMP 41 Rock Whakapapa Area Crags',10,'Minimise','All areas','Volcanic eruption','Stop, watch for burning ash and flying rocks. Run away from the path of fast-moving burning clouds. Otherwise find shelter behind something - banks, ridges or in hollows. Don’t turn away from flying rocks unless you are sure they won’t hit you. Evacuate out of the hazard zone and away from the eruption site. Contact Hillary Base for further advice. DM will seek advice from relevant authorities'),
  ('AMP 41 Rock Whakapapa Area Crags',20,'Minimise','All areas','Lahar','If a Lahar occurs or the early warning detection system is heard go to higher ground and contact DM. DM approval is required for movement. DM will seek advice from relevant authorities.'),
  ('AMP 41 Rock Whakapapa Area Crags',30,'Minimise','Halfmoon','Pendulums when rigging anchors','First (climbers left) instructor anchors are for rigging;
Spaceballs, Moonraker, Apollo 13
The second/main instructor anchors are for rigging;
Sputnik, Superblood Wolfmoon, Marama
Then using the second/main anchors, clip into extra bolt to prevent pendulum to access;
Luna, Death Star
You can walk up to anchor for Armstrong (far right end).'),
  ('AMP 41 Rock Whakapapa Area Crags',40,'Minimise','Meads Wall','Clients accessing the top of the crag. Steep drop on both sides','Clients to be managed with a safety line. Cowstails to be used. Clients to remain on safety line until instructor advises otherwise.'),
  ('AMP 41 Rock Whakapapa Area Crags',50,'Minimise','Meads Wall','Other users at the site','Request that they stay clear of your hazard area. If they choose not to, you need to cease activity until they are clear. Check anchors if other people have been in the area.'),
  ('AMP 41 Rock Whakapapa Area Crags',60,'Minimise','Pehi’s Crag','Anchors a long way back from edge. 
Loose rocks/blocks.','Bring long rigging ropes if not using the double ring bolts
Check and brief for loose rocks/blocks.'),
  ('AMP 41 Rock Whakapapa Area Crags',70,'Minimise','General','Loose rocks on approach and at the top of the crags


Clients left unaccompanied while instructor is rigging','Group management to ensure clients do not walk below one another. 
Consider helmets on approach. 
Disclose loose rock hazard and what to do if you push one downhill. 
Keep group away from top of crags.
Identify safe areas for clients to wait while the instructor is rigging.
Clients to be monitored by instructor. Give them a task and ensure that they are in areas where they cannot cause a hazard to themselves or the environment.'),
  ('AMP 41 Rock Whakapapa Area Crags',80,'Minimise','General','Clients left unaccompanied while instructor is rigging','Clients to be monitored by instructor. Give them a task and ensure that they are in areas where they cannot cause a hazard to themselves or the environment.'),
  ('AMP 42 Rock Lower Rock Wall',10,'Eliminate/Minimise',null,'Anchor posts breaking','Do not use the front wooden posts. Use trees for anchors and drape focal point over metal rail to keep it high off the concrete.'),
  ('AMP 42 Rock Lower Rock Wall',20,'Minimise',null,'Falling from top of wall','All clients to be briefed to move slowly across top of wall. Instructor to remove all trip hazards from the top of the wall area before allowing clients to access.'),
  ('AMP 42 Rock Lower Rock Wall',30,'Minimise',null,'Sharp edges of concrete and metal structure','Disclose risk, report any issues to DM
Use rope protection when ropes are rubbing on surface of concrete'),
  ('AMP 43 Rock Meads Wall Traverse',10,'Minimise',null,'Participant falling / Disconnecting from safety rope','Each participant to have cows tails and be trained and observed in proper use before commencing activity and, as often as possible, observe while doing activity.
Participants must be connected to a safe system throughout the activity
Rope systems must be rigged to minimise participant exposure to edges'),
  ('AMP 43 Rock Meads Wall Traverse',20,'Minimise',null,'Failure of single attachment when rigging and derigging','Use a device with a back up function, tie off when hands free – recommend Grigri'),
  ('AMP 43 Rock Meads Wall Traverse',30,'Minimise',null,'Large Fall Factors/Swing','Must Rig in North to South direction and de rig South to North
All staff to be connected with a fall arrest device that allows a dynamic catch when rigging or de rigging the traverse.
The Traverse is to be rigged with Static Rope and all persons must use Dynamic cows-tails (Lanyards).'),
  ('AMP 43 Rock Meads Wall Traverse',40,'Minimise',null,'Extreme Weather events','Obtain weather information prior to commencing trip. Be prepared for sudden changes'),
  ('AMP 43 Rock Meads Wall Traverse',50,'Minimise',null,'Cams dislodging','Front-tie cams where possible to stop them walking'),
  ('AMP 43 Rock Meads Wall Traverse',60,'Minimise',null,'Client Fear, Injury, Refusal','Be prepared for some coaching. Instructor must be have equipment and be able to escape the ridge at anytime'),
  ('AMP 44 Rock Meads Wall Loop',10,'Minimise',null,'Participant falling / Disconnecting from safety rope','Each participant to have cows tails and be trained and observed in proper use before commencing activity and, as often as possible, observe while doing activity.
Participants must be connected to a safe system throughout the activity
Rope systems must be rigged to minimise participant exposure to edges'),
  ('AMP 44 Rock Meads Wall Loop',20,'Minimise',null,'Failure of single attachment when rigging and derigging','Use a device with a back up function, tie off when hands free – recommend Grigri'),
  ('AMP 44 Rock Meads Wall Loop',30,'Minimise',null,'Extreme Weather events','Obtain weather information prior to commencing trip. Be prepared for sudden changes'),
  ('AMP 44 Rock Meads Wall Loop',40,'Minimise',null,'Client Fear, Injury, refusal','Be prepared for some coaching. Instructor must be have equipment and be able to access all parts of the loop at all times.'),
  ('AMP 45 Rock Mangatepopo Area Crags',10,'Minimise',null,'Volcanic eruption','Stop, watch for burning ash and flying rocks. Run away from the path of fast-moving burning clouds. Otherwise find shelter behind something - banks, ridges or in hollows. Don’t turn away from flying rocks unless you are sure they won’t hit you. Evacuate out of the hazard zone and away from the eruption site. Contact Hillary base for further advice. DM will seek advice from relevant authorities'),
  ('AMP 45 Rock Mangatepopo Area Crags',20,'Minimise',null,'Lahar','If a Lahar occurs or the early warning detection system is heard go to higher ground and contact DM. DM approval is required for movement. DM will seek advice from relevant authorities.'),
  ('AMP 45 Rock Mangatepopo Area Crags',30,'Minimise',null,'Loose rocks on approach and in working area at top','Consider helmets on approach
Disclose loose rock hazard, brief ‘rock’ call, and what to do if you hear it
Identify safe areas for students to wait while rigging'),
  ('AMP 45 Rock Mangatepopo Area Crags',40,'Minimise',null,'Old bolts and warratahs','Check all bolts (esp. for rockfall damage). Older bolt and warratahs are of unknown origin and age and should be used with caution, and as part of an anchor incorporating other pieces of protection.'),
  ('AMP 45 Rock Mangatepopo Area Crags',50,'Minimise',null,'Clients left unaccompanied while instructor is rigging','Clients to be monitored by instructor. Give them a clear boundaries and ensure that they are in areas where they cannot cause a hazard to themselves or the environment'),
  ('AMP 46 Rock Self-directed Abseil',10,'Minimise',null,'Heights','Instructor to create a safety line for clients to clip onto while they are working on the abseil'),
  ('AMP 46 Rock Self-directed Abseil',20,'Minimise',null,'Anchor failure','Check all the components of the anchor before it is used.'),
  ('AMP 46 Rock Self-directed Abseil',30,'Minimise',null,'Participants falling due to inadequate belay system','Manage belay so that participants cannot fall. Use backup belayer for novice belayers.'),
  ('AMP 46 Rock Self-directed Abseil',40,'Minimise',null,'Large groups – the setup can get quite busy and messy','Instructor to be in position to check all harnesses, safety lines etc before exposing participants to height hazard. Max 1:4 ratio at top of wall. Instructor to keep site clear of trip hazards/tangles.'),
  ('AMP 47 Rock Taranaki Falls Abseil',10,'Eliminate',null,'High water levels','Do not use abseil site'),
  ('AMP 47 Rock Taranaki Falls Abseil',20,'Eliminate',null,'Icy conditions causing slips','Do not use abseil site'),
  ('AMP 47 Rock Taranaki Falls Abseil',30,'Minimise',null,'Slipping into the stream above waterfall','Keep students away from stream edge'),
  ('AMP 47 Rock Taranaki Falls Abseil',40,'Minimise',null,'Lack of visibility / communication between top and bottom.','Establish method of communication between top and bottom. Ensure participants keep helmets on when at bottom until moved away. Set up method of how to communicate if help is needed.'),
  ('AMP 47 Rock Taranaki Falls Abseil',50,'Minimise',null,'Public around site / edges / anchors causing distraction or anchor failure','Be aware and stop the activity if necessary. Check anchors regularly.'),
  ('AMP 47 Rock Taranaki Falls Abseil',60,'Minimise',null,'Members of the public beneath abseil area (unseen)','Ensure area is clear before dropping ropes or abseiling clients.'),
  ('AMP 47 Rock Taranaki Falls Abseil',70,'Minimise',null,'Clients not able to get off rope','Ensure your clients are briefed on how to get out of the system when they reach the bottom (before they leave the top)'),
  ('AMP 48 Rock Pukehinau Abseil',10,'Minimise',null,'Driving on Caves Rd','Refer driving AMP 81'),
  ('AMP 48 Rock Pukehinau Abseil',20,'Minimise',null,'Client falling','Instructor to ensure that safe areas and boundaries are communicated to clients'),
  ('AMP 48 Rock Pukehinau Abseil',30,'Minimise',null,'Unsupervised students at base of abseil','Use the teacher in group to help supervise if possible'),
  ('AMP 48 Rock Pukehinau Abseil',40,'Minimise',null,'Stonefall from abseil lip','All students to keep helmets on at base of abseil and move away from fall line of rocks'),
  ('AMP 48 Rock Pukehinau Abseil',50,'Minimise',null,'Equipment damage – abseil rope under belay rope and wear on abseil rope','Correctly rig. Use appropriate rope protection. If ropes become damaged report to RO'),
  ('AMP 48 Rock Pukehinau Abseil',60,'Minimise',null,'Slippery track leading up to abseil site','Last few metres, disclose risk'),
  ('AMP 48 Rock Pukehinau Abseil',70,'Minimise',null,'Environmental damage rigging from trees','Use rigging system that minimises rubbing on trees e.g. W3P2'),
  ('AMP 50 Rock High Ropes Course',10,'Minimise','Flea Jump','Sharp, hard edges
Slack in rope/caught on structure','Good progression to ensure a clean jump
Instructor to highlight hazard; rope must be un-snagged from structure'),
  ('AMP 50 Rock High Ropes Course',20,'Minimise','Giant’s Ladder','Bottom rung swinging into belayers
Slack in rope/caught on structure','Use of bystanders or instructor to stabilise in order to avoid injury to belayers
Instructor to highlight hazard, climbing on same side of ladder as belay rope'),
  ('AMP 50 Rock High Ropes Course',30,'Minimise','Rickety Bridge','Slack in rope/caught on structure','Instructor to highlight hazard; rope must be un-snagged from structure'),
  ('AMP 50 Rock High Ropes Course',40,'Minimise','Big Swing','Bystanders being hit by swinging participant
Falling from structure
Falling off ladder
Students injured while using piñata stick
Inappropriate belaying / Falling from climbing wall while accessing tower
Client dropping with slack cables causing whiplash','Instructor to ensure area below Big Swing is clear before participant jumps – or be laying down
Safety to be attached to participant before being exposed to edge
 Safety chain to be used at all times to minimise exposure to fall. 
 Gate to be closed when not in use. Other clients monitored if gate open. Or to tie gate shut when clients on platform.
Participants instructed to climb halfway down ladder before unclipping from red karabiner. Ladder to be stabilised securely by bystanders
Brief them to let go before being flung or dislocating shoulder, no swinging of stick.
Instructor to be monitoring the belayers while clients are climbing. Cannot be operating swing while student climbing up. Refer T2 rope and rigging
Client to be briefed, at time of jump, to drop sideways or slightly back from ledge. Feet behind the metal strip'),
  ('AMP 50 Rock High Ropes Course',50,'Minimise','Trapeze','Uneven belaying causing difficult descent
Participant swings into pole 
 Incorrect Harness','Belay teams to communicate between each other

Participants to prevent injury with arms/legs outstretched
Full body harness to be worn, instructor to understand its use.'),
  ('AMP 50 Rock High Ropes Course',60,'Minimise','General','Ladders falling and hitting someone','All ladders must be held or secured when someone is climbing or in windy conditions'),
  ('AMP 50 Rock High Ropes Course',70,'Eliminate','General','Lightning strike','HR closed during lightning or thunderstorms. Refer DM and Tier 2 Handbook'),
  ('AMP 50 Rock High Ropes Course',80,'Minimise','General','Falling','All equipment checked prior to participant leaving ground
Correct belay technique to be used and monitored at all times
No climbing without ropes
Participants to tie into rope; no karabiners used for climber attachment except for Climbing Wall, Trapeze and Big Swing
Instructor to use approved method and anchors if climbing above 2m (Staples are not approved anchors)
Climbing communication to be used
Ensure Shear Reduction Block (SRB) is close to directly above the student as they climb.
Belayer to control speed of climber ascending and move along horizontal elements.'),
  ('AMP 50 Rock High Ropes Course',90,'Minimise','General','Injured or stuck client at height','Instructor to be aware of procedures for removing client from elements. See images (page 3), photos in HR shed and competency.'),
  ('AMP 50 Rock High Ropes Course',100,'Minimise','General','Instructor inattention','Maximum of 3 belay ropes at a time OR Big swing only. You need to be able to safely manage and support all the ropes that are being run'),
  ('AMP 50 Rock High Ropes Course',110,'Minimise','General','Anchor / Attachment point failure','Staples on poles are not to be used for personal safety. They are not rated for this purpose. We do utilise them when accessing the poles but they are used in conjunction with the new cables (installed 2023). Ladder to access wire cables and put on a wire shunt attached to you with a Yates Screamer.'),
  ('AMP 50 Rock High Ropes Course',120,'Minimise','General','Swinging into elements','Clients to be briefed on a safe method of lowering off elements to prevent them swinging into elements and hitting chest, face, teeth etc.'),
  ('AMP 51 Rock Indoor Climbing Walls (Tongariro)',10,'Minimise',null,'Falling from height while bouldering','No bouldering above red line on old wall, or above chalk line on new wall.
Bouldering mats to be used if students are bouldering up (mats do not have to be used if low-level traversing just off the ground), especially when on roof sections (left hand end of new wall, or upstairs bouldering cave). Students must be briefed in appropriate bouldering mat positioning.
Appropriate spotting techniques must be taught and used.
Brief students on how to fall (spot landing).
Ensure there are no gaps between ground or bouldering pads to prevent ankle injury.'),
  ('AMP 51 Rock Indoor Climbing Walls (Tongariro)',20,'Minimise',null,'Belayer losing control when lowering climber (using Grigri or Eddy)','Staff to be inducted and familiar in use of both belay devices.
Good belay brief including how to lower, and supervision when lowering.
Use of back up belayer.
Brief students and practice letting go of lowering lever when instructor says “Stop!”
Consider not teaching lowering and/or getting belayer to call instructor when they want to lower.'),
  ('AMP 51 Rock Indoor Climbing Walls (Tongariro)',30,'Minimise',null,'Students climbing unsupervised on the wall','Climbing wall to be locked (new wall) or ground pads placed vertically on wall at end of session.
Sign disclosing ‘no unsupervised climbing’ to be placed on wall at end of session.'),
  ('AMP 51 Rock Indoor Climbing Walls (Tongariro)',40,'Minimise',null,'Old wall - Distraction of other people in RC and other people coming too close to climbers','Careful group management by instructor.
Clear designation of climbing area.
Consider not using the old wall when the RC is busy.'),
  ('AMP 51 Rock Indoor Climbing Walls (Tongariro)',50,'Minimise',null,'New wall - Placing fingers in hangers/rings on wall','Brief students not to put fingers in hangers and ring bolts.'),
  ('AMP 51 Rock Indoor Climbing Walls (Tongariro)',60,'Minimise',null,'New wall - Falling from height lead climbing','Students to have adequate progression and demonstrate skills required at ground level before completing task at height.
Direct supervision until competence demonstrated.'),
  ('AMP 51 Rock Indoor Climbing Walls (Tongariro)',70,'Minimise',null,'Taupo Wall – Falling from height accessing abseil platform','Clients should be belayed up the access ladder for abseil platform.'),
  ('AMP 51 Rock Waitomo Crags (Tertiary)',10,'Admin
PPE',null,'Loose rock','Brief students. Wear helmets and avoid areas where rock looks soft.'),
  ('AMP 51 Rock Waitomo Crags (Tertiary)',20,'Admin',null,'Insufficient supervision at height','Brief students about boundaries. Ensure students can be seen operating at height until deemed competent.'),
  ('AMP 51 Rock Waitomo Crags (Tertiary)',30,'Admin',null,'Wide variety of anchors (potential for student confusion).','Instructors to brief students about different anchors, and teach a method that works for all types of anchor set ups.'),
  ('AMP 51 Rock Waitomo Crags (Tertiary)',40,'Admin',null,'Access to anchors difficult in places to set top rope.','Lead climb to anchors where necessary.'),
  ('AMP 51 Rock Waitomo Crags (Tertiary)',50,'Admin',null,'Some significant ledges on ‘Tigger’ (14) that have tricky bolts protecting them.','Ensure students are briefed about ledges and are confident leading at the grade.'),
  ('AMP 51 Rock Waitomo Crags (Tertiary)',60,'Admin',null,'Falling into tomo','Brief students about tomo and to stay on track..'),
  ('AMP 51 Rock Waitomo Crags (Tertiary)',70,'Admin
PPE',null,'Falling awkwardly from height','Manage what boulders students are on.
Ensure spotters are used and spotting correctly.
Brief students on how to fall.
Recommend use of bouldering pads.'),
  ('AMP 52 Rock South Waikato Crags',10,'Admin',null,'Insufficient supervision at height – difficult to see anchors at most of these crags','Ensure students can be seen operating at height until deemed competent. Consider bringing binoculars. Consider climbing the climbs and clipping into anchors.'),
  ('AMP 52 Rock South Waikato Crags',20,'Admin',null,'Wide variety of anchors (potential for student confusion).','Instructors to brief students about different anchors, and teach a method that works for all types of anchor set ups. Consider bringing anchor boards.'),
  ('AMP 52 Rock South Waikato Crags',30,'Admin',null,'Old coach bolts','Not found on well used climbs, but still present in the area. Check these thoroughly before use and if any doubt, do not use!'),
  ('AMP 52 Rock South Waikato Crags',40,'Admin',null,'Road between Mangakino and Waipapa Dam is narrow and windy, often with logging trucks.','Take it slow and expect on-coming trucks.'),
  ('AMP 52 Rock South Waikato Crags',50,'Admin
/Engineer',null,'Castle Rock & Waipari – High first bolt on many climbs.','Students to be confident at grade, or use stick clip, or instructor to clip first bolt.'),
  ('AMP 52 Rock South Waikato Crags',60,'Admin',null,'Waipari - Significant ledge on Slug Wall','Ensure students are briefed about ledge and are confident leading at the grade.'),
  ('AMP 52 Rock South Waikato Crags',70,'Isolate',null,'Sheridans - very hollow rock on the climbs on the right hand end of Meteor Buttress','Avoid the two grade 16 climbs at the right hand end (Terrapin & unknown).'),
  ('AMP 52 Rock South Waikato Crags',80,'Admin',null,'Pakeho - some significant ledges on ‘Tigger’ (14) that have tricky bolts protecting them.','Ensure students are briefed about ledges and are confident leading at the grade.'),
  ('AMP 52 Rock South Waikato Crags',90,'Admin',null,'Airstrips - Falling into tomos','Brief students about tomos and to stay on track..'),
  ('AMP 52 Rock South Waikato Crags',100,'Admin/
PPE',null,'Airstrips - Falling awkwardly while bouldering','Manage what boulders students are on.
Use bouldering pads.
Ensure spotters are used and spotting correctly.
Brief students on how to fall (spot landing).'),
  ('AMP 54 Rock Kawakawa Bay Crag',10,'M3',null,'Loose rocks on approach and in working area at top (Cracks Wall)','Consider helmets on approach
Disclose loose rock hazard and what to do if you push one downhill.
Identify safe areas for students to wait while rigging'),
  ('AMP 54 Rock Kawakawa Bay Crag',20,'M3',null,'Incorrect protection placement for lead climber','Climber to demonstrate good protection placements prior to climbing
Instructor to be in position to render assistance to climber if needed, until instructor deems they are competent to climb without assistance.
Once climber is deemed competent to climb unassisted they still need route approval from instructor for further climbs'),
  ('AMP 54 Rock Kawakawa Bay Crag',30,'M3',null,'Communication difficulties','Consistent language to be used as communication between climber and belayer
Names to be used to avoid confusion with other site users
Prior to climbing, the method of descent needs to be established between climber and belayer'),
  ('AMP 54 Rock Kawakawa Bay Crag',40,'M3',null,'Access Tracks','Check and use handlines where fixed on approach to crags. Consider helmets. 
 Be aware of mountain bikers when on the main track'),
  ('AMP 54 Rock Kawakawa Bay Crag',50,'M2',null,'Insufficient anchors / rigging','SOME TREES ARE SMALL, AND A LONG WAY FROM THE EDGE
Carry appropriate equipment for large rigging
Instructor to have current knowledge of appropriate anchors at top of crag'),
  ('AMP 54 Rock Kawakawa Bay Crag',60,'M2',null,'Environmental damage','Where possible stick to tracks, Carry out all rubbish, Camp in designated locations.'),
  ('AMP 55 Rock Kinloch 1.2 Crag',10,'Minimise',null,'Loose rocks','Helmets at all times at bottom of cliffs.
Leave bags away from cliff (good area 20m downhill in open-ish area).
Brief students as per usual (calling "rock", etc.), plus being aware of what they are pulling/standing on.'),
  ('AMP 55 Rock Kinloch 1.2 Crag',20,'Minimise','Steep terrain at top of crag.','Students should be accompanied the first time they go up and move around at the top of the crag.','   '),
  ('AMP 55 Rock Kinloch 1.2 Crag',30,'Minimise','Possums sometimes present in cracks of Devil is Six (14) and Surfer Rosa (13)','Warn students that possums might be there; and if they are brief not to try and poke/pat/provoke them.','   '),
  ('AMP 55 Rock Kinloch 1.2 Crag',40,'Minimise','Incorrect protection placement for trad lead climber','Climber to demonstrate good protection placements prior to climbing
Instructor to be in position to render assistance to climber if needed, until instructor deems they are competent to climb without assistance.','   '),
  ('AMP 55 Rock Kinloch 1.2 Crag',50,'Minimise','Environmental damage','Stick to tracks.','   '),
  ('AMP 56 Rock Dunedin Crags',10,'Minimise',null,'Loose rock (Particularly at Main cliff and sport climbs in cave area)','Brief students. Helmets. Don''t linger in fall zones.'),
  ('AMP 57 Rock Timaru Crags',10,'Minimise',null,'Old bolts','Stick to using newer glue in bolts, rather than old carrot and expansion'),
  ('AMP 57 Rock Timaru Crags',20,'Eliminate/Minimise',null,'Dead branches overhead, especially at Spur Road','Instructors must check for overhead branches and disclose, and eliminate/Isolate hazard.'),
  ('AMP 57 Rock Timaru Crags',30,'Minimise',null,'Narrow path/places to belay at bottom of crag.','Brief students.'),
  ('AMP 58 Rock Sebastopol Bluffs',10,'Minimise',null,'Long pitches, with wind hard to communicate','Teach students non-verbal comms between climber and belayer. Consider use of walkie talkies.'),
  ('AMP 58 Rock Sebastopol Bluffs',20,'Minimise',null,'Quality of rock','Use instructor knowledge to choose suitable climbs'),
  ('AMP 59 Rock Tukino',10,'Minimise',null,'Loose rocks','Brief students about loose nature of NZ alpine rock, and to be aware of what they are pulling/standing on, and testing it before grabbing it
Brief students to call "rock" if they dislodge one
Helmets at all times at bottom of cliffs.
Leave bags away from cliff bottom and out of fall zone of rocks (they can bounce a long way out)'),
  ('AMP 59 Rock Tukino',20,'Minimise',null,'Fall from height','Students not to go to clifftop without supervision
Instructors to ensure students are supervised during transitions or deemed competent at task.'),
  ('AMP 59 Rock Tukino',30,'Minimise',null,'Insufficient anchors/rigging','Anchors are checked by instructor before use.'),
  ('AMP 61 Water Lake Otamangakau Water Activities',10,'Minimise',null,'Unconfident/incompetent swimmers','Check medical forms and consider suitability of activity
Client competence to be checked before commencing journey, consider wet exit drill.'),
  ('AMP 61 Water Lake Otamangakau Water Activities',20,'Minimise',null,'Cold water immersion/hypothermia','Consider getting participants wet beforehand (Decreases the issues with cold shock)
Ensure students are wearing suitable clothing for conditions'),
  ('AMP 61 Water Lake Otamangakau Water Activities',30,'Minimise',null,'Landing badly during bridge jump','Ensure first jump is a foot first entry
Jump only from the concrete not the rail
Students must jump – no bum shuffling 
Disclose risk of landing badly and demonstrate a good method for jumping. Slightly bent legs, feet together, straight back
If clients are jumping together then ensure enough space so they do not land on each other. No holding hands while jumping.
Deep water is in between piles 4-6 from river right (Check and see where is best to jump as silt in channel shifts regularly) 
Check depth with weighted throwbag- must be greater than 2m depth for activity to take place
If water lower, option to jump on lower side of the bridge. 
Instructor to be in position for rescue at all times'),
  ('AMP 61 Water Lake Otamangakau Water Activities',40,'Minimise',null,'Heavy boats and equipment','When carrying boats
 - 2 people per single vessel
 - 4 people min per double vessel'),
  ('AMP 61 Water Lake Otamangakau Water Activities',50,'Minimise',null,'Lost boots in mud','Disclose risk to students and ensure that all footwear is securely fastened.
Clients to either wear own footwear or understand that they can wear Hillary Outdoors rubber boots and if they lose them they have to pay for them.'),
  ('AMP 61 Water Lake Otamangakau Water Activities',60,'Minimise',null,'Losing gear in the lake','Lake levels rise and fall rapidly. Ensure all equipment is secured (especially on overnights)
Ensure sinkable equipment is secured to boat'),
  ('AMP 61 Water Lake Otamangakau Water Activities',70,'Minimise',null,'Conflicts with other lake users','Give fishermen as much space as possible. Stay off private land.
Be quick and efficient on the boat ramps and don’t spread gear around.'),
  ('AMP 62 Water Lake Taupo Activities',10,'Minimise',null,'Wind – forecast or localised','Check specific Lake Taupo Marine forecast
Know your escape options
Have knowledge of localised effects of the wind 
Watch for thunderstorms – they can create massive wind gusts'),
  ('AMP 62 Water Lake Taupo Activities',20,'Minimise',null,'Cold water','Brief about effects of cold water immersion. Consider pre-exposure splashing face to minimise adverse effects of immersion. Check for adequate layers for conditions.'),
  ('AMP 62 Water Lake Taupo Activities',30,'Minimise',null,'Other users','Be respectful and keep your distance, Be time efficient on boat ramps. Rules of the sea apply (Maritime Transport Act and Maritime Rules Part 22)'),
  ('AMP 62 Water Lake Taupo Activities',40,'Minimise',null,'Damage to boat','Load and unload correctly. Care needed in shallow water. Carry general repair kit and know how to use it!'),
  ('AMP 62 Water Lake Taupo Activities',50,'Minimise',null,'Off water environment – Blackberry, Bees, Seagulls','Dive bombing sea gulls, Bees and Blackberry exist in some areas around the lake, especially around the Motuoapa swamp area. Just be aware of these things. Avoid area if person/s with allergies to bees etc.'),
  ('AMP 62 Water Lake Taupo Activities',60,'Minimise',null,'Vans being damaged by Sea Kayaks too close to van','Extend drawbar when towing Sea Kayaks'),
  ('AMP 63 Water Kayaking G2-3 Tarawera Slalom site',10,'Minimise',null,'Strainers on either side of rapid above slalom site','If Paddling Rapids above slalom site take time to scout rapids with students identifying hazards and talking through line choice.'),
  ('AMP 63 Water Kayaking G2-3 Tarawera Slalom site',20,'Minimise',null,'Multiple channels with pinning potential at low flow','Paddle the main channel avoiding taking potentially blind Channels'),
  ('AMP 63 Water Kayaking G2-3 Tarawera Slalom site',30,'Minimise',null,'Strainer below take out','Ensure that students are aware of Hazard and also know where take out is. Instructor to stay on water until all students are off the water.'),
  ('AMP 64 Tongariro River - SOT, Inflatable',10,'Eliminate',null,'Flooding','River not to be used if there is a chance the water levels may rise above 40 cumecs'),
  ('AMP 64 Tongariro River - SOT, Inflatable',20,'Minimise',null,'Getting run over by the inflatable vessels','Briefing to include getting off the vessel if it gets stuck. Get off on the side. If people get off the front they will get run over. Make sure participants on sit-on-tops keep away from larger vessels when near rapids.'),
  ('AMP 64 Tongariro River - SOT, Inflatable',30,'Minimise',null,'Rocks falling from unstable banks','Helmets to be worn at all times. Instructor to have awareness for rocks on overhanging or steep areas.'),
  ('AMP 64 Tongariro River - SOT, Inflatable',40,'Minimise',null,'Proximity to fishermen','Some fishermen dislike other river users. The river is there for all of us to enjoy. If you see fishermen, paddle down and talk to them. Any issues report to DM, anything serious call the police. Do your best to keep out of their way. Instructor to give directions to avoid other river users.'),
  ('AMP 64 Tongariro River - SOT, Inflatable',50,'Minimise',null,'Falling off craft','Brief to either get back on immediately or float in the white-water swim position to a pool then get on. If unable to get on, swim to the side of the river. Swim progression must be briefed to all students and recommend doing a practice swim before commencing the trip. Consider throw bagging and whitewater swim position practice. Kayaking progression on moving water must be done before commencing trip, including ferry gliding and breaking in and out of eddies.'),
  ('AMP 64 Tongariro River - SOT, Inflatable',60,'Note','Rapids','Duchess Pool (Southpaw) - entry rapid','Take right hand channel (can take centre channel, rapid not as long and very shallow). Starts with small waves, goes around hard left hand bend and drops into a series of big waves. These waves may flip a sit-on-top boat. Long flat swim to next rapid. Group eddied into large shallow eddy at top river left, one instructor in river left above this rapid, one instructor at bottom. Instructors to call students through. Only expose two inflatable kayaks or two sit-on-tops at a time to this rapid. Old log removed.'),
  ('AMP 64 Tongariro River - SOT, Inflatable',70,'Note','Rapids','Silly Pool - Hatchery','Small, narrow fast channel exists on river left. This can contain strainers. Follow the main flow down the main channel and keep clear of it.'),
  ('AMP 64 Tongariro River - SOT, Inflatable',80,'Note','Rapids','Kamahi Pool - exit rapid (Waka-Muncher)','Rapid to be visually scouted with the group. Show the group the line you want them to take, how and where to portage if they choose, what to do if they tip off craft, and where to regroup. Only expose two inflatable kayaks or two sit-on-tops at a time to this rapid.'),
  ('AMP 65 Water Tongariro River Delta',10,'Eliminate',null,'Flooding','River not to be used if there is a chance the water levels may rise above 40 cumecs'),
  ('AMP 65 Water Tongariro River Delta',20,'Minimise',null,'Trees on either bank and submerged','Disclose hazard to students – Give early and clear directions before corners. Consider a flat-water training before river journey. Portage where corner have significant flow into trees.'),
  ('AMP 65 Water Tongariro River Delta',30,'Minimise',null,'Wind on Lake','Make sure that the Lake forecast is appropriate for the craft being used. MAX Force 2 for Mavericks and SOT
See Tier 2 for Canoe and Sea kayak cut off'),
  ('AMP 65 Water Tongariro River Delta',40,'Minimise',null,'Proximity to fishermen','Some fishermen dislike other river users. The river is there for all of us to enjoy. If you see fishermen, paddle down and talk to them. Any issues report to DM, anything serious call the police. Do your best to keep out of their way.
Instructor to give directions to avoid other river users.'),
  ('AMP 65 Water Tongariro River Delta',50,'Minimise',null,'Falling off craft','Brief to hold onto craft and all equipment. Canoes have swim lines at the stern and teach students how to use them.'),
  ('AMP 66 Water Kayaking G2 Aniwhenua',10,'Minimise',null,'Kayakers caught in tail race bay','Brief to keep clear. Do not launch off structure, use rocks upstream. Consider carpet to minimise damage to boats.'),
  ('AMP 66 Water Kayaking G2 Aniwhenua',20,'Minimise',null,'Number of places with overhanging trees','Brief group about strainers and how to deal with and be in a position to identify new hazards.'),
  ('AMP 66 Water Kayaking G2 Aniwhenua',30,'Minimise',null,'Injury from hitting rock ledge on waterfall and kayaker landing badly','Waterfall no longer suitable for students due to rock shelf. Do not use with students.'),
  ('AMP 66 Water Kayaking G2 Aniwhenua',40,'Minimise',null,'Jet boats','Brief group on possibility of other users and at any observations to signal group to move to side and get out of way'),
  ('AMP 66 Water Kayaking G2 Aniwhenua',50,'Minimise',null,'Poor communication areas. Cell phone limited reception.','PLB is to be carried by the instructor in the last boat.'),
  ('AMP 68 Water Canoe G2 Tongariro (Tongariro)',10,'Eliminate',null,'Flooding','River not to be used if there is a chance the water levels may rise above 40 cumecs'),
  ('AMP 68 Water Canoe G2 Tongariro (Tongariro)',20,'Minimise',null,'Number of places with overhanging trees','Brief group about strainers and how to deal with and be in a position to identify new hazards.'),
  ('AMP 68 Water Canoe G2 Tongariro (Tongariro)',30,'Minimise',null,'Pinned Canoe on rapid after island pool','Ensure clients have seen line and know hazards to avoid. Consider positioning safety at rock to be able to respond to any pin quickly'),
  ('AMP 68 Water Canoe G2 Tongariro (Tongariro)',40,'Minimise',null,'Fishermen','Some fishermen dislike other river users. The river is there for all of us to enjoy. If you see fishermen, paddle down and talk to them. Any issues report to DM, anything serious call the police. Do your best to keep out of their way.
Instructor to give directions to avoid other river users.'),
  ('AMP 68 Water Kayaking G4 Kaituna (Tertiary)',10,'Admin',null,'Trout pool falls – dangerous tow back at bottom','All students to take out before trout pool.'),
  ('AMP 68 Water Kayaking G4 Kaituna (Tertiary)',20,'Admin',null,'Student ability insufficient- resulting in exit from boat','Ensure that any students have a reliable roll and are a grade 4 paddler.'),
  ('AMP 68 Water Kayaking G4 Kaituna (Tertiary)',30,'Admin',null,'Undercut after Abyss rapid. 3m long','Best line - Middle, go left.'),
  ('AMP 68 Water Kayaking G4 Kaituna (Tertiary)',40,'Admin',null,'Undercut left on rapid above playhole','Move to right'),
  ('AMP 69 Water Kayaking Mohaka G2',10,'Admin',null,'Strainers in water at “The Organs” Wood in river on outside of bend','Disclose risk and ensure students are paddling a line to keep away from the hazard'),
  ('AMP 69 Water Kayaking Mohaka G2',20,'Admin',null,'Strainer hazard (Trees) in right channel.','(See Map.) Can avoid by taking the left channel early.'),
  ('AMP 69 Water Kayaking Mohaka G2',30,'PPE',null,'Poor communication areas. Cell phone limited reception.','PLB is to be carried by the instructor in the last boat.'),
  ('AMP 71 Water Tawhai Falls Jump',10,'Minimise',null,'Unconfident/incompetent swimmers','Client competency must be ascertained before proceeding with jumps. Consider a swim test
Check medical forms and consider suitability of activity'),
  ('AMP 71 Water Tawhai Falls Jump',20,'Minimise',null,'Cold water immersion/hypothermia','Get participants wet beforehand (Decreases the issues with cold shock) 
Ensure instructor able to rescue at all times (PFD on, throwbag accessible)
Ensure students are wearing suitable clothing, PFD and footwear'),
  ('AMP 71 Water Tawhai Falls Jump',30,'Minimise',null,'Landing badly','Demonstrate a good method for jumping. One foot take off, Straight legs, feet together, straight back
Student must demonstrate good jumping practice (Straight legs, feet together, straight back) off practice jump rock before moving up to the waterfall jump.
Disclose risk of landing badly
Challenge by choice operating at all times'),
  ('AMP 71 Water Tawhai Falls Jump',40,'Minimise',null,'Student/Instructor Slip and falls down cliff','Attach sling/hand line to Doc viewing platform with hand loop for instructor
Only 1 instructor/student at approved jumpsite at a time
Instructor has hand behind student to push out and away from cliff (if required)'),
  ('AMP 71 Water Tawhai Falls Jump',50,'Minimise',null,'Student Flushing out of pool through slot at bottom and suffering entrapment','Disclose risk of hazard
Brief white-water swim position, swim to right if unable to make left eddy'),
  ('AMP 71 Water Tawhai Falls Jump',60,'Minimise',null,'Lost footwear','Disclose risk to students
Students to either wear own footwear or understand that they can wear rubber boots and if they lose them they have to pay for them'),
  ('AMP 72 Water Whanganui River Travel',10,'Elimination/ Minimise',null,'Flooded river','Instructor to be able to obtain river levels before putting on river. Use river levels matrix for operational levels. Instructor to know cut off levels for trip.'),
  ('AMP 72 Water Whanganui River Travel',20,'Minimise',null,'Jet boats / Other motor craft','Make students aware. Give way to larger/faster vessels. Beware of wake they may produce. Encourage students to turn 90 degrees to face into the wake'),
  ('AMP 72 Water Whanganui River Travel',30,'Minimise',null,'Heavy boats, Poor manoeuvrability. Hard to upright.','Allow more room and time to manoeuvre around obstacles. Equipment to be tied to the boat'),
  ('AMP 72 Water Whanganui River Travel',40,'Minimise',null,'Damage to vessels','Brief students about looking after the boats. Emphasis on care when fully loaded.'),
  ('AMP 72 Water Whanganui River Travel',50,'Minimise',null,'Entrapment - under gear or thwart','Brief students about hazard and ensure gear is tied to reduce hazard. Saw to be carried by each instructor as per tier 2.'),
  ('AMP 72 Water Whanganui River Travel',60,'Minimise',null,'Head injury-Rocks or objects in rapids','Helmets to be taken on journey, Instructor to identify situations, hazards, rapids and communicate when they must be worn to clients'),
  ('AMP 72 Water Whanganui River Travel',70,'Minimise',null,'Canoe Pin','Brief priority to avoid, if occurs get out quick, get clear or stay upstream. Instructor to lead recovery of canoe'),
  ('AMP 72 Water Whanganui River Travel',80,'Minimise',null,'Loss of gear','Tie boats much higher than needed when leaving unattended. Consider removing all gear from boats
All gear to be attached to boats or stored away when paddling'),
  ('AMP 72 Water Whanganui River Travel',90,'Minimise',null,'Other vessels','Give them room on rapids. Be aware that they may do unexpected things.'),
  ('AMP 72 Water Whanganui River Travel',100,'Minimise',null,'Potential remoteness of trip','Carry PLB and Inreach and adequate repair kit. All participants to be aware of the location of emergency communication devices.'),
  ('AMP 72 Water Whanganui River Travel',110,'Minimise',null,'Re-bar, Steel on river right 500m before Pipiriki Landing.','Disclose to clients and stay clear.'),
  ('AMP 72 Water Whanganui River Travel',120,'Minimise',null,'Trees on banks and submerged in water','Brief hazard to students before trip. 
Instructor to identify safe route or portage'),
  ('AMP 72 Water Whanganui River Travel',130,'Minimise',null,'Getting caught on the river during dark hours','Off water at least 1 hour before sunset. 
Sunset times need to go onto off site plan.'),
  ('AMP 73 Water Kayak Piriaka',10,'Admin',null,'Power station','Ensure all persons put in below power station and remain clear of outflows.'),
  ('AMP 73 Water Kayak Piriaka',20,'Admin',null,'Branches and strainer','20 mins down stream chanel veer to right after grassy flat on left. Branches on island in middle of river. Easily avoidable'),
  ('AMP 73 Water Kayak Piriaka',30,'Admin',null,'Known Hole','Below the above hazard, is a hole behind a rock that shows at low water .Big hole at high water
Trees down on river bank to the right of this downstream'),
  ('AMP 73 Water Kayak Piriaka',40,'Admin',null,'Limited access or space at put in','Be prepared for put in to take a while as is limited access, and a small eddy in which to wait. Put on in groups and cross to big eddy river right across from put in'),
  ('AMP 74 Water Kayaking Waikato Reids Farm',10,'Admin',null,'Slalom wires at high water flows','Disclose risk. Keep away from these spots'),
  ('AMP 74 Water Kayaking Waikato Reids Farm',20,'Admin',null,'Tree hazard on left channel near Cherry Island.','Avoid by taking other channel'),
  ('AMP 74 Water Kayaking Waikato Reids Farm',30,'Admin',null,'Student washing or pinning on small islands','Disclose to clients and remind to lean onto the obstacle.'),
  ('AMP 74 Water Kayaking Waikato Reids Farm',40,'Admin',null,'Other kayakers','Disclose hazard to clients. Keep group in close proximity when around other users.'),
  ('AMP 74 Water Kayaking Waikato Reids Farm',50,'Admin',null,'Willows/Pine trees along banks all the way down river','Disclose hazard to clients'),
  ('AMP 74 Water Kayaking Waikato Reids Farm',60,'Admin',null,'Hot Pools: Ameobic menegitis, Rubbish, Broken Glass','Keep head above water, Disclose hazard to clients.'),
  ('AMP 74 Water Kayaking Waikato Reids Farm',70,'Admin',null,'Strong Currents in Bungy Eddie','Keep clear of the bungy site/eddie'),
  ('AMP 74 Water Kayaking Waikato Reids Farm',80,'Admin',null,'Blackberry on banks','Disclose hazard to clients'),
  ('AMP 75 Water Pukehinau Stream Travel',10,'Eliminate/Minimise',null,'Flooding','Stream not to be used during a heavy rain warning
If water flow increases dramatically or river changes colour get out of the river and walk at first escape route possible
If instructor unable to access any part of the river must take out at next possible escape route'),
  ('AMP 75 Water Pukehinau Stream Travel',20,'Minimise',null,'Cold','Minimum clothing to be worn: wetsuit, thermals, windproof jacket. Consider: Fleece layer, beanie
Hot drinks to be carried
Keep people moving
If using tubes can work to keep clients mostly out of water.'),
  ('AMP 75 Water Pukehinau Stream Travel',30,'Minimise',null,'Foot entrapments, snags on rocks or trees','Lie flat on tube, keep feet up. River flow must be low enough for instructor to walk out into each rapid and assist'),
  ('AMP 75 Water Pukehinau Stream Travel',40,'Minimise',null,'Logjams and slippery surfaces','Disclose hazard
See map for major logjam locations - other logs could get jammed during floods
L1 – (see map) All participants to stand before logjam and wait on river right, walking down slippery log as directed by instructor
L2 – (see map) All participants to stand in the shallows river right before logjam, then instructor to direct at their own discretion'),
  ('AMP 75 Water Pukehinau Stream Travel',50,'Minimise',null,'Communication','No radio comms while in narrow section and poor elsewhere in stream
Instructor to radio in immediately prior to entering, and upon exiting stream – see map for areas of known reception.'),
  ('AMP 75 Water Pukehinau Stream Travel',60,'Minimise',null,'Impact to Blue Ducks','End of November – Mid December, tube float not recommended. Follow recommended blue duck protocols'),
  ('AMP 75 Water Pukehinau Stream Travel',70,'Minimise',null,'Bruising from hitting rocks','Disclose hazard. Lie flat on the tube and keep feet up'),
  ('AMP 75 Water Pukehinau Stream Travel',80,'Minimise',null,'Large sieves/ land slide','Instructor to manage group around land slide at the start of the gorge containing large person sized sieves. Good line out of water on river left.'),
  ('AMP 76 Water Kayaking Murchison G2-3',10,'Eliminate',null,'Flooded rivers','Buller river not to be used if above 150 cumecs on Longford gauge. Other rivers visual gauge.'),
  ('AMP 76 Water Kayaking Murchison G2-3',20,'Minimise',null,'New hazards on river runs','Gain local knowledge from Kayak school staff or other professionals for all runs that are being run.
Scout all rapids – either from boat or from bank that the instructor does not have recent experience of.'),
  ('AMP 76 Water Kayaking Murchison G2-3',30,'Minimise',null,'Student ability insufficient on grade 3 runs','Ensure students have a structured progression up to running higher grades and have demonstrated reliable roll and/or ability to stay in boat and be rescued.'),
  ('AMP 76 Water Kayaking Murchison G2-3',40,'Minimise',null,'Operating remote to Hillary Outdoors– no one to raise alarm.','Check in with Dm with daily Intentions in morning and checking off river end of day.'),
  ('AMP 77 Water Upper Mangatepopo Steep Creek Trip',10,'PPE',null,'Deep cold water','All persons to wear whitewater helmet, Buoyancy Aid and Wetsuit while participating in this activity, including the 7m jump'),
  ('AMP 77 Water Upper Mangatepopo Steep Creek Trip',20,'Admn',null,'Hidden submerged hazards including logs and strainers and undercuts','Jumping pools checked with mask after any flooding 
Dangerous undercuts identified to students
Visually check all possible runouts on any river crossings or swims'),
  ('AMP 77 Water Upper Mangatepopo Steep Creek Trip',30,'Admin',null,'Strong Hydraulics','Brief clients on the necessity to stay away from dangerous water features. 
Instructor to ensure that clients walk around these hazards and jump into the pools as far clear of them as they can.
Make sure an instructor guards drops number 2-4 (See map below)'),
  ('AMP 77 Water Upper Mangatepopo Steep Creek Trip',40,'Admin',null,'Flash flooding','If there is any rise in water level the instructor will let DM know and evacuate immediately or head for nearest muster point and await assistance from DM.
No weather warning or watch for rain in place for the trip time period'),
  ('AMP 77 Water Upper Mangatepopo Steep Creek Trip',50,'Admin',null,'Loss of radio comms','Entry and exit times recorded by DM
Exit times to be adhered to if there is a loss of comms
Limited to No Comms at river level, ascend the river left bank to reach Radio communication'),
  ('AMP 77 Water Upper Mangatepopo Steep Creek Trip',60,'Admin',null,'Isolated by flood water','There are regular exit points throughout the trip. 
If caught on the wrong side of the stream stay put until the flow drops. 
Communicate with Base to ensure they are aware of the situation and your location.'),
  ('AMP 77 Water Upper Mangatepopo Steep Creek Trip',70,'Admin',null,'Undercuts','Teach river crossing techniques
Only jump in designated sites keeping as far as possible from undercuts
Get students to physically help each other and stand a little downstream ready to help
Throw bag to be carried on Instructor'),
  ('AMP 77 Water Upper Mangatepopo Steep Creek Trip',80,'Admin',null,'Slippery rocks','Brief to walk between the rocks instead of on top, dark rocks slippery, light rocks generally gripey.
Exit Stream before Large submerge flat rocks at the top of drops where possible'),
  ('AMP 77 Water Upper Mangatepopo Steep Creek Trip',90,'Admin',null,'Landing badly from 7m Jump','Demonstrate a good method for jumping. Straight legs, feet together, straight back
Disclose risk of landing badly
Challenge by choice operating at all times
Instructor to be able, and prepared to jump to assist client in water.
Instructor to have planned for assistance at the bottom.'),
  ('AMP 77 Water Upper Mangatepopo Steep Creek Trip',100,'Admin',null,'Access tracks / Traverses','Instructor to disclose risk of exposure to clients. Briefing to include using hand lines appropriately. Spot clients at locations if necessary.
Use flagged route to avoid 7m jump up to access track. Don’t use scramble route down around due to active slip.'),
  ('AMP 79 Water River rescue Grade 2 Tongariro',10,'Minimise',null,'Foot Entrapment','Brief, demonstrate and practice swimming both aggressive and passive techniques including “white water float position”. 
Teach methods for regaining feet in shallow moving water. 
If floating downstream, then don’t stand up in moving water more than knee depth.'),
  ('AMP 79 Water River rescue Grade 2 Tongariro',20,'Minimise',null,'Swimming ability','Have progression to assess water confidence of clients'),
  ('AMP 79 Water River rescue Grade 2 Tongariro',30,'Minimise',null,'Communication','Ensure River Communication is covered (verbal,whistle, hand signals- refer Tier 2). If using rope systems, ensure verbal/hand and whistle signals are covered for this.'),
  ('AMP 79 Water River rescue Grade 2 Tongariro',40,'Minimise',null,'Real incident','Brief signal for communicating real incident “Real Time”call or 3 x whistle blasts'),
  ('AMP 79 Water River rescue Grade 2 Tongariro',50,'Minimise',null,'Rope entanglement','Only attach to ropes via releasable system. Knife to be available for cutaway rescue. If teaching static belay for throwbagging ensure load rope is held on the downstream side. Dynamic belay preferred where possible'),
  ('AMP 79 Water River rescue Grade 2 Tongariro',60,'Minimise',null,'Rocks in water at entry sites','Jump spots to be inspected before use. Clients to be briefed on water entry techniques'),
  ('AMP 79 Water River rescue Grade 2 Tongariro',70,'Minimise',null,'Quick release harness not releasing','Ensure quick release belt has a short tail (ideally 3cm) and threaded through load spreader and plastic release buckle correctly. (See River Rescue Instructional Points doc for guidance with client PFD’s)'),
  ('AMP 79 Water River rescue Grade 2 Tongariro',80,'Minimise',null,'Incorrect attachment to PFD','All attachments to be to attachment ring or cows tail ring on PFD'),
  ('AMP 79 Water River rescue Grade 2 Tongariro',90,'Minimise',null,'Flooding','Check river flow before activity and visual inspection by instructor. Tongariro R 60 cumecs or below'),
  ('AMP 79 Water River rescue Grade 2 Tongariro',100,'Minimise',null,'Other river users','Have an upstream spotter whenever swimmers or ropes are across river.'),
  ('AMP 79 Water River rescue Grade 2 Tongariro',110,'Minimise',null,'Instructor unaware of clients in river','Consider buddy system for clients in water. Instructor to be in a position to effect rescue'),
  ('AMP 79 Water River rescue Grade 2 Tongariro',120,'Minimise',null,'Clients/Instructor unprepared for immersion in water','PPE checks done before any activity that may involve immersion in water.'),
  ('AMP 79 Water River rescue Grade 2 Tongariro',130,'Minimise',null,'Swimming shallow rapid','Brief ww swim position with emphasis on technique for shallow water and identifying shallow rocks.'),
  ('AMP 79 Water River rescue Grade 2 Tongariro',140,'Minimise',null,'Damaged equipment','Only use designated boats for boat wrap scenarios'),
  ('AMP 79 Water River rescue Grade 2 Tongariro',150,'Minimise',null,'Waders','Brief clients on swimming with waders. Use of wader belt or trapping air in waders for flotation. How to exit river with full waders.'),
  ('AMP 82 Other Swimming Pool (Tongariro)',10,'Minimise',null,'Drowning in Pool','Hillary Outdoors Staff member to act in role of Lifeguard and maintain alertness at all times
Ratios to be followed
All doors and gates must be closed to prevent unauthorised or accidental entry to the pool.'),
  ('AMP 82 Other Swimming Pool (Tongariro)',20,'Minimise',null,'Chemicals','Only authorised persons to have access to chemicals
Check med-forms for info regarding allergies or skin conditions'),
  ('AMP 82 Other Swimming Pool (Tongariro)',30,'Minimise',null,'Waterborne illness/disease','Pool chemical levels need to be checked daily. Sign in/out of pool so user quantity is known'),
  ('AMP 82 Other Swimming Pool (Tongariro)',40,'Minimise',null,'Cold water','Appropriate clothing and monitoring of participants.'),
  ('AMP 83 Other Competitive Events',10,'Minimise',null,'Group operating in an outdoor environment containing hazards

Steep Cliffs, rocky ground, slippery terrain, rivers and streams to cross.

Groups in competition and will be operating through challenging conditions when tired
Teams pushing themselves too hard','Activity or accompanying instructor is briefed and is in a position to intervene at all times to ensure the safety of the team. Ensure the team has access to an emergency contact system to Hillary Outdoors at all times during the event or know to move to where communication will be effective
Instructor to adopt a level of supervision appropriate to the terrain and level of risk.
Instructors to be briefed to place safety above the competition
Disclose risk to students and instructors of “competitive mentality”
Advise competitors to closely monitor their team members and take rest stops when necessary. Accompanying instructor to also monitor to ensure that this is happening.'),
  ('AMP 83 Other Competitive Events',20,'Minimise',null,'Changing weather and environmental conditions – cold wet weather','Provide a compulsory gear/clothing list for competitors that includes sufficient safety items to cover all weather conditions. Team briefings to reiterate this message. Instructors and team managers to ensure this is being carried.
Updated weather forecast obtained. Weather state set and information relayed to instructors at morning briefings.'),
  ('AMP 83 Other Competitive Events',30,'Minimise',null,'Instructors pressured into making less conservative decisions','Instructors / Marshalls to be briefed on the importance of safety
Have strict guidelines, safety parameters and contingency plans built into event planning'),
  ('AMP 83 Other Competitive Events',40,'Minimise',null,'Instructors often working with groups that they have not had time to assess the skills of.','Maintain strict entry criteria or compulsory training schedule so all clients meet a minimum standard
Consider sequencing the competition so that there is time to observe or evaluate participants. If unsure, instructor is to assume clients have no / low skill level'),
  ('AMP 83 Other Competitive Events',50,'Minimise',null,'Inadequate supervision of individuals as group spreads out.
Team members getting separated.','Event briefing to reinforce sticking together, and the hazards of separation
Instructors / marshals have clear authority to stop a team'),
  ('AMP 83 Other Competitive Events',60,'Minimise',null,'Plans are made well in advance. Pressure to stick with these plans.','Event organisers to develop comprehensive contingency plans
Instructors, marshals and organisers to keep safety as the priority focus'),
  ('AMP 83 Other Competitive Events',70,'Minimise',null,'Exhaustion.','Disclose risk of exhaustion and advise competitors to take rests and carry sufficient nutrition to cover at least the duration of each stage'),
  ('AMP 83 Other Competitive Events',80,'Minimise',null,'Using gear incorrectly, losing gear, leaving gear behind','Brief on correct techniques, safety and use of gear
Expect clients to be in a hurry. Plan for this.
Consider building care of gear into the points system'),
  ('AMP 83 Other Competitive Events',90,'Minimise',null,'Lack of supervision of team due to instructor being injured or slow.','Team to be briefed to stop, slow down or provide assistance as required. Communicate with
Hillary Outdoors to establish the best course of action to take.'),
  ('AMP 83 Other Competitive Events',100,'Minimise',null,'Instructors or race officials distracted by external influences e.g. media, spectators, accompanying parents or teachers.','Expect interference from outside parties
Develop clear plans, contingency plans and stick to them where appropriate
Where necessary, make decisions away from external pressures'),
  ('AMP 87 Supervising Instruction Events',10,'Minimise',null,'Group Instruction','Hillary Outdoors Instructor to remain as Lead Safety during activity and step in to ensure safety is paramount.'),
  ('AMP Bush Tertiary',10,'Minimise',null,'Students getting seperated and lost','Brief students what to do if seperated from group (stay put!)'),
  ('AMP Bush Tertiary',20,'Minimise',null,'Hunters','Keep making lots of noise especially in hunting season. Obtain info from and inform them of your intentions if you meet.'),
  ('AMP Bush Tertiary',30,'Minimise',null,'River crossings and stream travel','Be aware of flow speed and depth, temperature, water clarity, bed surface and run out. Educate students on river crossing judgment. Staff to consider recce of the the river crossing prior to goingin with students.'),
  ('AMP Bush Tertiary',40,'Minimise',null,'Cliffs and bluffs','Be near or at the front of the group if you know there is steep ground ahead.
Brief students on what to do if steep ground encountered.'),
  ('AMP Bush Tertiary',50,'Minimise',null,'Poisons (1080, Cyanide etc.)','Brief participants on the hazards of poisons. Be aware of local advisory/poison summary from DOC'),
  ('AMP Bush Tertiary',60,'Minimise',null,'Insect stings','Check medical forms prior to trip. Avoid area if needed. Brief students about what to do if a wasp nest is encountered. Obtain info from other staff especially in warmer months about location of any known spots. Provide medical help as needed.'),
  ('AMP Bush Tertiary',70,'Minimise',null,'Overhead hazards','Area for camping to be checked for overhead hazards, epiphytes and dead branches before establishing.'),
  ('AMP Bush Tertiary',80,'Minimise',null,'Flooded campsite','Be aware of forecast and select campsite based on forecast effect on streamways and potential to flood site.'),
  ('AMP Bush Tertiary',90,'Minimise',null,'Cookers-burns','Ensure new students know how to use their cookers safely.'),
  ('AMP Bush Tertiary',100,'Minimise',null,'Poor or inadequate comms','Enusre there are two forms of reliable comms in the group (e.g. 2 PLBs)'),
  ('AMP Bush Tertiary',110,'Minimise',null,'Forestry','Instructor to gather local information before heading into known forestry areas. Listen carefully for forestry machinery – especially chainsaws.'),
  ('AMP Rock Wharepapa South',10,'Admin',null,'Fall from height','Students not to go to clifftop without supervision
Instructors to ensure students are supervised during transitions or deemed competent at task.
Consider using stick clip for high first bolts (we have an expendable stick clip in tertiary gear shed), especially at Castle Rock.'),
  ('AMP Rock Wharepapa South',20,'Admin',null,'Insufficient anchors/rigging','Anchors are checked by instructor before use.'),
  ('AMP Rock Wharepapa South',30,'Admin',null,'Communication difficulties.','Consistent calls to be used between climber and belayer.
Names to be used to avoid confusion with other site users.'),
  ('AMP Rock Wharepapa South',40,'Admin',null,'Insufficient supervision','Students given clear boundaries.'),
  ('AMP Rock Wharepapa South',50,'Admin
PPE',null,'Falling objects from above.','Establish helmet areas, visual check of area above in case of trees.
Disclose risk to students.'),
  ('AMP Rock Wharepapa South',60,'Admin',null,'Wasp stings','Disclose to students.
Be vigilant for wasp nests.'),
  ('AMP Tertiary Snow Sports',10,'Minimise',null,'Volcanic eruption','Stop, watch for burning ash and flying rocks. Run away from the path of fast-moving burning clouds. Otherwise find shelter behind something - banks, ridges or in hollows. Don’t turn away from flying rocks unless you are sure they won’t hit you. Evacuate out of the hazard zone and away from the eruption site. Contact Hillary base for further advise. DM will seek advice from relevant authorities'),
  ('AMP Tertiary Snow Sports',20,'Minimise',null,'Lahar','If a Lahar occurs or the early warning detection system is heard go to higher ground contact base. DM approval is required for movement. DM will seek advice from relevant authorities.'),
  ('AMP Tertiary Snow Sports',30,'Minimise',null,'Cold Leading to Hypothermia or frost bite','Ensure appropriate clothing/equipment is worn/ for weather conditions.'),
  ('AMP Tertiary Snow Sports',40,'Minimise',null,'Sunburn, Dehydration, Snow blindness','Promote use of sunscreen. Encourage fluid intake. Ensure sunglasses or goggles are worn. Instructor to carry spare glasses. Instructor may be working down low below inversion cloud while clients are working above inversion cloud exposed to bright sun. Don’t forget about them!'),
  ('AMP Tertiary Snow Sports',50,'Minimise',null,'Sliding on ice and/or too steep, hitting rocks','Instructor to brief students on terrain suitable for ability levels. 
Bried students on icy mornings to take it easy and stay on terrain thats well within skill level'),
  ('AMP Tertiary Snow Sports',60,'Minimise',null,'Head Injury','All clients and staff to wear Industry standard helmets.'),
  ('AMP Tertiary Snow Sports',70,'Minimise',null,'Lost student','Students to indicate what lift they are on, and if they are moving between lifts, on WhatsApp group chat. 
Students are encouraged to ski with a classmate.')
) as v(name, so, control, part, hazard, strategy)
join activities a on a.name = v.name join amps m on m.act_id = a.id
where not exists (select 1 from amp_hazards h where h.amp_id = m.id);

commit;

-- what landed:
select count(*) as hazard_rows from amp_hazards;
-- expect 444
