require "enumerator"
require "nokogiri"
require "pathname"
require "csv"

require_relative "common"

def column_for_turn(direction, kind)
  if direction == "left"
    if kind == "turn"
      0
    else
      1
    end
  else
    if kind == "turn"
      4
    else
      3
    end
  end    
end

def process_maneuvers(moves, maneuver_string, color)
  unless maneuver_string == nil
    maneuver_string = maneuver_string.downcase.gsub("forward", "straight")
    maneuver_string = maneuver_string.downcase.gsub("come about", "about")
    maneuvers = maneuver_string.split(/\s*,\s*/)
    maneuvers.each do |one_move|
      speed, kind = one_move.split(/\s+/)
      if kind == "straight" || kind == "flank" || kind == "stop" || kind == "about"
        moves.push({:color => color, :speed => speed.to_i, :kind => kind, :column => 2})
      elsif kind == "rotate"
        moves.push({:color => color, :speed => 0, :kind => speed + "-" + kind, :column => 2})
      elsif kind == "reverse"
        moves.push({:color => color, :speed => speed.to_i * -1, :kind => "straight", :column => 2})
      else
        ["left", "right"].each do |direction|
          moves.push({:color => color, :speed => speed.to_i, :kind => "#{direction}-#{kind}", :column => column_for_turn(direction, kind)})          
        end
      end
    end
  end
end

# Timestamp	Uniqueness	Ship Name	Faction	Ship Class	Attack	Agility	Hull	Shield	Ability	Action Bar	Cost	Borg Upgrade Slots	Crew Upgrade Slots	Tech Upgrade Slots	Weapon Upgrade Slots	Expansion Pack	Maneuver Grid	Firing Arcs	Build/Price Adjustment	Green Maneuvers	White Maneuvers	Red Maneuvers										
ship = <<-SHIPTEXT
12/7/2015 13:39:40	72020 - Robinson	Non-unique	Dominion Starship	Dominion	Jem'Hadar Attack Ship	Jem'Hadar Attack Ship				3	2	3	2		Battle Stations, Evasive, Scan, Target Lock	20	0	1	1	1	90-degree forward		0
12/7/2015 13:41:17	72020 - Robinson	Unique	Robinson	Federation	Jem'Hadar Attack Ship	Jem'Hadar Attack Ship				3	2	3	3	When defending, if you are hit and you don't already have a "Warp Core Breach" critical damage card assigned to your ship, you may choose to ignore up to 3 damage being inflicted to your ship and suffer a "Warp Core Breach" critical damage instead.	Battle Stations, Evasive, Scan, Target Lock	22	0	4	0	0	90-degree forward		0
12/17/2015 13:15:43	72021 - Denorios	Non-unique	Bajoran Starship	Bajoran	Bajoran Lightship		1 Bank, 1 Forward, 2 Forward	1 Turn, 2 Turn, 2 Bank, 3 Bank, 3 Forward	1 Come About, 2 Come About	1	2	3	0		Evasive, Scan	12	0	0	1	0	90-degree rear		0
12/17/2015 13:17:14	72021 - Denorios	Unique	Denorios	Bajoran	Bajoran Lightship	Bajoran Lightship				1	2	3	0	When defending, during the Compare Results step, you may place an Auxiliary Power Token beside your ship to cancel 1 [HIT] result.	Evasive, Scan	12	0	0	2	0	90-degree forward		0
12/19/2015 22:51:14	72360 - Weapon Zero	Non-unique	Xindi Starship	Xindi	Xindi Weapon		1 Bank, 1 Forward, 2 Forward	2 Bank, 2 Turn, 3 Bank, 3 Forward	1 Reverse, 3 Turn, 4 Forward	6	0	8	0		Evasive, Scan, Target Lock	28	0	1	1	2	90-degree forward		0
12/19/2015 22:53:08	72360 - Weapon Zero	Unique	Weapon Zero	Xindi	Xindi Weapon	Xindi Weapon				6	0	8	0	When defending, during the Roll Defense Dice step, you may roll 1 defense die for each [HIT] or [CRIT] result rolled by the attacking ship.  If you do so, place an auxiliary Power Token beside your ship.	Battle Stations, Evasive, Scan, Target Lock	30	0	1	1	3	90-degree forward		0
12/25/2015 10:26:23	72315p - IRW T'Met	Non-unique	Romulan Starship	Romulan	D'deridex Class	D'deridex Class				3	2	6	3		Cloak, Evasive, Sensor Echo, Target Lock	28	0	1	1	2	90-degree forward		0
12/25/2015 10:33:40	72315p - IRW T'Met	Unique	I.R.W. T'Met	Romulan	D'deridex Class	D'deridex Class				3	2	6	4	ACTION: If your ship is not Cloaked, when attacking with your Primary Weapon at Range 1 this round, gain +1 attack die and roll -1 defense die.	Cloak, Evasive, Sensor Echo, Target Lock	30	0	1	2	2	90-degree forward		0
1/3/2016 15:38:39	72023 - USS Valiant	Non-unique	Federation Starship	Federation	Defiant Class	Defiant Class				3	2	3	3		Battle Stations, Evasive, Scan, Target Lock	22	0	1	1	2	90-degree forward, 90-degree rear		0
1/3/2016 15:40:00	72023 - USS Valiant	Unique	U.S.S. Valiant	Federation	Defiant Class	Defiant Class				3	2	3	4	When attacking with Photon Torpedoes, during the Roll Attack Dice step, you may discard the Photon Torpedoes Upgrade to gain 1 additional attack die.	Battle Stations, Evasive, Scan, Target Lock	24	0	3	1	1	90-degree forward, 90-degree rear		0
SHIPTEXT


