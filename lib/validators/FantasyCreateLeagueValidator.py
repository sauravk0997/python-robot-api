from lib.schemas import *
from lib.schemas.FantasyMemberInviteSchema import FantasyMemberInviteSchema
from lib.schemas.FantasyTeamSchema import FantasyTeamSchema
from marshmallow import ValidationError
from robot.api.deco import keyword, library
from robot.api.exceptions import Failure
import requests
import string


@library(scope='GLOBAL', version='5.0.2')
class FantasyCreateLeagueValidator(object):
    """JSON validation for Fantasy Sports Fans API"""

    def __init__(self, *p, **k):
        pass

    @keyword('Fantasy Create League Schema from ${response} should be valid', types={'response': requests.Response})
    def fantasy_league(self, response) -> bool:
        try:
            data = FantasyCreateLeagueSchema().load(response.json())

        except ValidationError as ve:
            raise Failure(f'Schema Data failed validation: {ve.messages}')
        return True

    @keyword('Fantasy Member Invite Schema from ${response} should be valid', types={'response': requests.Response})
    def fantasy_member_invite_schema(self, response) -> bool:
        try:
            data = FantasyMemberInviteSchema().load(response.json())

        except ValidationError as ve:
            raise Failure(f'Schema Data failed validation: {ve.messages}')
        return True

    
    @keyword('Fantasy Teams Schema from ${response} should be valid', types={'response': requests.Response})
    def fantasy_teams_schema(self, response) -> bool:
        try:
            data = FantasyTeamSchema().load(response.json())

        except ValidationError as ve:
            raise Failure(f'Schema Data failed validation: {ve.messages}')
        return True