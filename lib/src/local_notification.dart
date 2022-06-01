/// @property {number} [id] - 通知 id, 可用于取消通知
/// @property {string} [title] - 通知标题
/// @property {string} [content] - 通知内容
/// @property {object} [extras] - extra 字段
/// @property {number} [fireTime] - 通知触发时间（秒）
class LocalNotification {
  late int buildId = 0;
  late int id;
  late String title;
  late String content;
  Map<String, String>? extras;
  DateTime? fireTime;

  LocalNotification(
      {required this.id,
      required this.title,
      required this.content,
      this.extras});

  // LocalNotification.fromMap(Map<String, dynamic> map) {
  //   id = map["id"];
  //   title = map["title"];
  //   content = map["content"];
  //   extras = map["extras"];
  // }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> param = {
      'buildId': 0,
      'id': id,
      'title': title,
      'content': content
    };
    if (fireTime != null) param['fireTime'] = fireTime;
    if (extras != null) param['extras'] = extras;
    return param;
  }
}
