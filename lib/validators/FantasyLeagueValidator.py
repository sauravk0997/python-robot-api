from robot.api.deco import keyword, library
import requests
from robot.api.logger import console


@library(scope='GLOBAL', version='5.0.2')
class FantasyLeagueValidator(object):
    """JSON"""

    def __init__(self, *p, **k):
        pass

    @keyword('Extract LeagueId from fantasy league API Response', tags=['leagues'],
             types={'response': requests.Response})
    def extract_current_league_id(self, response) -> list:
       """Expects to receive json requests object as 'response'
          and extract the LeagueId from it and returns that value.
          Returns 0 if the key LeagueId is not available in response

        """

       if 'id' not in response:
           console(f'response contains no current league ID, returning 0')
           return [0]

       else:
           return response['id']
