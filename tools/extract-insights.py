#!/usr/bin/env python3
"""
Extract insights from Claude Code log files

Searches JSONL log files for "★ Insight " markers and extracts the insight content.
Used by the /aggregate-insights command.

Usage:
    python3 extract-insights.py [options]

Options:
    --path PATH          Directory to search (default: ~/.claude/projects)
    --recent-days DAYS   Only include insights from last N days
    --category CAT       Filter by category (parallel, architecture, security, etc.)
    --output FORMAT      Output format: json, markdown, or summary (default: summary)
    --min-length N       Minimum insight length in characters (default: 50)
    --since-last         Only process insights since last aggregation
    --update-timestamp   Update last aggregation timestamp after processing
    --force-all          Process all insights, ignoring last timestamp
"""

import os
import re
import json
import argparse
from datetime import datetime, timedelta
from collections import defaultdict
from pathlib import Path


class InsightExtractor:
    """Extracts and categorizes insights from Claude Code log files"""

    CATEGORIES = {
        'parallel': ['parallel', 'concurrent', 'orchestration', 'multi-agent', 'simultaneous'],
        'architecture': ['architecture', 'design', 'pattern', 'hexagonal', 'clean', 'separation'],
        'performance': ['performance', 'optimization', 'speed', 'efficiency', 'resource', 'memory'],
        'security': ['security', 'vulnerability', 'auth', 'sanitize', 'validation', 'xss', 'injection'],
        'review': ['review', 'quality', 'maintainability', 'readability', 'code smell'],
        'testing': ['test', 'coverage', 'e2e', 'unit', 'integration', 'mock'],
        'tools': ['agent', 'tool', 'command', 'workflow', 'automation'],
        'errors': ['error', 'exception', 'failure', 'resilience', 'handling'],
    }

    TIMESTAMP_FILE = os.path.expanduser('~/.claude/.insight-aggregation-timestamp')

    def __init__(self, base_path=None, min_length=50, since_last=False, force_all=False):
        self.base_path = base_path or os.path.expanduser('~/.claude/projects')
        self.min_length = min_length
        self.insights = []
        self.stats = defaultdict(int)
        self.since_last = since_last
        self.force_all = force_all
        self.last_timestamp = None if force_all else self._read_last_timestamp()

    def _read_last_timestamp(self):
        """Read the timestamp of last aggregation"""
        try:
            if os.path.exists(self.TIMESTAMP_FILE):
                with open(self.TIMESTAMP_FILE, 'r') as f:
                    data = json.load(f)
                    return data.get('last_aggregation', None)
        except Exception:
            pass
        return None

    def _write_timestamp(self):
        """Write the current timestamp as last aggregation time"""
        try:
            timestamp = datetime.now().timestamp()
            with open(self.TIMESTAMP_FILE, 'w') as f:
                json.dump({
                    'last_aggregation': timestamp,
                    'last_aggregation_date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                    'insights_processed': len(self.insights)
                }, f, indent=2)
            return True
        except Exception as e:
            print(f"Warning: Could not write timestamp file: {e}")
            return False

    def update_timestamp(self):
        """Public method to update timestamp after successful aggregation"""
        return self._write_timestamp()

    def scan_files(self, recent_days=None):
        """Scan all JSONL files for insights"""
        cutoff_date = None

        # Determine cutoff date
        if recent_days:
            cutoff_date = datetime.now() - timedelta(days=recent_days)
        elif self.since_last and self.last_timestamp:
            cutoff_date = datetime.fromtimestamp(self.last_timestamp)

        # Track cutoff info for stats
        if cutoff_date:
            self.stats['cutoff_date'] = cutoff_date.strftime('%Y-%m-%d %H:%M:%S')

        for root, dirs, files in os.walk(self.base_path):
            for file in files:
                if file.endswith('.jsonl'):
                    filepath = os.path.join(root, file)

                    # Check file modification time
                    if cutoff_date:
                        mtime = datetime.fromtimestamp(os.path.getmtime(filepath))
                        if mtime < cutoff_date:
                            self.stats['files_skipped_old'] += 1
                            continue

                    self.stats['files_scanned'] += 1
                    self._extract_from_file(filepath)

    def _extract_from_file(self, filepath):
        """Extract insights from a single file"""
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()

                # Find all occurrences of "★ Insight" with context
                pattern = r'★ Insight\s+─+\\n(.+?)(?=\\n\\n##|\\n\\n\*\*Next|\\n\\n─{10,}|\\n\\n✅|\\n\\n\*\*│|$)'
                matches = re.finditer(pattern, content, re.DOTALL)

                for match in matches:
                    insight_text = match.group(1).strip()

                    # Clean up escape sequences
                    insight_text = insight_text.replace('\\n', '\n')
                    insight_text = insight_text.replace('\\"', '"')
                    insight_text = insight_text.replace('\\t', '\t')
                    insight_text = re.sub(r'\n{3,}', '\n\n', insight_text)

                    # Filter out noise
                    if len(insight_text) < self.min_length:
                        self.stats['filtered_too_short'] += 1
                        continue

                    # Don't include if it's just repeated markers
                    if insight_text.startswith('★ Insight'):
                        self.stats['filtered_malformed'] += 1
                        continue

                    # Create insight object
                    insight = {
                        'file': os.path.basename(filepath),
                        'filepath': filepath,
                        'text': insight_text,
                        'timestamp': os.path.getmtime(filepath),
                        'date': datetime.fromtimestamp(os.path.getmtime(filepath)).strftime('%Y-%m-%d'),
                        'length': len(insight_text),
                        'categories': self._categorize(insight_text)
                    }

                    self.insights.append(insight)
                    self.stats['insights_found'] += 1

        except Exception as e:
            self.stats['errors'] += 1
            # Continue processing other files

    def _categorize(self, text):
        """Categorize insight based on content keywords"""
        text_lower = text.lower()
        categories = []

        for category, keywords in self.CATEGORIES.items():
            if any(keyword in text_lower for keyword in keywords):
                categories.append(category)

        return categories if categories else ['general']

    def filter_by_category(self, category):
        """Filter insights by category"""
        return [i for i in self.insights if category in i['categories']]

    def remove_duplicates(self):
        """Remove duplicate insights based on text similarity"""
        unique_insights = []
        seen_texts = set()

        for insight in self.insights:
            # Use first 200 chars as similarity hash
            text_hash = insight['text'][:200]

            if text_hash not in seen_texts:
                seen_texts.add(text_hash)
                unique_insights.append(insight)
            else:
                self.stats['duplicates_removed'] += 1

        self.insights = unique_insights

    def get_summary(self):
        """Generate summary statistics"""
        category_counts = defaultdict(int)

        for insight in self.insights:
            for category in insight['categories']:
                category_counts[category] += 1

        summary = {
            'files_scanned': self.stats['files_scanned'],
            'files_skipped_old': self.stats.get('files_skipped_old', 0),
            'insights_found': self.stats['insights_found'],
            'unique_insights': len(self.insights),
            'duplicates_removed': self.stats['duplicates_removed'],
            'filtered_too_short': self.stats['filtered_too_short'],
            'filtered_malformed': self.stats['filtered_malformed'],
            'errors': self.stats['errors'],
            'category_counts': dict(category_counts),
            'date_range': self._get_date_range()
        }

        # Add timestamp info if using since_last mode
        if self.last_timestamp:
            summary['last_aggregation'] = datetime.fromtimestamp(self.last_timestamp).strftime('%Y-%m-%d %H:%M:%S')
            summary['cutoff_date'] = self.stats.get('cutoff_date', 'N/A')

        return summary

    def _get_date_range(self):
        """Get date range of insights"""
        if not self.insights:
            return None

        dates = [i['timestamp'] for i in self.insights]
        return {
            'oldest': datetime.fromtimestamp(min(dates)).strftime('%Y-%m-%d'),
            'newest': datetime.fromtimestamp(max(dates)).strftime('%Y-%m-%d')
        }

    def output_json(self):
        """Output insights as JSON"""
        return json.dumps({
            'summary': self.get_summary(),
            'insights': self.insights
        }, indent=2)

    def output_markdown(self):
        """Output insights as formatted markdown"""
        summary = self.get_summary()

        md = f"""# Insight Extraction Report

**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**Files Scanned:** {summary['files_scanned']}
**Total Insights:** {summary['insights_found']}
**Unique Insights:** {summary['unique_insights']}
**Duplicates Removed:** {summary['duplicates_removed']}

---

## 📊 Summary by Category

"""

        # Category table
        for category, count in sorted(summary['category_counts'].items(), key=lambda x: x[1], reverse=True):
            md += f"- **{category.title()}:** {count} insights\n"

        md += "\n---\n\n## 💡 Insights\n\n"

        # Group by category
        by_category = defaultdict(list)
        for insight in self.insights:
            for cat in insight['categories']:
                by_category[cat].append(insight)

        for category in sorted(by_category.keys()):
            insights = by_category[category]
            md += f"\n### {category.title()} ({len(insights)} insights)\n\n"

            for i, insight in enumerate(insights, 1):
                md += f"#### Insight {i}: {insight['date']}\n"
                md += f"**Source:** {insight['file']}\n\n"
                md += f"{insight['text'][:500]}"
                if len(insight['text']) > 500:
                    md += "... [truncated]\n"
                md += "\n\n---\n\n"

        return md

    def output_summary(self):
        """Output brief summary"""
        summary = self.get_summary()

        output = f"""
╔══════════════════════════════════════════════════════════════════════════════╗
║                        INSIGHT EXTRACTION SUMMARY                            ║
╚══════════════════════════════════════════════════════════════════════════════╝

📁 Files Scanned:          {summary['files_scanned']}
"""

        if summary.get('files_skipped_old', 0) > 0:
            output += f"⏭️  Files Skipped (old):    {summary['files_skipped_old']}\n"

        output += f"""💡 Insights Found:         {summary['insights_found']}
✨ Unique Insights:        {summary['unique_insights']}
🔁 Duplicates Removed:     {summary['duplicates_removed']}
⚠️  Filtered (too short):  {summary['filtered_too_short']}
❌ Filtered (malformed):   {summary['filtered_malformed']}
🚫 Errors:                 {summary['errors']}

"""

        # Show timestamp info if using incremental mode
        if 'last_aggregation' in summary:
            output += f"🕐 Last Aggregation:       {summary['last_aggregation']}\n"
            output += f"📅 Processing Since:       {summary['cutoff_date']}\n\n"

        if summary['date_range']:
            output += f"📅 Insight Date Range:     {summary['date_range']['oldest']} to {summary['date_range']['newest']}\n"

        output += "\n" + "─" * 80 + "\n"
        output += "INSIGHTS BY CATEGORY\n"
        output += "─" * 80 + "\n\n"

        for category, count in sorted(summary['category_counts'].items(), key=lambda x: x[1], reverse=True):
            bar = '█' * min(count, 50)
            output += f"{category.ljust(15)} {bar} {count}\n"

        output += "\n" + "═" * 80 + "\n"
        output += f"Use --output markdown or --output json for detailed insights\n"

        if summary['unique_insights'] > 0:
            output += f"Use --update-timestamp to mark these insights as processed\n"

        output += "═" * 80 + "\n"

        return output


