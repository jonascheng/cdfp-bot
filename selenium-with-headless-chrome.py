import os
import logging

from datetime import datetime

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

    SaveResult(sb, 'enter-visit-signup')

    # check if element exists
    selector = 'div#applylist'
    if self.is_element_present(selector):
        logger.info("%s | VisitSignUp: #applylist present" % self.get_title())

    selector = 'div[class="td t-sign"]'
    if self.is_element_present(selector):
        logger.info("%s | VisitSignUp: t-sign present" % self.get_title())

    # click signup button
    selector = 'div[class="td t-sign"] a'
    if self.is_element_present(selector):
        logger.info("%s | VisitSignUp: t-sign link present" % self.get_title())
        self.click(selector)
        logger.info("%s | VisitSignUp: t-sign link clicked" % self.get_title())

    logger.info("%s | VisitSignUp successfully" % self.get_title())


def SaveResult(self, prefix_name):
    logger.info("%s | SaveResult %s" % (self.get_title(), prefix_name))

    png_name = '%s-%s.png' % (prefix_name, current_time)
    self.save_screenshot(png_name, folder=screenshot_path)
    src_name = '%s-%s.html' % (prefix_name, current_time)
    self.save_page_source(src_name, folder=source_path)

    return '%s%s' % (screenshot_path, png_name)


# if screenshot_path not exists, create it
if not os.path.exists(screenshot_path):
    os.makedirs(screenshot_path)

# if source_path not exists, create it
if not os.path.exists(source_path):
    os.makedirs(source_path)

with SB(browser='Chrome', incognito=True) as sb:
    try:
        sb.open("https://www.living-safety.com/safe/index.php#applylist")

        # maximize window
        sb.maximize_window()

        # visit signup page
        VisitSignUp(sb)

        # save result
        SaveResult(sb, 'finish')

    except Exception as e:
        logger.error('Exception: %s' % str(e))

        # save last error screen
        SaveResult(sb, 'error')
