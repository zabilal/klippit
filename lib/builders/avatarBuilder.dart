import 'package:klippit/navigationUtils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../assets.dart';

class AvatarBuilder extends StatelessWidget {
  final String imageUrl;
  final int onlineStatus;
  final double avatarSize;
  final double holderSize;
  final bool canClick;
  //https://bit.ly/2HYMYBp
  const AvatarBuilder(
      {Key key,
      this.imageUrl = "",
      this.onlineStatus = NONE,
      this.avatarSize = 95.0,
      this.holderSize = 25.0,
      this.canClick = true})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return _buildAvatar(context);
  }

  _buildAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (imageUrl.isEmpty || !canClick) {
          return;
        }
//        popUpWidget(
//            context,
//            ImagePreview(
//              imageURL: imageUrl,
//            ));
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            height: avatarSize,
            width: avatarSize,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: retrieveStatusColor(onlineStatus), width: 2.5)),
          ),
          Container(
            height: avatarSize - 5,
            width: avatarSize - 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(avatarSize - 5 / 2),
              child:
                  /*imageUrl == null || imageUrl.isEmpty
                  ? Container(
                      color: APP_COLOR.withOpacity(0.7),
                      height: avatarSize,
                      width: avatarSize,
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.person,
                        color: Colors.white.withOpacity(.9),
                        size: avatarSize / 3,
                      ),
                    )
                  :*/
                  CachedNetworkImage(
                      imageUrl: imageUrl,
                      //imageUrl: userModel.image == null ? "" : userModel?.image,
                      fit: BoxFit.cover,
                      height: avatarSize,
                      width: avatarSize,
                      //color: APP_COLOR,
                      placeholder: (_, s) {
                        return Container(
                          color: APP_COLOR.withOpacity(0.4),
                          height: avatarSize,
                          width: avatarSize,
                          /*padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.person,
                            color: Colors.white.withOpacity(.4),
                            size: avatarSize / 3,
                          ),*/
                        );
                      },
                      errorWidget: (_, s, o) {
                        return Container(
                          //height: 250,
                          color: APP_COLOR,
                          child: Center(
                              child: Icon(
                            Icons.person,
                            color: Colors.white.withOpacity(.9),
                            size: avatarSize / 3,
                          )),
                        );
                      }),
            ),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                shape: BoxShape.circle,
                color: APP_COLOR.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }
}

retrieveStatusColor(int onlineStatus) {
  if (onlineStatus == ONLINE) {
    return Colors.green[800];
  }
//  if (onlineStatus == OnlineStatus.AWAY) {
//    return Colors.orange[800];
//  }

  return Colors.transparent;
}
