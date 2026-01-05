import boto3
import json
import random
import time
from datetime import datetime
from faker import Faker

# --- CONFIGURATION ---
# UPDATE THIS TO MATCH YOUR TERRAFORM OUTPUT
BUCKET_NAME = "datamesh-demo-v1-finance-raw" 
AWS_REGION = "ap-southeast-1"

fake = Faker()

def generate_transaction():
    """Generates a purchase event attributed to a campaign."""
    # Must match campaigns used in Marketing Generator for the join to work
    campaigns = ['SUMMER_SALE', 'BLACK_FRIDAY', 'NEW_USER_PROMO', 'RETARGETING_Q1']
    
    event = {
        "transaction_id": fake.uuid4(),
        "transaction_at": datetime.utcnow().isoformat(),
        "campaign_id": random.choice(campaigns), # The join key
        "user_id": fake.uuid4(),
        "amount": round(random.uniform(20.00, 500.00), 2),
        "currency": "USD"
    }
    return event

def upload_to_s3(events):
    s3 = boto3.client('s3', region_name=AWS_REGION)
    file_name = f"transactions_{int(time.time())}.json"
    body = "\n".join([json.dumps(e) for e in events])
    
    try:
        s3.put_object(Bucket=BUCKET_NAME, Key=file_name, Body=body)
        print(f"💰 Uploaded {file_name} with {len(events)} transactions")
    except Exception as e:
        print(f"❌ Error: {e}")

def main():
    print("🚀 Starting Finance Transaction Generator...")
    try:
        while True:
            batch_size = random.randint(5, 20) # Fewer transactions than clicks
            events = [generate_transaction() for _ in range(batch_size)]
            upload_to_s3(events)
            time.sleep(10) # Slower velocity than clicks
    except KeyboardInterrupt:
        print("\n🛑 Stopped.")

if __name__ == "__main__":
    main()