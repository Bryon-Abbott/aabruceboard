//import 'package:bruceboard/flutter_any_logo/AnyLogo.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_any_logo/flutter_logo.dart';
// import 'package:flutter_any_logo/gen/assets.gen.dart';
//import 'package:bruceboard/flutter_logo.dart';
import 'package:bruceboard/flutter_any_logo/class.dart';
import 'package:bruceboard/flutter_any_logo/assets.gen.dart';

enum SeriesType { itemNFL, itemCFL, itemNBA, itemOther }

class SeriesItem {
  String seriesText = "";
  Icon seriesIcon = const Icon(Icons.device_unknown_outlined);
  SeriesItem(this.seriesText, this.seriesIcon);
}

Map<SeriesType, SeriesItem> seriesData = {
  SeriesType.itemNFL :  SeriesItem("NFL", const Icon(Icons.sports_football_outlined)),
  SeriesType.itemCFL :  SeriesItem("CFL", const Icon(Icons.sports_football_outlined)),
  SeriesType.itemNBA :  SeriesItem("NBA",  const Icon(Icons.sports_basketball_outlined)),
  SeriesType.itemOther :  SeriesItem("Other", const Icon(Icons.cabin_outlined)),
};

class TeamData {
  String teamKey = "None";
  String teamCity = "None";
  String teamName = "None";
  AssetGenImage teamLogo = const AssetGenImage('assets/question-mark.png');

  TeamData( this.teamKey, this.teamCity, this.teamName, this.teamLogo );
}

