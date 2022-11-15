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

    @keyword('fetch droppable player')
    def get_the_value_and_status_code_of_preferences_key_links(self, response,  key)  :
        try:
            URL = []
            length = len(response['preferences'])
            for j in range(length):
                for k in response["preferences"][j]["metaData"]["entry"]:
                    if k == key:
                        x = response["preferences"][j]["metaData"]["entry"][key]
                        URL.append(x)
            UniqueURL= set(URL)

        except ValidationError as ve:
            raise Failure(f'Schema Data failed validation: {ve.messages}')

        return True