import os
import re
import time
import json
import base64
import logging
import pause
import platform
import requests

from string import Template

from datetime import timedelta, date, datetime

from icalendar import Calendar, Event, vCalAddress, vText
from botocore.exceptions import ClientError

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service

from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from selenium.common.exceptions import TimeoutException

from seleniumbase import SB


# calcuate book date
now = datetime.now()
current_time = now.strftime("%Y-%m-%d-%H-%M-%S")


# init a logger that will be used to log in a file /tmp/app.log as well as stdout
logger = logging.getLogger()
logFormatter = logging.Formatter("%(asctime)s [%(levelname)-5.5s]  %(message)s")
fileHandler = logging.FileHandler("/tmp/app-%s.log" % current_time)
fileHandler.setFormatter(logFormatter)
logger.addHandler(fileHandler)
consoleHandler = logging.StreamHandler()
consoleHandler.setFormatter(logFormatter)
logger.addHandler(consoleHandler)
logger.setLevel(logging.INFO)


logger.info('Current time is %s' % current_time)

# default values
timeout = 5
screenshot_path = '/screenshot/'
source_path = '/source/'


def VisitSignUp(self):
    logger.info("%s | VisitSignUp" % self.get_title())

    logger.info("%s | VisitSignUp successfully" % self.get_title())


def SaveResult(self, name):
    logger.info("%s | SaveResult" % self.get_title())

    self.save_screenshot(name, folder=screenshot_path)
    self.save_page_source('%s%s' % (name, 'html'), folder=source_path)

    return '%s%s' % (screenshot_path, name)


with SB(uc=True, browser='Chrome', incognito=True) as sb:
    try:
        sb.open("https://www.living-safety.com/safe/index.php#applylist")

        # visit signup page
        VisitSignUp(sb)

        # save result
        SaveResult(sb, 'finish.png')

    except Exception as e:
        logger.error('Exception: %s' % str(e))

        # save last error screen
        SaveResult(sb, 'error.png')
