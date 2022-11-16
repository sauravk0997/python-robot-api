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

    
    @keyword('Get droppable players of any team from ${response}', tags=['drop player', 'functional', 'CoreV3'],
             types={'response': requests.Response})
    def get_droppable_players(self, response) -> bool:
        try:
            scoring_period_id = response.json()['scoringPeriodId']
            for i in response.json()['teams']:
                noofplayers= len(i['roster']['entries'])
                for k in range(0,noofplayers):
                    if(i['roster']['entries'][k]["playerPoolEntry"]["player"]["droppable"]) == True:
                        teamid = i['roster']['entries'][k]["playerPoolEntry"]["onTeamId"]
                        playerid = i['roster']['entries'][k]["playerPoolEntry"]["id"]
                        break
                    else:
                        continue
        
            return scoring_period_id,teamid,playerid
        except ValidationError as ve:
            raise Failure(f'Parsing failed :{ve.messages}')
