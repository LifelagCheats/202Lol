# -*- coding: utf-8 -*-
import unittest
from unittest.mock import patch, MagicMock
import sys
import os
from halo import Halo
import requests

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from main import WebRequestHandler


class TestWebsiteChecker(unittest.TestCase):

    def setUp(self):
        """Set up the WebRequestHandler instance once per test."""
        self.checker = WebRequestHandler()

    @patch('builtins.input', return_value='https://httpbin.org/get')
    @patch('requests.get')
    def test_checker_success(self, mock_get, mock_input):
        spinner = Halo(spinner='dots')
        spinner.start('Testing website checker... ')

        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_get.return_value = mock_response

        try:
            result = self.checker.check_website()
            self.assertTrue(result)
            spinner.succeed('Found no errors')

        except Exception as e:
            spinner.fail(f'Found error while testing: {str(e)}')

    @patch('builtins.input', return_value='https://nonexistentwebsite.com.org.net')
    @patch('requests.get', side_effect=requests.exceptions.ConnectionError)
    def test_checker_failure(self, mock_get, mock_input):
        spinner = Halo(spinner='dots')
        spinner.start('Testing website checker...')

        try:
            result = self.checker.check_website()
            self.assertFalse(result)
            spinner.succeed('Found no errors')

        except Exception as e:
            spinner.fail(f'Found error while testing: {str(e)}')


if __name__ == '__main__':
    unittest.main()
