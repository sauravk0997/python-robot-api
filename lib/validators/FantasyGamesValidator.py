#!/Library/Frameworks/Python.framework/Versions/3.10/bin/python3.10-intel64
from lib.schemas import *
from robot.api.deco import keyword, library
import requests
from robot.api.logger import console


@library(scope='GLOBAL', version='5.0.2')
class FantasyGamesValidator(object):
    """JSON"""

    def __init__(self, *p, **k):
        pass

    @keyword('Extract current season Id from fantasy game API Response', tags=['events'],
             types={'response': requests.Response})
    def extract_current_season_id(self, response) -> list:
        """ Expects to receive json requests object as 'response'
          and extract the currentSeasonId from it and returns that value.
          Returns 0 if the key currentSeasonId is not available in response

        Examples:
        |                  Keyword                                      |    Arg      |     Response        |
        | Extract current season Id from fantasy game API Response      | ${response} | currentSeasonId     |
        """

        if 'currentSeasonId' not in response:
            console(f'Games response contains no current season IDs, returning 0')
            return [0]
        else:
            return response['currentSeasonId']

    @keyword('Extract client flags from fantasy game API Response', tags=['events'],
             types={'response': requests.Response, 'clientflag': str})
    def extract_client_flags_value(self, response, clientflag) -> list:
        """ Expects to receive json requests object as 'response'
          and extract the value of the client flag passed as argument and returns that value.
          Returns 0 if the key not available in response
          Returns None if the client flag key is not valid

        Examples:
        |                  Keyword                             |    Arg                 |     Response        |
        | Extract client flags from fantasy game API Response  | ${response},clientFlag | value of clientFlag passed in arg     |
        """
        if 'currentSeason' not in response:
            console(f'Games response contains no current season key, returning 0')
            return [0]
        else:
            currentSeason_dict = response.get("currentSeason")
            if "settings" not in currentSeason_dict:
                console(f'Games response contains no settings key, returning 0')
                return [0]
            else:
                settings_dict = currentSeason_dict.get("settings")
                if "clientFlags" not in settings_dict:
                    console(f'Games response contains no clientFlags key, returning 0')
                    return [0]
                else:
                    clientFlags_dict = settings_dict.get("clientFlags")
                    for clientflag_key in clientFlags_dict:
                        if clientflag_key == clientflag:
                            return clientFlags_dict[clientflag_key]
                        else:
                            return None

    @keyword('Extract current scoring period id from fantasy game API Response', tags=['events'],
             types={'response': requests.Response})
    def extract_current_scoring_period(self, response) -> list:
        """ Expects to receive json requests object as 'response'
          and extract the id from currentScoringPeriod from it and returns that value.
          Returns 0 if the key currentScoringPeriod is not available in response

        Examples:
        |                  Keyword                                          |    Arg      |     Response           |
        | Extract current scoring period id from fantasy game API Response  | ${response} | currentScoringPeriodId |
        """

        if 'currentSeason' not in response:
            console(f'Games response contains no current season key, returning 0')
            return [0]
        else:
            currentSeason = response.get('currentSeason')
            if 'currentScoringPeriod' not in currentSeason:
                console(f'Games response contains no currentScoringPeriod key, returning  0')
                return [0]
            else:
                currentScoringPeriod = currentSeason.get('currentScoringPeriod')
                return currentScoringPeriod['id']

    @keyword('Extract value of the key from settings object of fantasy game API Response', tags=['events'],
             types={'response': requests.Response, 'key': str})
    def extract_key_from_settings(self, response, key) -> list:
        """ Expects to receive json requests object as 'response'
          and extract the value of key in settings json object and returns that value.
          Returns 0 if the key is not available in response

        Examples:
        |                  Keyword                                                    |    Arg      | Response    |
        | Extract value of the key from settings object of fantasy game API Response  | ${response} | value of key |
        """

        if 'currentSeason' not in response:
            console(f'Games response contains no current season key, returning 0')
            return [0]
        else:
            currentSeason = response.get('currentSeason')
            if 'settings' not in currentSeason:
                console(f'Games response contains no settings key, returning  0')
                return [0]
            else:
                settings_dict = currentSeason.get('settings')
                if key not in settings_dict:
                    console(f'Settings does not have ${key}. Returning 0')
                    return [0]
                else:
                    return settings_dict[key]

    @keyword('Extract draft schedule settings from fantasy game API Response', tags=['events'],
             types={'response': requests.Response, 'draftScheduleKey': str})
    def extract_draft_schedule_settings_value(self, response, draftScheduleKey) -> list:
        """ Expects to receive json requests object as 'response'
          and extract the value of the draft schedule settings passed as argument and returns that value.
          Returns 0 if the key not available in response
          Returns None if the client flag key is not valid

        Examples:
        |                  Keyword                                        |    Arg                              |     Response        |
        | Extract draft schedule settings from fantasy game API Response  | ${response},draftScheduleSettingKey | value of draftScheduleSetting key    |
        """
        if 'currentSeason' not in response:
            console(f'Games response contains no current season key, returning 0')
            return [0]
        else:
            currentSeason_dict = response.get("currentSeason")
            if "settings" not in currentSeason_dict:
                console(f'Games response contains no settings key, returning 0')
                return [0]
            else:
                settings_dict = currentSeason_dict.get("settings")
                if "draftScheduleSettings" not in settings_dict:
                    console(f'Games response contains no draftScheduleSettings key, returning 0')
                    return [0]
                else:
                    draftScheduleSettings_dict = settings_dict.get("draftScheduleSettings")
                    for draftScheduleSettings_key in draftScheduleSettings_dict:
                        if draftScheduleSettings_key == draftScheduleKey:
                            return draftScheduleSettings_dict[draftScheduleSettings_key]
                        else:
                            return None
