import requests
from lib.schemas import *
from marshmallow import ValidationError
from robot.api.deco import keyword, library
from robot.api.exceptions import Failure


@library(scope='GLOBAL', version='5.0.2')
class FantasyLeagueCoreValidator(object):

    def __init__(self, *p, **k):
        pass

    @keyword('Move Player Schema from ${response} should be valid', tags=['schema checks', 'functional', 'CoreV3'],
             types={'response': requests.Response})
    def move_player_should_be_valid(self, response) -> bool:
        """
                    Schema for the endpoint: apis/v3/games/fba/seasons/2023/segments/0/leagues/${leagueid}/transactions/

                    Expects to receive an embedded python requests object as 'response'
                    and validates the json against the FantasyLeague class.

                  Examples:
                  'Move Player Schema from ${response} should be valid
                """
        try:
            schema = MovePlayerSchema().load(response.json())

        except ValidationError as ve:
            raise Failure(f'Schema Data failed validation: {ve.messages}')
        return True
