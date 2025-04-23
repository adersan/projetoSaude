
String gerarMensagemMotivacional(int totalRealizado, int dias) {
  final int atividadesEsperadas = dias * 3;
  final double percentual = (atividadesEsperadas == 0)
      ? 0
      : (totalRealizado / atividadesEsperadas * 100);

  if (percentual >= 90) {
    return "Incrível! Você cumpriu ${percentual.toStringAsFixed(1)}% da sua rotina. Continue assim!";
  } else if (percentual >= 70) {
    return "Muito bem! ${percentual.toStringAsFixed(1)}% de adesão. Está quase lá!";
  } else if (percentual >= 50) {
    return "Você está no caminho! ${percentual.toStringAsFixed(1)}%. Tente melhorar amanhã!";
  } else {
    return "Vamos focar! Só ${percentual.toStringAsFixed(1)}% cumprido. Recomece com confiança!";
  }
}
