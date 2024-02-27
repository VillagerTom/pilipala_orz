import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/models/video/play/quality.dart';
import 'package:PiliPalaX/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPalaX/plugin/pl_player/index.dart';
import 'package:PiliPalaX/services/service_locator.dart';
import 'package:PiliPalaX/utils/storage.dart';

import 'widgets/switch_item.dart';

class PlaySetting extends StatefulWidget {
  const PlaySetting({super.key});

  @override
  State<PlaySetting> createState() => _PlaySettingState();
}

class _PlaySettingState extends State<PlaySetting> {
  Box setting = GStrorage.setting;
  late dynamic defaultVideoQa;
  late dynamic defaultAudioQa;
  late dynamic defaultDecode;
  late int defaultFullScreenMode;
  late int defaultBtmProgressBehavior;

  @override
  void initState() {
    super.initState();
    defaultVideoQa = setting.get(SettingBoxKey.defaultVideoQa,
        defaultValue: VideoQuality.values.last.code);
    defaultAudioQa = setting.get(SettingBoxKey.defaultAudioQa,
        defaultValue: AudioQuality.values.last.code);
    defaultDecode = setting.get(SettingBoxKey.defaultDecode,
        defaultValue: VideoDecodeFormats.values.last.code);
    defaultFullScreenMode = setting.get(SettingBoxKey.fullScreenMode,
        defaultValue: FullScreenMode.values.first.code);
    defaultBtmProgressBehavior = setting.get(SettingBoxKey.btmProgressBehavior,
        defaultValue: BtmProgresBehavior.values.first.code);
  }

