import random
from robot.api.deco import keyword, not_keyword, library
from webdriver_manager.chrome import ChromeDriverManager
from robot.libraries.BuiltIn import BuiltIn
import logging

@library(scope='GLOBAL', version='5.0.2')
class FantasyUICustomKeywords:
    @not_keyword
    def __init__(self):
        self.selLib = BuiltIn().get_library_instance("SeleniumLibrary")

    @keyword('Get the Browser Path')
    def get_driver_path(self):
        """Will add more Browser to this Method"""
        driver_path = ChromeDriverManager().install()
        return driver_path

    @keyword('get the player details')
    def get_all_player_details(self, locators) -> list:
        self.selLib.wait_until_element_is_visible(f'{locators[1]}', 15)
        eligible_slot_of_each_player = self.selLib.get_webelements(f'{locators[1]}')
        self.selLib.wait_until_element_is_visible(f'{locators[2]}', 15)
        players_name = self.selLib.get_webelements(f'{locators[2]}')
        self.selLib.wait_until_element_is_visible(f'{locators[3]}', 15)
        on_slot_prefix_of_players = self.selLib.get_webelements(f'{locators[3]}')
        player_details = []
        for element in range(len(locators[0])):
            on_slot_prefix_of_player = self.selLib.get_text(on_slot_prefix_of_players[element])
            eligible_slot_prefix_of_each_player = self.selLib.get_text(eligible_slot_of_each_player[element])
            individual_player_name = self.selLib.get_element_attribute(players_name[element], 'title')
            player_details += [[individual_player_name, [eligible_slot_prefix_of_each_player],[on_slot_prefix_of_player]]]
        return player_details

    @keyword('Get the details of the players before swapping and then swap their position')
    def get_player_details(self, player_details) -> list or None:
        for players in range(len(player_details)):
            for compare_players in range(len(player_details)):
                if players == compare_players:
                    continue
                else:
                    if player_details[players][1] == player_details[compare_players][1]:
                        button = self.selLib.get_webelements("//button[@title='MOVE']")
                        self.selLib.click_button(button[players])
                        here = self.selLib.get_webelement(f'//div[@title="{player_details[compare_players][0]}"]//following::div[6]/button')
                        status = BuiltIn().run_keyword_and_return_status('page_should_contain_element', here)
                        if status is True:
                            self.selLib.click_button(here)
                            logging.info([player_details[players], player_details[compare_players]])
                            return [player_details[players], player_details[compare_players]]
                        else:
                            continue
        return None

    @keyword('Assert whether the player swapped their Position')
    def assert_swap_position(self, before_swapping_player_details) -> bool:
        before_swapping_position_player1 = before_swapping_player_details[0][2]
        before_swapping_position_player2 = before_swapping_player_details[1][2]
        self.selLib.get_webelements("//button[@title='MOVE']")
        after_swapping_position_player1 = self.selLib.get_text(f'//div[@title="{before_swapping_player_details[0][0]}"]//preceding::div[1][contains(@class,"table--cell")]')
        after_swapping_position_player2 = self.selLib.get_text(f'//div[@title="{before_swapping_player_details[1][0]}"]//preceding::div[1][contains(@class,"table--cell")]')
        if before_swapping_position_player1 == [after_swapping_position_player2] and before_swapping_position_player2 == [after_swapping_position_player1]:
            logging.info('Players successfully swapped positions')
            return True
        else:
            logging.info('Players failed to swap positions')
            return False

    @keyword('Get random player no in range of ${player}')
    def random(self, player):
        random_number = random.randint(0, (len(player)-1))
        return random_number
