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
        for players in range(0, 13):
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

        if len(benchplayers_player_id) == 0:
            logging.info(f'team has {no_of_players_on_bench} players on bench but cannot be moved to lineup as lineup is locked')
        else:
            for player in range(0, len(benchplayer_eligible_slots)):
                benchplayer_eligible_slots[player].remove(12)  # Removing 12 from list since the player has to be moved to lineup from Bench
                benchplayer_eligible_slots[player].remove(13)  # Removing 13 from list since the player has to be moved to lineup from Bench and not for IR

            for bench_player in range(0, len(benchplayers_player_id)):
                for random_slot in range(0, len(benchplayer_eligible_slots[bench_player])):
                    player_id = benchplayers_player_id[bench_player]
                    eligible_slots = benchplayer_eligible_slots[bench_player]
                    slot = eligible_slots[random_slot]
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
                                return [player_id, line_up_player_id, slot]
                        else:
                            continue
            return None

    @keyword('Generate a random future scoring period between ${current} and ${final}')
    def generate_random_future_scoring_period(self, current, final):
        future_scoring_period = random.randint(current, final)
        return future_scoring_period

    @keyword('Get the Eligible players details who can swap their positions from response')
    def get_eligible_players_details_to_swap_postions(self, scoringperiodid, teamid, response):
            for player in range(0, 13):
                current_scoring_period = response.get('scoringPeriodId')
                lineupslotid = JSON().get_value_from_json(response,
                                                          f'$.teams[{teamid}].roster.entries[{player}].lineupSlotId')
                if lineupslotid == 12:
                    continue
                elif current_scoring_period == scoringperiodid:
                    line_up_status = JSON().get_value_from_json(response,
                                                                    f'$.teams[{teamid}].roster.entries[{player}].'
                                                                    f'playerPoolEntry.lineupLocked')
                    if line_up_status is False:
                        eligible_slot_player1 = JSON().get_value_from_json(response,f'$.teams[{teamid}].roster.entries[{player}].'
                                                                           f'playerPoolEntry.player.eligibleSlots')
                    else:
                        continue
                else:
                    eligible_slot_player1 = JSON().get_value_from_json(response,
                                                                       f'$.teams[{teamid}].roster.entries[{player}].'
                                                                       f'playerPoolEntry.player.eligibleSlots')
                for player1 in range(0, 13):
                    lineupslotid = JSON().get_value_from_json(response,f'$.teams[{teamid}].roster.entries[{player1}].lineupSlotId')
                    if player == player1:
                        continue
                    elif lineupslotid == 12:
                        continue
                    elif current_scoring_period == scoringperiodid:
                        line_up_status = JSON().get_value_from_json(response,
                                                                    f'$.teams[{teamid}].roster.entries[{player1}].'
                                                                    f'playerPoolEntry.lineupLocked')
                        if line_up_status is False:
                            eligible_slot_player2 = JSON().get_value_from_json(response,
                                                                               f'$.teams[{teamid}].roster.entries[{player1}].'
                                                                               f'playerPoolEntry.player.eligibleSlots')
                            if eligible_slot_player1 == eligible_slot_player2:
                                player1_player_id = JSON().get_value_from_json(response,f'$.teams[{teamid}].roster.entries[{player}].playerId')
                                player2_player_id = JSON().get_value_from_json(response,f'$.teams[{teamid}].roster.entries[{player1}].playerId')
                                player1_lineup_slot_id =  JSON().get_value_from_json(response,f'$.teams[{teamid}].roster.entries[{player}].lineupSlotId')
                                player2_lineup_slot_id = JSON().get_value_from_json(response, f'$.teams[{teamid}].roster.entries[{player1}].lineupSlotId')
                                return  player1_player_id, player2_player_id,player1_lineup_slot_id,player2_lineup_slot_id
                    else:
                        eligible_slot_player2 = JSON().get_value_from_json(response,
                                                                           f'$.teams[{teamid}].roster.entries[{player1}].'
                                                                           f'playerPoolEntry.player.eligibleSlots')
                        player1_player_id = JSON().get_value_from_json(response,
                                                                       f'$.teams[{teamid}].roster.entries[{player}].playerId')
                        player2_player_id = JSON().get_value_from_json(response,
                                                                       f'$.teams[{teamid}].roster.entries[{player1}].playerId')
                        player1_lineup_slot_id = JSON().get_value_from_json(response,
                                                                            f'$.teams[{teamid}].roster.entries[{player}].lineupSlotId')
                        player2_lineup_slot_id = JSON().get_value_from_json(response,
                                                                            f'$.teams[{teamid}].roster.entries[{player1}].lineupSlotId')
                        return player1_player_id, player2_player_id, player1_lineup_slot_id, player2_lineup_slot_id
            return None

























        









