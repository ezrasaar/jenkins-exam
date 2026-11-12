import os


def app_info():
    return {
        "name": "jenkins-exam",
        "environment": os.getenv("APP_ENV", "dev"),
        "version": os.getenv("APP_VERSION", "0.1.0"),
    }
