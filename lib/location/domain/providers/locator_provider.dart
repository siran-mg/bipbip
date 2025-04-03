import 'package:ndao/location/domain/entities/position_entity.dart';

abstract class LocatorProvider {
  Future<PositionEntity> getCurrentPosition();
}
