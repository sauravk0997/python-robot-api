from lib.schemas import *
from marshmallow import ValidationError
from robot.api.deco import keyword, library
from robot.api.exceptions import Failure
import requests
import string


@library(scope='GLOBAL', version='5.0.2')
class FantasyUtils(object):
    """Common Functions"""

    def __init__(self, *p, **k):
        pass

    @keyword('Get SWID from cookie ${result}', types={'result': str})
    def get_SWID(self, result) -> str:
        # print(result)
        swid = result.split(";")
        return swid[0].split("SWID=")[1]
