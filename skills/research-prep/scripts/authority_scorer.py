#!/usr/bin/env python3
"""
Research material authority scorer
Evaluates the authority and reliability of research sources
"""

import sys
import argparse
import re
from urllib.parse import urlparse
from datetime import datetime, timedelta
import json

# Official domain patterns (case-insensitive)
OFFICIAL_PATTERNS = {
    'official_docs': [
        r'\.io$', r'kubernetes\.io', r'docker\.com', r'golang\.org',
        r'rust-lang\.org', r'python\.org', r'reactjs\.org', r'vuejs\.org',
        r'angular\.io', r'spring\.io', r'nginx\.org', r'apache\.org',
        r'mozilla\.org', r'w3\.org', r'ietf\.org'
    ],
    'official_repos': [
        r'github\.com/(kubernetes|docker|rust-lang|python|golang)',
        r'github\.com/(facebook|google|microsoft|apple|mozilla)',
        r'github\.com/cncf', r'gitlab\.com/(gitlab-org|gitlab-com)'
    ],
    'rfcs': [
        r'rfc-editor\.org', r'ietf\.org/rfc', r'w3\.org/TR'
    ],
    'major_tech': [
        r'cloud\.google\.com', r'aws\.amazon\.com', r'azure\.microsoft\.com',
        r'developers\.google\.com', r'developer\.mozilla\.org'
    ]
}

def score_source_authority(url):
    """Score source based on URL (0-40 points)"""
    domain = urlparse(url).netloc.lower()
    
    # Check official docs
    for pattern in OFFICIAL_PATTERNS['official_docs']:
        if re.search(pattern, domain):
            return 40
    
    # Check official repos
    for pattern in OFFICIAL_PATTERNS['official_repos']:
        if re.search(pattern, url.lower()):
            return 38
    
    # Check RFCs/standards
    for pattern in OFFICIAL_PATTERNS['rfcs']:
        if re.search(pattern, domain):
            return 40
    
    # Check major tech companies
    for pattern in OFFICIAL_PATTERNS['major_tech']:
        if re.search(pattern, domain):
            return 35
    
    # GitHub (general)
    if 'github.com' in domain and '/blob/' in url:
        return 25
    
    # Medium, Dev.to (personal blogs)
    if any(x in domain for x in ['medium.com', 'dev.to', 'hashnode']):
        return 5
    
    return 0

def score_timeliness(date_str):
    """Score content freshness (0-30 points)"""
    if not date_str:
        return 0
    
    try:
        # Try parsing different date formats
        for fmt in ['%Y-%m-%d', '%Y/%m/%d', '%b %d, %Y', '%d %b %Y']:
            try:
                content_date = datetime.strptime(date_str, fmt)
                break
            except ValueError:
                continue
        else:
            return 0
        
        age = datetime.now() - content_date
        
        if age < timedelta(days=90):  # 3 months
            return 30
        elif age < timedelta(days=180):  # 6 months
            return 25
        elif age < timedelta(days=365):  # 1 year
            return 20
        elif age < timedelta(days=730):  # 2 years
            return 10
        else:
            return 5
    except:
        return 0

def score_technical_depth(content_type):
    """Score technical depth (0-20 points)"""
    depth_scores = {
        'architecture': 20,
        'design': 20,
        'rfc': 20,
        'api-reference': 18,
        'implementation': 15,
        'source-code': 15,
        'tutorial': 10,
        'guide': 10,
        'overview': 5,
        'introduction': 5
    }
    return depth_scores.get(content_type.lower(), 10)

def score_community_recognition(stars=0, is_official=False):
    """Score community recognition (0-10 points)"""
    if is_official:
        return 10
    
    if stars > 10000:
        return 10
    elif stars > 1000:
        return 7
    elif stars > 100:
        return 5
    else:
        return 0

def calculate_total_score(url, date_str=None, content_type='guide', stars=0):
    """Calculate total authority score"""
    source_score = score_source_authority(url)
    time_score = score_timeliness(date_str)
    depth_score = score_technical_depth(content_type)
    community_score = score_community_recognition(stars, source_score >= 35)
    
    total = source_score + time_score + depth_score + community_score
    
    return {
        'total': total,
        'breakdown': {
            'source_authority': source_score,
            'timeliness': time_score,
            'technical_depth': depth_score,
            'community_recognition': community_score
        },
        'rating': get_rating(total)
    }

def get_rating(score):
    """Get star rating based on score"""
    if score >= 90:
        return '⭐⭐⭐⭐⭐'
    elif score >= 75:
        return '⭐⭐⭐⭐'
    elif score >= 60:
        return '⭐⭐⭐'
    elif score >= 40:
        return '⭐⭐'
    else:
        return '⭐'

def main():
    parser = argparse.ArgumentParser(description='Score research material authority')
    parser.add_argument('--url', help='URL to score')
    parser.add_argument('--date', help='Content date (YYYY-MM-DD)')
    parser.add_argument('--type', default='guide', 
                       choices=['architecture', 'design', 'rfc', 'api-reference', 
                               'implementation', 'source-code', 'tutorial', 
                               'guide', 'overview', 'introduction'])
    parser.add_argument('--stars', type=int, default=0, help='GitHub stars')
    parser.add_argument('--file', help='Score all URLs in a markdown file')
    parser.add_argument('--report', action='store_true', help='Generate report')
    
    args = parser.parse_args()
    
    if args.file:
        # TODO: Parse markdown file and score all URLs
        print("File scoring not yet implemented")
        return
    
    if not args.url:
        parser.print_help()
        return
    
    result = calculate_total_score(args.url, args.date, args.type, args.stars)
    
    if args.report:
        print(json.dumps(result, indent=2))
    else:
        print(f"Authority Score: {result['total']}/100")
        print(f"Rating: {result['rating']}")
        print(f"\nBreakdown:")
        for category, score in result['breakdown'].items():
            print(f"  {category}: {score}")

if __name__ == '__main__':
    main()
