#!/Library/Frameworks/Python.framework/Versions/3.10/bin/python3.10-intel64
from lib.schemas import *
from marshmallow import ValidationError
from robot.api.deco import keyword, library
from robot.api.exceptions import Failure
import requests
import random

@library(scope='GLOBAL', version='5.0.2')
class FantasyAddPlayerValidator(object):
    """JSON validation for Add Player Schema API"""

    def __init__(self, *p, **k):
        pass

    @keyword('Add Player Schema from ${response} should be valid', tags=['schema checks', 'functional', 'CoreV3'],
             types={'response': requests.Response})
    def fantasy_games_schema_from_response_should_be_valid(self, response) -> bool:
        """
            Schema for the endpoint: apis/v3/games/FFL

            Expects to receive an embedded python requests object as 'response'
            and validates the json against the FantasyGames class.

          Examples:
          Fantasy Games Schema from ${response} should be valid
        """
        try:
            data = AddPlayerSchema().load(response.json())

        except ValidationError as ve:
            raise Failure(f'Schema Data failed validation: {ve.messages}')

        return True

    @keyword('Get the droppable player and free-agent player id')
    def get_droppable_and_freeAgents_players(self, teamId, droppable_player_response, free_agent_response) -> list:
        try:
            player_id_details = []
            random_no = random.randint(0, 35)
            team_id = int(teamId)-1
            no_of_players = len(droppable_player_response.json()['teams'][team_id]['roster']['entries'])
            no_of_free_agents = len(free_agent_response.json()['players'])
            for agents in range(random_no, (no_of_free_agents)-1):   
                flag = False      
                free_agents_id = free_agent_response.json()['players'][agents]['id']
                free_agents_position_id = free_agent_response.json()['players'][agents]['player']['defaultPositionId']
                for player in range(0, no_of_players):
                    entries = droppable_player_response.json()['teams'][team_id]['roster']['entries']
                    isPlayerDroppable = entries[player]["playerPoolEntry"]["player"]["droppable"]
                    isLineupLocked = entries[player]["playerPoolEntry"]['lineupLocked']
                    onTeamId = entries[player]["playerPoolEntry"]['onTeamId']
                    droppable_player_position_id = droppable_player_response.json()['teams'][team_id]['roster']['entries'][player]["playerPoolEntry"]['player']['defaultPositionId'] 
                    if onTeamId == int(teamId):
                        if ((isPlayerDroppable == True) and (isLineupLocked == False)):
                            if droppable_player_position_id == free_agents_position_id:
                                    droppable_player_id = droppable_player_response.json()['teams'][team_id]['roster']['entries'][player]["playerPoolEntry"]["id"]
                                    flag = True
                                    break        
                            else:
                                continue
                        else:
                            continue
                    else:
                        continue
                if flag == True:
                    break    
            player_id_details.append(droppable_player_id)   
            player_id_details.append(free_agents_id)
        except ValidationError as ve:
             raise Failure(f'Parsing failed :{ve.messages}')
        return player_id_details   