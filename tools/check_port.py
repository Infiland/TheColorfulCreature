#!/usr/bin/env python3
"""Static release configuration checks. Runtime self-check is in scr_port_selfcheck."""
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def yy(path):
    return json.loads(re.sub(r',\s*([}\]])', r'\1', (ROOT / path).read_text()))


def main():
    project = yy('The Colorful Creature.yyp')
    resources = [r['id'] for r in project['resources']]
    names = [r['name'] for r in resources]
    assert len(names) == len(set(names)), 'Duplicate project resources'
    assert all((ROOT / r['path']).is_file() for r in resources), 'Missing resource'
    assert project['MetaData']['IDEVersion'] == '2026.0.0.16'
    steam = yy('extensions/Steamworks/Steamworks.yy')
    assert steam['ConfigValues']['Apple']['copyToTargets'] == '0'
    assert steam['ConfigValues']['Mobile']['copyToTargets'] == '0'
    assert steam['extensionVersion'] == '2.1.6'
    for extension, version in [('GMAdMob','2.0.2'),('GMGameCenter','2.0.2'),('GMGooglePlayServices','3.0.2')]:
        assert yy(f'extensions/{extension}/{extension}.yy')['extensionVersion'] == version
    android_release = next(c for c in project['configs']['children'] if c['name'] == 'Mobile')
    android_release = next(c for c in android_release['children'] if c['name'] == 'Android')
    assert any(c['name'] == 'AndroidRelease' for c in android_release['children'])
    assert any(c['name'] == 'SteamAndroid' for c in android_release['children'])
    for extension in ['GMAdMob', 'GMGooglePlayServices', 'TCCPrivacy']:
        assert yy(f'extensions/{extension}/{extension}.yy')['ConfigValues']['SteamAndroid']['copyToTargets'] == '0'
    assert yy('extensions/TCCAndroidSafeArea/TCCAndroidSafeArea.yy')['ConfigValues']['SteamAndroid']['copyToTargets'] == '8'
    admob = yy('options/extensions/GMAdMob.json')['configurables']
    production_ad_ids = {
        'fb7dfcc4-8a4f-480d-80a1-4353f93c9a2d': 'ca-app-pub-7108130195717311~2960588105',
        'b9284c2f-2652-43e0-8857-83c4b381d452': 'ca-app-pub-7108130195717311/1705849205',
        '4253cbf6-25ef-47ab-a865-b33f15272ba6': 'ca-app-pub-7108130195717311/1322705824',
        'b19aeb11-226a-4d31-a7b2-1960aa422c5d': 'ca-app-pub-7108130195717311/8981703993',
    }
    assert all(admob[guid] == {'AndroidRelease': {'value': ad_id}}
               for guid, ad_id in production_ad_ids.items())
    assert 'AdMob' not in names and 'GooglePlayServices' not in names
    ios = yy('options/ios/options_ios.yy')
    assert ios['option_ios_min_version'] == '15.0'
    assert ios['option_ios_orientation_landscape'] and ios['option_ios_orientation_landscape_flipped']
    assert not ios['option_ios_orientation_portrait'] and not ios['option_ios_orientation_portrait_flipped']
    assert ios['option_ios_launchscreen_image'] == '${options_dir}/shared/launch.png'
    assert ios['option_ios_launchscreen_image_landscape'] == '${options_dir}/shared/launch.png'
    mac = yy('options/mac/options_mac.yy')
    assert mac['option_mac_icon_png'] == '${options_dir}/shared/icon.png'
    assert mac['option_mac_splash_png'] == '${options_dir}/shared/launch.png'
    android = yy('options/android/options_android.yy')
    assert android['option_android_target_sdk'] == '36'
    assert android['option_android_minimum_sdk'] == '23'
    assert android['option_android_splash_time'] == 0
    assert android['option_android_gamepad_support'] is True
    steam_android = android['ConfigValues']['SteamAndroid']
    assert steam_android['option_android_package_product'] == 'tccsteam'
    assert steam_android['option_android_google_dynamic_asset_delivery'] == 'False'
    assert steam_android['option_android_google_services_app_id'] == ''
    assert steam_android['option_android_permission_internet'] == 'True'
    for path in (ROOT / 'options/ios/icons').rglob('*.png'):
        # PNG IHDR color type 2 is RGB without an alpha channel, required by Apple.
        assert path.read_bytes()[25] == 2, f'Apple icon must be opaque: {path}'
    assert '.'.join(android['option_android_package_' + k] for k in ['domain','company','product']) == 'com.infiland.tcc'
    catalog = json.loads((ROOT / 'docs/release/apple-achievements.json').read_text())
    assert len(catalog) <= 100
    assert len({c['apple_id'] for c in catalog}) == len(catalog)
    assert all(c['game_id'] not in ['OOPS','MAKE_LEVEL','PUBLISHER','RACES_MULTI','WORKSHOP_MASTER'] for c in catalog)
    ads = (ROOT / 'objects/Obj_AdMob/Create_0.gml').read_text()
    assert 'AdMobConsentDebugGeography.Disabled' in ads
    for p in list((ROOT/'scripts').rglob('*.gml')) + list((ROOT/'objects').rglob('*.gml')) + list((ROOT/'rooms').rglob('*.gml')):
        if p.parent.name.endswith('_API'):
            continue
        source = p.read_text()
        assert not re.search(r'\b(?:AdMob_|GooglePlayServices_)\w+\s*\(', source), f'Obsolete SDK call: {p}'
        if p.parent.name not in ['scr_steam_safe', 'scr_platform_services']:
            assert not re.search(r'\bsteam_(?:inventory_|ugc_|get_achievement|set_achievement|upload_score|initialised)\w*\s*\(', source), f'Unguarded Steam call: {p}'
    print(f'Configuration checks passed; {len(catalog)} Apple achievement candidates. Device/store checks remain separate.')


if __name__ == '__main__':
    main()
