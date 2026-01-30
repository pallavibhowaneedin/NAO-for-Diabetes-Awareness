import qi
import logging

# Configure logging
logging.basicConfig(level=logging.DEBUG)

# NAO robot IP address
NAO_IP = '11.0.0.126'

def test_nao_connection():
    # Create a session object
    session = qi.Session()
    
    try:
        # Attempt to connect to the NAO robot
        logging.info("Attempting to connect to NAO robot...")
        session.connect("tcp://{}:9559".format(NAO_IP))
        
        # Check if connected
        if session.isConnected():
            logging.info("Successfully connected to NAO robot.")
            print("Connected to NAO robot.")
        else:
            logging.error("Failed to connect to NAO robot.")
            print("Failed to connect to NAO robot.")
    except Exception as e:
        # Handle exceptions and log errors
        logging.error("Error while connecting to NAO robot: {}".format(e))
        print("Error while connecting to NAO robot: {}".format(e))

if __name__ == '__main__':
    test_nao_connection()
