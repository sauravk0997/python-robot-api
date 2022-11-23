#!/Library/Frameworks/Python.framework/Versions/3.10/bin/python3.10-intel64
from lib.schemas import *
from marshmallow import ValidationError
from robot.api.deco import keyword, library
from robot.api.exceptions import Failure
import requests
import logging

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

    

    @keyword('Get the free agent player id and free agent position Id')
    def get_free_agent_players(self, response) -> bool:
        try:
                
            no_of_free_agents = len(response.json()['players'])
            for agents in range(0, (no_of_free_agents)-1):   
                        
                free_agents_id = response.json()['players'][agents]['id']
                global free_agents_position_id
                free_agents_position_id = response.json()['players'][agents]['player']['defaultPositionId']
                #if check_matching_position_id(free_agents_id, free_agents_position_id) == True:

                        
        except ValidationError as ve:
            raise Failure(f'Parsing failed :{ve.messages}')
        return free_agents_id, free_agents_position_id

    
    @keyword('Get the scoring period Id and drop player id')
    def get_droppable_players(self, TEAM_ID, response) -> bool:
        try:
            
            scoring_period_id = response.json()['scoringPeriodId']
            team_id = int(TEAM_ID)-1
            no_of_players = len(response.json()['teams'][team_id]['roster']['entries'])
            for player in range(1, no_of_players):
                drop_player_id = 0
                droppableBool = response.json()['teams'][team_id]['roster']['entries'][player]["playerPoolEntry"]["player"]["droppable"]
                lineupLockedBool = response.json()['teams'][team_id]['roster']['entries'][player]["playerPoolEntry"]['lineupLocked']
                drop_player_Position_Id = response.json()['teams'][team_id]['roster']['entries'][player]["playerPoolEntry"]['player']['defaultPositionId']
                if ((droppableBool== True) and (lineupLockedBool == False)):
                    if drop_player_Position_Id == free_agents_position_id:
                        drop_player_id = response.json()['teams'][team_id]['roster']['entries'][player]["playerPoolEntry"]["id"]
                        break
                    else:
                        #logging.info(f"Player with {free_agents_position_id}, either he is not drooppable or he is locked")
                        continue
                        #antasyAddPlayerValidator.get_free_agent_players(response)
                            
                else:
                    #logging.info(f"There is no droppable player available with {free_agents_position_id}")
                    continue
                
        except ValidationError as ve:
             raise Failure(f'Parsing failed :{ve.messages}')
        return scoring_period_id, drop_player_id    