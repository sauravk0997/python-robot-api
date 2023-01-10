from lib.schemas import *
from marshmallow import ValidationError
from robot.api.deco import keyword, library
from robot.api.exceptions import Failure
import requests
import base64
import string
import datetime
import math
import random

@library(scope='GLOBAL', version='5.0.2')
class FantasyUtils(object):
    """Common Functions"""

    def __init__(self, *p, **k):
        pass

    @keyword('Get SWID from cookie ${result}', types={'result': str})
    def get_SWID(self, result) -> str:
        swid = result.split(";")
        return swid[0].split("SWID=")[1]

    @keyword('Get decrypted password ${encrypted_password}', types={'result': str})
    def get_credentials(self, result) -> str:
        return base64.b64decode(result).decode('utf-8')

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

    @keyword('Generate a random email')
    def generate_random_email(self):
        length = 4
        random_string = ''.join(random.choice(string.ascii_lowercase) for x in range(length))
        random_number = str(random.randint(0, 10))
        random_email = 'test' + '_' + random_string + '_' + random_number + '@test.com'
        return random_email
    
    @keyword('Generate a random password')
    def generate_random_password(self):
        length = 12
        random_string = ''.join(random.choice(string.ascii_lowercase) for x in range(length))
        random_number = str(random.randint(0, 10))
        random_pass = random_string + '@' + random_number
        return random_pass
