import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import '../../http/search.dart';
import '../../utils/utils.dart';
import '../constants.dart';
import 'badge.dart';
import 'network_img_layer.dart';
import 'stat/danmu.dart';
import 'stat/view.dart';
import 'video_popup_menu.dart';

// 视频卡片 - 水平布局
class VideoCardH extends StatelessWidget {
  const VideoCardH({
    super.key,
    required this.videoItem,
    this.longPress,
    this.longPressEnd,
    this.source = 'normal',
    this.showOwner = true,
    this.showView = true,
    this.showDanmaku = true,
    this.showPubdate = false,
  });
  // ignore: prefer_typing_uninitialized_variables
  final videoItem;
  final Function()? longPress;
  final Function()? longPressEnd;
  final String source;
  final bool showOwner;
  final bool showView;
  final bool showDanmaku;
  final bool showPubdate;

  @override
  Widget build(BuildContext context) {
    final int aid = videoItem.aid;
    final String bvid = videoItem.bvid;
    final String heroTag = Utils.makeHeroTag(aid);
    return Semantics(
        label: Utils.videoItemSemantics(videoItem),
        excludeSemantics: true,
        child: GestureDetector(
          onLongPress: () {
            if (longPress != null) {
              longPress!();
            }
          },
          // onLongPressEnd: (details) {
          //   if (longPressEnd != null) {
          //     longPressEnd!();
          //   }
          // },
          child: InkWell(
            onTap: () async {
              try {
                final int cid = videoItem.cid ??
                    await SearchHttp.ab2c(aid: aid, bvid: bvid);
                Get.toNamed('/video?bvid=$bvid&cid=$cid',
                    arguments: {'videoItem': videoItem, 'heroTag': heroTag});
              } catch (err) {
                SmartDialog.showToast(err.toString());
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  StyleString.safeSpace, 5, StyleString.safeSpace, 5),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints boxConstraints) {
                  final double width = (boxConstraints.maxWidth -
                          StyleString.cardSpace *
                              6 /
                              MediaQuery.textScalerOf(context).scale(1.0)) /
                      2;
                  return Container(
                    constraints: const BoxConstraints(minHeight: 88),
                    height: width / StyleString.aspectRatio,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: StyleString.aspectRatio,
                          child: LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints boxConstraints) {
                              final double maxWidth = boxConstraints.maxWidth;
                              final double maxHeight = boxConstraints.maxHeight;
                              return Stack(
                                children: [
                                  Hero(
                                    tag: heroTag,
                                    child: NetworkImgLayer(
                                      src: videoItem.pic as String,
                                      width: maxWidth,
                                      height: maxHeight,
                                    ),
                                  ),
                                  PBadge(
                                    text: Utils.timeFormat(videoItem.duration!),
                                    right: 6.0,
                                    bottom: 6.0,
                                    type: 'gray',
                                  ),
                                  // if (videoItem.rcmdReason != null &&
                                  //     videoItem.rcmdReason.content != '')
                                  //   pBadge(videoItem.rcmdReason.content, context,
                                  //       6.0, 6.0, null, null),
                                ],
                              );
                            },
                          ),
                        ),
                        VideoContent(
                          videoItem: videoItem,
                          source: source,
                          showOwner: showOwner,
                          showView: showView,
                          showDanmaku: showDanmaku,
                          showPubdate: showPubdate,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ));
  }
}

class VideoContent extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final videoItem;
  final String source;
  final bool showOwner;
  final bool showView;
  final bool showDanmaku;
  final bool showPubdate;

  const VideoContent({
    super.key,
    required this.videoItem,
    this.source = 'normal',
    this.showOwner = true,
    this.showView = true,
    this.showDanmaku = true,
    this.showPubdate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 6, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (videoItem.title is String) ...[
              Text(
                videoItem.title as String,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  height: 1.4,
                  letterSpacing: 0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ] else ...[
              RichText(
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                text: TextSpan(
                  children: [
                    for (final i in videoItem.title) ...[
                      TextSpan(
                        text: i['text'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize:
                              Theme.of(context).textTheme.bodyMedium!.fontSize,
                          letterSpacing: 0.3,
                          color: i['type'] == 'em'
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
            const Spacer(),
            // if (videoItem.rcmdReason != null &&
            //     videoItem.rcmdReason.content != '')
            //   Container(
            //     padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(4),
            //       border: Border.all(
            //           color: Theme.of(context).colorScheme.surfaceTint),
            //     ),
            //     child: Text(
            //       videoItem.rcmdReason.content,
            //       style: TextStyle(
            //           fontSize: 9,
            //           color: Theme.of(context).colorScheme.surfaceTint),
            //     ),
            //   ),
            // const SizedBox(height: 4),
            if (showOwner || showPubdate)
              Expanded(
                flex: 0,
                child: Text(
                  "${showPubdate ? Utils.dateFormat(videoItem.pubdate!, formatType: 'day') + '  ' : ''}  ${showOwner ? videoItem.owner.name : ''}",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1,
                    color: Theme.of(context).colorScheme.outline,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
            Row(
              children: [
                if (showView) ...[
                  StatView(
                    theme: 'gray',
                    view: videoItem.stat.view as int,
                  ),
                  const SizedBox(width: 8),
                ],
                if (showDanmaku)
                  StatDanMu(
                    theme: 'gray',
                    danmu: videoItem.stat.danmu as int,
                  ),
                const Spacer(),
                if (source == 'normal')
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: VideoPopupMenu(
                      size: 32,
                      iconSize: 18,
                      videoItem: videoItem,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
