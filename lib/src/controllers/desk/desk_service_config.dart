class DeskServiceConfig {
  final String serviceUuid;
  final List<String> normalStateUuids;
  final List<String> reportStateUuids;
  final List<String> deviceInfoUuids;

  const DeskServiceConfig({
    required this.serviceUuid,
    required this.normalStateUuids,
    required this.reportStateUuids,
    required this.deviceInfoUuids,
  });

  static const List<DeskServiceConfig> configurations = [
    DeskServiceConfig(
      serviceUuid: 'ff12',
      normalStateUuids: ['ff01'],
      reportStateUuids: ['ff02'],
      deviceInfoUuids: ['ff06'],
    ),
    DeskServiceConfig(
      serviceUuid: 'fe60',
      normalStateUuids: ['fe61'],
      reportStateUuids: ['fe62'],
      deviceInfoUuids: ['fe63'],
    ),
  ];

  static DeskServiceConfig? getConfigForService(String serviceUuid) {
    return configurations.where((config) {
      return config.serviceUuid == serviceUuid;
    }).firstOrNull;
  }

  /// Convierte un UUID de 16/32 bits al formato completo de 128 bits.
  /// - 16 bits: "FE60" -> "0000fe60-0000-1000-8000-00805f9b34fb"
  /// - 32 bits: "feedbeef" -> "feedbeef-0000-1000-8000-00805f9b34fb"
  /// - 128 bits: se asume que ya está en formato completo y solo se normaliza a minúsculas.
  /// Si no se reconoce el formato, retorna la cadena tal cual.
  static String standardizeUuid(String uuid) {
    String lower = uuid.toLowerCase().replaceAll('0x', '').trim();

    // Si ya está en formato 128 bits (36 caracteres con guiones), se devuelve en minúsculas
    if (lower.length == 36 && lower.contains('-')) {
      return lower;
    }

    // Si es de 4 caracteres (16 bits), convertir a 128 bits
    if (lower.length == 4) {
      return '0000$lower-0000-1000-8000-00805f9b34fb';
    }

    // Si es de 8 caracteres (32 bits), convertir a 128 bits
    if (lower.length == 8) {
      return '$lower-0000-1000-8000-00805f9b34fb';
    }

    // Si no coincide con ninguno de los casos anteriores, lo retornamos sin cambios
    return lower;
  }
}
