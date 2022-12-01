from lib.schemas import *
from marshmallow import ValidationError
from robot.api.deco import keyword, library
from robot.api.exceptions import Failure
import requests
import string
import datetime
import math


@library(scope='GLOBAL', version='5.0.2')
class FantasyUtils(object):
    """Common Functions"""

    def __init__(self, *p, **k):
        pass

    @keyword('Get SWID from cookie ${result}', types={'result': str})
    def get_SWID(self, result) -> str:
        swid = result.split(";")
        return swid[0].split("SWID=")[1]

    @keyword('Get unixtimestamp time')
    def get_unix_timestamp_time(self) -> int:
        presentDate = datetime.datetime.now()
        unix_timestamp = math.ceil(datetime.datetime.timestamp(presentDate)*1000)
        return unix_timestamp
    
    @keyword('Get COPY_TO_CLIPBOARD invite id from ${response}', types={'response': requests.Response})
    def get_copytoclipboard_invite_id(self, response) -> str:
            invited_dict = response.get("invited")
            for invite in invited_dict:
                if invite.get("inviteType") == "COPY_TO_CLIPBOARD":
                    return invite.get("id")