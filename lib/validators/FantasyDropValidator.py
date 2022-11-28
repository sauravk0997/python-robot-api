from lib.schemas import *
from lib.schemas.FantasyDropSchema import *
from marshmallow import ValidationError
from robot.api.deco import keyword, library
from robot.api.exceptions import Failure
import requests


@library(scope='GLOBAL', version='5.0.2')
class FantasyDropValidator(object):
    """JSON validation for ESPN Fantasy Games API"""

    def __init__(self, *p, **k):
        pass

    @keyword('Fantasy Drop Schema from ${response} should be valid', tags=['schema checks', 'functional', 'CoreV3'],
             types={'response': requests.Response})
    def base_resp_is_valid(self, response) -> bool:
        """
            Schema for the endpoint: apis/v3/games/FFL

            Expects to receive an embedded python requests object as 'response'
            and validates the json against the FantasyGames class.

          Examples:
          Fantasy Games Schema from ${response} should be valid
        """
        try:
            schema = DropSchema().load(response.json())

        except ValidationError as ve:
            raise Failure(f'Schema Data failed validation: {ve.messages}')
        return True

    @keyword('Get a player to drop ${response} ${myteamid}', tags=['drop player', 'functional', 'CoreV3'],
             types={'response': requests.Response})
    def fetch_droppable_players(self, response, teamid) -> bool:
        try:
            teams = response.json()['teams']
            scoring_period_id = response.json()['scoringPeriodId']
            if teamid == '0':
                print("league manager")
                for team in teams:
                    print(team['id'])
                    no_of_players = len(team['roster']['entries'])
                    for player in range(0, no_of_players):
                        if (team['roster']['entries'][player]["playerPoolEntry"]["player"]["droppable"]) == True:
                            team_id = team['roster']['entries'][player]["playerPoolEntry"]["onTeamId"]
                            player_id = team['roster']['entries'][player]["playerPoolEntry"]["id"]
                            break
                        else:
                            continue
                    break
                return scoring_period_id, team_id, player_id
            
            else:
                drop_flag = True
                scoring_period_id, teamid, drop_player_list = self.create_player_list(response,teamid,drop_flag)
                return scoring_period_id, teamid, drop_player_list[0]
        except ValidationError as ve:
            raise Failure(f'Parsing failed :{ve.messages}')


    def create_player_list(self,response,teamid,drop_flag):

        teams = response.json()['teams']
        scoring_period_id = response.json()['scoringPeriodId']
        teamid = int(teamid) - 1
        no_of_players = len(teams[teamid]['roster']['entries'])
        drop_player_list = []
        for player in range(0, no_of_players):
            if (teams[teamid]['roster']['entries'][player]["playerPoolEntry"]["player"]["droppable"]) == drop_flag:
                player_id = teams[teamid]['roster']['entries'][player]["playerPoolEntry"]["id"]
                team_id = teams[teamid]['roster']['entries'][player]["playerPoolEntry"]["onTeamId"]
                drop_player_list.append(player_id) 
            else:
                continue
        return scoring_period_id, team_id, drop_player_list


    @keyword('Find droppable players of a team ${response} ${myteamid}', tags=['drop player', 'functional', 'CoreV3'],
                types={'response': requests.Response})
    def get_droppable_players(self, response, teamid) -> bool:

        drop_flag = True
        scoring_period_id, teamid, drop_player_list = self.create_player_list(response,teamid,drop_flag)
        return scoring_period_id, teamid, drop_player_list


    @keyword('Find undroppable players of a team ${response} ${myteamid}', tags=['drop player', 'functional', 'CoreV3'],
                types={'response': requests.Response})
    def get_undroppable_players(self, response, teamid) -> bool:

        drop_flag = False
        scoring_period_id, teamid, drop_player_list = self.create_player_list(response,teamid,drop_flag)
        return scoring_period_id, teamid, drop_player_list
    

    @keyword('Find injured players of a team ${response} ${myteamid}', tags=['drop player', 'functional', 'CoreV3'],
                types={'response': requests.Response})
    def get_injured_players(self, response, teamid) -> bool:

        drop_flag = True
        injured_flag = True
        # print(self._teamid)
        teams = response.json()['teams']
        scoring_period_id = response.json()['scoringPeriodId']
        teamid = int(teamid) - 1
        no_of_players = len(teams[teamid]['roster']['entries'])
        # injured_bool = teams[teamid]['roster']['entries'][player]["playerPoolEntry"]["player"]["injured"]
        # droppable_bool = teams[teamid]['roster']['entries'][player]["playerPoolEntry"]["player"]["droppable"]
        drop_player_list = []
        for player in range(0, no_of_players):
            print("hehy")
            if (teams[teamid]['roster']['entries'][player]["playerPoolEntry"]["player"]["droppable"] == drop_flag) and (teams[teamid]['roster']['entries'][player]["playerPoolEntry"]["player"]["injured"] == injured_flag):
                player_id = teams[teamid]['roster']['entries'][player]["playerPoolEntry"]["id"]
                # team_id = teams[teamid]['roster']['entries'][player]["playerPoolEntry"]["onTeamId"]
                drop_player_list.append(player_id) 
            else:
                continue
        return scoring_period_id, teamid, drop_player_list
