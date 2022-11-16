#!/Library/Frameworks/Python.framework/Versions/3.10/bin/python3.10-intel64
from lib.schemas import *
from marshmallow import ValidationError
from robot.api.deco import keyword, library
from robot.api.exceptions import Failure
import requests



@library(scope='GLOBAL', version='5.0.2')
class FantasyAddPlayerValidator(object):
    """JSON validation for ESPN Fantasy Games API"""

    def __init__(self, *p, **k):
        pass

    @keyword('Fantasy Games Schema from ${response} should be valid', tags=['schema checks', 'functional', 'CoreV3'],
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

    @keyword('Fetching droppable player')
    def get_the_droppable_player(self, response)  :
        try:
            spid = response.json()['scoringPeriodId']
            Dropplayerid = None
            noofplayers= len(response.json()['teams'][0]['roster']['entries'])
            Dropplayerid=''
            for k in range(0,noofplayers):
                if(response.json()['teams'][0]['roster']['entries'][k]["playerPoolEntry"]["player"]["droppable"]) == True:
                    Dropplayerid = response.json()['teams'][0]['roster']['entries'][k]["playerPoolEntry"]["id"]
                    #global Dropplayerid
                    break
                else:
                    continue

            return  spid, Dropplayerid
        except ValidationError as ve:
            raise Failure(f'Schema Data failed validation: {ve.messages}')
            