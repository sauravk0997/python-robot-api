import string
from lib.schemas import *
from marshmallow import ValidationError
from robot.api.deco import keyword, library
from robot.api.exceptions import Failure
import requests
import logging


@library(scope='GLOBAL', version='5.0.2')
class FantasySportFansValidator(object):
    """JSON validation for Fantasy Sports Fans API"""

    def __init__(self, *p, **k):
        pass

    @keyword('Fantasy Fans Sports Schema from ${response} should be valid', tags=['functional'], types={'response': requests.Response})
    def base_resp_is_valid(self, response) -> bool:
        try:
            data = FantasySportFansSchema().load(response.json())

        except ValidationError as ve:
            raise Failure(f'Schema Data failed validation: {ve.messages}')
        return True

    @keyword('get the count of ${key} objects in ${key1} from ${response}', tags=['functional'], types={'response': requests.Response, 'key': string, 'key1': string})
    def get_the_count_objects_from_response(self, key, key1, response) -> bool:
        try:
            length = len(response.get(key))
            logging.info(f"The total number of objects are :: {length}") if length > 0 else logging.error(
                f"There are no objects.")

        except ValidationError as ve:
            raise Failure(f'Schema Data failed validation: {ve.messages}')
        return True

    @keyword('get the ${key} from fantasy fans schema ${response}', tags=['schema checks'], types={'response': requests.Response,
                                                                                           'key': string})
    def get_values_for_keys_of_fans_from_response(self, key, response):
        try:
            logging.info(f"The value of {key} is {response.get(key)}") if response.get(
                key) != None and response.get(key) != "" else logging.error(f"The value of {key} is {response.get(key)}")

        except ValidationError as ve:
            raise Failure(f'Schema Data failed validation: {ve.messages}')

    @keyword('get the ${key} from fantasy profile schema ${response}', tags=['schema checks'], types={'response': requests.Response,
                                                                                              'key': string})
    def get_values_for_keys_of_profile_from_response(self, key, response):
        try:

            logging.info(f'The value of {key} is {response.get("profile")[key]}') if response.get("profile")[
                key] != "" else logging.error(f'The value of {key} is {response.get("profile")[key]}')

        except ValidationError as ve:
            raise Failure(f'Schema Data failed validation: {ve.messages}')

    @keyword('Is ${key} present in ${response}', tags=['functional'], types={'response': requests.Response, 'key': string})
    def validate_key_is_present(self, key, response) -> bool:
        try:
            if key in response:
                logging.info(f"{key} is present")
                return True
            else:
                logging.error(f"Expected the {key} exists in the JSON response but {key} not found. "
                              f"\n${response}")
                return False
        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')
