import logging
import random
from lib.schemas import *
from marshmallow import ValidationError
from robot.api.deco import keyword, library
from robot.api.exceptions import Failure
from RPA.JSON import JSON


@library(scope='GLOBAL', version='5.0.2')
class FantasyMovePlayerValidator(object):
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

    @keyword('check whether the players on Bench are eligible to moved into lineup from ${response}')
    def check_whether_the_players_on_Bench_are_eligible_to_moved_into_lineup(self, response):
        no_of_players_on_bench = 0
        benchplayers_player_id = []
        benchplayer_eligible_slots = []
        for players in range(0, 12):
            lineupslotid = JSON().get_value_from_json(response, f'$.teams[0].roster.entries[{players}].lineupSlotId')
            if lineupslotid == 12:  # Bench players line up slot id is 12
                no_of_players_on_bench += 1
                line_up_status = JSON().get_value_from_json(response, f'$.teams[0].roster.entries[{players}]'
                                                                      f'.playerPoolEntry.lineupLocked')
                if line_up_status is False:
                    player_id = JSON().get_value_from_json(response, f'$.teams[0].roster.entries[{players}].playerId')
                    benchplayers_player_id += [player_id]
                    eligible_slots = JSON().get_value_from_json(response, f'$.teams[0].roster.entries[{players}].'
                                                                          f'playerPoolEntry.player.eligibleSlots')
                    benchplayer_eligible_slots += [eligible_slots]
                else:
                    continue

        for player in range(0, 3):
            benchplayer_eligible_slots[player].remove(12)  #Removing 12 from list since the player has to be moved to lineup from Bench
            benchplayer_eligible_slots[player].remove(13)  #Removing 13 from list since the player has to be moved to lineup from Bench and not for IR
        
        if len(benchplayers_player_id) == 0:
            logging.info(f'team has {no_of_players_on_bench} on bench but cannot be moved to lineup as lineup is locked')
        else:
            for no in range(0, 3):
                for random_no in range(0, len(benchplayer_eligible_slots[no])):
                    player_id = benchplayers_player_id[no]
                    eligible_slots = benchplayer_eligible_slots[no]
                    slot = eligible_slots[random_no]
                    for players in range(0, 12):
                        lineupslotid = JSON().get_value_from_json(response,
                                                                  f'$.teams[0].roster.entries[{players}].lineupSlotId')
                        if lineupslotid == slot:
                            line_up_status = JSON().get_value_from_json(response,
                                                                        f'$.teams[0].roster.entries[{players}].'
                                                                        f'playerPoolEntry.lineupLocked')
                            if line_up_status is False:
                                line_up_player_id = JSON().get_value_from_json(response,
                                                                               f'$.teams[0].roster.entries[{players}].playerId')
                                line_up_slot_id = JSON().get_value_from_json(response,
                                                                             f'$.teams[0].roster.entries[{players}].lineupSlotId')
                                return [player_id, line_up_player_id, slot, line_up_slot_id]
                        else:
                            continue
            return None










        