convert_terms(ship)

new_ships = File.open("new_ships.xml", "w")

shipLines = ship.split "\n"
shipLines.each do |l|
# Timestamp		Ship Name	Faction	Ship Class	Attack	Agility	Hull	Shield	Ability	Action Bar	Cost	Borg Upgrade Slots	Crew Upgrade Slots	Tech Upgrade Slots	Weapon Upgrade Slots	Expansion Pack	Maneuver Grid										*
  parts = l.split "\t"
  title = parts[3]
  shipClass = parts[5]
  unique = parts[2] == "Unique" ? "Y" : "N"
  mirrorUniverseUnique = parts[2] == "Mirror Universe Unique" ? "Y" : "N"
  faction_string = parts[4]
  faction_parts = faction_string.split(/\s*,\s*/)
  faction = faction_parts[0]
  additional_faction = faction_parts[1]
  unless faction
    throw "Faction missing"
  end
  attack = parts[10]
  agility = parts[11]
  hull = parts[12]
  shield = parts[13]
  ability = parts[14]
  action_bar = parts[15].split(/,\s*/)
  evasiveManeuvers = action_bar.include?("Evasive") ? 1 : 0
  battleStations = action_bar.include?("Battle Stations") ? 1 : 0
  cloak = action_bar.include?("Cloak") ? 1 : 0
  sensorEcho = action_bar.include?("Sensor Echo") ? 1 : 0
  targetLock = action_bar.include?("Target Lock") ? 1 : 0
  scan = action_bar.include?("Scan") ? 1 : 0
  regenerate = action_bar.include?("Regenerate") ? 1 : 0
  cost = parts[16]
  borg = parts[17]
  crew = parts[18]
  tech = parts[19]
  squad = parts[23]
  weapon = parts[20]
  expansion = parts[1]
  firing_arcs = parts[21]
  arc_360 = firing_arcs.include?("360-degree") ? "Y" : "N"
  setId = set_id_from_expansion(expansion)
  externalId = make_external_id(setId, title)
if cost.length == 0
	cost = (agility.to_i + attack.to_i + hull.to_i + shield.to_i) * 2
end
  shipXml = <<-SHIPXML
  <Ship>
    <Title>#{title}</Title>
    <Unique>#{unique}</Unique>
    <MirrorUniverseUnique>#{mirrorUniverseUnique}</MirrorUniverseUnique>
    <ShipClass>#{shipClass}</ShipClass>
    <Faction>#{faction}</Faction>
    <AdditionalFaction>#{additional_faction}</AdditionalFaction>
    <Attack>#{attack}</Attack>
    <Agility>#{agility}</Agility>
    <Hull>#{hull}</Hull>
    <Shield>#{shield}</Shield>
    <Ability>#{ability}</Ability>
    <Cost>#{cost}</Cost>
    <EvasiveManeuvers>#{evasiveManeuvers}</EvasiveManeuvers>
    <TargetLock>#{targetLock}</TargetLock>
    <Scan>#{scan}</Scan>
    <Battlestations>#{battleStations}</Battlestations>
    <Cloak>#{cloak}</Cloak>
    <SensorEcho>#{sensorEcho}</SensorEcho>
    <Regenerate>#{regenerate}</Regenerate>
    <Borg>#{borg}</Borg>
    <Tech>#{tech}</Tech>
    <Weapon>#{weapon}</Weapon>
    <Crew>#{crew}</Crew>
    <SquadronUpgrade>#{squad}</SquadronUpgrade>
    <Has360Arc>#{arc_360}</Has360Arc>
    <Id>#{externalId}</Id>
    <Set>#{setId}</Set>
  </Ship>
  SHIPXML
  new_ships.puts shipXml
end

new_ship_class_details = File.open("new_ship_class_details.xml", "w")

shipLines.each do |l|
  parts = l.split "\t"
  ship_class = parts[5]
  ship_class_id = sanitize_title(ship_class).downcase
  maneuver_grid = parts[6]
  firing_arcs = parts[21]
  front_arc = ""
  rear_arc = ""
  firing_arc_parts = firing_arcs.split(",")
  firing_arc_parts.each do |arc_part|
    arc_part = arc_part.strip
    case arc_part.chomp
    when "90-degree forward"
      front_arc = "90"
    when "180-degree forward"
      front_arc = "180"
    when "90-degree rear"
      rear_arc = "90"
    end
  end
  moves = []
  green_maneuvers = parts[7]
  process_maneuvers(moves, green_maneuvers, "green")
  white_maneuvers = parts[8]
  process_maneuvers(moves, white_maneuvers, "white")
  red_maneuvers = parts[9]
  process_maneuvers(moves, red_maneuvers, "red")
  moves.sort! do |a,b| 
    v = b[:speed] <=> a[:speed]
    if v == 0
     v = a[:column] <=> b[:column] 
    end
    v
  end
  
  maneuver_parts = moves.collect do |one_move|
    %Q(      <Maneuver speed="#{one_move[:speed]}" kind="#{one_move[:kind]}" color="#{one_move[:color]}" />)
  end
  shipClassXml = <<-SHIPXML
  <ShipClassDetail>
    <Name>#{ship_class}</Name>
    <Id>#{ship_class_id}</Id>
    <Maneuvers>
#{maneuver_parts.join("\n")}
    </Maneuvers>
    <FrontArc>#{front_arc}</FrontArc>
    <RearArc>#{rear_arc}</RearArc>
  </ShipClassDetail>
  SHIPXML
  new_ship_class_details.puts shipClassXml
end
