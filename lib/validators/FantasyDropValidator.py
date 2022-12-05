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

    #Validates the schema of the response.
    @keyword('Fantasy Drop Schema from ${response} should be valid', tags=['drop-player','schema checks', 'functional', 'CoreV3'],
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


    #Selects the first player fromn all the teams for drop
    @keyword('Get a player to drop ${response} ${myteamid}', tags=['drop-player', 'functional', 'CoreV3'],
             types={'response': requests.Response})
    def fetch_droppable_players(self, response, teamid):
        try:
            teams = response.json()['teams']
            scoring_period_id = response.json()['scoringPeriodId']
            team_id = 0
            if teamid == '0':
                for team in teams:
                    no_of_players = len(team['roster']['entries'])
                    for player in range(0, no_of_players):
                        player_pool_entry = team['roster']['entries'][player]["playerPoolEntry"]
                        if (player_pool_entry["player"]["droppable"]) == True and (player_pool_entry["status"]) != 'FREEAGENT':
                            team_id = player_pool_entry["onTeamId"]
                            player_id = player_pool_entry["id"]
                            break
                    else:
                        continue
                    break                    

                return scoring_period_id, team_id, player_id

            else:
                drop_flag = True
                scoring_period_id, teamid, drop_player_list = self.create_player_list(
                    response, teamid, drop_flag)
                return scoring_period_id, teamid, drop_player_list[0]
        except ValidationError as ve:
            raise Failure(f'Parsing failed :{ve.messages}')

    #custom function to create list of players that are droppable
    def create_player_list(self, response, teamid, drop_flag):
        teams = response.json()['teams']
        scoring_period_id = response.json()['scoringPeriodId']
        teamid = int(teamid) - 1
        team_id = 0
        no_of_players = len(teams[teamid]['roster']['entries'])
        drop_player_list = []
        for player in range(0, no_of_players):
            player_entry = teams[teamid]['roster']['entries'][player]["playerPoolEntry"]
            if (player_entry["player"]["droppable"]) == drop_flag and (player_entry["onTeamId"]) != 0:
                player_id = player_entry["id"]
                team_id = player_entry["onTeamId"]
                drop_player_list.append(player_id)
            else:
                continue
        return scoring_period_id, team_id, drop_player_list

    #Finds the droppable player of team
    @keyword('Find droppable players of a team ${response} ${myteamid}', tags=['drop-player', 'functional', 'CoreV3'],
             types={'response': requests.Response})
    def get_droppable_players(self, response, teamid):
        drop_flag = True
        scoring_period_id, teamid, drop_player_list = self.create_player_list(
            response, teamid, drop_flag)
        return scoring_period_id, teamid, drop_player_list

    #Find the undroppable players of a team
    @keyword('Find undroppable players of a team ${response} ${myteamid}', tags=['drop-player', 'functional', 'CoreV3'],
             types={'response': requests.Response})
    def get_undroppable_players(self, response, teamid):
        drop_flag = False
        scoring_period_id, teamid, drop_player_list = self.create_player_list(
            response, teamid, drop_flag)
        return scoring_period_id, teamid, drop_player_list

    #Finds the injured players in a team
    @keyword('Find injured players of a team ${response} ${myteamid}', tags=['drop-player', 'functional', 'CoreV3'],
             types={'response': requests.Response})
    def get_injured_players(self, response, teamid):
        drop_flag = True
        injured_flag = True
        teams = response.json()['teams']
        scoring_period_id = response.json()['scoringPeriodId']
        teamid = int(teamid) - 1
        team_id = 0
        entries = teams[teamid]['roster']['entries']
        no_of_players = len(entries)
        drop_player_list = []
        for player in range(0, no_of_players):
            player_entry = entries[player]["playerPoolEntry"]
            if (player_entry["player"]["droppable"] == drop_flag) and (player_entry["player"]["injured"] == injured_flag):
                player_id = player_entry["id"]
                team_id = player_entry["onTeamId"]
                drop_player_list.append(player_id)
            else:
                continue
        return scoring_period_id, team_id, drop_player_list
