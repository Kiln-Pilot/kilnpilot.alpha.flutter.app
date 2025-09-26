import 'package:json_annotation/json_annotation.dart';

part 'cement_agent_config.g.dart';

@JsonSerializable()
class CementAgentConfig {
  final String modelName;
  final int thinkingBudget;
  final bool includeThoughts;
  final double temperature;

  CementAgentConfig({
    required this.modelName,
    required this.thinkingBudget,
    required this.includeThoughts,
    required this.temperature,
  });

  factory CementAgentConfig.fromJson(Map<String, dynamic> json) => _$CementAgentConfigFromJson(json);
  Map<String, dynamic> toJson() => _$CementAgentConfigToJson(this);
}
