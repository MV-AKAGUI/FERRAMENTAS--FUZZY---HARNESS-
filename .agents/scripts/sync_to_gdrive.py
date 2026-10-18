#!/usr/bin/env python3
"""
Sync Local Docs to Google Drive
Purpose: Keep local /docs folder synchronized with official Drive location
Author: Claude Code
Version: 1.0
"""

import os
import json
import argparse
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, Any

# NOTE: Requires google-auth-oauthlib, google-auth-httplib2, google-api-python-client
# Install: pip install google-auth-oauthlib google-auth-httplib2 google-api-python-client

try:
    from google.auth.transport.requests import Request
    from google.oauth2.credentials import Credentials
    from google.auth.oauthlib.flow import InstalledAppFlow
    from googleapiclient.discovery import build
    from googleapiclient.http import MediaFileUpload
    GDRIVE_AVAILABLE = True
except ImportError:
    GDRIVE_AVAILABLE = False
    print("⚠️  Google Drive API not installed.")
    print("    Install: pip install google-auth-oauthlib google-auth-httplib2 google-api-python-client")


class GoogleDriveSync:
    """
    Synchronizes local documentation to Google Drive
    """

    SCOPES = ['https://www.googleapis.com/auth/drive.file']

    def __init__(self, folder_id: str, config_file: str = ".agents/config/gdrive_config.json"):
        self.folder_id = folder_id
        self.config_file = config_file
        self.service = None
        self.sync_log = []

    def authenticate(self, credentials_file: str = "credentials.json"):
        """
        Authenticate with Google Drive API
        """
        if not GDRIVE_AVAILABLE:
            print("❌ Google Drive API not available. Run: pip install google-auth-oauthlib")
            return False

        creds = None

        # Load existing token
        if os.path.exists('token.json'):
            creds = Credentials.from_authorized_user_file('token.json', self.SCOPES)

        # Get new token if needed
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                flow = InstalledAppFlow.from_client_secrets_file(
                    credentials_file, self.SCOPES)
                creds = flow.run_local_server(port=0)

            # Save token
            with open('token.json', 'w') as token:
                token.write(creds.to_json())

        self.service = build('drive', 'v3', credentials=creds)
        print("✅ Authenticated with Google Drive")
        return True

    def upload_file(self, local_path: str, drive_path: str, mime_type: str = "text/plain"):
        """
        Upload a file to Google Drive
        """
        if not self.service:
            print("❌ Not authenticated. Call authenticate() first.")
            return None

        try:
            file_metadata = {
                'name': Path(local_path).name,
                'parents': [self.folder_id]
            }

            media = MediaFileUpload(local_path, mimetype=mime_type)

            file = self.service.files().create(
                body=file_metadata,
                media_body=media,
                fields='id, webViewLink'
            ).execute()

            print(f"✅ Uploaded: {local_path} → {file.get('webViewLink')}")
            self.sync_log.append({
                'action': 'upload',
                'file': local_path,
                'drive_id': file.get('id'),
                'timestamp': datetime.now().isoformat()
            })

            return file.get('id')

        except Exception as e:
            print(f"❌ Error uploading {local_path}: {e}")
            return None

    def sync_folder(self, local_folder: str, ignore_patterns: list = None):
        """
        Recursively sync a local folder to Google Drive
        """
        if not self.service:
            print("❌ Not authenticated. Call authenticate() first.")
            return False

        if ignore_patterns is None:
            ignore_patterns = ['.git', '__pycache__', '.DS_Store', 'node_modules']

        for root, dirs, files in os.walk(local_folder):
            # Skip ignored patterns
            dirs[:] = [d for d in dirs if d not in ignore_patterns]

            for file in files:
                file_path = os.path.join(root, file)
                relative_path = os.path.relpath(file_path, local_folder)

                # Determine MIME type
                if file.endswith('.md'):
                    mime_type = "text/markdown"
                elif file.endswith('.pdf'):
                    mime_type = "application/pdf"
                elif file.endswith('.json'):
                    mime_type = "application/json"
                else:
                    mime_type = "application/octet-stream"

                print(f"Syncing: {relative_path}")
                self.upload_file(file_path, relative_path, mime_type)

        return True

    def save_sync_log(self):
        """
        Save sync log to file
        """
        log_file = ".agents/logs/gdrive_sync.json"
        os.makedirs(os.path.dirname(log_file), exist_ok=True)

        with open(log_file, 'w') as f:
            json.dump({
                'timestamp': datetime.now().isoformat(),
                'folder_id': self.folder_id,
                'sync_count': len(self.sync_log),
                'logs': self.sync_log
            }, f, indent=2)

        print(f"✅ Sync log saved: {log_file}")


def main():
    parser = argparse.ArgumentParser(description="Sync local docs to Google Drive")
    parser.add_argument("--folder_id", required=True, help="Google Drive folder ID")
    parser.add_argument("--source", default="./docs", help="Local source folder")
    parser.add_argument("--destination", default="SDD", help="Drive destination subfolder")
    parser.add_argument("--mode", default="sync_docs_only", help="Sync mode")
    parser.add_argument("--credentials", default="credentials.json", help="Google credentials file")

    args = parser.parse_args()

    print("🔄 Starting Google Drive Sync...")
    print(f"   Folder ID: {args.folder_id}")
    print(f"   Source: {args.source}")
    print(f"   Destination: {args.destination}")

    # Initialize sync
    sync = GoogleDriveSync(args.folder_id)

    # Authenticate
    if not sync.authenticate(args.credentials):
        print("❌ Authentication failed")
        return 1

    # Sync folder
    if not sync.sync_folder(args.source):
        print("❌ Sync failed")
        return 1

    # Save log
    sync.save_sync_log()

    print("\n✅ Sync Complete")
    return 0


if __name__ == "__main__":
    exit(main())
