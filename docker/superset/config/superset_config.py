'''≈
import os

from flask_appbuilder.security.manager import AUTH_DB

# Superset specific config
ROW_LIMIT = 5000
SUPERSET_WEBSERVER_PORT = 8088

# Flask App Builder configuration
SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY", "superset-secret")

# The SQLAlchemy connection string to your database backend
SQLALCHEMY_DATABASE_URI = "sqlite:////app/superset_home/superset.db"

# Flask-WTF flag for CSRF
WTF_CSRF_ENABLED = True
# Add endpoints that need to be exempt from CSRF protection
WTF_CSRF_EXEMPT_LIST = []
# A CSRF token that expires in 1 year
WTF_CSRF_TIME_LIMIT = 60 * 60 * 24 * 365

# Set this API key to enable Mapbox visualizations
MAPBOX_API_KEY = ""

# Trino connection parameters
TRINO_HOST = "trino"
TRINO_PORT = 8080
TRINO_USER = "admin"
TRINO_CATALOG_HIVE = "hive"
TRINO_CATALOG_DELTA = "delta"
TRINO_SCHEMA = "default"

# Add Trino to the database connection parameters
SQLALCHEMY_CUSTOM_PASSWORD_STORE = {}

# Setup the DB connection for Trino
from superset.db_engine_specs.trino import TrinoEngineSpec
from sqlalchemy.engine.url import make_url

def get_trino_uri(catalog):
    return f"trino://{TRINO_USER}@{TRINO_HOST}:{TRINO_PORT}/{catalog}/{TRINO_SCHEMA}"

# Add default Trino connection
SQLALCHEMY_EXAMPLES_URI = get_trino_uri(TRINO_CATALOG_HIVE)

# Add Delta Lake as an additional database
ADDITIONAL_DATABASE_URIS = {
    "trino-delta": get_trino_uri(TRINO_CATALOG_DELTA)
}

# Enable feature flags
FEATURE_FLAGS = {
    "ALERT_REPORTS": True,
    "DASHBOARD_NATIVE_FILTERS": True,
    "DASHBOARD_CROSS_FILTERS": True,
    "DASHBOARD_NATIVE_FILTERS_SET": True,
    "ENABLE_TEMPLATE_PROCESSING": True,
}

# Cache configuration
CACHE_CONFIG = {
    'CACHE_TYPE': 'redis',
    'CACHE_DEFAULT_TIMEOUT': 300,
    'CACHE_KEY_PREFIX': 'superset_',
    'CACHE_REDIS_HOST': 'redis',
    'CACHE_REDIS_PORT': 6379,
    'CACHE_REDIS_DB': 1,
    'CACHE_REDIS_URL': 'redis://redis:6379/1'
}

# Celery configuration
CELERY_CONFIG = {
    'BROKER_URL': 'redis://redis:6379/0',
    'CELERY_IMPORTS': ('superset.sql_lab', ),
    'CELERY_RESULT_BACKEND': 'redis://redis:6379/0',
    'CELERYD_LOG_LEVEL': 'DEBUG',
    'CELERYD_PREFETCH_MULTIPLIER': 10,
    'CELERY_ACKS_LATE': True,
    'CELERY_ANNOTATIONS': {
        'sql_lab.get_sql_results': {
            'rate_limit': '100/s',
        },
    },
    'CELERYBEAT_SCHEDULE': {
        'reports.scheduler': {
            'task': 'reports.scheduler',
            'schedule': 5,
        },
    },
}

# Additional configurations
RESULTS_BACKEND = CELERY_CONFIG['CELERY_RESULT_BACKEND']
'''

import os

# Basic Superset configuration
SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY", "your-secret-key-here")
SQLALCHEMY_DATABASE_URI = "sqlite:////app/superset_home/superset.db"

# Default row limit for SQL Lab queries
ROW_LIMIT = 5000

# Enable some useful features
FEATURE_FLAGS = {
    "DASHBOARD_NATIVE_FILTERS": True,
    "DASHBOARD_CROSS_FILTERS": True
}

# Allow for larger file uploads if needed
UPLOAD_FOLDER = "/app/superset_home/uploads/"
UPLOAD_MAX_LENGTH = 100000000