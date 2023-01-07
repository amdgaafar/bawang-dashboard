class Bawang {
  Channel? channel;
  List<Feeds>? feeds;

  Bawang({this.channel, this.feeds});

  Bawang.fromJson(Map<String, dynamic> json) {
    channel =
        json['channel'] != null ? Channel.fromJson(json['channel']) : null;
    if (json['feeds'] != null) {
      feeds = <Feeds>[];
      json['feeds'].forEach((v) {
        feeds!.add(Feeds.fromJson(v));
      });
    }
  }
}

class Channel {
  int? id;
  String? name;
  String? latitude;
  String? longitude;
  String? field1;
  String? field2;
  String? field3;
  String? field4;
  String? field5;
  String? createdAt;
  String? updatedAt;
  int? lastEntryId;

  Channel(
      {this.id,
      this.name,
      this.latitude,
      this.longitude,
      this.field1,
      this.field2,
      this.field3,
      this.field4,
      this.field5,
      this.createdAt,
      this.updatedAt,
      this.lastEntryId});

  Channel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    field1 = json['field1'];
    field2 = json['field2'];
    field3 = json['field3'];
    field4 = json['field4'];
    field5 = json['field5'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    lastEntryId = json['last_entry_id'];
  }
}

class Feeds {
  String? createdAt;
  int? entryId;
  String? field1;
  String? field2;
  String? field3;
  String? field4;
  String? field5;

  Feeds(
      {this.createdAt,
      this.entryId,
      this.field1,
      this.field2,
      this.field3,
      this.field4,
      this.field5});

  Feeds.fromJson(Map<String, dynamic> json) {
    createdAt = json['created_at'];
    entryId = json['entry_id'];
    field1 = json['field1'];
    field2 = json['field2'];
    field3 = json['field3'];
    field4 = json['field4'];
    field5 = json['field5'];
  }
}
