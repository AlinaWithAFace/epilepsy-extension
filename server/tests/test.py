import unittest
import http.client
import urllib.parse
import json


class TestScreen(unittest.TestCase):
    """Tests the screen-video route"""

    def make_request(self, body):
        """Takes the dictionary body and makes a POST request to /screen-video"""
        self.connection.request("POST",
                                "/screen-video",
                                headers=self.headers,
                                body=json.dumps(body))
        return self.connection.getresponse()

    def setUp(self):
        self.connection = http.client.HTTPConnection("localhost", port=5000)
        self.headers = {"Content-Type": "application/json"}

    def test_screen_good_url(self):
        """Test that we get a 201 response when the url is well formed"""

        response = self.make_request({"url":
                                      "https://www.youtube.com/watch?v=8L_9hXnUzRk"})
        self.assertEqual(response.status, 201)

    def test_bad_url(self):
        """Test that we get a 400 response when the url is incompatible"""
        response = self.make_request({"url": "https://www.wikipedia.org"})
        self.assertEqual(response.status, 400)

    def test_no_url(self):
        """Test that we get a 400 response when the url is not provided"""
        response = self.make_request({"site": "https://www.wikipedia.org"})
        self.assertEqual(response.status, 400)


if __name__ == '__main__':
    unittest.main()
