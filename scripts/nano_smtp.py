#!/usr/bin/env python3
"""
NANO SMTP Transport — Email-based messaging
Delta Chat compatible transport layer for NANO Dark Messenger.
"""

import smtplib
import imaplib
import email
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import base64
import time
from typing import List, Optional, Tuple
from dataclasses import dataclass
from pathlib import Path

# Import crypto from proto_encrypt
import sys
sys.path.insert(0, str(Path(__file__).parent))
from proto_encrypt import encrypt_message, decrypt_message


@dataclass
class NANOEmail:
    """Encrypted email message"""
    from_addr: str
    to_addr: str
    subject: str
    encrypted_body: str
    timestamp: float
    message_id: str
    
    def decrypt(self, password: str) -> str:
        """Decrypt message body"""
        return decrypt_message(self.encrypted_body, password)


class NANOTransport:
    """SMTP/IMAP transport for NANO Dark Messenger"""
    
    def __init__(
        self,
        email: str,
        password: str,
        smtp_server: str,
        smtp_port: int = 587,
        imap_server: str = None,
        imap_port: int = 993
    ):
        self.email = email
        self.password = password
        self.smtp_server = smtp_server
        self.smtp_port = smtp_port
        self.imap_server = imap_server or smtp_server.replace("smtp", "imap")
        self.imap_port = imap_port
        
    def send_message(
        self,
        to: str,
        message: str,
        password: str,
        subject: str = None
    ) -> bool:
        """Send encrypted message via SMTP"""
        
        # Encrypt message
        encrypted = encrypt_message(message, password)
        
        # Create email
        msg = MIMEMultipart()
        msg['From'] = self.email
        msg['To'] = to
        msg['Subject'] = subject or f"NANO:encrypted {int(time.time())}"
        
        # Add encrypted body
        msg.attach(MIMEText(encrypted, 'plain'))
        
        # Add NANO header for easy filtering
        msg['X-NANO-Protocol'] = 'v1'
        msg['X-NANO-Encrypted'] = 'true'
        
        try:
            # Connect and send
            server = smtplib.SMTP(self.smtp_server, self.smtp_port)
            server.starttls()
            server.login(self.email, self.password)
            server.send_message(msg)
            server.quit()
            
            print(f"✅ Message sent to {to}")
            return True
            
        except Exception as e:
            print(f"❌ Failed to send: {e}")
            return False
    
    def fetch_messages(self, limit: int = 10) -> List[NANOEmail]:
        """Fetch encrypted messages from IMAP"""
        
        messages = []
        
        try:
            # Connect to IMAP
            mail = imaplib.IMAP4_SSL(self.imap_server, self.imap_port)
            mail.login(self.email, self.password)
            mail.select('inbox')
            
            # Search for NANO messages
            status, data = mail.search(None, '(HEADER "X-NANO-Protocol" "v1")')
            
            if status != 'OK':
                print("❌ No NANO messages found")
                return messages
            
            # Get last N messages
            msg_ids = data[0].split()[-limit:]
            
            for msg_id in reversed(msg_ids):
                status, msg_data = mail.fetch(msg_id, '(RFC822)')
                
                if status != 'OK':
                    continue
                
                raw_email = msg_data[0][1]
                email_msg = email.message_from_bytes(raw_email)
                
                # Extract encrypted body
                encrypted_body = self._extract_body(email_msg)
                if encrypted_body:
                    nano_email = NANOEmail(
                        from_addr=email_msg['from'],
                        to_addr=email_msg['to'],
                        subject=email_msg['subject'],
                        encrypted_body=encrypted_body,
                        timestamp=time.time(),
                        message_id=str(msg_id, 'utf-8')
                    )
                    messages.append(nano_email)
            
            mail.logout()
            
        except Exception as e:
            print(f"❌ Failed to fetch messages: {e}")
        
        return messages
    
    def _extract_body(self, email_msg) -> Optional[str]:
        """Extract plain text body from email"""
        
        if email_msg.is_multipart():
            for part in email_msg.walk():
                content_type = part.get_content_type()
                content_disposition = str(part.get("Content-Disposition"))
                
                # Skip attachments
                if "attachment" in content_disposition:
                    continue
                
                if content_type == "text/plain":
                    try:
                        charset = part.get_content_charset() or 'utf-8'
                        return part.get_payload(decode=True).decode(charset)
                    except:
                        pass
        else:
            try:
                charset = email_msg.get_content_charset() or 'utf-8'
                return email_msg.get_payload(decode=True).decode(charset)
            except:
                pass
        
        return None
    
    def test_connection(self) -> bool:
        """Test SMTP and IMAP connections"""
        
        print(f"📧 Testing connection for {self.email}...")
        
        # Test SMTP
        try:
            smtp = smtplib.SMTP(self.smtp_server, self.smtp_port)
            smtp.starttls()
            smtp.login(self.email, self.password)
            smtp.quit()
            print("✅ SMTP OK")
        except Exception as e:
            print(f"❌ SMTP failed: {e}")
            return False
        
        # Test IMAP
        try:
            imap = imaplib.IMAP4_SSL(self.imap_server, self.imap_port)
            imap.login(self.email, self.password)
            imap.logout()
            print("✅ IMAP OK")
        except Exception as e:
            print(f"❌ IMAP failed: {e}")
            return False
        
        return True


def main():
    """CLI for testing SMTP transport"""
    import argparse
    
    parser = argparse.ArgumentParser(description="NANO SMTP Transport CLI")
    parser.add_argument('--email', required=True, help='Your email')
    parser.add_argument('--password', required=True, help='App password')
    parser.add_argument('--smtp', required=True, help='SMTP server')
    parser.add_argument('--to', help='Recipient email')
    parser.add_argument('--message', '-m', help='Message to send')
    parser.add_argument('--secret', '-s', help='Shared secret password')
    parser.add_argument('--fetch', action='store_true', help='Fetch messages')
    parser.add_argument('--test', action='store_true', help='Test connection')
    
    args = parser.parse_args()
    
    transport = NANOTransport(
        email=args.email,
        password=args.password,
        smtp_server=args.smtp
    )
    
    if args.test:
        transport.test_connection()
    
    elif args.fetch:
        print("📥 Fetching messages...")
        messages = transport.fetch_messages()
        for msg in messages:
            print(f"\n📨 From: {msg.from_addr}")
            print(f"   Subject: {msg.subject}")
            if args.secret:
                decrypted = msg.decrypt(args.secret)
                print(f"   Decrypted: {decrypted}")
            else:
                print(f"   Encrypted: {msg.encrypted_body[:100]}...")
    
    elif args.to and args.message and args.secret:
        print(f"📤 Sending to {args.to}...")
        transport.send_message(
            to=args.to,
            message=args.message,
            password=args.secret
        )
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
