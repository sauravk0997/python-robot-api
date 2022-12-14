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


class FantasyLoginManager(object):
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

    @keyword("Fantasy API Cookie")
    def fantasy_api_cookie(self, value: str = None):
        """
        # TODO: complete method documentation

        :param value: str

        :return:
        """
        if value not in (None,):
            self.cookie_combined = value
        else:
            console("***** Fetching User cookie***** ")
            self.cookie_combined = f"SWID={self.cookie_swid['value']}; espn_s2={self.cookie_espn_s2['value']};"

        return self.cookie_combined

    @keyword("Login Fantasy User")
    def login_fantasy_user(self, username="", password="", expected_profile_name_span_value="", url="https://www.espn.com/fantasy/"):
        # TODO: complete method documentation

        #variable which defines local or Sauce run
        sauce_run = "False"
        
        if sauce_run == "True": 
            options = ChromeOptions()
            options.browser_version = os.getenv('BROWSER_VERSION')
            options.platform_name = os.getenv('PLATFORM_NAME')
            sauce_options = {}
            sauce_options['build'] = os.getenv('SAUCE_BUILD')
            sauce_options['name'] = os.getenv('SAUCE_NAME')
            sauce_options['screenResolution'] = os.getenv('SAUCE_SCREEN_RESOLUTION')
            options.set_capability('sauce:options', sauce_options)
            sauce_username = os.getenv('SAUCE_USER')
            sauce_accesskey= os.getenv('SAUCE_KEY')
            sauce_url = f"https://{sauce_username}:{sauce_accesskey}@ondemand.apac-southeast-1.saucelabs.com:443/wd/hub"
            self.driver = webdriver.Remote(command_executor=sauce_url, options=options)
        else:
            self.driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()))

        self.action_chain = ActionChains(self.driver)

        try:
            xpaths= 'resource/JSON/xpaths.json'
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
            sleep(1)
            username_field = WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.XPATH, xlogin["XPATH_USER_LOGIN_MODAL_IFRAME_USERNAME_FIELD"])))
            self.action_chain.send_keys_to_element(username_field, username).perform()
            console("***** Entered username *****")

            # look for password field and fill
            password_field = WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.XPATH, xlogin["XPATH_USER_LOGIN_MODAL_IFRAME_PASSWORD_FIELD"])))
            self.action_chain.send_keys_to_element(password_field, password).perform()
            console("***** Entered password *****")

            # locate and press the login button
            login_button = self.driver.find_element(By.XPATH, xlogin["XPATH_USER_LOGIN_MODAL_IFRAME_LOGIN_BUTTON"])
            self.action_chain.click(login_button).perform()
            console("***** Click on Login Button *****")

        except Exception as e:
            console(e)
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

        sleep(5)

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

    @keyword("Browser shutdown")
    def close_browser(self):
        """Closes the current browser."""
        try:
            self.driver.close()
        except Exception as e:
            console(e)
     

def main():
    good_user = ''
    good_pass = ''
    bad_user  = 'no-reply@disney.com'
    bad_pass  = 'badpassword'
    f = FantasyLoginManager(xpaths='resource/xpaths.json')
    login_successful = f.login_fantasy_user(good_user, good_pass, "QA!", url="https://www.espn.com/fantasy/")

    if login_successful:
        print(f"{f.fantasy_api_cookie()=}")
    else:
        print('there was an issue logging in.')


if __name__ == "__main__":
    #main()
    pass