def main():
    parser = argparse.ArgumentParser(
        description='Extract insights from Claude Code log files'
    )
    parser.add_argument(
        '--path',
        default=None,
        help='Directory to search (default: ~/.claude/projects)'
    )
    parser.add_argument(
        '--recent-days',
        type=int,
        default=None,
        help='Only include insights from last N days'
    )
    parser.add_argument(
        '--category',
        default=None,
        help='Filter by category (parallel, architecture, security, etc.)'
    )
    parser.add_argument(
        '--output',
        choices=['json', 'markdown', 'summary'],
        default='summary',
        help='Output format (default: summary)'
    )
    parser.add_argument(
        '--min-length',
        type=int,
        default=50,
        help='Minimum insight length in characters (default: 50)'
    )
    parser.add_argument(
        '--since-last',
        action='store_true',
        help='Only process insights since last aggregation'
    )
    parser.add_argument(
        '--update-timestamp',
        action='store_true',
        help='Update last aggregation timestamp after processing'
    )
    parser.add_argument(
        '--force-all',
        action='store_true',
        help='Process all insights, ignoring last timestamp'
    )

    args = parser.parse_args()

    # Create extractor
    extractor = InsightExtractor(
        base_path=args.path,
        min_length=args.min_length,
        since_last=args.since_last,
        force_all=args.force_all
    )

    # Scan files
    if args.since_last and extractor.last_timestamp:
        last_date = datetime.fromtimestamp(extractor.last_timestamp).strftime('%Y-%m-%d %H:%M:%S')
        print(f"Scanning log files since last aggregation ({last_date})...")
    else:
        print(f"Scanning log files in {extractor.base_path}...")

    extractor.scan_files(recent_days=args.recent_days)

    # Remove duplicates
    extractor.remove_duplicates()

    # Filter by category if specified
    if args.category:
        extractor.insights = extractor.filter_by_category(args.category)

    # Output results
    if args.output == 'json':
        print(extractor.output_json())
    elif args.output == 'markdown':
        print(extractor.output_markdown())
    else:
        print(extractor.output_summary())

    # Update timestamp if requested
    if args.update_timestamp:
        if extractor.update_timestamp():
            print(f"\n✅ Timestamp updated - {len(extractor.insights)} insights marked as processed")
        else:
            print("\n⚠️  Warning: Could not update timestamp")


if __name__ == '__main__':
    main()
