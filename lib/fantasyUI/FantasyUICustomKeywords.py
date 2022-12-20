from robot.api.deco import keyword, not_keyword, library
from webdriver_manager.chrome import ChromeDriverManager
import logging


@library(scope='GLOBAL', version='5.0.2')
class FantasyUICustomKeywords:
    @not_keyword
    def __init__(self):
        pass

    @keyword('Get the Browser Path')
    def get_river_path(self):
        """Will add more Browser to this Method"""
        driver_path = ChromeDriverManager().install()
        return driver_path