Map<String, TeamData> nflTeamData = {
  AnyLogo.nfl.nflArizonaCardinals.keyName:     TeamData(AnyLogo.nfl.nflArizonaCardinals.keyName,    "Arizona",      "Carinals",   AnyLogo.nfl.nflArizonaCardinals),
  AnyLogo.nfl.nflAtlantaFalcons.keyName:       TeamData(AnyLogo.nfl.nflAtlantaFalcons.keyName,      "Atlanta",      "Falcons",    AnyLogo.nfl.nflAtlantaFalcons),
  AnyLogo.nfl.nflBaltimoreRavens.keyName:      TeamData(AnyLogo.nfl.nflBaltimoreRavens.keyName,     "Baltimore",    "Ravens",     AnyLogo.nfl.nflBaltimoreRavens),
  AnyLogo.nfl.nflBuffaloBills.keyName:         TeamData(AnyLogo.nfl.nflBuffaloBills.keyName,        "Buffalo",      "Bills",      AnyLogo.nfl.nflBuffaloBills),
  AnyLogo.nfl.nflCarolinaPanthers.keyName:     TeamData(AnyLogo.nfl.nflCarolinaPanthers.keyName,    "Carolina",     "Panthers",   AnyLogo.nfl.nflCarolinaPanthers),
  AnyLogo.nfl.nflChicagoBears.keyName:         TeamData(AnyLogo.nfl.nflChicagoBears.keyName,        "Chicago",      "Bears",      AnyLogo.nfl.nflChicagoBears),
  AnyLogo.nfl.nflCincinnatiBengals.keyName:    TeamData(AnyLogo.nfl.nflCincinnatiBengals.keyName,   "Cincinnati",   "Bengals",    AnyLogo.nfl.nflCincinnatiBengals),
  AnyLogo.nfl.nflClevelandBrowns.keyName:      TeamData(AnyLogo.nfl.nflClevelandBrowns.keyName,     "Cleveland",    "Browns",     AnyLogo.nfl.nflClevelandBrowns),
  AnyLogo.nfl.nflDallasCowboys.keyName:        TeamData(AnyLogo.nfl.nflDallasCowboys.keyName,       "Dallas",       "Cowboys",    AnyLogo.nfl.nflDallasCowboys),
  AnyLogo.nfl.nflDenverBroncos.keyName:        TeamData(AnyLogo.nfl.nflDenverBroncos.keyName,       "Denver",       "Broncos",    AnyLogo.nfl.nflDenverBroncos),
  AnyLogo.nfl.nflDetroitLions.keyName:         TeamData(AnyLogo.nfl.nflDetroitLions.keyName,        "Detroit",      "Lions",      AnyLogo.nfl.nflDetroitLions),
  AnyLogo.nfl.nflGreenBayPackers.keyName:      TeamData(AnyLogo.nfl.nflGreenBayPackers.keyName,     "Green Bay",    "Packers",    AnyLogo.nfl.nflGreenBayPackers),
  AnyLogo.nfl.nflHoustonTexans.keyName:        TeamData(AnyLogo.nfl.nflHoustonTexans.keyName,       "Houston",      "Texans",     AnyLogo.nfl.nflHoustonTexans),
  AnyLogo.nfl.nflIndianapolisColts.keyName:    TeamData(AnyLogo.nfl.nflIndianapolisColts.keyName,   "Indianapolis", "Colts",      AnyLogo.nfl.nflIndianapolisColts),
  AnyLogo.nfl.nflJacksonvilleJaguars.keyName:  TeamData(AnyLogo.nfl.nflJacksonvilleJaguars.keyName, "Jacksonville", "Jaguars",    AnyLogo.nfl.nflJacksonvilleJaguars),
  AnyLogo.nfl.nflKansasCityChiefs.keyName:     TeamData(AnyLogo.nfl.nflKansasCityChiefs.keyName,    "Kansas City",  "Chiefs",     AnyLogo.nfl.nflKansasCityChiefs),
  AnyLogo.nfl.nflLosAngelesChargers.keyName:   TeamData(AnyLogo.nfl.nflLosAngelesChargers.keyName,  "Los Angeles",  "Chargers",   AnyLogo.nfl.nflLosAngelesChargers),
  AnyLogo.nfl.nflLosAngelesRams.keyName:       TeamData(AnyLogo.nfl.nflLosAngelesRams.keyName,      "Los Angeles",  "Rams",       AnyLogo.nfl.nflLosAngelesRams),
  AnyLogo.nfl.nflMiamiDolphins.keyName:        TeamData(AnyLogo.nfl.nflMiamiDolphins.keyName,       "Miami",        "Dolphins",   AnyLogo.nfl.nflMiamiDolphins),
  AnyLogo.nfl.nflMinnesotaVikings.keyName:     TeamData(AnyLogo.nfl.nflMinnesotaVikings.keyName,    "Minnisota",    "Vikings",    AnyLogo.nfl.nflMinnesotaVikings),
  AnyLogo.nfl.nflNewEnglandPatriots.keyName:   TeamData(AnyLogo.nfl.nflNewEnglandPatriots.keyName,  "New England",  "Patriots",   AnyLogo.nfl.nflNewEnglandPatriots),
  AnyLogo.nfl.nflNewOrleansSaints.keyName:     TeamData(AnyLogo.nfl.nflNewOrleansSaints.keyName,    "New Orleans",  "Saints",     AnyLogo.nfl.nflNewOrleansSaints),
  AnyLogo.nfl.nflNewYorkGiants.keyName:        TeamData(AnyLogo.nfl.nflNewYorkGiants.keyName,       "New York",     "Giants",     AnyLogo.nfl.nflNewYorkGiants),
  AnyLogo.nfl.nflNewYorkJets.keyName:          TeamData(AnyLogo.nfl.nflNewYorkJets.keyName,         "New York",     "Jets",       AnyLogo.nfl.nflNewYorkJets),
  AnyLogo.nfl.nflOaklandRaiders.keyName:       TeamData(AnyLogo.nfl.nflOaklandRaiders.keyName,      "Oakland",      "Raiders",    AnyLogo.nfl.nflOaklandRaiders),
  AnyLogo.nfl.nflPhiladelphiaEagles.keyName:   TeamData(AnyLogo.nfl.nflPhiladelphiaEagles.keyName,  "Philadelphia", "Eagles",     AnyLogo.nfl.nflPhiladelphiaEagles),
  AnyLogo.nfl.nflPittsburghSteelers.keyName:   TeamData(AnyLogo.nfl.nflPittsburghSteelers.keyName,  "Pittsburgh",   "Steelers",   AnyLogo.nfl.nflPittsburghSteelers),
  AnyLogo.nfl.nflSanFrancisco49ers.keyName:    TeamData(AnyLogo.nfl.nflSanFrancisco49ers.keyName,   "San Fransisco","49ers",      AnyLogo.nfl.nflSanFrancisco49ers),
  AnyLogo.nfl.nflSeattleSeahawks.keyName:      TeamData(AnyLogo.nfl.nflSeattleSeahawks.keyName,     "Seattle",      "Seahawks",   AnyLogo.nfl.nflSeattleSeahawks),
  AnyLogo.nfl.nflTampaBayBuccaneers.keyName:   TeamData(AnyLogo.nfl.nflTampaBayBuccaneers.keyName,  "Tampa Bay",    "Buccaneers", AnyLogo.nfl.nflTampaBayBuccaneers),
  AnyLogo.nfl.nflTennesseeTitans.keyName:      TeamData(AnyLogo.nfl.nflTennesseeTitans.keyName,     "Tennessee",    "Titans",     AnyLogo.nfl.nflTennesseeTitans),
  AnyLogo.nfl.nflWashingtonCommanders.keyName: TeamData(AnyLogo.nfl.nflWashingtonCommanders.keyName,"Washington",   "Commanders", AnyLogo.nfl.nflWashingtonCommanders),
};


