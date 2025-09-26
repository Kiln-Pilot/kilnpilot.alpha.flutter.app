import 'package:json_annotation/json_annotation.dart';

part 'cement_query_request.g.dart';

@JsonSerializable()
class CementQueryRequest {
  final String query;
  final String? sessionId;
  final String? userId;

  CementQueryRequest({required this.query, this.sessionId, this.userId});

  factory CementQueryRequest.fromJson(Map<String, dynamic> json) => _$CementQueryRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CementQueryRequestToJson(this);
}

