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
            Valid_schema = MovePlayerSchema().load(response.json())

        except ValidationError as ve:
            raise Failure(f'Schema Data failed validation: {ve.messages}')
        return True

    @keyword('Invalid Move Player Schema from ${response} should be valid', tags=['schema checks', 'functional', 'CoreV3'],
             types={'response': requests.Response})
    def invalid_move_player_should_be_valid(self, response) -> bool:
        """
                    Schema for the endpoint: apis/v3/games/fba/seasons/2023/segments/0/leagues/${league_id}/transactions/

                    Expects to receive an embedded python requests object as 'response'
                    and validates the json against the FantasyLeague class.

                  Examples:
                  'Invalid Move Player Schema from ${response} should be valid
                """
        try:
           Invalid_schema = InvalidSchema().load(response.json())

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
                                                            f'$.teams[{team_id-1}].roster.entries[{players}].lineupSlotId')
                if lineup_slot_id == 12:  # Bench players line up slot id is 12
                    no_of_players_on_bench += 1
                    line_up_status = JSON().get_value_from_json(teams_response,
                                                                f'$.teams[{team_id-1}].roster.entries[{players}]'
                                                                f'.playerPoolEntry.lineupLocked')
                    if line_up_status is False:
                        player_id = JSON().get_value_from_json(teams_response,
                                                               f'$.teams[{team_id-1}].roster.entries[{players}].playerId')
                        bench_players_player_id += [player_id]
                        eligible_slots = JSON().get_value_from_json(teams_response,
                                                                    f'$.teams[{team_id-1}].roster.entries[{players}].'
                                                                    f'playerPoolEntry.player.eligibleSlots')
                        bench_player_eligible_slots += [eligible_slots]
                    else:
                        continue
            return [no_of_players_on_bench, bench_players_player_id, bench_player_eligible_slots]
        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')

    @keyword('check for ${bench_players} eligibility of team ${team_id} for moving to lineup from ${team_response}')
    def check_bench_player_eligibility_for_moving_to_lineup(self, bench_players, team_id, team_response) -> list:
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
                            lineup_slot_id = JSON().get_value_from_json(team_response, f'$.teams[{team_id-1}].roster.entries[{lineup_players}].lineupSlotId')
                            if lineup_slot_id == lineup_slot:
                                line_up_status = JSON().get_value_from_json(team_response, f'$.teams[{team_id-1}].roster.entries[{lineup_players}].playerPoolEntry.lineupLocked')
                                if line_up_status is False:
                                    line_up_player_id = JSON().get_value_from_json(team_response, f'$.teams[{team_id-1}].roster.entries[{lineup_players}].playerId')
                                    lineup_slot_id = JSON().get_value_from_json(team_response, f'$.teams[{team_id-1}].roster.entries[{lineup_players}].lineupSlotId')
                                    return [bench_player_id, line_up_player_id, lineup_slot_id]
                            else:
                                continue
                logging.info("Unable to Move Bench Players to lineup as the lineup transactions are locked")
        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')

    @keyword('Generate a random future scoring period between ${current} and ${final}')
    def generate_random_future_scoring_period(self, current, final) -> int:
        try:
            future_scoring_period = random.randint(current+1, final)
            return future_scoring_period
        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')

    @keyword('Get the Eligible players details who can swap their positions from response')
    def get_eligible_players_details_to_swap_positions(self, team_id, response) -> list:
        try:
            for line_up_player in range(0, 13):
                player1_lineup_slot_id = JSON().get_value_from_json(response, f'$.teams[{team_id-1}].roster.entries[{line_up_player}].lineupSlotId')
                if player1_lineup_slot_id == 12:
                    continue
                else:
                    line_up_status = JSON().get_value_from_json(response, f'$.teams[{team_id-1}].roster.entries[{line_up_player}].playerPoolEntry.lineupLocked')
                    if line_up_status is False:
                        eligible_slot_player1 = JSON().get_value_from_json(response,
                                                                    f'$.teams[{team_id-1}].roster.entries[{line_up_player}].'
                                                                    f'playerPoolEntry.player.eligibleSlots')
                    else:
                        continue
                for compare_line_up_player in range(0, 13):
                    if line_up_player == compare_line_up_player:
                        continue
                    player2_lineup_slot_id = JSON().get_value_from_json(response, f'$.teams[{team_id-1}].roster.entries[{compare_line_up_player}].lineupSlotId')
                    if (player2_lineup_slot_id == 12) or (player2_lineup_slot_id == player1_lineup_slot_id):
                        continue
                    else:
                        line_up_status = JSON().get_value_from_json(response,
                                                                    f'$.teams[{team_id-1}].roster.entries[{compare_line_up_player}].playerPoolEntry.lineupLocked')
                        if line_up_status is False:
                            eligible_slot_player2 = JSON().get_value_from_json(response, f'$.teams[{team_id-1}].roster.entries[{compare_line_up_player}].playerPoolEntry.player.eligibleSlots')
                            if eligible_slot_player1 == eligible_slot_player2:
                                line_up_player_player_id = JSON().get_value_from_json(response, f'$.teams[{team_id-1}].roster.entries[{line_up_player}].playerId')
                                compare_line_up_player_player_id = JSON().get_value_from_json(response, f'$.teams[{team_id-1}].roster.entries[{compare_line_up_player}].playerId')
                                line_up_player_lineup_slot_id = JSON().get_value_from_json(response, f'$.teams[{team_id-1}].roster.entries[{line_up_player}].lineupSlotId')
                                compare_line_up_player_lineup_slot_id = JSON().get_value_from_json(response, f'$.teams[{team_id-1}].roster.entries[{compare_line_up_player}].lineupSlotId')
                                return [line_up_player_player_id, compare_line_up_player_player_id, line_up_player_lineup_slot_id, compare_line_up_player_lineup_slot_id]
            logging.info('currently no lineup players can be swapped as lineup is locked')
        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')

    @keyword('Get any lineup player details of team ${team_id} from ${response}')
    def get_any_lineup_player_details(self, team_id, teams_response) -> list:
        try:
            for players in range(0, 13):
                lineup_slot_id = JSON().get_value_from_json(teams_response,
                                                            f'$.teams[{team_id - 1}].roster.entries[{players}].lineupSlotId')
                if lineup_slot_id == 12:  # Bench players line up slot id is 12
                    continue
                else:
                    line_up_status = JSON().get_value_from_json(teams_response,
                                                                f'$.teams[{team_id - 1}].roster.entries[{players}].playerPoolEntry.lineupLocked')
                    if line_up_status is False:
                        player_id = JSON().get_value_from_json(teams_response,
                                                               f'$.teams[{team_id - 1}].roster.entries[{players}].playerId')
                        lineup_slot_id = JSON().get_value_from_json(teams_response,
                                                                    f'$.teams[{team_id - 1}].roster.entries[{players}].lineupSlotId')
                        return [player_id, lineup_slot_id]
            logging.info('currently no lineup player can be moved to Bench as lineup is locked')
        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')

    @keyword('Get any different team_id from response')
    def get_any_different_team_id(self, response, league_creator_swid) -> int:
        try:
            length_of_teams = JSON().get_value_from_json(response, '$.teams')
            team_id = []
            for teams in range(0, len(length_of_teams)):
                if JSON().get_value_from_json(response,f'$.teams[{teams}].owners[{teams}]') == league_creator_swid:
                    continue
                else:
                    team = JSON().get_value_from_json(response, f'$.teams[{teams}].id')
                    team_id += [team]
            random_team_id = random.randint(0, (len(team_id)-1))
            return team_id[random_team_id]
        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')
    
    @keyword('Get any Lineup Player id along with ineligible slot of a player of team ${team_id} from the ${response}')
    def get_any_player_id_along_with_ineligible_slot(self,team_id,response) -> list or None:
        try:
            for players in range(0, 13):
                line_up_status = JSON().get_value_from_json(response, f'$.teams[{team_id - 1}].roster.entries[{players}].playerPoolEntry.lineupLocked')
                if line_up_status is False:
                    player_id = JSON().get_value_from_json(response, f'$.teams[{team_id - 1}].roster.entries[{players}].playerId')
                    default_position_id = JSON().get_value_from_json(response, f'$.teams[{team_id - 1}].roster.entries[{players}].playerPoolEntry.player.defaultPositionId')
                    player_lineup_slot_id = JSON().get_value_from_json(response, f'$.teams[{team_id - 1}].roster.entries[{players}].lineupSlotId')
                else:
                    continue
                for compare_players in range(0, 13):
                    lineup_slot_id = JSON().get_value_from_json(response, f'$.teams[{team_id - 1}].roster.entries[{compare_players}].lineupSlotId')
                    if compare_players == players or lineup_slot_id == 12:
                        continue
                    else:
                        default_position_id1 = JSON().get_value_from_json(response, f'$.teams[{team_id - 1}].roster.entries[{compare_players}].playerPoolEntry.player.defaultPositionId')
                        if default_position_id != default_position_id1:
                            lineup_slot_id = JSON().get_value_from_json(response, f'$.teams[{team_id-1}].roster.entries[{compare_players}].lineupSlotId')
                            return [player_id, player_lineup_slot_id, lineup_slot_id]
                        else:
                            continue
            return None
        except ValidationError as ve:
            raise Failure(f'Data validation failed: {ve.messages}')