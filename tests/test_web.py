import unittest
from unittest.mock import patch
from app.web import app


class WebTests(unittest.TestCase):
    def test_health(self):
        client = app.test_client()
        response = client.get("/health")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json(), {"status": "ok"})

    def test_app_info(self):
        with patch.dict("os.environ", {"APP_ENV": "ci", "APP_VERSION": "2.0.0"}):
            response = app.test_client().get("/")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json(), {
            "name": "jenkins-exam",
            "environment": "ci",
            "version": "2.0.0",
        })
