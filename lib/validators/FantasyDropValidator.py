import string
from typing import List
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

    @keyword('get the number of objects in the ${key} schema ${response}', tags=['functional'], types={'response': requests.Response, 'key': string})
    def get_the_number_of_objects(self, key, response) -> int:
        try:
            return len(response.get(key))

        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')

    @keyword('validate the ${key} value from fantasy fans schema is not null ${response}', tags=['schema checks'], types={'response': requests.Response,
                                                                                                                          'key': string})
    def get_values_for_keys_of_fans_from_response(self, key, response):
        try:
            logging.info(f"The value of {key} is {response.get(key)}") if response.get(
                key) != None and response.get(key) != "" else logging.error(f"The value of {key} is {response.get(key)}")

        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')

    @keyword('validate the ${key} value from fantasy profile schema is not null ${response}', tags=['schema checks'], types={'response': requests.Response,
                                                                                                                             'key': string})
    def get_values_for_keys_of_profile_from_response(self, key, response):
        try:

            logging.info(f'The value of {key} is {response.get("profile")[key]}') if response.get("profile")[
                key] != "" and response.get("profile")[key] != None else logging.error(f'The value of {key} is {response.get("profile")[key]}')

        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')

    @keyword('validate ${key} exists ${response}', tags=['functional'], types={'response': requests.Response, 'key': string})
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

    @keyword('get the ${key} links of ${key1} preferences schema ${response}', tags=['functional'], types={'response': requests.Response, 'key': string, 'key1': string})
    def get_links(self, key, key1, response) -> set:
        try:
            unique_links = set()
            response_dict = response.get("preferences")
            for objects in response_dict:
                metaData_dict = objects.get("metaData")
                for metadata1 in metaData_dict:
                    entry_dict = metaData_dict.get("entry")
                    if key1 == "entry":
                        for entryValue in entry_dict:
                            if entryValue == key and entry_dict.get(key) != None:
                                unique_links.add(entry_dict.get(key))
                    elif key1 == "entry groups":
                        if "groups" in entry_dict:
                            groups_dict = entry_dict.get("groups")[0]
                            for entryValue in groups_dict:
                                if entryValue == key and groups_dict.get(key) != None:
                                    unique_links.add(groups_dict.get(key))
            return unique_links
        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.message}')

    @keyword('validate ${links} should respond with ${status}', tags=['functional'], types={'links': List, 'status': int})
    def validate_links_should_respond_with_status_code(self, links, status):
        try:
            for link in links:
                resp = requests.get(link)
                if resp.status_code == status:
                    logging.info(
                        f'{link} received with status code {resp.status_code} has been Validated')
                else:
                    logging.error(
                        f'Received unexpected status code {resp.status_code} from {link}')
        except ValidationError as ve:
            raise Failure(f'API invocation failed: {ve.message}')

    @keyword('validate the ${value} count', tags=['functional'], types={'value': int})
    def validate_the_count_objects(self, value) -> int:
        try:
            logging.info(f"The value is {value} and it is greater than 0") if value > 0 else logging.error(
                f'The length is {value}')
        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')
