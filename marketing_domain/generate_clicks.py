import boto3
import json
import random
import time
from datetime import datetime
from faker import Faker

# --- CONFIGURATION ---
# UPDATE THESE TO MATCH YOUR TERRAFORM OUTPUTS
BUCKET_NAME = "datamesh-demo-v1-marketing-raw" # Ensure this matches your actual bucket name
AWS_REGION = "ap-southeast-1"

fake = Faker()

def generate_click_event():
    """Generates a single ad click JSON event."""
    campaigns = ['SUMMER_SALE', 'BLACK_FRIDAY', 'NEW_USER_PROMO', 'RETARGETING_Q1']
    platforms = ['iOS', 'Android', 'Web']
    
    event = {
        "event_id": fake.uuid4(),
        "event_timestamp": datetime.utcnow().isoformat(),
        "campaign_id": random.choice(campaigns),
        "user_id": fake.uuid4(),
        "device_type": random.choice(platforms),
        "cost_per_click": round(random.uniform(0.50, 5.00), 2),
        "is_bot_traffic": random.choice([True] + [False]*9) # 10% chance of bot traffic
    }
    return event

def upload_to_s3(events):
    """Uploads a batch of events as a JSON file to S3."""
    s3 = boto3.client('s3', region_name=AWS_REGION)
    
    # Create a unique filename based on time
    file_name = f"clicks_{int(time.time())}.json"
    
    # Convert list of dicts to a newline-delimited JSON string (NDJSON)
    body = "\n".join([json.dumps(e) for e in events])
    
    try:
        s3.put_object(Bucket=BUCKET_NAME, Key=file_name, Body=body)
        print(f"✅ Uploaded {file_name} with {len(events)} events to {BUCKET_NAME}")
    except Exception as e:
        print(f"❌ Error uploading to S3: {e}")

def main():
    print("🚀 Starting Marketing Data Generator...")
    print("Press CTRL+C to stop.")
    
    try:
        while True:
            # Generate a batch of 10-50 random events
            batch_size = random.randint(10, 50)
            events = [generate_click_event() for _ in range(batch_size)]
            
            upload_to_s3(events)
            
            # Sleep for a few seconds to simulate real-time traffic
            time.sleep(5) 
            
    except KeyboardInterrupt:
        print("\n🛑 Generator stopped.")

if __name__ == "__main__":
    main()