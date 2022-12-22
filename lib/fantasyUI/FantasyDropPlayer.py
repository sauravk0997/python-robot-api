import json
from robot.api.logger import console
from robot.api.deco import keyword, not_keyword
from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
from selenium.common.exceptions import *
from time import sleep
from selenium.webdriver.chrome.options import Options as ChromeOptions
import os
from dotenv import load_dotenv

class FantasyDropPlayer(object):
    """
    TODO: add class documentation.
    """
    __slots__ = [
        "xpath_settings",
        "cookie_espn_s2",
        "cookie_swid",
        "cookie_combined",
        "driver",
        "action_chain",
        "verbose"
    ]

    # scopes the class to the global level so that it's only ever instantiated once during a run
    # ROBOT_LIBRARY_SCOPE = "SUITE"
    # scopes the class to the Test level so that it's instantiated once during each test case run
    ROBOT_LIBRARY_SCOPE = "TEST"

    @not_keyword
    def __init__(self,
                 cookie_espn_s2=None,
                 cookie_swid=None,
                 cookie_combined=None,
                 verbose=False):

        self.cookie_espn_s2     = cookie_espn_s2
        self.cookie_swid        = cookie_swid
        self.cookie_combined    = cookie_combined
        self.verbose            = verbose
        self.driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()))
        self.action_chain = ActionChains(self.driver)
        try:
            xpaths= 'resource/UI/xpaths.json'
        # This check allows the user to overload the init to pass a variety of content into the xpaths variable
            if type(xpaths) in (dict, ):
                # assume the dict is in the correct format and move on
                self.xpath_settings = xpaths

            elif type(xpaths) in (str, ):
                # we either have a file path or a json string or a malformed item
                if '{' in xpaths:
                    # handle the json string
                    self.xpath_settings = json.loads(xpaths)
                else:
                    # handle the file path
                    with open(xpaths, 'r') as f:
                        self.xpath_settings     = json.load(f)

            else:
                # something unexpected came through or the item was None
                raise ValueError("xpath data was not recognized.")

        except Exception as e:
            console(f"Error encountered loading xpath: \n{e}")

        if len(self.xpath_settings) == 0:
            raise ValueError("xpath values were not provided.")
        


    @not_keyword
    def info(self, m: str) -> None:
        """
        Internal logging method for when items should only hit the console when self.verbose is True.

        :param m:
            Text

        :return:
            None
        """
        if self.verbose:
            console(m)

    @keyword("Click on teams")
    def login_fantasy_user(self):

        xlogin = self.xpath_settings['login']
        profile_link = WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.XPATH, xlogin["XPATH_USER_PROFILE_ICON"])))
        self.action_chain.move_to_element(profile_link).perform()
        console("***** Mouse hovered on Profile icon for team selection*****")

        teams_button = self.driver.find_element(By.XPATH, xlogin["XPATH_USER_LOGIN_MODAL_IFRAME_TEAMS_BUTTON"])
        self.action_chain.click(teams_button).perform()
        console("***** Click on teams Button *****")

        sleep(5)

    @keyword("Click on drop button")
    def click_drop(self):
        drop_button = self.driver.find_element(By.XPATH, xlogin["XPATH_USER_LOGIN_MODAL_IFRAME_DROP_BUTTON"])
        self.action_chain.click(drop_button).perform()
        console("***** Click on drop Button *****")


    @keyword("Click on drop player and continue")
    def click_continue(self):
        self.driver.execute_script("document.body.style.transform='scale(0.9)';")
        sleep(5)
        drop_player_button = self.driver.find_element(By.XPATH, xlogin["XPATH_USER_LOGIN_MODAL_IFRAME_DROP_PLAYER_BUTTON"])
        self.action_chain.click(drop_player_button).perform()
        console("***** Click on drop PLAYER Button *****")
        continue_button = self.driver.find_element(By.XPATH, xlogin["XPATH_USER_LOGIN_MODAL_IFRAME_CONTINUE_BUTTON"])
        self.action_chain.click(continue_button).perform()
        console("***** Click on continue Button *****")
        sleep(5)
  
    @keyword("Click on confirm drop")
    def click_confirm(self):
        confirm_button = self.driver.find_element(By.XPATH, xlogin["XPATH_USER_LOGIN_MODAL_IFRAME_CONFIRM_BUTTON"])
        self.action_chain.click(confirm_button).perform()
        console("***** Click on confirm Button to drop the player*****")
        sleep(5)
    