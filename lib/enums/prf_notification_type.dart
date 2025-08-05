enum PRFNotificationType {
  defaultPrompt;

  static PRFNotificationType fromType(String type) {
    switch (type) {
      default:
        return PRFNotificationType.defaultPrompt;
    }
  }
}