Map<String, TeamData> nbaTeamData = {

  AnyLogo.nba.atlanta.keyName:              TeamData(AnyLogo.nba.atlanta.keyName,                "Atlanta",       "Hawks",        AnyLogo.nba.atlanta ),
  AnyLogo.nba.bostonCeltics.keyName:        TeamData(AnyLogo.nba.bostonCeltics.keyName,          "Boston",        "Celtics",      AnyLogo.nba.bostonCeltics ),
  AnyLogo.nba.brooklynNets.keyName:         TeamData(AnyLogo.nba.brooklynNets.keyName,           "Brooklyn",      "Nets",         AnyLogo.nba.brooklynNets ),
  AnyLogo.nba.charlotteHornets.keyName:     TeamData(AnyLogo.nba.charlotteHornets.keyName,       "Charlotte",     "Hornets",      AnyLogo.nba.charlotteHornets ),
  AnyLogo.nba.chicagoBulls.keyName:         TeamData(AnyLogo.nba.chicagoBulls.keyName,           "Chicago",       "Bulls",        AnyLogo.nba.chicagoBulls ),
  AnyLogo.nba.clevelandCavaliers.keyName:   TeamData(AnyLogo.nba.clevelandCavaliers.keyName,     "Cleveland",     "Cavaliers",    AnyLogo.nba.clevelandCavaliers ),
  AnyLogo.nba.dallasMavericks.keyName:      TeamData(AnyLogo.nba.dallasMavericks.keyName,        "Dallas",        "Mavericks",    AnyLogo.nba.dallasMavericks ),
  AnyLogo.nba.denverNuggets.keyName:        TeamData(AnyLogo.nba.denverNuggets.keyName,          "Denver",        "Nuggets",      AnyLogo.nba.denverNuggets ),
  AnyLogo.nba.detroitPistons.keyName:       TeamData(AnyLogo.nba.detroitPistons.keyName,         "Detroid",       "Pistons",      AnyLogo.nba.detroitPistons ),
  AnyLogo.nba.goldenstateWarriors.keyName:  TeamData(AnyLogo.nba.goldenstateWarriors.keyName,    "Golden State",  "Warriors",     AnyLogo.nba.goldenstateWarriors ),
  AnyLogo.nba.houstonRockets.keyName:       TeamData(AnyLogo.nba.houstonRockets.keyName,         "Houston",       "Rockets",      AnyLogo.nba.houstonRockets ),
  AnyLogo.nba.indianaPacers.keyName:        TeamData(AnyLogo.nba.indianaPacers.keyName,          "Indiana",       "Pacers",       AnyLogo.nba.indianaPacers ),
  AnyLogo.nba.losangelesClippers.keyName:   TeamData(AnyLogo.nba.losangelesClippers.keyName,     "Los Angeles",   "Clippers",     AnyLogo.nba.losangelesClippers ),
  AnyLogo.nba.losangelesLakers.keyName:     TeamData(AnyLogo.nba.losangelesLakers.keyName,       "Los Angeles",   "Lakers",       AnyLogo.nba.losangelesLakers ),
  AnyLogo.nba.memphisGrizzlies.keyName:     TeamData(AnyLogo.nba.memphisGrizzlies.keyName,       "Memphis",       "Grizzlies",    AnyLogo.nba.memphisGrizzlies ),
  AnyLogo.nba.miamiHeat.keyName:            TeamData(AnyLogo.nba.miamiHeat.keyName,              "Miami",         "Heat",         AnyLogo.nba.miamiHeat ),
  AnyLogo.nba.milwaukeeBucks.keyName:       TeamData(AnyLogo.nba.milwaukeeBucks.keyName,         "Milwaukee",     "Bucks",        AnyLogo.nba.milwaukeeBucks ),
  AnyLogo.nba.minnesotaTimberwolves.keyName:TeamData(AnyLogo.nba.minnesotaTimberwolves.keyName,  "Minnesota",     "Timberwolves", AnyLogo.nba.minnesotaTimberwolves ),
  AnyLogo.nba.neworleansPelicans.keyName:   TeamData(AnyLogo.nba.neworleansPelicans.keyName,     "New Orleans",   "Pelicans",     AnyLogo.nba.neworleansPelicans ),
  AnyLogo.nba.newyorkKnicks.keyName:        TeamData(AnyLogo.nba.newyorkKnicks.keyName,          "New York",      "Knicks",       AnyLogo.nba.newyorkKnicks ),
  AnyLogo.nba.oklahomacityThunder.keyName:  TeamData(AnyLogo.nba.oklahomacityThunder.keyName,    "Oklahoma",      "Thunder",      AnyLogo.nba.oklahomacityThunder ),
  AnyLogo.nba.orlandoMagic.keyName:         TeamData(AnyLogo.nba.orlandoMagic.keyName,           "Orlando",       "Magic",        AnyLogo.nba.orlandoMagic ),
  AnyLogo.nba.philadelphia76ers.keyName:    TeamData(AnyLogo.nba.philadelphia76ers.keyName,      "Philadelphia",  "67ers",        AnyLogo.nba.philadelphia76ers ),
  AnyLogo.nba.phoenixSuns.keyName:          TeamData(AnyLogo.nba.phoenixSuns.keyName,            "Phoenix",       "Suns",         AnyLogo.nba.phoenixSuns ),
  AnyLogo.nba.portlandtrailBlazers.keyName: TeamData(AnyLogo.nba.portlandtrailBlazers.keyName,   "Portland",      "Blazers",      AnyLogo.nba.portlandtrailBlazers ),
  AnyLogo.nba.sacramentoKings.keyName:      TeamData(AnyLogo.nba.sacramentoKings.keyName,        "Sacremento",    "Kings",        AnyLogo.nba.sacramentoKings ),
  AnyLogo.nba.sanantonioSpurs.keyName:      TeamData(AnyLogo.nba.sanantonioSpurs.keyName,        "San Antonio",   "Spurs",        AnyLogo.nba.sanantonioSpurs ),
  AnyLogo.nba.torontoRaptors.keyName:       TeamData(AnyLogo.nba.torontoRaptors.keyName,         "Toronto",       "Raptors",      AnyLogo.nba.torontoRaptors ),
  AnyLogo.nba.utahJazz.keyName:             TeamData(AnyLogo.nba.utahJazz.keyName,               "Utah",          "Jazz",         AnyLogo.nba.utahJazz ),
  AnyLogo.nba.washingtonWizards.keyName:    TeamData(AnyLogo.nba.washingtonWizards.keyName,      "Washington",    "Wizards",      AnyLogo.nba.washingtonWizards )


};

