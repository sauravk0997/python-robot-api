import json
from robot.api.logger import console
from robot.api.deco import keyword, not_keyword
from selenium import webdriver
from lib.fantasyUI.FantasyLoginManager import FantasyLoginManager as FM
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

    # scopes the class to the global level so that it's only ever instantiated once during a run
    # ROBOT_LIBRARY_SCOPE = "SUITE"
    # scopes the class to the Test level so that it's instantiated once during each test case run
    ROBOT_LIBRARY_SCOPE = "TEST"

    @not_keyword
    def __init__(self):

        self.FM1 = FM()

    # @not_keyword
    # def initialise_xpath(self):
    #     # self.driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()))
    #     self.action_chain = ActionChains(self.FM1.driver)

    #     xpaths= 'resource/UI/xpaths.json'
    #     # This check allows the user to overload the init to pass a variety of content into the xpaths variable
    #     if type(xpaths) in (dict, ):
    #         # assume the dict is in the correct format and move on
    #         self.xpath_settings = xpaths

    #     elif type(xpaths) in (str, ):
    #         # we either have a file path or a json string or a malformed item
    #         if '{' in xpaths:
    #             # handle the json string
    #             self.xpath_settings = json.loads(xpaths)
    #         else:
    #             # handle the file path
    #             with open(xpaths, 'r') as f:
    #                 self.xpath_settings     = json.load(f)
    #     else:
    #         # something unexpected came through or the item was None
    #         raise ValueError("xpath data was not recognized.")

    #     if len(self.xpath_settings) == 0:
    #         raise ValueError("xpath values were not provided.")
        
    #     return self.xpath_settings

    @keyword("Login Fantasy User for drop")
    def login_user_drop(self, username="", password="", expected_profile_name_span_value="", url="https://www.espn.com/fantasy/"):
        # TODO: complete method documentation

        #variable which defines local or Sauce run

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

        # Attempt to launch the browser, maximize
        try:
            console("***** Launching Browser with URL *****")
            self.driver.get(url)
            self.driver.maximize_window()
            console("***** Maximizing window *****")
        except Exception as e:
            console(f'There was an error starting the browser.')
            console(e)
            return False

        # assign local xpath variable
        xlogin = self.xpath_settings['login']

        # OPEN PROFILE MENU
        try:
            # move to profile icon and hover
            profile_link = WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.XPATH, xlogin["XPATH_USER_PROFILE_ICON"])))
            self.action_chain.move_to_element(profile_link).perform()
            console("***** Mouse hovered on Profile icon *****")
            # once dropdown appears, move to login_link and click
            login_link = WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.XPATH, xlogin["XPATH_USER_LOGIN_LINK"])))
            self.action_chain.move_to_element(login_link).click().perform()
            console("***** Click on Log in link *****")
        except Exception as e:
            console(e)
            return False

        # MOVE TO LOGIN MODAL, FILL AND SUBMIT
        try:
            # wait for login modal to appear and switch to its iframe
            modal_wrapper = WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.XPATH, xlogin["XPATH_USER_LOGIN_MODAL_WRAPPER"])))
            self.driver.switch_to.frame(self.driver.find_element(By.XPATH, xlogin["XPATH_USER_LOGIN_MODAL_IFRAME"]))

            # wait a moment then look for username field and fill
            username_field = WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.XPATH, xlogin["XPATH_USER_LOGIN_MODAL_IFRAME_USERNAME_FIELD"])))
            self.action_chain.send_keys_to_element(username_field, username).perform()
            console("***** Entered username *****")

            # look for password field and fill
            password_field = WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.XPATH, xlogin["XPATH_USER_LOGIN_MODAL_IFRAME_PASSWORD_FIELD"])))
            self.action_chain.send_keys_to_element(password_field, password).perform()
            console("***** Entered password *****")

            # locate and press the login button
            sleep(1)
            login_button = self.driver.find_element(By.XPATH, xlogin["XPATH_USER_LOGIN_MODAL_IFRAME_LOGIN_BUTTON"])
            self.action_chain.click(login_button).perform()
            console("***** Click on Login Button *****")

        except Exception as e:
            console(e.with_traceback)
            return False

        #This code not required to run on sauce labs
        # # ATTEMPT TO LOCATE AN ERROR MESSAGE AND MOVE ON AFTER 5 SECONDS
        # try:
        #     WebDriverWait(self.driver, 5).until(EC.presence_of_element_located((By.XPATH, xlogin["XPATH_USER_LOGIN_MODAL_ERROR_DIV"])))
        #     console("An unexpected login message appeared during authentication.")
        #     return False

        # except Exception as e:
        #     # No error located, move along
        #     pass

        sleep(10)

        # REOPEN PROFILE MENU AND CONFIRM LOGGED IN
        try:
            # wait for profile link to reappear and hover over it.
            profile_link = WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.XPATH, xlogin["XPATH_USER_PROFILE_ICON"])))
            self.action_chain.move_to_element(profile_link).perform()

            # once dropdown appears, capture the User's name.
            profile_name = WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.XPATH, xlogin["XPATH_USER_PROFILE_NAME"])))
            profile_name_value = profile_name.text

            if profile_name_value == expected_profile_name_span_value:
                self.cookie_espn_s2     = self.driver.get_cookie('espn_s2')
                self.cookie_swid        = self.driver.get_cookie('SWID')
                self.fantasy_api_cookie()
            else:
                raise ValueError(f"Expected profile name span value did not match observed value.\n    expected: {expected_profile_name_span_value}\n    observed: {profile_name_value}")

        except Exception as e:
            console(e)
            return False

        # Everything ran as expected, return state
        return True

    @keyword("Click on teams button")
    def click_teams(self):
        # xpath_settings = self.initialise_xpath()
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
        xpath_settings = self.initialise_xpath()
        xlogin = xpath_settings['login']
        drop_button = self.driver.find_element(By.XPATH, xlogin["XPATH_USER_LOGIN_MODAL_IFRAME_DROP_BUTTON"])
        self.action_chain.click(drop_button).perform()
        console("***** Click on drop Button *****")


    @keyword("Click on drop player and continue")
    def click_continue(self):
        xpath_settings = self.initialise_xpath()
        xlogin = xpath_settings['login']
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
        xpath_settings = self.initialise_xpath()
        xlogin = xpath_settings['login']
        confirm_button = self.driver.find_element(By.XPATH, xlogin["XPATH_USER_LOGIN_MODAL_IFRAME_CONFIRM_BUTTON"])
        self.action_chain.click(confirm_button).perform()
        console("***** Click on confirm Button to drop the player*****")
        sleep(5)

def main():
    good_user = ''
    good_pass = ''
    # bad_user  = 'no-reply@disney.com'
    # bad_pass  = 'badpassword'
    f = FantasyDropPlayer(xpaths='resource/xpaths.json')
    login_successful = f.login_user_drop(good_user, good_pass, "QA!", url="https://www.espn.com/fantasy/")

    if login_successful:
        print(f"Success")
    else:
        print('there was an issue logging in.')



if __name__ == "__main__":
    # main()
    pass