  @override
  void dispose() {
    super.dispose();

    // 重新验证媒体通知后台播放设置
    videoPlayerServiceHandler.revalidateSetting();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;
    TextStyle subTitleStyle = Theme.of(context)
        .textTheme
        .labelMedium!
        .copyWith(color: Theme.of(context).colorScheme.outline);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          '播放设置',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            dense: false,
            onTap: () => Get.toNamed('/playSpeedSet'),
            title: Text('倍速设置', style: titleStyle),
            subtitle: Text('设置视频播放速度', style: subTitleStyle),
          ),
          const SetSwitchItem(
            title: '开启1080P',
            subTitle: '免登录查看1080P视频',
            setKey: SettingBoxKey.p1080,
            defaultVal: true,
          ),
          const SetSwitchItem(
            title: 'CDN优化',
            subTitle: '使用优质CDN线路',
            setKey: SettingBoxKey.enableCDN,
            defaultVal: true,
          ),
          const SetSwitchItem(
            title: '自动播放',
            subTitle: '进入详情页自动播放',
            setKey: SettingBoxKey.autoPlayEnable,
            defaultVal: true,
          ),
          const SetSwitchItem(
            title: '后台播放',
            subTitle: '进入后台时继续播放',
            setKey: SettingBoxKey.enableBackgroundPlay,
            defaultVal: false,
          ),
          if (Platform.isAndroid)
            const SetSwitchItem(
              title: '自动PiP播放',
              subTitle: '进入后台时画中画播放',
              setKey: SettingBoxKey.autoPiP,
              defaultVal: false,
            ),
          const SetSwitchItem(
            title: '自动全屏',
            subTitle: '视频开始播放时进入全屏',
            setKey: SettingBoxKey.enableAutoEnter,
            defaultVal: false,
          ),
          const SetSwitchItem(
            title: '自动退出',
            subTitle: '视频结束播放时退出全屏',
            setKey: SettingBoxKey.enableAutoExit,
            defaultVal: false,
          ),
          SetSwitchItem(
            title: '横屏适配（测试）',
            subTitle: '开启该项在播放页启用横屏布局与逻辑',
            setKey: SettingBoxKey.horizontalScreen,
            defaultVal: false,
            callFn: (value) {
              if (value) {
                autoScreen();
                SmartDialog.showToast('已开启横屏适配');
              } else {
                AutoOrientation.portraitUpMode();
                SmartDialog.showToast('已关闭横屏适配');
              }
            }
          ),
          const SetSwitchItem(
            title: '开启硬解',
            subTitle: '以较低功耗播放视频',
            setKey: SettingBoxKey.enableHA,
            defaultVal: true,
          ),
          const SetSwitchItem(
            title: '观看人数',
            subTitle: '展示同时在看人数',
            setKey: SettingBoxKey.enableOnlineTotal,
            defaultVal: false,
          ),
          const SetSwitchItem(
            title: '亮度记忆',
            subTitle: '返回时自动调整视频亮度',
            setKey: SettingBoxKey.enableAutoBrightness,
            defaultVal: false,
          ),
          const SetSwitchItem(
            title: '双击快退/快进',
            subTitle: '左侧双击快退，右侧双击快进',
            setKey: SettingBoxKey.enableQuickDouble,
            defaultVal: true,
          ),
          const SetSwitchItem(
            title: '全屏手势反向',
            subTitle: '默认播放器中部向上滑动进入全屏，向下退出\n开启后向下全屏，向上退出',
            setKey: SettingBoxKey.fullScreenGestureReverse,
            defaultVal: false,
          ),
          const SetSwitchItem(
            title: '弹幕开关',
            subTitle: '展示弹幕',
            setKey: SettingBoxKey.enableShowDanmaku,
            defaultVal: false,
          ),
          ListTile(
            dense: false,
            title: Text('默认画质', style: titleStyle),
            subtitle: Text(
              '当前画质${VideoQualityCode.fromCode(defaultVideoQa)!.description!}',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: '默认画质',
                      value: defaultVideoQa,
                      values: VideoQuality.values.reversed.map((e) {
                        return {'title': e.description, 'value': e.code};
                      }).toList());
                },
              );
              if (result != null) {
                defaultVideoQa = result;
                setting.put(SettingBoxKey.defaultVideoQa, result);
                setState(() {});
              }
            },
          ),
          ListTile(
            dense: false,
            title: Text('默认音质', style: titleStyle),
            subtitle: Text(
              '当前音质${AudioQualityCode.fromCode(defaultAudioQa)!.description!}',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: '默认音质',
                      value: defaultAudioQa,
                      values: AudioQuality.values.reversed.map((e) {
                        return {'title': e.description, 'value': e.code};
                      }).toList());
                },
              );
              if (result != null) {
                defaultAudioQa = result;
                setting.put(SettingBoxKey.defaultAudioQa, result);
                setState(() {});
              }
            },
          ),
          ListTile(
            dense: false,
            title: Text('默认解码格式', style: titleStyle),
            subtitle: Text(
              '当前解码格式${VideoDecodeFormatsCode.fromCode(defaultDecode)!.description!}',
              style: subTitleStyle,
            ),
            onTap: () async {
              String? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<String>(
                      title: '默认解码格式',
                      value: defaultDecode,
                      values: VideoDecodeFormats.values.map((e) {
                        return {'title': e.description, 'value': e.code};
                      }).toList());
                },
              );
              if (result != null) {
                defaultDecode = result;
                setting.put(SettingBoxKey.defaultDecode, result);
                setState(() {});
              }
            },
          ),
          ListTile(
            dense: false,
            title: Text('默认全屏方式', style: titleStyle),
            subtitle: Text(
              '当前全屏方式：${FullScreenModeCode.fromCode(defaultFullScreenMode)!.description}',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: '默认全屏方式',
                      value: defaultFullScreenMode,
                      values: FullScreenMode.values.map((e) {
                        return {'title': e.description, 'value': e.code};
                      }).toList());
                },
              );
              if (result != null) {
                defaultFullScreenMode = result;
                setting.put(SettingBoxKey.fullScreenMode, result);
                setState(() {});
              }
            },
          ),
          ListTile(
            dense: false,
            title: Text('底部进度条展示', style: titleStyle),
            subtitle: Text(
              '当前展示方式：${BtmProgresBehaviorCode.fromCode(defaultBtmProgressBehavior)!.description}',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: '底部进度条展示',
                      value: defaultBtmProgressBehavior,
                      values: BtmProgresBehavior.values.map((e) {
                        return {'title': e.description, 'value': e.code};
                      }).toList());
                },
              );
              if (result != null) {
                defaultBtmProgressBehavior = result;
                setting.put(SettingBoxKey.btmProgressBehavior, result);
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }
}
