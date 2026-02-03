#!/usr/bin/env python3
"""
Update research materials by checking links and finding updated versions
"""

import sys
import argparse
import re
import requests
from urllib.parse import urlparse
from datetime import datetime

def check_link_validity(url, timeout=5):
    """Check if a URL is still accessible"""
    try:
        response = requests.head(url, timeout=timeout, allow_redirects=True)
        return {
            'valid': response.status_code < 400,
            'status_code': response.status_code,
            'final_url': response.url if response.url != url else None
        }
    except requests.RequestException as e:
        return {
            'valid': False,
            'status_code': None,
            'error': str(e)
        }

def extract_urls_from_markdown(file_path):
    """Extract all URLs from a markdown file"""
    urls = []
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        # Match markdown links [text](url)
        pattern = r'\[([^\]]+)\]\(([^)]+)\)'
        matches = re.findall(pattern, content)
        for text, url in matches:
            urls.append({
                'text': text,
                'url': url,
                'line': content[:content.find(url)].count('\n') + 1
            })
    return urls

def check_research_file(file_path, fix=False):
    """Check all links in a research file"""
    print(f"Checking links in: {file_path}\n")
    
    urls = extract_urls_from_markdown(file_path)
    results = {
        'total': len(urls),
        'valid': 0,
        'invalid': 0,
        'redirected': 0,
        'issues': []
    }
    
    for item in urls:
        url = item['url']
        # Skip relative links and anchors
        if url.startswith('#') or url.startswith('/'):
            continue
        
        print(f"Checking: {url[:60]}...", end=' ')
        result = check_link_validity(url)
        
        if result['valid']:
            print("✓")
            results['valid'] += 1
            if result.get('final_url'):
                print(f"  → Redirected to: {result['final_url']}")
                results['redirected'] += 1
                results['issues'].append({
                    'type': 'redirect',
                    'line': item['line'],
                    'old_url': url,
                    'new_url': result['final_url']
                })
        else:
            print(f"✗ ({result.get('status_code', 'Error')})")
            results['invalid'] += 1
            results['issues'].append({
                'type': 'broken',
                'line': item['line'],
                'url': url,
                'error': result.get('error', f"HTTP {result['status_code']}")
            })
    
    # Print summary
    print(f"\n{'='*60}")
    print(f"Summary:")
    print(f"  Total links: {results['total']}")
    print(f"  Valid: {results['valid']} ✓")
    print(f"  Invalid: {results['invalid']} ✗")
    print(f"  Redirected: {results['redirected']} →")
    
    if results['issues']:
        print(f"\nIssues found:")
        for issue in results['issues']:
            if issue['type'] == 'broken':
                print(f"  Line {issue['line']}: BROKEN - {issue['url']}")
                print(f"    Error: {issue['error']}")
            elif issue['type'] == 'redirect':
                print(f"  Line {issue['line']}: REDIRECT")
                print(f"    Old: {issue['old_url']}")
                print(f"    New: {issue['new_url']}")
    
    return results

def main():
    parser = argparse.ArgumentParser(description='Update and validate research materials')
    parser.add_argument('file', help='Research markdown file to check')
    parser.add_argument('--fix', action='store_true', help='Auto-fix broken links (not implemented)')
    parser.add_argument('--timeout', type=int, default=5, help='Request timeout in seconds')
    
    args = parser.parse_args()
    
    try:
        results = check_research_file(args.file, args.fix)
        sys.exit(0 if results['invalid'] == 0 else 1)
    except FileNotFoundError:
        print(f"Error: File not found: {args.file}")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