Map<String, TeamData> cflTeamData = {
  AnyLogo.cfl.cflBCLions.keyName:             TeamData(AnyLogo.cfl.cflBCLions.keyName,           "BC",       "Lions",        AnyLogo.cfl.cflBCLions),
  AnyLogo.cfl.cflCalgaryStampeders.keyName:   TeamData(AnyLogo.cfl.cflCalgaryStampeders.keyName, "Calgary",  "Stampeders",   AnyLogo.cfl.cflCalgaryStampeders),
  AnyLogo.cfl.cflEdmontonEsks.keyName:        TeamData(AnyLogo.cfl.cflEdmontonEsks.keyName,      "Edmonton", "Elks",         AnyLogo.cfl.cflEdmontonEsks),
  AnyLogo.cfl.cflhamiltontigercats.keyName:   TeamData(AnyLogo.cfl.cflhamiltontigercats.keyName, "Hamilton", "Tiger Cats",   AnyLogo.cfl.cflhamiltontigercats),
  AnyLogo.cfl.cflmontrealalouettes.keyName:   TeamData(AnyLogo.cfl.cflmontrealalouettes.keyName, "Montreal", "Alouettes",    AnyLogo.cfl.cflmontrealalouettes),
  AnyLogo.cfl.cflottawaredblacks.keyName:     TeamData(AnyLogo.cfl.cflottawaredblacks.keyName,   "Ottawa",   "Redblacks",    AnyLogo.cfl.cflottawaredblacks),
  AnyLogo.cfl.cflsaskatchewanroughriders.keyName: TeamData(AnyLogo.cfl.cflsaskatchewanroughriders.keyName, "Saskatchewan", "Roughriders", AnyLogo.cfl.cflsaskatchewanroughriders),
  AnyLogo.cfl.cfltorontoargonauts.keyName:    TeamData(AnyLogo.cfl.cfltorontoargonauts.keyName,   "Toronto", "Argonauts",    AnyLogo.cfl.cfltorontoargonauts),
  AnyLogo.cfl.cflwinnepegbluebombers.keyName: TeamData(AnyLogo.cfl.cflwinnepegbluebombers.keyName,"Winnepeg","Blue Bombers", AnyLogo.cfl.cflwinnepegbluebombers),
};