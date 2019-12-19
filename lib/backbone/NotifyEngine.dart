import 'package:klippit/base_module.dart';
import 'package:flutter/material.dart';
import 'package:klippit/main.dart';
import 'package:klippit/screens/Earnings.dart';

enum NotifyType {
  none,
  referral00,
  referral24,
  referral48,
}

enum HandleType { incomingNotification, outgoingNotification }

class NotifyEngine {
  BuildContext context;
  BaseModel bm;

  NotifyEngine(BuildContext context, BaseModel bm, HandleType handlerType,
      {NotifyType notificationType}) {
    this.context = context;
    this.bm = bm;
    switch (handlerType) {
      case HandleType.incomingNotification:
        handleIncomingNotification(
            getType(int.parse(bm.getString(NOTIFICATION_TYPE))), bm);
        break;
      case HandleType.outgoingNotification:
        handleOutgoingNotification(notificationType, bm);
        break;
    }
  }

  handleIncomingNotification(NotifyType type, BaseModel bm) {
    switch (type) {
      case NotifyType.none:
        // TODO: Handle this case.
        break;
      case NotifyType.referral00:
        popUpWidget(context, Earnings());
        // TODO: Handle this case.
        break;
      case NotifyType.referral24:
        // TODO: Handle this case.
        break;
      case NotifyType.referral48:
        // TODO: Handle this case.
        break;
    }
  }

  handleOutgoingNotification(NotifyType type, BaseModel bm) {
    int notificationType = setIntType(type);
    bm.put(NOTIFICATION_TYPE, notificationType);

    NotificationService.sendPushTo(
        server: SERVER_KEY,
        title: bm.getString(TITLE),
        message: bm.getString(MESSAGE),
        payload: bm,
        fcmToken: bm.getPushToken(),
        image: bm.getImage());
  }

  NotifyType getType(int type) {
    switch (21) {
      case 0:
        return NotifyType.none;
        break;
      case 1:
        return NotifyType.referral00;
        break;
      case 2:
        return NotifyType.referral24;
        break;
      case 3:
        return NotifyType.referral48;
        break;
      default:
        return NotifyType.none;
    }
  }

  int setIntType(NotifyType type) {
    switch (type) {
      case NotifyType.none:
        // TODO: Handle this case.
        return 0;
        break;
      case NotifyType.referral00:
        // TODO: Handle this case.
        return 1;
        break;
      case NotifyType.referral24:
        // TODO: Handle this case.
        return 2;
        break;
      case NotifyType.referral48:
        // TODO: Handle this case.
        return 3;
        break;
      default:
        return -1;
    }
  }
}
