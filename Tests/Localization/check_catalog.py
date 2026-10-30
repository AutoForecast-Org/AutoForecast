import json
import re
from pathlib import Path

catalog = json.loads(Path('Localizable.xcstrings').read_text())
assert catalog['sourceLanguage'] == 'it'
placeholder = re.compile(r'%(?:(\d+)\$)?(@|lld|ld|d|lf|f)')

def signature(value):
    result = []
    for index, match in enumerate(placeholder.finditer(value.replace('%%', '')), 1):
        result.append((int(match.group(1) or index), match.group(2)))
    return sorted(result)

def leaves(value):
    if isinstance(value, dict):
        if 'stringUnit' in value:
            yield value['stringUnit']
        for key, item in value.items():
            if key != 'stringUnit':
                yield from leaves(item)

for key, entry in catalog['strings'].items():
    for language in ('it', 'en'):
        localization = entry.get('localizations', {}).get(language)
        assert localization, (key, language, 'missing translation')
        units = list(leaves(localization))
        assert units, (key, language, 'empty translation')
        for unit in units:
            assert unit['state'] == 'translated', (key, language, unit['state'])
            assert unit['value'].strip(), (key, language, 'empty value')
            assert signature(key) == signature(unit['value']), (key, language, 'placeholder mismatch', unit['value'])
assert 'Language Notice' not in catalog['strings']
print(f"PASS: {len(catalog['strings'])} entries, Italian and English 100% translated, placeholders preserved")
