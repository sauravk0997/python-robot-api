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
                    Schema for the endpoint: apis/v3/games/fba/seasons/2023/segments/0/leagues/${league_id}/transactions/

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

    @keyword('Get the bench players details of team ${team_id} from ${teams_response}')
    def get_the_bench_players_details_of_team(self, team_id, teams_response) -> list:
        try:
            no_of_players_on_bench = 0
            bench_players_player_id = []
            bench_player_eligible_slots = []
            for players in range(0, 13):
                lineup_slot_id = JSON().get_value_from_json(teams_response,
                                                            f'$.teams[{team_id}].roster.entries[{players}].lineupSlotId')
                if lineup_slot_id == 12:  # Bench players line up slot id is 12
                    no_of_players_on_bench += 1
                    line_up_status = JSON().get_value_from_json(teams_response,
                                                                f'$.teams[{team_id}].roster.entries[{players}]'
                                                                f'.playerPoolEntry.lineupLocked')
                    if line_up_status is False:
                        player_id = JSON().get_value_from_json(teams_response,
                                                               f'$.teams[{team_id}].roster.entries[{players}].playerId')
                        bench_players_player_id += [player_id]
                        eligible_slots = JSON().get_value_from_json(teams_response,
                                                                    f'$.teams[{team_id}].roster.entries[{players}].'
                                                                    f'playerPoolEntry.player.eligibleSlots')
                        bench_player_eligible_slots += [eligible_slots]
                    else:
                        continue
            return [no_of_players_on_bench, bench_players_player_id, bench_player_eligible_slots]
        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')

    @keyword('check for ${bench_players} eligibility for moving to lineup from ${team_response}')
    def check_bench_player_eligibility_for_moving_to_lineup(self, bench_players, team_response) -> list:
        try:
            no_players_on_bench = bench_players[0]
            bench_players_player_ids = bench_players[1]
            bench_players_eligible_slots = bench_players[2]
            if len(bench_players_player_ids) == 0:
                logging.info(
                    f'team has {no_players_on_bench} players on bench but cannot be moved to lineup as lineup is locked')
            else:
                for bench_player_slots in range(0, len(bench_players_eligible_slots)):
                    bench_players_eligible_slots[bench_player_slots].remove(12)  # Removing 12 from list since the player has to be moved to lineup from Bench
                    bench_players_eligible_slots[bench_player_slots].remove(13)  # Removing 13 from list since the player has to be moved to lineup from Bench and not for IR
                for bench_player in range(0, len(bench_players_player_ids)):
                    for bench_player_slots in range(0, len(bench_players_eligible_slots[bench_player])):
                        bench_player_id = bench_players_player_ids[bench_player]
                        eligible_slots = bench_players_eligible_slots[bench_player]
                        lineup_slot = eligible_slots[bench_player_slots]
                        for lineup_players in range(0, 13):
                            lineup_slot_id = JSON().get_value_from_json(team_response, f'$.teams[0].roster.entries[{lineup_players}].lineupSlotId')
                            if lineup_slot_id == lineup_slot:
                                line_up_status = JSON().get_value_from_json(team_response, f'$.teams[0].roster.entries[{lineup_players}].playerPoolEntry.lineupLocked')
                                if line_up_status is False:
                                    line_up_player_id = JSON().get_value_from_json(team_response, f'$.teams[0].roster.entries[{lineup_players}].playerId')
                                    return [bench_player_id, line_up_player_id, lineup_slot]
                            else:
                                continue
                logging.info("Unable to Move Bench Players to lineup as the lineup transactions are locked")
        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')


    @keyword('Generate a random future scoring period between ${current} and ${final}')
    def generate_random_future_scoring_period(self, current, final):
        try:
            future_scoring_period = random.randint(current, final)
            return future_scoring_period
        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')


    @keyword('Get the Eligible players details who can swap their positions from response')
    def get_eligible_players_details_to_swap_positions(self, scoring_period_id, team_id, response):
        try:
            for line_up_player in range(0, 13):
                lineup_slot_id = JSON().get_value_from_json(response, f'$.teams[{team_id}].roster.entries[{line_up_player}].lineupSlotId')
                if lineup_slot_id == 12:
                    continue
                current_scoring_period = response.get('scoringPeriodId')
                if current_scoring_period == scoring_period_id:
                    line_up_status = JSON().get_value_from_json(response, f'$.teams[{team_id}].roster.entries[{line_up_player}].playerPoolEntry.lineupLocked')
                    if line_up_status is False:
                        eligible_slot_player1 = JSON().get_value_from_json(response, f'$.teams[{team_id}].roster.entries[{line_up_player}].playerPoolEntry.player.eligibleSlots')
                    else:
                        continue
                else:
                    eligible_slot_player1 = JSON().get_value_from_json(response, f'$.teams[{team_id}].roster.entries[{line_up_player}].playerPoolEntry.player.eligibleSlots')
                for compare_line_up_player in range(0, 13):
                    if line_up_player == compare_line_up_player:
                        continue
                    lineup_slot_id = JSON().get_value_from_json(response, f'$.teams[{team_id}].roster.entries[{compare_line_up_player}].lineupSlotId')
                    if lineup_slot_id == 12:
                        continue
                    if current_scoring_period == scoring_period_id:
                        line_up_status = JSON().get_value_from_json(response,
                                                                    f'$.teams[{team_id}].roster.entries[{compare_line_up_player}].playerPoolEntry.lineupLocked')
                        if line_up_status is False:
                            eligible_slot_player2 = JSON().get_value_from_json(response, f'$.teams[{team_id}].roster.entries[{compare_line_up_player}].playerPoolEntry.player.eligibleSlots')
                            if eligible_slot_player1 == eligible_slot_player2:
                                line_up_player_player_id = JSON().get_value_from_json(response, f'$.teams[{team_id}].roster.entries[{line_up_player}].playerId')

                                compare_line_up_player_player_id = JSON().get_value_from_json(response, f'$.teams[{team_id}].roster.entries[{compare_line_up_player}].playerId')
                                line_up_player_lineup_slot_id = JSON().get_value_from_json(response, f'$.teams[{team_id}].roster.entries[{line_up_player}].lineupSlotId')
                                compare_line_up_player_lineup_slot_id = JSON().get_value_from_json(response, f'$.teams[{team_id}].roster.entries[{compare_line_up_player}].lineupSlotId')
                                return line_up_player_player_id, compare_line_up_player_player_id, line_up_player_lineup_slot_id, compare_line_up_player_lineup_slot_id
                    else:
                        eligible_slot_player2 = JSON().get_value_from_json(response,
                                                                           f'$.teams[{team_id}].roster.entries[{compare_line_up_player}].playerPoolEntry.player.eligibleSlots')
                        if eligible_slot_player1 == eligible_slot_player2:
                            line_up_player_player_id = JSON().get_value_from_json(response, f'$.teams[{team_id}].roster.entries[{line_up_player}].playerId')
                            compare_line_up_player_player_id = JSON().get_value_from_json(response, f'$.teams[{team_id}].roster.entries[{compare_line_up_player}].playerId')
                            line_up_player_lineup_slot_id = JSON().get_value_from_json(response, f'$.teams[{team_id}].roster.entries[{line_up_player}].lineupSlotId')
                            compare_line_up_player_lineup_slot_id = JSON().get_value_from_json(response, f'$.teams[{team_id}].roster.entries[{compare_line_up_player}].lineupSlotId')
                            return line_up_player_player_id, compare_line_up_player_player_id, line_up_player_lineup_slot_id, compare_line_up_player_lineup_slot_id
            return None
        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')

    @keyword('Get any random lineup player details of team ${team_id} from ${response} to move on bench')
    def get_any_random_lineup_player_details(self, team_id, teams_response) -> list:
        try:
            for players in range(0, 13):
                lineup_slot_id = JSON().get_value_from_json(teams_response, f'$.teams[{team_id}].roster.entries[{players}].lineupSlotId')
                if lineup_slot_id == 12:  # Bench players line up slot id is 12
                    continue
                else:
                    line_up_status = JSON().get_value_from_json(teams_response, f'$.teams[{team_id}].roster.entries[{players}].playerPoolEntry.lineupLocked')
                    if line_up_status is False:
                        player_id = JSON().get_value_from_json(teams_response, f'$.teams[{team_id}].roster.entries[{players}].playerId')
                        lineup_slot_id = JSON().get_value_from_json(teams_response, f'$.teams[{team_id}].roster.entries[{players}].lineupSlotId')
                        return [player_id, lineup_slot_id]
            logging.info('currently no lineup player can be moved to Bench as lineup is locked')
        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')























        









