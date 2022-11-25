#!/Library/Frameworks/Python.framework/Versions/3.10/bin/python3.10-intel64
from lib.schemas import *
from marshmallow import ValidationError
from robot.api.deco import keyword, library
from robot.api.exceptions import Failure
import requests
import logging
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

    @keyword('Get the drop player Id and free agent player Id')
    def get_droppable_and_FreeAgents_players(self, TEAM_ID, response, free_agent_response) -> bool:
        try:
            random_no = random.randint(0, 15)
            team_id = int(TEAM_ID)-1
            no_of_players = len(response.json()['teams'][team_id]['roster']['entries'])
            no_of_free_agents = len(free_agent_response.json()['players'])
            for agents in range(random_no, (no_of_free_agents)-1):   
                flag = False       
                free_agents_id = free_agent_response.json()['players'][agents]['id']
                free_agents_position_id = free_agent_response.json()['players'][agents]['player']['defaultPositionId']
                for player in range(0, no_of_players):
                    droppableBool = response.json()['teams'][team_id]['roster']['entries'][player]["playerPoolEntry"]["player"]["droppable"]
                    lineupLockedBool = response.json()['teams'][team_id]['roster']['entries'][player]["playerPoolEntry"]['lineupLocked']
                    drop_player_Position_Id = response.json()['teams'][team_id]['roster']['entries'][player]["playerPoolEntry"]['player']['defaultPositionId']
                    if ((droppableBool == True) and (lineupLockedBool == False)):
                        if drop_player_Position_Id == free_agents_position_id:
                            drop_player_id = response.json()['teams'][team_id]['roster']['entries'][player]["playerPoolEntry"]["id"]
                            flag = True
                            break        
                    else:
                        continue
                if flag == True:
                    break        
        except ValidationError as ve:
             raise Failure(f'Parsing failed :{ve.messages}')
        return drop_player_id, free_agents_id    